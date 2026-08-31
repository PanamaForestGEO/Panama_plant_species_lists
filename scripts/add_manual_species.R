# Add pending manual species requests to the BCNM Botanists Species List
#
# Description: reads splists_raw/Manual_additions/manual_additions_log.csv,
# WCVP- and GBIF-matches any row not yet marked as incorporated
# (date_added_to_bcnm_list blank), appends those rows to the most recent
# splists_out/BCNM_SPECIES_BOTANISTS_LIST_*.xlsx, and writes a new dated
# output file with the same three sheets (BCNM List, Dictionary, Metadata).
# Also updates the log's date_added_to_bcnm_list and output_file columns.
#
# This is the lightweight companion to scripts/species_plantnet.Rmd for
# one-off, botanist-requested additions between full pipeline reruns (e.g.
# an emailed request, or a species approved after reviewing a
# tocheck/panamabiota_not_garwood_*.xlsx file). It does not repeat any of
# the Garwood/Zotz/Lianas/Plots/Wright merge logic in species_plantnet.Rmd -
# see the "Manual additions" note near the top of that Rmd.
#
# Input:  splists_raw/Manual_additions/manual_additions_log.csv
#         latest splists_out/BCNM_SPECIES_BOTANISTS_LIST_*.xlsx
# Output: new splists_out/BCNM_SPECIES_BOTANISTS_LIST_<today>.xlsx
#         splists_raw/Manual_additions/manual_additions_log.csv (status columns updated)

library(readxl)
library(writexl)
library(dplyr)
library(stringr)
suppressPackageStartupMessages({
  library(rWCVP)
  library(rWCVPdata)
})
library(rgbif)

LOG_FILE <- "splists_raw/Manual_additions/manual_additions_log.csv"

# --- Find the most recent BCNM list ---
existing_files <- list.files("splists_out", pattern = "^BCNM_SPECIES_BOTANISTS_LIST_.*\\.xlsx$", full.names = TRUE)
existing_dates <- as.Date(str_extract(existing_files, "\\d{4}-\\d{2}-\\d{2}"))
latest_file <- existing_files[which.max(existing_dates)]

message("Using latest BCNM list: ", latest_file)

bcnm_list <- read_excel(latest_file, sheet = "BCNM List")
dict_columns <- read_excel(latest_file, sheet = "Dictionary")
metadata_df <- read_excel(latest_file, sheet = "Metadata")

# --- Read the manual additions log and find pending rows ---
manual_log <- read.csv(LOG_FILE, colClasses = "character", na.strings = "")

pending <- manual_log %>% filter(is.na(date_added_to_bcnm_list) | date_added_to_bcnm_list == "")

if (nrow(pending) == 0) {
  stop("No pending rows in ", LOG_FILE, " - nothing to add.")
}

# Guard against re-adding a species already present in the current list
already_present <- pending$orig_name %in% c(bcnm_list$current_name, bcnm_list$wcvp_accepted_name, bcnm_list$wcvp_matched_name)
if (any(already_present)) {
  message("Skipping already-present species: ", paste(pending$orig_name[already_present], collapse = ", "))
  pending <- pending[!already_present, ]
}

if (nrow(pending) == 0) {
  stop("All pending rows are already present in the current list - nothing to add.")
}

# --- WCVP match the pending species ---
wcvp_names <- rWCVPdata::wcvp_names

