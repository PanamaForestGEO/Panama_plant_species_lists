
# Revisando especies del herbario

library(readxl)
library(writexl)
library(dplyr)
library(tidyr)
library(stringi)
library(stringr)
library(knitr)
library(DT)
library(rgbif)



botanists_list <- read_excel("../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_out/BCNM_SPECIES_BOTANISTS_LIST_2026-04-27.xlsx", sheet=1)



################ QUICK COMPARISON WITH HERBARIUM LIST ###################################################

herbarium_list <- read_excel("../Documentos/PROYECTOS/STRI/BCI-PlantList-20111025.xls", sheet = 2)


herbarium_list <- herbarium_list %>% mutate(
  sp_name = trimws(paste0(genus, " ", sp1, " ", coalesce(rank1, ""), " ", coalesce(sp2,"")) ),
  sp_binomial = paste0(genus, " ", sp1)
)

herbarium_list %>% select(sp_name, sp_binomial)

herb_names <- unique(c(
  herbarium_list$sp_name,
  herbarium_list$sp_binomial
))
botanists_new <- botanists_list %>%
  filter(
    !coalesce(current_name %in% herb_names, FALSE) &
      !coalesce(garwood_name %in% herb_names, FALSE) &
      !coalesce(liana_name %in% herb_names, FALSE) &
      !coalesce(zotz_name %in% herb_names, FALSE)
  )

datatable(botanists_new %>% select(
  sp6, sp4,  current_name, 
  source_current_name, garwood_name,
  zotz_name, liana_name, census_plot
  ) %>% select(
    sp6, sp4,  current_name, source_current_name, garwood_name, zotz_name, liana_name, census_plot
  ))



#from the species IN The list, see the ones that might be problematic according to Carmen
botanists_revise <- botanists_list %>% 
  filter(!garwood_name %in% botanists_new$garwood_name) %>%
  left_join(herbarium_list %>% select(sp_name, tag), by=c("garwood_name"= "sp_name"))
  
datatable(botanists_revise %>% filter(str_detect(tag, "\\?")) %>% select(current_name, source_current_name, 
                                                             census_plot, garwood_name, tag))


##########


herbarium_problem <- herbarium_list %>%
  filter(
      !sp_name %in% botanists_list$current_name &
      !sp_name %in% botanists_list$garwood_name &
      !sp_name %in% botanists_list$liana_name &
      !sp_name %in% botanists_list$zotz_name &
      !sp_binomial %in% botanists_list$current_name &
      !sp_binomial %in% botanists_list$garwood_name &
      !sp_binomial %in% botanists_list$liana_name &
      !sp_binomial %in% botanists_list$zotz_name 
  ) %>%
  select(sp_name, tag) %>% arrange(sp_name)

# see species in herbarium that are NOT in the botanists list
datatable(
  herbarium_problem %>% filter(tag == "bci") %>% select(sp_name))




nrow(botanists_list)
nrow(herbarium_list)



##################################### QUICK COMPARISON WITH CENSUS CHECK #####################################
# Plot abundance in BCNM
bci_plots_abund_orig <- read_excel("../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_raw/Plots/abundance_plots_HM.xlsx")

bci_plots_abund <- bci_plots_abund_orig %>% 
  select(sp, binomial, 
         # plots in bci
         bci, `bci 10 ha plot`, P11, P14,
         
         # plots in BCNM
         P10, P12, P13, P18, gigante1, gigante2
         
  ) %>%
  rename(
    sp6 = sp,
    census_name = binomial,
    bci50ha = bci,
    bci10ha = `bci 10 ha plot`,
  ) 

# Other BCI census
bci_other_plots_orig <- read.delim(
  "../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_raw/Plots/doi_10_5061_dryad_1g1jwsvc3__v20260226/mainfile.txt"
)

# summarise
bci_other_plots <- bci_other_plots_orig %>%
  group_by(sp6, plot) %>%
  summarise(n_distinct_tag = n_distinct(tag), .groups = "drop") %>%
  pivot_wider(
    names_from = plot,
    values_from = n_distinct_tag,
    values_fill = 0
  ) %>%
  rename(
    bci10ha = `10ha`,
    bci25ha = `25ha`
  )

# Census from Gigante project
census_gigante <- read.csv(
  "../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_raw/Plots/gigante_census_2026-04-05.csv"
)
census_gigante <- census_gigante%>%
  select(sp6, freq) %>%
  rename(gigante_plot = freq)


