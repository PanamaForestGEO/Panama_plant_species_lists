library(tidyverse)
library(readxl)
library(rgbif)

latest_splist <- "Perez-et-al_PanamaPlantSp_2025-03-23tnrsHM2.xlsx"

splist <- read_excel(file.path("splists_out", latest_splist))

# Species ------
splist_acceptednames <- splist %>%
  select(Accepted_name)

splist_gbif <- name_backbone_checklist(splist_acceptednames, kingdom = "Plantae")
not_exact <- splist_gbif %>% filter(matchType != "EXACT")

#Fix not exact matches
splist_acceptednames <- splist %>%
  mutate(name = paste(Accepted_name),
         name = case_when(
           name == "Cleyera theoides" ~ "Cleyera theoides (Sw.) Choisy", #need to add author
           name == "Swartzia" ~ "Swartzia Schreb.", #need to add author
           name == "Triplaris americana" ~ "Triplaris americana L.", #need to add author
           TRUE ~ name
         )) %>%
  select(name)

splist_gbif <- name_backbone_checklist(splist_acceptednames, kingdom = "Plantae")
not_exact <- splist_gbif %>% filter(matchType != "EXACT") #all 'species' rank, only synonyms or typo

# Join with original splist to add accepted scientific names and taxon IDs
splist_withgbif <- splist %>%
  left_join(splist_gbif %>%
              filter(rank %in% c("SPECIES", "SUBSPECIES")) %>%
              distinct(verbatim_name, .keep_all = TRUE) %>%
              mutate(gbif_accepted_scientific_name = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), canonicalName, species),
                     gbif_accepted_taxon_id = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), usageKey, acceptedUsageKey)) %>%
              select(verbatim_name, gbif_accepted_scientific_name, gbif_accepted_taxon_id) %>% 
              mutate(verbatim_name = case_when(
                verbatim_name == "Cleyera theoides (Sw.) Choisy" ~ "Cleyera theoides",
                verbatim_name == "Swartzia Schreb." ~ "Swartzia",
                verbatim_name == "Triplaris americana L." ~ "Triplaris americana",
                TRUE ~ verbatim_name
              )),
            by = c("Accepted_name" = "verbatim_name")
  )

# Create taxon_column for Labelbox and keep only species or subspecies (exclude genus)
sponlylist_withgbif <- splist_withgbif %>%
  filter(Accepted_name_rank %in% c("species", "subspecies")) %>%
  mutate(taxon_code = case_when(
    (!is.na(sp6) & !is.na(sp4)) ~ paste(Current_name, toupper(sp6), toupper(sp4), sep = '-'),
    (!is.na(sp6) & is.na(sp4)) ~ paste(Current_name, toupper(sp6), sep = '-'),
    (is.na(sp6) & !is.na(sp4)) ~ paste(Current_name, toupper(sp4), sep = '-'),
    .default = Current_name))

write.csv(sponlylist_withgbif, "labelboxlists/labelbox_bci_splist.csv",
          fileEncoding = 'latin1', row.names = F, quote = T)