match_one_species <- function(orig_name, sp6 = NA_character_) {
  match_result <- wcvp_match_names(data.frame(orig_name = orig_name), wcvp_names, name_col = "orig_name")

  if (sum(match_result$wcvp_status == "Accepted", na.rm = TRUE) > 1) {
    stop("Multiple accepted WCVP matches for '", orig_name, "' - resolve manually before rerunning.")
  }

  match_result <- match_result %>%
    mutate(status_priority = case_when(
      wcvp_status == "Accepted"     ~ 1,
      wcvp_status == "Synonym"      ~ 2,
      wcvp_status == "Illegitimate" ~ 3,
      wcvp_status == "Unplaced"     ~ 4,
      TRUE                          ~ 5
    )) %>%
    slice_min(status_priority, n = 1, with_ties = FALSE)

  accepted <- wcvp_names %>%
    filter(plant_name_id == match_result$wcvp_accepted_id) %>%
    mutate(
      wcvp_accepted_authority = paste0(
        ifelse(!is.na(parenthetical_author), paste0("(", parenthetical_author, ") "), ""),
        coalesce(primary_author, "")
      )
    )

  gbif_matched <- name_backbone(name = match_result$wcvp_name)
  gbif_accepted <- name_backbone(name = accepted$taxon_name)

  data.frame(
    current_binomial = accepted$taxon_name,
    current_name = accepted$taxon_name,
    source_current_name = "Manual addition (WCVP accepted name)",
    current_authority = accepted$wcvp_accepted_authority,
    sp6 = ifelse(is.na(sp6) || sp6 == "", NA_character_, sp6),
    sp4 = NA_character_,
    wcvp_matched_authors = match_result$wcvp_authors,
    wcvp_matched_name = match_result$wcvp_name,
    wcvp_matched_plant_name_id = as.character(match_result$wcvp_id),
    wcvp_matched_ipni_id = match_result$wcvp_ipni_id,
    wcvp_matched_status = match_result$wcvp_status,
    wcvp_match_similarity = as.character(match_result$match_similarity),
    wcvp_accepted_name = accepted$taxon_name,
    wcvp_accepted_binomial = paste(accepted$genus, accepted$species),
    wcvp_accepted_family = accepted$family,
    wcvp_accepted_authority = accepted$wcvp_accepted_authority,
    wcvp_accepted_plant_name_id = as.character(accepted$plant_name_id),
    wcvp_accepted_powo_id = accepted$powo_id,
    wcvp_accepted_ipni_id = accepted$ipni_id,
    wcvp_accepted_lifeform = accepted$lifeform_description,
    garwood_name = NA_character_,
    garwood_synonyms = NA_character_,
    garwood_lifeform = NA_character_,
    zotz_name = NA_character_,
    census_plot = NA_character_,
    BCI = NA,
    garwood_BCNM = NA,
    liana_name = NA_character_,
    woody_forestgeo = NA,
    forestgeo_habit = NA_character_,
    source_list = "Manual_addition",
    wcvp_matched_name_gbif_id = as.character(gbif_matched$usageKey[1]),
    wcvp_matched_name_gbif_scientificName = gbif_matched$scientificName[1],
    wcvp_matched_name_gbif_matchtype = gbif_matched$matchType[1],
    wcvp_matched_name_gbif_status = gbif_matched$status[1],
    wcvp_matched_name_gbif_acceptedScientificName = if ("acceptedScientificName" %in% names(gbif_matched)) gbif_matched$acceptedScientificName[1] else NA_character_,
    wcvp_accepted_name_gbif_id = as.character(gbif_accepted$usageKey[1]),
    wcvp_accepted_name_gbif_scientificName = gbif_accepted$scientificName[1],
    wcvp_accepted_name_gbif_matchtype = gbif_accepted$matchType[1],
    wcvp_accepted_name_gbif_status = gbif_accepted$status[1],
    wcvp_accepted_name_gbif_acceptedScientificName = if ("acceptedScientificName" %in% names(gbif_accepted)) gbif_accepted$acceptedScientificName[1] else NA_character_,
    stringsAsFactors = FALSE
  )
}

if (!"sp6" %in% names(pending)) pending$sp6 <- NA_character_

new_rows <- bind_rows(Map(match_one_species, pending$orig_name, pending$sp6))

# Evidence of BCI presence is recorded per-request in the log's "evidence" column;
# mark BCI = TRUE only when that evidence mentions BCI/Panamabiota explicitly.
new_rows$BCI <- str_detect(pending$evidence, regex("BCI|Panamabiota", ignore_case = TRUE))

stopifnot(all(names(new_rows) %in% dict_columns$column))

bcnm_list_updated <- bind_rows(bcnm_list, new_rows) %>%
  arrange(current_name) %>%
  select(all_of(dict_columns$column))

# --- Write new dated output ---
today <- Sys.Date()
out_file <- paste0("splists_out/BCNM_SPECIES_BOTANISTS_LIST_", today, ".xlsx")

metadata_df <- bind_rows(
  metadata_df %>% filter(item != "Date created"),
  data.frame(item = "Date created", description = format(today, "%Y-%m-%d")),
  data.frame(item = "Manual additions", description = paste0("Includes manually-requested species from ", LOG_FILE, " (source list value: 'Manual_addition')"))
)

write_xlsx(
  list(
    "BCNM List" = bcnm_list_updated,
    "Dictionary" = dict_columns,
    "Metadata" = metadata_df
  ),
  out_file
)

message("Wrote ", nrow(new_rows), " new species to ", out_file)

# --- Update the log with incorporation status ---
manual_log$date_added_to_bcnm_list[manual_log$orig_name %in% pending$orig_name] <- format(today, "%Y-%m-%d")
manual_log$output_file[manual_log$orig_name %in% pending$orig_name] <- out_file
write.csv(manual_log, LOG_FILE, row.names = FALSE, na = "")

message("Updated ", LOG_FILE, " with incorporation status.")
