# Stale WCVP entries found (2026-06-29)

Found while triangulating species names for the Pl@ntNet
`Carlos_Jaramillo_BCI_BW_leaf_2007` import (see
`Pl@ntNet_uploads/Carlos_Jaramillo_BCI_BW_leaf_2007/prepare_plantnet_import.R`),
cross-checking 251 sp6 codes against:
- `BCNM_SPECIES_BOTANISTS_LIST_2026-04-30.xlsx` (in `Pl@ntNet_uploads/PlantNet_plots/input/`)
- `CurrentPanamaWoody_2026-04-11.xlsx` (`splists_out/` here)
- a fresh WCVP snapshot dated 2026-06-04 (`Pl@ntNet_uploads/wcvp_cache/`)

## Confirmed stale entry

- **sp6 `HERRPU`**: both lists give `wcvp_accepted_binomial` = **Herrania
  purpurea** (Pittier) R.E.Schult. As of the 2026-06-04 WCVP snapshot, this
  name is a **Synonym** - the current accepted name is **Theobroma
  purpureum** Pittier (Malvaceae). Both lists' `wcvp_matched_status`/
  `wcvp_accepted_*` columns are out of date for this one.

## Scope of this check

This was a spot-check of only the 251 species in one BCI leaf-scan dataset,
not a full audit of either list (1505 rows in BCNM, 4095 in
CurrentPanamaWoody). The other 250 species in this check were all still
current against the 2026-06-04 WCVP snapshot, but that doesn't rule out
other stale entries elsewhere in either list - worth a full re-run against
a current WCVP snapshot (`wcvp_match_names()`) next time either list is
refreshed, rather than assuming this is the only one.
