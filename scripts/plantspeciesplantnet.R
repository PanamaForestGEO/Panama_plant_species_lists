library("readxl")
library("writexl")
library("dplyr")
library(tidyr)
library("TNRS")
library("stringi")
library("stringr")


# installing packages for name checking 
#install.packages("rWCVPdata", repos=c("https://matildabrown.github.io/drat", "https://cloud.r-project.org"))
#install.packages("rWCVP") # this doesnt seem to work 
#install.packages("remotes")
#install.packages("units")
#install.packages('sf')

#library(remotes)
#Sys.setenv(PATH = paste("/usr/bin:/usr/lib", Sys.getenv("PATH"), sep = ":"))
#install_github("r-spatial/sf")


#remotes::install_github("matildabrown/rWCVP")

library(rWCVP)
library(rWCVPdata)
citation("rWCVPdata") # so according to this, this is using version 13.

# Load the names and distributions
wcvp_names <- rWCVPdata::wcvp_names 
wcvp_names

rm(list=ls())

setwd("/home/paula/Documentos/PROYECTOS/STRI/Panama_plant_species_lists")
getwd()

lastwoody_path <-  "splists_out/PanamaSpCombined_2026-02-05_MOD.xlsx"

bci_angiosperms_path <- "splists_raw/Panamabiota/Downloaded_2026-02-04/Plants of Barro Colorado - eudicots, magnoliids, and basal angiosperms_1770221196.csv"
bci_ferns_path <- "splists_raw/Panamabiota/Downloaded_2026-02-04/Plants of Barro Colorado - ferns and allies_1770221067.csv"
bci_monocots_path <- "splists_raw/Panamabiota/Downloaded_2026-02-04/Plants of Barro Colorado - monocots_1770221178.csv"

panamabiotatrees <- "splists_raw/Panamabiota/Downloaded_2026-02-04/Complete Tree Species of Panama_1770221306.csv"
panamabiotalianas <- "splists_raw/Panamabiota/Downloaded_2026-02-04/CTFS Liana Atlas of Panama_1770221260.csv"


lastwoody <- read_excel(lastwoody_path)
nrow(lastwoody)

bciangio <- read.csv(bci_angiosperms_path, sep = ",")
bciferns <- read.csv(bci_ferns_path, sep = ",")
bcimonocots <- read.csv(bci_monocots_path, sep = ",")


# This returns TRUE only if all three are exactly the same
all(colnames(bciangio) == colnames(bcimonocots)) && all(colnames(bcimonocots) == colnames(bciferns))

# merge all bci in just one list and keep the source.
bciangio$source <- "angio"
bciferns$source <- "ferns"
bcimonocots$source <- "monocots"

bcibiota <- do.call(rbind, list(bciangio, bciferns, bcimonocots))

nrow(bcibiota)

bcibiota %>% count(source, name = "species_count")

# Lets check consistency:

# Duplicated names 
# check for duplicate and address if needed

bindups <- bcibiota %>% group_by(ScientificName) %>% arrange(ScientificName) %>% filter(n()>1) %>% ungroup()
nrow(bindups)

######################### PANMA BIOTA WCVP names #########################################################


# Merging accepted names 
matchaccepted_names<- function(matcheswcvp){
  matcheswcvp %>% 
    left_join(wcvp_names %>% select(plant_name_id, genus, species, taxon_rank, family, primary_author, infraspecific_rank, infraspecies, lifeform_description, taxon_status),
              by=c("wcvp_accepted_id"="plant_name_id")) %>% 
    mutate(
      Accepted_name = case_when(
        is.na(species) | species == "" ~ genus,
        !is.na(infraspecies) & infraspecies != "" ~ paste(genus, species, infraspecific_rank, infraspecies),
        TRUE ~ paste(genus, species))
    ) %>%
    rename(
      Accepted_family= family,
      Accepted_name_rank = taxon_rank,
      Accepted_name_author = primary_author,
      Accepted_name_status = taxon_status,
      Accepted_name_genus = genus, 
      Accepted_name_species = species, 
      Accepted_name_infraspecific_rank = infraspecific_rank, 
      Accepted_name_infraspecies = infraspecies
    )
  
}