# Join safely (keeps all census_list species)
census_list <- bci_plots_abund %>%
  full_join(bci_other_plots, by = "sp6") %>%
  mutate(bci10ha = coalesce(bci10ha.x, bci10ha.y)) %>%
  select(-bci10ha.x, -bci10ha.y) %>%
  full_join(census_gigante, by = "sp6")

# Filter safely (handle NA just in case)
census_list <- census_list %>%
  mutate(across(c(bci50ha, bci10ha, P14, P11, Zetek, bci25ha, AVA, Drayton, Pearson, P10, P12, P13, P18, gigante1, gigante2, gigante_plot), ~coalesce(., 0))) %>%
  filter(
    if_any(c(P11, P14, bci10ha, bci50ha, Zetek, bci25ha, AVA, Drayton, Pearson, P10, P12, P13, P18, gigante1, gigante2, gigante_plot),
           ~ !is.na(.) & . > 0)
  )


census_list <- census_list %>% mutate(
  BCI = (bci50ha>0 | bci10ha>0 | P14>0 | P11>0 | Zetek>0 | bci25ha>0 | 
           AVA>0 | Drayton>0 | Pearson>0),
  
  # if it is in any of the plots outside of BCI that are in the BCNM
  Other_BCNM_plots = (P10 >0 | P12>0| P13>0| P18>0| gigante1>0| gigante2>0 | gigante_plot > 0)
)

# 6. Create census_plot column safely
census_list <- census_list %>%
  rowwise() %>%
  mutate(
    census_plot = paste(
      c(
        if (bci50ha > 0) "bci50ha",
        if (bci10ha > 0) "bci10ha",
        if(bci25ha > 0) "bci25ha",
        if (P14 > 0) "P14",
        if (P11 > 0) "P11",
        if(Zetek > 0) "Zetek",
        if(AVA > 0) "AVA",
        if(Drayton > 0) "Drayton",
        if(Pearson > 0) "Pearson",
        if (P10 > 0) "P10",
        if (P12 > 0) "P12",
        if (P13 > 0) "P13",
        if (P18 > 0) "P18",
        if (gigante1 > 0) "gigante1",
        if (gigante2 > 0) "gigante2",
        if (gigante_plot > 0) "gigante_plot"
      ),
      collapse = ", "
    )
  ) %>%
  ungroup()

panwoody_list <- read_excel("../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_out/CurrentPanamaWoody_2026-04-11.xlsx")


census_list <- census_list %>% left_join(
  panwoody_list, by="sp6"
) %>%
  rename(forestgeo_current_name = orig_name)%>% 
  # leaving out species that dont have a name
  filter(!is.na(forestgeo_current_name))



# see the species in the final list that are NOT in Garwood and are coming from a plot census and need to be checked
species_census_check <- botanists_list %>% 
            filter(is.na(garwood_name) & source_current_name != "Zotz" &
                     !str_detect(census_plot, c("bci50"))) %>%
            select(sp6, sp4, current_name, census_plot)

# species and the abundance in each plot
species_census_abundance <- census_list %>% 
  filter(sp6 %in% species_census_check$sp6) %>% 
  select(sp6, Zetek, P13, P18, bci10ha, bci25ha, gigante1, gigante2, gigante_plot)


# species and the abundance in each plot
species_census_abundance <- census_list %>% 
  filter(sp6 %in% c("unonpi", "unonpa")) %>% 
  select(sp6, Zetek, P13, P18, bci10ha, bci25ha, gigante1, gigante2, gigante_plot)

# species and tags from the census
species_census_tags <- bci_other_plots_orig %>% 
  filter(sp6 %in% species_census_check$sp6) %>% 
  select(sp6, plot, census, tag, status, px, py, utmx, utmy)



# species and tags from the census
species_census_tags <- bci_other_plots_orig %>% 
  filter(sp6 %in% c("unonpi", "unonpa")) %>% 
  select(sp6, plot, census, tag, status, px, py, utmx, utmy)


species_census_tags %>% arrange(sp6, desc(census)) %>% distinct(tag, .keep_all = TRUE)

library(ggplot2)

# 2. Create the plot
ggplot(species_census_tags, aes(x = utmx, y = utmy, color = sp6, shape = plot)) +
  geom_point(size = 3, alpha = 0.7) +
  # Use a color palette that makes it easy to distinguish the codes
  scale_color_brewer(palette = "Set1") +
  # Customizing labels and theme
  labs(
    title = "Spatial Distribution of Species by Plot",
    x = "X Coordinate (utmx)",
    y = "Y Coordinate (utmy)",
    color = "Species Code (sp6)",
    shape = "Plot Name"
  ) +
  theme_minimal() +
  theme(legend.position = "right")



