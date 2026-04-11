# Species lists

This subdirectory contains lists of plant species in Panama. 

# BCNM Botanists Species List

Previously the BCI species list, now extended to species across the broader Barro Colorado Natural Monument (BCNM). Based on Garwood (2009) with additions from Zotz, plot census records, and the lianas list. A `BCI` column indicates presence on the island specifically.

---

### Core identifiers & current name

| Column | Description |
|--------|-------------|
| `current_name` | Name currently used by STRI botanists. May differ from WCVP matched or accepted names. |
| `source_current_name` | Source of the current name. |
| `sp6` | Current 6-letter ForestGEO species code. |
| `sp4` | Current 4-letter ForestGEO species code. |
| `source_list` | Original source from which this species was added to the list. |

---

### WCVP matched name

> The name as matched in the World Checklist of Vascular Plants. Closest to the name used by botanists — used as the primary basis for GBIF lookups.

| Column | Description |
|--------|-------------|
| `wcvp_matched_name` | Species name as matched in WCVP. |
| `wcvp_matched_plant_name_id` | WCVP internal ID for the matched name. Used within the WCVP/Kew ecosystem only. |
| `wcvp_matched_ipni_id` | IPNI identifier for the matched name |
| `wcvp_matched_status` | Taxonomic status of the matched name (e.g. accepted, synonym). |

---

### WCVP accepted name

> Current taxonomic consensus according to WCVP. May include name changes that STRI botanists have not yet reviewed or may disagree with — use with caution.

| Column | Description |
|--------|-------------|
| `wcvp_accepted_name` | Currently accepted species name according to WCVP. |
| `wcvp_accepted_binomial` | Accepted genus + species binomial. |
| `wcvp_accepted_family` | Accepted family according to WCVP. |
| `wcvp_accepted_authority` | Taxonomic authority for the accepted name. |
| `wcvp_accepted_plant_name_id` | WCVP internal ID for the accepted name. |
| `wcvp_accepted_powo_id` | Plants of the World Online (POWO) identifier — links to `powo.science.kew.org`. Often numerically identical to the accepted IPNI ID. |
| `wcvp_accepted_ipni_id` | IPNI identifier for the accepted name. |
| `wcvp_accepted_lifeform` | Life form classification according to WCVP. |

---

### Sources: Garwood, Zotz & plots

| Column | Description |
|--------|-------------|
| `garwood_name` | Species name as it appears in Garwood (2009) — the primary base list. |
| `garwood_synonyms` | Synonyms listed for this species in Garwood (2009). |
| `garwood_lifeform` | Life form as classified in Garwood (2009). |
| `garwood_Other_BCNM_plots` | Species present in BCNM plots outside BCI according to Garwood, but not recorded on the island. |
| `zotz_name` | Species name as it appears in the Zotz epiphyte list. |
| `liana_name` | Species name as it appears in the lianas list. |
| `census_plot` | Census plot(s) in which this species has been recorded. |
| `BCI` | Species recorded in a BCI plot (bci50ha, bci10ha, P14, P11, Zetek, bci25ha, AVA, Drayton, Pearson) or listed as BCI in the lianas list, Garwood, or Zotz. |
| `woody_forestgeo` | Whether the species is classified as woody based on ForestGEO presence or binomial match. |
| `forestgeo_habit` | Habit classification from the ForestGEO list: Freestanding or Climbing |

---

### GBIF — matched name lookup

> GBIF fields derived by querying the GBIF backbone with `wcvp_matched_name`. Primary GBIF reference — closer to the names used by botanists.

| Column | Description |
|--------|-------------|
| `wcvp_matched_name_gbif_id` | GBIF usage key for the matched name. |
| `wcvp_matched_name_gbif_scientificName` | Scientific name returned by GBIF for the matched name. |
| `wcvp_matched_name_gbif_matchtype` | GBIF match type (EXACT, FUZZY, NONE). |
| `wcvp_matched_name_gbif_status` | Taxonomic status according to GBIF (ACCEPTED, SYNONYM, etc.). |
| `wcvp_matched_name_gbif_acceptedScientificName` | GBIF accepted name if the matched name is a synonym. NA if already accepted. |

---

### GBIF — accepted name lookup

> GBIF fields derived by querying the GBIF backbone with `wcvp_accepted_name`. Provided for reference — botanists may not have reviewed these name changes.

| Column | Description |
|--------|-------------|
| `wcvp_accepted_name_gbif_id` | GBIF usage key for the accepted name. |
| `wcvp_accepted_name_gbif_scientificName` | Scientific name returned by GBIF for the accepted name. |
| `wcvp_accepted_name_gbif_matchtype` | GBIF match type (EXACT, FUZZY, NONE). |
| `wcvp_accepted_name_gbif_status` | Taxonomic status according to GBIF. |
| `wcvp_accepted_name_gbif_acceptedScientificName` | GBIF accepted name if the accepted name is a synonym. NA if already accepted. |

---

# Panama Woody Plant Species List

A consolidation of woody plant species across Panama. This dataset integrates original STRI botanical records with global taxonomic standards from the **World Checklist of Vascular Plants (WCVP)** and the **GBIF Backbone Taxonomy**.

---

### Original Taxonomy & Identifiers
> Based on the original nomenclature used by STRI botanists and historical ForestGEO plot codes.

| Column | Description |
|--------|-------------|
| `orig_name` | Full original scientific name as used by STRI botanists. |
| `orig_binomial` | Original genus + species binomial. |
| `orig_family` | Original family assignment according to STRI list. |
| `orig_genus` | Original genus according to STRI list. |
| `orig_species` | Original species epithet according to STRI list. |
| `orig_authority` | Taxonomic authority for the original name. |
| `sp6` | Species code (SP6) used in ForestGEO plots. |
| `sp4` | Species code (SP4) used in ForestGEO plots. |
| `orig_habit` | Growth habit assigned in the original dataset. |
| `vouchers` | Voucher specimen information for the species. |
| `names_notes` | Notes related to taxonomic matching or naming issues. |

---

Same as described in the BCI list:

### WCVP Matched Name

### WCVP Accepted Name

### GBIF — Matched Name Lookup


### GBIF — Accepted Name Lookup

