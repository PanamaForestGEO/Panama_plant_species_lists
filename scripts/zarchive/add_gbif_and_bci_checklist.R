library(tidyverse)
library(readxl)
library(rgbif)
library(TNRS)

latest_splist <- "Perez-et-al_PanamaPlantSp_2025-03-23tnrsHM2.xlsx"
splist <- read_excel(file.path("splists_out", "zarchive", latest_splist))

# Using BCI checklist to filter splist
bcichecklist <- read_csv("labelbox_lists/checklist/Plants of Barro Colorado_1744208630.csv",
                          col_types = cols(Notes = "c", TaxonId = "i")) 

bcichecklist <- bcichecklist %>%
  mutate(ID = 1:nrow(bcichecklist)) %>% 
  select(ID, ScientificName)

bcichecklist_tnrs_res <- TNRS(taxonomic_names = bcichecklist)

bcichecklist_tnrs_species <- as_tibble(bcichecklist_tnrs_res)

bcichecklist_not_matched_to_species <- bcichecklist_tnrs_species %>% 
  filter(!Name_matched_rank %in% c('species', 'subspecies', 'variety'))

bcichecklist_species <- bcichecklist_tnrs_species %>% 
  mutate(name = ifelse(Taxonomic_status != "No opinion", paste(Accepted_name, Accepted_name_author), paste(Name_matched))) %>% 
  select(name)

bcichecklist_species_gbif <- name_backbone_checklist(bcichecklist_species, kingdom = 'Plantae')
not_exact <- bcichecklist_species_gbif %>% filter(matchType != "EXACT")

bcichecklist_species_gbif <- bcichecklist_species_gbif %>% 
  mutate(gbif_accepted_scientific_name = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), canonicalName, species),
         gbif_accepted_taxon_id = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), usageKey, acceptedUsageKey))

# Species ------
splist_acceptednames <- splist %>%
  mutate(name = paste(Accepted_name, Accepted_name_author)) %>% 
  select(name)

splist_gbif <- name_backbone_checklist(splist_acceptednames, kingdom = "Plantae")
not_exact <- splist_gbif %>% filter(matchType != "EXACT") #all 'species' rank, only synonyms or typo

splist_withgbif <- splist %>%
  mutate(name = paste(Accepted_name, Accepted_name_author)) %>% 
  left_join(splist_gbif %>%
              filter(rank %in% c("SPECIES", "SUBSPECIES")) %>%
              distinct(verbatim_name, .keep_all = TRUE) %>%
              mutate(gbif_accepted_scientific_name = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), canonicalName, species),
                     gbif_accepted_taxon_id = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), usageKey, acceptedUsageKey)) %>%
              select(verbatim_name, gbif_accepted_scientific_name, gbif_accepted_taxon_id),
            by = c("name" = "verbatim_name")) %>%
  select(-name)

# filter with checklist
splist_withgbif_checklist <- splist_withgbif %>% 
  filter(gbif_accepted_taxon_id %in% c(bcichecklist_species_gbif$gbif_accepted_taxon_id, 9158473)) #add missing species Pochota fendleri

# Create taxon_column for Labelbox and keep only species or subspecies (exclude genus)
sponlylist_withgbif_checklist <- splist_withgbif_checklist %>%
  filter(Accepted_name_rank %in% c("species", "subspecies")) %>%
  mutate(taxon_code = case_when(
    (!is.na(sp6) & !is.na(sp4)) ~ paste(Current_name, toupper(sp6), toupper(sp4), sep = '-'),
    (!is.na(sp6) & is.na(sp4)) ~ paste(Current_name, toupper(sp6), sep = '-'),
    (is.na(sp6) & !is.na(sp4)) ~ paste(Current_name, toupper(sp4), sep = '-'),
    .default = Current_name))

write.csv(sponlylist_withgbif_checklist, "labelbox_lists/labelbox_bci_splist.csv",
          fileEncoding = 'latin1', row.names = F, quote = T)

