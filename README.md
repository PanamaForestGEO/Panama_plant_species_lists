# Panama_plant_species_lists

This github repository is intended to provide an up-to-date database of scientific names of plants (mostly woody plants) in Panama, 
together with their 6-letter and 4-letter codes (as used in Smithsonian research), and histories of changes in species names associated with these codes. 

Current files and their provenance:

**Condit-et-al_2020_PanamaTreeSpDataset.pdf** is the dataset description file for Condit et al. 2020 dataset of *tree* species names.  Full bibliographic info: Condit, Richard; Pérez, Rolando; Aguilar, Salomón (2020), Complete Tree Species of Panama, v2, Dataset, https://doi.org/10.15146/R3M97W

**PanamaTreeSpecies.tsv** is part of Condit et al. 2020, as described in Condit-et-al_2020_PanamaTreeSpDataset.pdf. In brief, "A tab-delimited ascii table including a record for 3045 *tree* species we consider native to Panama."
Columns: Family	Latin	Author	countries	minLat	maxLat	minLong	maxLong	Npan	N	range	plots	dens	inventories	maxht

**PanamaTreeNameLookup.tsv** is part of Condit et al. 2020, as described in Condit-et-al_2020_PanamaTreeSpDataset.pdf.  In brief, "A tab-delimited ascii table including a record for 4497 Latin names which we found to be associated with the native *tree* species of Panama, including the 3045 currently accepted names plus 1452 alternate names."
Columns: Family	Latin	Author	ValidLatin	Scope

**nomenclature_R_20210224_Rready.csv** is a file from S. Joseph Wright with Panama plant species codes and info, including *trees, lianas, herbaceous plants, etc.* (2017 rows).  
Columns: sp4	sp6	family	genus	species	deciduous	oldname	climber	free	liana	vine	shrub	understory	midstory	tree	herb	epiphyte	hemiepiphyte	parasite.
Note that all the columns from climber to parasite have entries of 1, 0 or NA.  

**ViewTaxonomy2024-04-30.xlsx** is a file from Suzanne Lao on Panama *tree* species maintained by ForestGEO (1430 rows).
Columns: Family mnemonic	Genus	SpeciesName	Rank Supspecies IDlevel supspMnemonic

**CTFSSpeciesList1.xls** is a file from an unknown source with Panama *tree* species (1362 rows). 
Columns: Family	Genus	species	subspecies	mnemonic	IDlevel	Authority	PriorNames	SpeciesID

**Schnitzer_2019-03_New species names table1.xls** is a BCI *liana* species list from Stefan Schnitzer (223 rows)).
Columns: species (actual)	FINAL SP Codigos	Genus	species	Nombres actualizados	Notas	Nombre original de Stefan	ROLANDO'S Codigos	Unique species codes	error?