# Check for species names changes
matchresult <-wcvp_match_names(bcibiota, wcvp_names, name_col="ScientificName")
nrow(matchresult)
nrow(bcibiota)

# All the species are still on the table
all(unique(matchresult$ScientificName) %in% unique(bcibiota$ScientificName))

# There can be multiple matches for one species, but only one is considered accepted
#sanity check of that
matchresult %>%
  group_by(ScientificName) %>%
  summarise(
    n_rows = n(),
    n_accepted = sum(wcvp_status == "Accepted", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_accepted > 1)

# If they have two accepted names its probably because they were registered twice. The two records have different ids
manyaccepted <- matchresult %>%
  group_by(ScientificName) %>%
  summarise(
    n_rows = n(),
    n_accepted = sum(wcvp_status == "Accepted", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_accepted > 1)

matchresult %>%
  filter(ScientificName %in% manyaccepted$ScientificName) %>%
  select(ScientificName, wcvp_name,wcvp_status, wcvp_accepted_id, wcvp_id)
  
# They  have two accepted names! I will stay with the original.
inc = matchresult$ScientificName %in% manyaccepted$ScientificName
if (any(inc, na.rm = TRUE)) {
  matchresult$wcvp_accepted_id[inc] <- matchresult$wcvp_id[inc]
}

# rules to keep 1 name per species:
# if there is only one record with the current name keep that.
# if there are more than one keep the one with wcvp_status = "Accepted"
matchresult_clean <- matchresult %>%
  mutate(
    status_priority = case_when(
      wcvp_status == "Accepted"     ~ 1,
      wcvp_status == "Synonym"      ~ 2,
      wcvp_status == "Illegitimate" ~ 3,
      wcvp_status == "Unplaced"     ~ 4,
      TRUE                          ~ 5
    )
  ) %>%
  group_by(ScientificName) %>%
  slice_min(status_priority, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(-status_priority)


nrow(matchresult)
# Now this should be TRUE.
nrow(matchresult_clean) == nrow(bcibiota) 
# All the species are still on the table
all(unique(matchresult_clean$ScientificName) %in% unique(bcibiota$ScientificName))

# sanity check one species per row
matchresult_clean %>%
  group_by(ScientificName) %>%
  summarise(
    n_rows = n(),
    .groups = "drop"
  ) %>%
  filter(n_rows > 1)


matchresult_clean <- matchaccepted_names(matchresult_clean)

# Now left join 
bcibiotawcvpplus <-   bcibiota %>%
  left_join(matchresult_clean %>% 
            select(ScientificName, wcvp_name, wcvp_authors,wcvp_rank, wcvp_status, 
                   Accepted_name, Accepted_family, Accepted_name_rank, Accepted_name_author, Accepted_name_status,
                   Accepted_name_genus,
                   Accepted_name_species, 
                   Accepted_name_infraspecific_rank, 
                   Accepted_name_infraspecies,
                   lifeform_description, match_similarity, match_edit_distance),
            by="ScientificName") %>%
  rename(
    Name_matched = wcvp_name,
    Name_matched_rank = wcvp_rank

  )
nrow(bcibiotawcvpplus)

# some species have accepted status but dont have accepted name for mysterious reasons...
bcibiotawcvpplus %>% filter(is.na(Accepted_name)) %>% select(ScientificName, Name_matched, wcvp_status)

# Scientific name is current name
bcibiotawcvpplus <- bcibiotawcvpplus %>% rename(Current_name = ScientificName,
                            Current_name_author = ScientificNameAuthorship,
                            Current_family = Family
                            )

# in that case leave the Name-matched as the accepted_name 
inc <- bcibiotawcvpplus$Accepted_name=="" | is.na(bcibiotawcvpplus$Accepted_name)
if (any(inc, na.rm = TRUE)) {
  table(inc)
  
  bcibiotawcvpplus$Accepted_name[inc] <- bcibiotawcvpplus$Name_matched[inc]
  bcibiotawcvpplus$Accepted_name_rank[inc] <- bcibiotawcvpplus$Name_matched_rank[inc]
  bcibiotawcvpplus$Accepted_name_author[inc] <- ifelse(is.na(bcibiotawcvpplus$Accepted_name_author[inc]) & bcibiotawcvpplus$Accepted_name[inc] == bcibiotawcvpplus$Current_name[inc],
                                                       bcibiotawcvpplus$Current_name_author[inc],
                                                       bcibiotawcvpplus$Accepted_name_author[inc]
  )
}

# lets see the taxonomic status of the matches
bcibiotawcvpplus %>% 
  count(wcvp_status, name = "n")


# Adding subspecies, species and genus of current name:
bcibiotawcvpplus <- bcibiotawcvpplus %>%
  mutate(
    name_clean = str_squish(Current_name)
  ) %>%
  separate(
    name_clean,
    into = c("Current_genus", "Current_species", "Current_infraspecific_rank", "Current_infraspecies"),
    sep = " ",
    fill = "right",
    extra = "merge"
  ) %>%
  mutate(
    # Normalizar rangos infraespecíficos
    Current_infraspecific_rank = case_when(
      Current_infraspecific_rank %in% c("subsp.", "var.", "f.") ~ Current_infraspecific_rank,
      TRUE ~ NA_character_
    ),
    # Si el tercer término no es rango, no es infraespecie
    Current_infraspecies = if_else(is.na(Current_infraspecific_rank), NA_character_, Current_infraspecies)
  )



# Matching errors should be only on typos or spelling errors:
# subspecies and hybrids are common errors. 
matchingerrors <- bcibiotawcvpplus %>%
  filter((is.na(Name_matched) | Current_name !=Name_matched) & wcvp_status == "Accepted") %>%
  arrange(match_similarity)  %>%
  mutate(row_id = row_number())


matchingerrors %>%  select(row_id, Current_name,Accepted_name, match_similarity)


# If genus, species or subspecies seem very different (not just spelling). It is probably a mistake
# If the error is a small spelling, leave the name in WCVP (accepted name)
# For the species that the match is weird, lets leave the current name as accepted name.

# list of species name that we will change as they have a different spelling
change_name <- matchingerrors %>%
  filter(row_id %in% c(13:19, 21:49)) %>%
  mutate(note = "Spelling changed") %>%
  select(Current_name, Accepted_name)


# Some species have changed their name, that is normal. Lets check that wcvp didint make a mistake in the matching
noacceptedwcvpname <- bcibiotawcvpplus %>% 
  filter(
    (is.na(wcvp_status) | wcvp_status != "Accepted") &
      !is.na(Current_name) &
      !is.na(Name_matched) &
      Current_name != Name_matched
  ) %>%
  arrange(wcvp_status, match_similarity) %>%
  mutate(row_id = row_number()) %>%
  select(row_id, Current_name, Name_matched, Accepted_name, wcvp_status, match_similarity) 

print(noacceptedwcvpname)

# If the matched name is very different needs revision
# otherwise its probably a spelling error, the accepted name is okay
change_name2 <- noacceptedwcvpname %>%
  filter(row_id %in% c(11:18)) %>%
  mutate(note = "Spelling changed. Accepted name changed") %>%
  select(Current_name, Accepted_name)

change_name2

changes_spelling <- bind_rows(change_name, change_name2)
changes_spelling

# Two species can now have the same accepted name. 
# One is now considered a synonym or illegitimate and the other is the accepted name

# OR the synonim could be a different species but with a matching error. Lets check. 

acceptednamesdup <- bcibiotawcvpplus %>% 
  filter(!is.na(Accepted_name)) %>%
  group_by(Accepted_name) %>% 
  arrange(Accepted_name) %>% filter(n()>1) %>% ungroup() %>%
  mutate(mismatch = (Current_name != Name_matched)) %>% 
  arrange(Accepted_name, mismatch, match_similarity) %>%
  select( Accepted_name, Current_name, Name_matched, wcvp_status, mismatch, match_similarity )

print(acceptednamesdup, n= 250)

# For this species we dont want the accepted name to change to the current name. Because we would loose information
print(acceptednamesdup %>% filter(mismatch== TRUE & !Current_name %in% changes_spelling$Current_name), n = 24)

# Most cases is leaving out the subspecies. Lets leave the Current_name as the accepted one. 
change3 <- acceptednamesdup %>% filter(mismatch== TRUE) %>%
  mutate(note = "Subspecies not in wcvp") %>%
  select(Current_name, Accepted_name)


# Now the species names we would like to change:
# 1. It is in the changespelling list
# 2. No missmatch between Name_matched and Current_name and The state is non accepted 
print(bcibiotawcvpplus %>% filter(((Current_name == Name_matched & wcvp_status != "Accepted") | 
                        (Current_name %in% changes_spelling$Current_name)) & 
                        !Current_name %in% change3$Current_name # leave the current species if it is in this list
                        ) %>% select( Accepted_name, Current_name, Name_matched, wcvp_status ))


# FIXING 1

inc <- with(bcibiotawcvpplus,(
        ((!is.na(Current_name) & !is.na(Name_matched) & Current_name == Name_matched & wcvp_status != "Accepted") |
        (!is.na(Current_name) & Current_name %in% changes_spelling$Current_name)) &
        (!Current_name %in% change3$Current_name)))

sum(inc == TRUE)

species_modified <- bcibiotawcvpplus[inc,]
bcibiotafix <- bcibiotawcvpplus
bcibiotafix$currnamechanged = FALSE
bcibiotafix$note = ""
bcibiotafix$Old_name = ""

if (any(inc, na.rm = TRUE)) {
  print(paste0("Changing name to wcvp version: ", bcibiotafix$Current_name[inc], " to ", bcibiotafix$Accepted_name[inc]))
  bcibiotafix$currnamechanged[inc] = TRUE
  bcibiotafix$Current_name_author[inc] =  coalesce(bcibiotafix$Accepted_name_author[inc], bcibiotafix$Current_name_author[inc])
  bcibiotafix$Current_family[inc] = coalesce(bcibiotafix$Accepted_family[inc], bcibiotafix$Current_family[inc])
  bcibiotafix$note[inc] = ifelse(bcibiotafix$Current_name[inc] %in% changes_spelling$Current_name, "Spelling mismatch. Keeping wcvp spelling", "Name changed according to wcvp")
  bcibiotafix$Old_name[inc] = bcibiotafix$Current_name[inc]
  bcibiotafix$Current_name[inc] = bcibiotafix$Accepted_name[inc]
}


# lets see what was left witouth change
bcibiotafix %>% filter(Current_name != Accepted_name) %>% select(Current_name, Accepted_name, wcvp_status, note)


# Porcentaje del cambio: 
(nrow(bcibiotafix %>% filter(currnamechanged))  / nrow(bcibiotafix) ) * 100


# see what changed
bcibiotafix %>% filter(currnamechanged) %>% select(Current_name, Old_name, wcvp_status, note)


# Remove duplicated names: 
acceptednamesdup <- bcibiotafix %>% 
  filter(!is.na(Current_name)) %>%
  group_by(Current_name) %>% 
  filter(n() > 1) %>% 
  ungroup()

print(n = 110, acceptednamesdup %>% filter(currnamechanged) %>% select(Current_name, Old_name, wcvp_status, note))

bcibiotafix_clean <- bcibiotafix %>%
  filter(!is.na(Current_name)) %>%
  distinct(Current_name, .keep_all = TRUE)

nrow(bcibiotafix)
nrow(bcibiotafix_clean)


################################ MERGE WOODY AND BCI ####################################################################


# lets verify again woody panama
# asumamos que me quedo bien

# Left join woodypanama and bcibiota

# woody species that ARE in BCI
woodybci <- lastwoody %>%
  filter(Current_name %in% bcibiotafix_clean$Current_name)


woodybci

# woody species NOT in BCI
woodynotbci <- lastwoody %>%
  filter(!Current_name %in% bcibiotafix_clean$Current_name)


# BCI species NOT in woody list
bcinotwoody <- bcibiotafix_clean %>%
  filter(!Current_name %in% lastwoody$Current_name,
         source != "ferns"
         )

bcinotwoody %>% select(Current_name, source, lifeform_description)

unique(bcinotwoody$lifeform_description)

bcimaybewoody <- bcinotwoody %>%
  filter(lifeform_description %in% c("tree", "scrambling shrub or tree", "subshrub, shrub or tree", "shrub or tree" ))

bcimaybewoody %>% select(Current_name, source, lifeform_description)

nrow(bcimaybewoody)
nrow(woodynotbci)