write_xlsx(
  list(
    "Unonopsis"  = species_census_tags %>% arrange(sp6, desc(census)) %>% distinct(tag, .keep_all = TRUE)
  ),
  path = "../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/tocheck/species_unonopsis_tags.xlsx"
)


#species in the gigante plot
gigante_census <- read.delim("../Documentos/PROYECTOS/STRI/Gigante_2023census_WorkingFile20240829.txt")  


census_tag_gigante <-  gigante_census %>% 
    mutate(sp6 = tolower(sp23) ) %>%
    filter(sp6 %in% species_census_check$sp6) #%>%
    #distinct(tag, .keep_all = TRUE) %>% arrange(sp23) %>% select(-sp6)

census_tag_gigante <-  gigante_census %>% 
  mutate(sp6 = tolower(sp23) ) %>%
  filter(sp6 %in% c("unonpi", "unonpa")) #%>%
#distinct(tag, .keep_all = TRUE) %>% arrange(sp23) %>% select(-sp6)


census_tag_gigante 

# Write the three filtered datasets into one Excel file with separate sheets
write_xlsx(
  list(
    "Species_Check" = species_census_check,
    "Abundance"    = species_census_abundance,
    "Census_Tags"  = species_census_tags,
    "Census_Tags_Gigante" = census_tag_gigante
  ),
  path = "../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/tocheck/species_validation_results.xlsx"
)




################# what happens to the list if we ignore subspecies and varieties? ##########################

botanists_list <- read_excel("../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_out/BCNM_SPECIES_BOTANISTS_LIST_2026-04-20.xlsx", sheet=1)


# Fix the hybrid notation with the correct x 
botanists_list <- botanists_list %>% 
  mutate(current_name = ifelse(str_detect(current_name, " x | x | × "),
                               paste0(word(current_name,1), " × ", word(current_name,3)),
                               current_name),
         
         current_binomial = ifelse(str_detect(wcvp_matched_name, " x | x | × "),
                                   wcvp_matched_name, # keep the full name 
                                    word(wcvp_matched_name, 1,2)))  # extract binomial
         

botanists_list <- botanists_list %>% add_count(current_binomial, name="binomials")

datatable(botanists_list %>% filter(!is.na(word(current_name, 4))) %>% select(current_name, current_binomial, source_current_name))

datatable(botanists_list %>% 
        filter(binomials > 1) %>% 
        select(sp6, current_name, source_current_name))

# Write the three filtered datasets into one Excel file with separate sheets
write_xlsx(
  list(
    "Subspecies" = botanists_list %>% filter(!is.na(word(current_name, 4))) %>% select(current_name, current_binomial, source_current_name),
    "Duplicated species"    = botanists_list %>% 
      filter(binomials > 1) %>% 
      select(sp6, current_name, source_current_name)
  ),
  path = "../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/tocheck/species_subspecies.xlsx"
)


subspecies_to_keep <- c("Swartzia simplex var. continentalis",
                        "Swartzia simplex var. grandiflora")

# keep only one species binomial, preferably the one with forestgeo name. 

botanists_list_binomials <- botanists_list %>%
  # for swartzia simplex leave the current name as binomial
  mutate(
    
    current_binomial = ifelse(current_name %in% subspecies_to_keep |
                              word(current_name,2) == "×", 
                              current_name, 
                              word(current_name, 1,2)
                              ),
    
    status_priority = case_when(
      source_current_name == "ForestGeo"~ 1,
      TRUE~ 2
    )
  ) %>%
  group_by(current_binomial) %>%
  slice_min(status_priority, n = 1, with_ties = FALSE) %>%
  ungroup()

datatable(botanists_list_binomials %>% select(sp6, current_binomial, source_current_name))

# now that we will only use the binomials of the species the wcvp ids and names are wrong! and need to be changed
species_to_fix <- botanists_list_binomials %>% filter(
  current_name != current_binomial
)

datatable(species_to_fix %>% select(current_name, current_binomial, wcvp_matched_name))

################################## COMPARE PIPER SPECIES IN REVISION #######################################

piper_revision <- read_xlsx("../Documentos/PROYECTOS/STRI/Panama_plant_species_lists/splists_raw/Piper_revision/piper_revision_list.xlsx")


piper_now <- botanists_list %>% filter(word(current_name,1) == "Piper")

piper_now


# we have 22 species of piper, all coming form Garwood except for 
piper_now %>% filter(is.na(garwood_name))

# Now see species in the current list that are not in the revision
piper_now %>% filter(!current_name %in% piper_revision$Current_name)

piper_revision %>% filter(!Current_name %in% piper_now$current_name)
