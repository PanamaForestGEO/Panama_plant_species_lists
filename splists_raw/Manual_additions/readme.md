# Manual additions

This directory holds `manual_additions_log.csv`, a running ledger of ad hoc
requests to add a species to the BCNM Botanists Species List outside of a
full rerun of `scripts/species_plantnet.Rmd` — for example, a one-off email
request from a botanist, or a species approved after review of a
`tocheck/panamabiota_not_garwood_*.xlsx` file (see the "Reviewing
Panamabiota-only species" section of the root README).

Unlike the other `splists_raw` subdirectories, this file is not a static
snapshot received from an external source — it is an append-only log
maintained by this project. Rows are only ever added, never edited or
deleted, so each row stays a permanent record of who requested what and
why. `scripts/add_manual_species.R` reads it, WCVP/GBIF-matches any row
that hasn't yet been incorporated, and fills in `date_added_to_bcnm_list`
and `output_file` once it has appended that row to a new dated BCNM list.

## Columns

- `date_requested` — date the addition was requested.
- `orig_name` — species name as requested (binomial + authority in
  `orig_author`).
- `orig_author` — taxonomic authority as given in the request, if known.
- `sp6` — 6-letter ForestGEO code for the species, if one was assigned at
  request time; left blank if not yet assigned.
- `requested_by` — name/role of the person who requested the addition.
- `request_source` — how the request arrived (e.g. "Email to J. Haeder
  2026-08-31").
- `evidence` — why this species belongs on the list (e.g. a source list it
  already appears in, such as Panamabiota, that just hasn't been merged in).
- `notes` — any other relevant detail (e.g. WCVP status/family/lifeform).
- `date_added_to_bcnm_list` — filled in by the script once the row has been
  incorporated into a BCNM list output; blank means still pending.
- `output_file` — the specific `splists_out/BCNM_SPECIES_BOTANISTS_LIST_*.xlsx`
  file the row was first added to.

## Adding a new species

1. Add a new row to `manual_additions_log.csv` with the fields above filled
   in (leave the last two blank).
2. Run `scripts/add_manual_species.R`. It matches any pending rows against
   WCVP and GBIF, appends them to the latest BCNM list, writes a new dated
   output file, and updates the log's last two columns.
3. Note that this only creates an up-to-date output file — it does not
   change what a future full rerun of `species_plantnet.Rmd` produces. See
   the "Manual additions" note near the top of that Rmd for how to fold
   this log's entries back into a full rebuild.
