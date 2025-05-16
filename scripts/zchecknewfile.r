# zchecknewfile.r

# code to check new versions of taxonomy files, before they 
# are integrated into the main workflow.  

# code by Helene Muller-Landau

library("readxl")
library("writexl")
library("dplyr")
library(tidyr)
library("TNRS")
library("stringi")
library("stringr")

rm(list=ls())

redotnrs <- TRUE  # if this is true, all the TNRS checks are redone 

DIRINSP <- "splists_raw/"
DIRMIDSP <- "splists_mid/"
DIROUTSP <- "splists_out/"
DIRCHECK <- "tocheck/"

FNNEW <- paste0(DIRINSP,"Forestgeo/speciesmaster_2025_HM.xlsx")

newtaxa <- read_excel(FNNEW,col_types="text")

table(table(newtaxa$Codigo_final))
table(newtaxa$Codigo_final)[table(newtaxa$Codigo_final)>1]
table(table(newtaxa$codigo))
table(newtaxa$codigo)[table(newtaxa$codigo)>1]
dupoldcodes <- names(table(newtaxa$codigo)[table(newtaxa$codigo)>1])
table(is.na(newtaxa$Codigo_final))
table(newtaxa$Liana)
table(newtaxa$Orden==trimws(newtaxa$Orden))
table(newtaxa$Familia==trimws(newtaxa$Familia))
table(newtaxa$Genero==trimws(newtaxa$Genero))
table(newtaxa$Especie==trimws(newtaxa$Especie))
newtaxa$binomial <- paste(newtaxa$Genero,newtaxa$Especie)
table(table(newtaxa$binomial))
table(newtaxa$binomial)[table(newtaxa$binomial)>1]
duptaxa <- names(table(newtaxa$binomial)[table(newtaxa$binomial)>1])
temp <- subset(newtaxa,binomial %in% duptaxa) %>% arrange(binomial)
write_xlsx(temp,"tempdupbinomial.xlsx")

newtnrs <- TNRS(unique(sort(newtaxa$binomial)))
table(newtnrs$Name_submitted==newtnrs$Name_matched)
newtnrs$Name_submitted[newtnrs$Name_submitted != newtnrs$Name_matched]
table(newtnrs$Accepted_name==newtnrs$Name_matched)
newtnrs$Name_matched[newtnrs$Accepted_name != newtnrs$Name_matched]

temp2 <- subset(newtnrs,Name_submitted!=Name_matched | Name_matched!=Accepted_name) %>%
  mutate(name_matched_in_tnrs=Name_submitted==Name_matched,
         name_matched_is_accepted=Name_matched==Accepted_name) %>%
  arrange(name_matched_in_tnrs,Name_submitted) %>%
  select(Name_submitted,Name_matched,Accepted_name,
         name_matched_in_tnrs,name_matched_is_accepted,everything())
write_xlsx(temp2,"temptnrsprob.xlsx")

# check that a single genus always has the same family:
genus_check1 <- newtaxa %>%
  group_by(Genero) %>%
  summarise(n_families = n_distinct(Familia), .groups = "drop") %>%
  filter(n_families > 1)
genus_check1
# yes it does

# check that a single family always has the same order:
family_check1 <- newtaxa %>%
  group_by(Familia) %>%
  summarise(n_orders = n_distinct(Orden), .groups = "drop") %>%
  filter(n_orders > 1)
family_check1

table(newtaxa$Codigo_final==tolower(newtaxa$Codigo_final))
table(newtaxa$codigo==tolower(newtaxa$codigo))
newtaxa$codigo[newtaxa$codigo!=tolower(newtaxa$codigo)&!is.na(newtaxa$codigo)]

table(nchar(newtaxa$Codigo_final))
newtaxa$Codigo_final[nchar(newtaxa$Codigo_final)>6]
newtaxa$Codigo_final[nchar(newtaxa$Codigo_final)<6]
temp3 <- subset(newtaxa,!is.na(Codigo_final) & nchar(Codigo_final)!=6)

newtaxa$genuscode <- substr(newtaxa$Codigo_final,1,4)


table(newtaxa$Especie=="sp.")
table(is.na(newtaxa$Especie))

table(newtnrs$Name_submitted==newtnrs$Name_accepted)