# Families ------
familieslist <- bind_rows(splist %>%
                            select(Current_family, Accepted_family) %>%
                            pivot_longer(cols = c(Current_family, Accepted_family), names_to = "source", values_to = "family") %>%
                            select(family),
                          splist_gbif %>%
                            select(family),
                          data.frame(family = c("Fabaceae-Mimosoideae", 
                                                "Fabaceae-Papilionoideae", 
                                                "Fabaceae-Caesalpiniodeae"))) %>%
  filter(!is.na(family)) %>%
  distinct() %>% 
  mutate(name = family) %>% 
  mutate(name = case_when(
    str_detect(name, "Fabaceae") ~ "Fabaceae",
    TRUE ~ name
  ))


familieslist_gbif <- name_backbone_checklist(familieslist, kingdom = 'Plantae')
familieslist_withgbif <- familieslist_gbif %>% 
  select(taxon_code = verbatim_family,
         gbif_accepted_scientific_name = family,
         gbif_accepted_taxon_id = familyKey) %>% 
  arrange(gbif_accepted_scientific_name)

# Genera ------
generalist <- bind_rows(splist %>%
                          filter(Accepted_name_rank == "genus") %>%
                          select(genus = Accepted_name),
                        splist %>%
                          filter(Accepted_name_rank %in% c("species", "subspecies")) %>%
                          mutate(genus = word(Accepted_name, 1)) %>%
                          select(genus),
                        splist_gbif %>%
                          select(genus)) %>%
  distinct()

generalist_gbif <- name_backbone_checklist(generalist, phylum = 'Tracheophyta')
not_exact <- generalist_gbif %>% filter(matchType != "EXACT")

#Fix not exact matches
generalist_fixed <- generalist %>%
  mutate(name = paste(genus),
         name = case_when(
           name == "Acanthocladus" ~ "Acanthocladus Klotzsch ex Hassk.",
           name == "Chione" ~ "Chione DC.",
           name == "Cuspidaria" ~ "Cuspidaria DC.",
           name == "Heisteria" ~ "Heisteria Jacq.",
           name == "Hirtella" ~ "Hirtella L.",
           name == "Hura" ~ "Hura L.",
           name == "Lunania" ~ "Lunania Hook.",
           name == "Simira" ~ "Simira Aubl.",
           name == "Tonduzia" ~ "Tonduzia Pittier",
           TRUE ~ name
         )) %>%
  select(name)
                        
generalist_gbif <- name_backbone_checklist(generalist_fixed, phylum = 'Tracheophyta')
not_exact <- generalist_gbif %>% filter(matchType != "EXACT")

# Join with original splist to add taxon codes, accepted scientific names and taxon IDs
generalist_withgbif <- splist %>%
  filter(Accepted_name_rank == "genus") %>%
  right_join(generalist_gbif %>%
              mutate(gbif_accepted_scientific_name = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), canonicalName, genus),
                     gbif_accepted_taxon_id = ifelse(status %in% c("ACCEPTED", "DOUBTFUL"), usageKey, acceptedUsageKey)) %>%
              select(verbatim_name, gbif_accepted_scientific_name, gbif_accepted_taxon_id),
            by = c("Accepted_name" = "verbatim_name")) %>%
  mutate(taxon_code = case_when(
    (!is.na(sp6) & !is.na(sp4)) ~ paste(Accepted_name, toupper(sp6), toupper(sp4), sep = '-'),
    (!is.na(sp6) & is.na(sp4)) ~ paste(Accepted_name, toupper(sp6), sep = '-'),
    (is.na(sp6) & !is.na(sp4)) ~ paste(Accepted_name, toupper(sp4), sep = '-'),
    .default = word(Accepted_name, 1)))

# Complete checklist for Labelbox ------
labelbox_bci_checklist <- bind_rows(sponlylist_withgbif_checklist,
                                    familieslist_withgbif,
                                    generalist_withgbif) %>% 
  select(taxon_code, gbif_accepted_taxon_id, gbif_accepted_scientific_name, habit) %>% 
  mutate(across(everything(), 
                ~ifelse(is.na(.) | . == "NA", "", .))) %>% 
  arrange(taxon_code)

write.csv(labelbox_bci_checklist, "labelbox_lists/labelbox_bci_completelist.csv",
          fileEncoding = 'latin1', row.names = F, quote = T)
