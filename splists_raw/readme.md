Original species files and their provinence:

**Forestgeo/Condit-et-al_2020_PanamaTreeSpDataset.pdf** is the dataset description file for Condit et al. 2020 dataset of *tree* species names.  
Full bibliographic info: Condit, Richard; Pérez, Rolando; Aguilar, Salomón (2020), Complete Tree Species of Panama, v2, Dataset, https://doi.org/10.15146/R3M97W

**Forestgeo/PanamaTreeSpecies.tsv** is part of Condit et al. 2020, as described in Condit-et-al_2020_PanamaTreeSpDataset.pdf. 
In brief, "A tab-delimited ascii table including a record for 3045 *tree* species we consider native to Panama."
Columns: Family	Latin	Author	countries	minLat	maxLat	minLong	maxLong	Npan	N	range	plots	dens	inventories	maxht

**Forestgeo/PanamaTreeNameLookup.tsv** is part of Condit et al. 2020, as described in Condit-et-al_2020_PanamaTreeSpDataset.pdf.  
In brief, "A tab-delimited ascii table including a record for 4497 Latin names which we found to be associated with the native *tree* species of Panama, including the 3045 currently accepted names plus 1452 alternate names."
Columns: Family	Latin	Author	ValidLatin	Scope

**Forestgeo/ViewTaxonomy2024-04-30.xlsx** is a file from Suzanne Lao on Panama *tree* species maintained by ForestGEO (1430 rows).
Columns: Family mnemonic	Genus	SpeciesName	Rank Supspecies IDlevel supspMnemonic

**Forestgeo/ViewTaxonomy2024-09-10HM.xlsx** is a file from Suzanne Lao on Panama *tree* species maintained by ForestGEO (1430 rows).  Suffix HM indicates minor manual modifications by Helene Muller-Landau to improve read-in to R. 
Columns: Family mnemonic	Genus	SpeciesName	Rank Supspecies IDlevel supspMnemonic

**Forestgeo/CTFSSpeciesList1.xls** is a file from an unknown source with Panama *tree* species (1362 rows). 
Columns: Family	Genus	species	subspecies	mnemonic	IDlevel	Authority	PriorNames	SpeciesID

**Forestgeo/Rolando Pérez, Salomón Aguilar y David Mitre, Lista de árboles, arbustos y palmas  de la flora de Panamá, marzo 2025.xls** is a file obtained from Rolando Pérez in March 2025 (3070 rows).
Contains current names, synonyms, and 6-letter codes for all tree and shrub species of Panama.  
Columns: ORDEN	FAMILIA APG	ESPECIE 	AUTORIDAD	SINONIMOS	CODIGO	HERBARIO (PMA,SCZ).

**Forestgeo/Rolando Pérez, Salomón Aguilar y David Mitre, Lista de Lianas y enredaderas de la flora de Panamá, marzo 20255.xls** is a file obtained from Rolando Pérez in March 2025 (763 rows).
Contains current names, synonyms, and 6-letter codes for all liana and vine species of Panama.  
Columns: ORDEN	FAMILIA APG	ESPECIE 	AUTORIDAD	SINONIMOS	CODIGO	HERBARIO (PMA,SCZ).

**Forestgeo/Perez-et-al_PanamaPlantSp_2025-03.xlsx** is a file manually combining the data from the prior two files into one file (3833 rows).
Columns: ORDEN	FAMILIA_APG	ESPECIE 	AUTORIDAD	SINONIMOS	CODIGO	HERBARIO_PMA_SCZ	Habit

**Wright/nomenclature_R_20210224_Rready.csv** is a file from S. Joseph Wright with Panama plant species codes and info, including *trees, lianas, herbaceous plants, etc.* (2036 rows).  
Columns: sp4	sp6	family	genus	species	deciduous	oldname	climber	free	liana	vine	shrub	understory	midstory	tree	herb	epiphyte	hemiepiphyte	parasite.
Note that all the columns from climber to parasite have entries of 1, 0 or NA.  
WARNING: importing this file into Excel will automatically change some species codes to dates.  

**Schnitzer_2019-03_New species names table1.xls** is a BCI *liana* species list from Stefan Schnitzer (223 rows).
Columns: species (actual)	FINAL SP Codigos	Genus	species	Nombres actualizados	Notas	Nombre original de Stefan	ROLANDO'S Codigos	Unique species codes	error?

**AguaSalud/AgauSaludspecies_2025-01-19.csv** is an Agua Salud woody plant species list from Michiel van Breugel (644 rows).
Columns: specid	family	genus	species	GF
