# sp6 duplicates and a likely synonym-table error found (2026-08-31)

Found while matching STRI herbarium specimens (Panama collections) against
`splists_out/CurrentPanamaWoody_2026-04-11.xlsx` and its companion
`splists_mid/alternates_and_synonyms/CurrentPanamaWoody_SYNONYMS_2026-04-11.xlsx`,
for the `../Herbarium` project (see `../Herbarium/matching_notes.md` for that
analysis). Built an alias table of every name associated with each sp6
(`orig_binomial`, `wcvp_matched_name`, `wcvp_accepted_binomial` from the List
sheet, plus `orig_name`/`SynonymTextSingle` from the synonyms file) to match
herbarium determinations to species, and found 13 name strings that
ambiguously map to **two different sp6 codes**. Checked each individually —
they're not all the same kind of issue.

## 1. True duplicate entries — same species, listed twice

Same `orig_binomial` and same `wcvp_accepted_binomial`, under two different
sp6 codes. Looks like a merge artifact from combining multiple source lists
without full deduplication. Candidates to collapse to a single sp6:

| Species | sp6 codes | Notes |
|---|---|---|
| *Inga ciliata* | `ingaci`, `ingac1` | Different `orig_family` values: "Fabaceae" vs "Fabaceae-mimosoideae" |
| *Pouteria glomerata* | `poutgl`, `poutg1` | Identical in every checked field |
| *Sorocea pubivena* | `sorop1`, `soropu` | Identical in every checked field |
| *Swartzia simplex* | `swars1`, `swars2` | Identical in every checked field |

## 2. Unmerged old-name / current-name pairs

Two different original entries (different `orig_binomial`, likely from
different source lists) that both WCVP-resolve to the same accepted species.
Not wrong, but redundant — each pair is probably meant to be one sp6 with
the other name recorded as a synonym, not two separate sp6 codes.

| Original name A | Original name B | Both accepted as |
|---|---|---|
| *Cestrum haberi* (`cestha`) | *Cestrum rugulosum* (`cestru`) | *Cestrum rugulosum* |
| *Guarea grandifolia* (`guargr`) | *Guarea guidonia* (`guargu`) | *Guarea guidonia* |
| *Tournefortia bicolor* (`tourbi`) | *Heliotropium verdcourtii* (`tourhi`) | *Heliotropium verdcourtii* |
| *Neea laetevirens* (`neeala`) | *Neea psychotrioides* (`neeaps`) | *Neea psychotrioides* |
| *Passiflora panamensis* (`passpa`) | *Passiflora vitifolia* (`passvi`) | *Passiflora vitifolia* |

## 3. Likely error: sp6 `prott2` cross-linked to an unrelated family

`prott2`'s own row in the List sheet: `orig_binomial` = "Protium
tenuifolium" (Burseraceae), `wcvp_accepted_binomial` = **Protium mcleodii**.

But the synonyms file *also* lists `prott2` as a synonym entry for
**Picramnia latifolia** (Picramniaceae) — an unrelated family. That
cross-reference looks like a data-entry error in the synonym table, not a
real taxonomic relationship.

Separately, and adding to the confusion: the literal name string "Protium
tenuifolium" is the `orig_binomial` for **two** different sp6 codes with two
different accepted-name resolutions:
- `protte`: orig_binomial "Protium tenuifolium" → accepted as itself, *Protium tenuifolium*
- `prott2`: orig_binomial "Protium tenuifolium" → accepted as *Protium mcleodii*

Worth a manual look at both `prott2` rows (List sheet + synonyms file) to
confirm which accepted name is correct and fix/remove the Picramnia
cross-link.

## 4. Possible genuine taxonomic homonym — needs a botanist's call, not obviously an error

"Psychotria pubescens" appears in the synonyms file as a synonym for **two**
different currently-accepted species:
- `psycpu` → accepted as *Palicourea hebeclada*
- `palipb` → accepted as *Palicourea pubescens*

This could be a real historical case of one name having been applied to two
different plants before they were taxonomically split (not uncommon), rather
than a data error — didn't have the expertise to resolve this one, flagging
for review rather than guessing.

## Scope of this check

This was a byproduct of matching herbarium names against the woody list, not
a dedicated audit — it only surfaces sp6 duplication that happens to matter
for herbarium name-matching (i.e. cases where two sp6 codes share an
overlapping name across `orig_binomial`/`wcvp_matched_name`/
`wcvp_accepted_binomial`/synonym text). It would not catch a duplicate pair
that has *no* name in common (e.g. two identical taxa entered under two
completely different original names with no shared synonym record), nor any
sp6 that's simply wrong/mismatched without being duplicated. A full
dedup/QC pass on the 4,095-row list would need to check by
`wcvp_accepted_plant_name_id` directly rather than by name-string overlap.
