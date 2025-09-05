**Wright** This subdirectory contains files of plant species that appear in the seed, seedling, and other datasets collected in Panama under the supervision of S. Joseph Wright, together with the 4-letter species codes used in these studies and often corresponding 6-letter species codes.  Include some non-woody species and morphospecies.  Files are organized by date, from most recent (current) to older

**Wright/nomenclature_R_20210224_Rready_fixed.xlsx** is a modification of the file below to change format and avoid problems with code conversions to dates.

**Wright/nomenclature_R_20210224_Rready.csv** is a file from S. Joseph Wright with Panama plant species codes and info, including *trees, lianas, herbaceous plants, etc.* (2036 rows).  
Columns: sp4	sp6	family	genus	species	deciduous	oldname	climber	free	liana	vine	shrub	understory	midstory	tree	herb	epiphyte	hemiepiphyte	parasite.
Note that all the columns from climber to parasite have entries of 1, 0 or NA.  
WARNING: importing this file into Excel will automatically change some species codes to dates
