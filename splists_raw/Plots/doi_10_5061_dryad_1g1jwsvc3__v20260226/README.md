# Tree census data for 58 hectares of secondary and old-growth forests at Barro Colorado Island, Panama

Dataset DOI: [10.5061/dryad.1g1jwsvc3](https://doi.org/10.5061/dryad.1g1jwsvc3)

## Description of the data and file structure

Data are presented for three censuses of large trees in six plots on Barro Colorado Island (BCI), Panama (9° 10’ N, 79° 51’ W). Large trees are defined to have a diameter at breast height larger than 200 mm, which includes virtually every tree that reaches the forest canopy at BCI. The six plots cover 58 hectares, and the three censuses include 34,367 measurements of 15,562 trees of 222 species completed over 21 years.

BCI supports tropical moist forest in the Holdridge Life Zone system with a tropical monsoon climate in the Köppen climate classification, mean annual temperature of 26 °C, mean annual rainfall of 2,655 mm, and four drier months whose cumulative rainfall averages 299 mm (Muller-Landau and Wright 2024). BCI also supports secondary and old-growth forest, and disturbance history varies across the six plots (Dent and Elsy 2024, McMichael and Bush 2024). The 6-ha Drayton and Zetek plots support old-growth forest where the most recent widespread disturbance occurred 500 years ago (Dent and Elsy 2024). The BCI 50-ha forest dynamics plot is largely in the same old-growth forest (Piperno 1990). The 6-ha Pearson plot is in secondary forest disturbed 130 to 140 years ago (Dent and Elsy 2024). The 6-ha AVA and 25-ha plots are largely in secondary forest disturbed 90 to 120 years ago (Dent and Elsy 2024). Finally, the 10-ha plot lies along the northern edge of the 50-ha plot and encompasses all three disturbance histories (Dent and Elsy 2024). Meakem et al. (2024) use the 50-ha plot and the first two censuses of the six plots presented here to compare canopy structure, dynamics, and composition of secondary and old-growth forest.

The 2004/05 census was conducted to support a study of seed dispersal by wind. The 2014 census provided initial estimates of growth, mortality, and carbon turnover rates. The 2025 census extended these estimates and supported remote sensing studies. The AVA, Drayton, Pearson, and Zetek plots included canopy towers and seed traps used to document seed dispersal. The 10-ha plot (1,000 by 100 m) extended the 50-ha BCI Forest Dynamics Plot 100 m northwards for canopy trees. The 50-ha plot includes 250 seed traps. Canopy towers are still maintained at plot-level coordinates 100, 100 in the Drayton, Pearson, and Zetek plots. 

References

Dent, DH, A Elsy. 2024. Structure, Diversity, and Composition of Secondary Forests of the Barro Colorado Nature Monument. In *The First 100 Years of Research on Barro Colorado: Plant and Ecosystem Science*, Volume 1, ed. Muller-Landau, HC and SJ Wright, pp. 61–69. Washington, DC: Smithsonian Institution Scholarly Press. [https://doi.org/10.5479/si.26809615](https://doi.org/10.5479/si.26809615)

McMichael, C. N. H. and M. B. Bush. 2024. The Fire History of Old-Growth Forest in the Barro Colorado Nature Monument, Panama. In *The First 100 Years of Research on Barro Colorado: Plant and Ecosystem Science*, Volume 1, ed. Muller-Landau, HC and SJ Wright, pp. 41–46. Washington, DC: Smithsonian Institution Scholarly Press. [https://doi.org/10.5479/si.26814823](https://doi.org/10.5479/si.26814823)

Meakem V, SJ Wright, HC Muller-Landau. 2024. Variation in forest structure, dynamics, and composition across 100 ha of forest plots on Barro Colorado Island. Pages 71-78. In: Muller-Landau HC, Wright SJ (eds) The First 100 Years of Research on Barro Colorado: Plant and Ecosystem Science. Smithsonian Institution Scholarly Press, Washington, DC. [https://doi.org/10.5479/si.26809618](https://doi.org/10.5479/si.26809618).

Muller-Landau HC, Wright SJ (eds). 2024. The First 100 Years of Research on Barro Colorado: Plant and Ecosystem Science. 837 pages. Smithsonian Institution Scholarly Press, Washington, DC.  [https://doi.org/10.5479/si.26048527](https://doi.org/10.5479/si.26048527)

Piperno, DR. 1990. Fitolitos, arquelogia y cambios prehistoricos de la vegetacion en un lote de cincuenta hectáreas de la isla de Barro Colorado. Pages 153–156 in EG Leigh Jr, AS Rand, DM Windsor, eds. Ecologia de un bosque tropical. Smithsonian Institution Press, Washington, D. C., USA.

### Files and variables

#### File: Key_sp6.txt

**Description:** A tab-delimited text file that provides a key to the variable **sp6**. The variable **sp6** identifies trees to species in the main census file ("mainfile.txt"). Helene Muller-Landau updated the nomenclature using the World Checklist of Vascular Plants (WCVP) version 13 on 11 February 2026. The WCVP reduces *Guarea grandifolia* to a synonym of *G. guidonia*. We retain *G. grandifolia* because there are clearly two species in central Panama. The values "unknwn" and "nectsp" indicate  unidentified trees and trees identified to the genus *Nectandra,* respectively. Just five unidentified trees were alive in the 2025 census. These five could not be identified because they were leafless, four having lost their crowns entirely. 

##### Variables

* sp6: six-character species mnemonic used to identify trees to species in the main census file ("mainfile.txt"). There are no missing values.
* sp4: four-character species mnemonic used widely at BCI. Missing values are represented by NA.
* family: plant family. There is one missing value (NA) when **sp6** equals “unknwn”.
* genus: plant genus. There is one missing value (NA) when **sp6** equals “unknwn”.
* species: plant species. There are missing values (NA) when **sp6** equals “unknwn” and “nectsp”.
* subspecies: plant subspecies. The only non-missing values are for two varieties of *Swartzia simplex.*  Missing values are represented by NA.
* author: the authority that described the species. There are missing values (NA) when **sp6** equals “unknwn” and “nectsp”.

#### File: Plot_UTM_coordinates.txt

**Description:** A tab-delimited text file that provides information required to convert plot-level coordinates to Universal Transverse Mercator easting and northing coordinates (UTMs; zone 17N) and vice versa. The information includes the reference southwest corner of each plot for plot-level and UTM coordinate systems and the angle of each plot relative to magnetic north. Note, magnetic north changed by 0.0698 radians between 1980 when the orientation of the 50-ha and 10-ha plots was determined and 2004 when the orientation of the five remaining plots was determined. For the 10-ha and 25-ha plots, the reference southwest corner for plot-level coordinates is the southwest corner of the 50-ha plot.

##### Variables

* Plot: the name of the plot. Values are “10ha”, “25ha”, “AVA”, “Drayton”, “Pearson”, and “Zetek”. There are no missing values.
* SW_UTM_easting: easting UTM coordinate for the southwest corner of the plot (zone 17N). There are no missing values.
* SW_UTM_northing: northing UTM coordinate for the southwest corner of the plot (zone 17N). There are no missing values.
* angle: the angle of the western and eastern boundaries of the plot relative to north. Units are radians. There are no missing values.
* xmin: the minimum value of the local plot-level coordinate in the west-to-east direction. For the 25-ha plot, the reference point (coordinates 0, 0) is the western edge of the BCI 50-ha plot. There are no missing values.
* ymin: the minimum value of the local plot-level coordinate in the south-to-north direction. For the 10-ha and 25-ha plots, the reference point (coordinates 0, 0) is the southern edge of the BCI 50-ha plot. There are no missing values.
* xmax: the maximum value of the local plot-level coordinate in the west-to-east direction. For the 25-ha plot, the reference point (coordinates 0, 0) is the western edge of the BCI 50-ha plot. There are no missing values.
* ymax: the maximum value of the local plot-level coordinate in the south-to-north direction. For the 10-ha and 25-ha plots, the reference point (coordinates 0, 0) is the southern edge of the BCI 50-ha plot. There are no missing values.

#### File: stemfile.txt

**Description:** A tab-delimited text file that provides measurements for each stem for multi-stemmed trees. There are 19,153 observations (rows) of six variables (columns). This stem file and the main census file ("mainfile.txt") can be merged in two steps. First, a unique identifier for each tree, plot, and census combination must be created by combining the shared variables **tag**, **plot**, and **census** (note the same tag number can occur on trees in different plots). Second, the stem and main census files can be merged by this unique identifier. 

##### Variables

* plot: the name of the plot. Values are “10ha”, “25ha”, “AVA”, “Drayton”, “Pearson”, and “Zetek”. There are no missing values.
* census: the year of the census. Values are 2004, 2014, and 2025. The 2004 census started in 2004 and ended in 2005. There are no missing values.
* tag: integer value on an aluminum tag affixed to each tree. Multi-stemmed trees receive a single tag number. Thus, stems cannot be followed across censuses. There are no missing values.
* dbh: integer diameter of each stem. Units are millimeters. There are no missing values.
* code: one or two characters that describe stem condition (e.g., QB). Definitions of the possible characters follow: ‘B’ **hom** should be > 1.3 m; ‘L’ stem leans at more than a 45° angle; ‘R’ stem broken off below 1.3 m (**dbh** is often zero); ‘Q’ more than half of crown lost.  Missing values occur for all stems in the 2004 and 2014 censuses and when none of these definitions apply for the 2025 census. Missing values are represented by NA.
* exposure: five-point scale representing crown exposure to sunlight. Values are 1 for understory trees that only receive direct sunlight from sun flecks, 2 for understory trees with foliage oriented towards canopy gaps that are not directly overhead, 3 for understory trees with more than 10% and less than 90% of foliage under a canopy gap that is directly overhead, 4 for canopy trees whose foliage forms part of the forest canopy, and 5 for emergent trees whose crowns emerge above the continuous forest canopy and whose foliage receives direct sunlight from the sides as well as from above. Missing values occur for all trees in the 2004 and 2014 censuses and when status is “dead” or “missing” in the 2025 census. Missing values are represented by NA.

#### File: mainfile.txt

**Description:** A tab-delimited text file that provides plot-level and Universal Transverse Mercator (zone 17N) coordinates and tree-level measurements for every tree in every census. For multi-stemmed trees, values refer to the tallest stem with the exception of the variable **dbh,** which aggregates stems. There are 46,686 observations (rows) of 15 variables (columns). This main census file and the stem census file ("stemfile.txt") can be merged in two steps. First, a unique identifier for each tree, plot, and census combination must be created by combining the shared variables **tag**, **plot**, and **census** (note the same tag number can occur on trees in different plots). Second, the stem and main census files can be merged by this unique identifier. 

##### Variables

* plot: the name of the plot. Values are “10ha”, “25ha”, “AVA”, “Drayton”, “Pearson”, and “Zetek”. There are no missing values.
* census: the year of the census. Values are 2004, 2014, and 2025. The 2004 census started in 2004, but most trees were censused in 2005 (see the variable **date** for exact dates). There are no missing values.
* tag: integer value on an aluminum tag affixed to each tree. There are no missing values.
* unique.id: a unique identifier for each tree formed by pasting together **plot**, a hyphen, and **tag** (e.g., AVA-19142). Created because the same value of **tag** can occur in different plots.
* sp6: six-character mnemonic for species. The file “Key_sp6.txt” provides a key that links values of **sp6** to full Latin binomials and authorities. There are no missing values.
* status: Values are “future recruit”, “alive”, “missing”, and “dead”. Future recruits first reached the minimum, threshold diameter to be included in 2014 or 2025. Trees that were alive were evaluated for the next five variables. Missing trees were alive in the previous census and not found in the current census. With 10-year census intervals, most missing trees are probably dead. But a handful of trees were overlooked in the 2014 census and found alive in the 2025 census. Dead trees were found dead in 2014 or 2025 or are presumed dead in 2025 if missing in both 2014 and 2025. There are no missing values.
* dbh: integer diameter of tree. Units are millimeters. Diameter is measured at the height given by the variable **hom**. For multiple-stemmed trees, the entry is the diameter of a single stem with basal area equal to the summed basal area of all stems (see the stem file for the diameter of each stem). Missing values occur when status is “future recruits”, “missing”, or “dead” and for 79 observations when status is “alive”. Missing values are represented by NA.
* code: one to four characters that describe tree condition (e.g., BLMQ). Definitions of the possible characters follow: ‘B’ **hom** should be > 1.3 m; ‘D’ dead; ‘L’ main stem leans at more than a 45° angle; ‘M’ multiple stems; ‘N’ missing; ‘R’ main stem broken off below 1.3 m (**dbh** is often zero); ‘Q’ more than half of crown lost; ‘wasps’ prevented **dbh** measurement.  Missing values occur when none of these definitions apply and when status is “future recruits”. Missing values are represented by NA.
* hom: the height at which **dbh** is measured. Units are meters. Missing values occur when status is “future recruits”, “missing”, or “dead” and for 27 observations when status is “alive”. Missing values are represented by NA.
* stems: integer number of stems that cut through a plane at a standard height (1.3 m) above the ground. The accompanying stem file provides the diameter of each stem. Missing values occur when status is “future recruits”, “missing”, or “dead” and for 43 observations when status is “alive”. Missing values are represented by NA.
* date: integer date each tree was censused in YYYYMMDD format. Missing values occur when status is “future recruits” and for 82 observations when status is “alive”. Missing values are represented by NA.
* exposure: five-point scale representing crown exposure to sunlight. Values are 1 for understory trees that only receive direct sunlight during sun flecks, 2 for understory trees with foliage oriented towards canopy gaps that are not directly overhead, 3 for understory trees with more than 10% and less than 90% of foliage under a canopy gap that is directly overhead, 4 for canopy trees whose foliage forms part of the forest canopy, and 5 for emergent trees whose crowns emerge above the continuous forest canopy and whose foliage receives direct sunlight from the sides as well as from above. Missing values occur for all trees in the 2004 and 2014 censuses and when status is “dead” or “missing” in the 2025 census. Missing values are represented by NA.
* px: meters east of the southwest corner of the plot, with east determined by compass. For the 10-ha and 25-ha plots, the southwest corner of the BCI 50-ha plot is used as the reference southwest corner. There are no missing values.
* py: meters north of the southwest corner of the plot, with north determined by compass. For the 10-ha and 25-ha plots, the southwest corner of the BCI 50-ha plot is used as the reference southwest corner. There are no missing values.
* utmx: easting Universal Transverse Mercator (UTM, zone 17N) coordinate. There are no missing values.
* utmy: northing Universal Transverse Mercator (UTM, zone 17N) coordinate. There are no missing values.

## Code/software

The data is comprised of four tab-delimited text files that can be opened with virtually any software.

## Access information

Other publicly accessible locations of the data:

* An earlier data publication included the 2004/05 and 2014 censuses (Wright 2024). The data presented here adds the 2025 census, UTM easting and northing coordinates for each tree, and many corrections to previous location errors and other types of errors. The data published by Wright (2024) should no longer be used.

Reference

Wright, SJ. 2024. Tree census data for the 25-ha, 10-ha and tower plots on Barro Colorado Island, Panama. Smithsonian Research Data Repository. Smithsonian Figshare. [https://doi.org/10.25573/data.24531133](https://doi.org/10.25573/data.24531133).
