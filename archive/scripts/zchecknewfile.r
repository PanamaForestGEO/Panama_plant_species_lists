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
library(taxize)


rm(list=ls())

redotnrs <- TRUE  # if this is true, all the TNRS checks are redone 

DIRINSP <- "splists_raw/"
DIRMIDSP <- "splists_mid/"
DIROUTSP <- "splists_out/"
DIRCHECK <- "tocheck/"

FNNEW <- paste0(DIRINSP,"PanamaWoodySpLists/2025-09-08FromSuzanne/FloraPanama_8Sept25.xlsx")

newtaxa <- read_excel(FNNEW,col_types="text")
names(newtaxa)

# check for duplicate codes
table(table(newtaxa$Spcode))
table(newtaxa$Spcode)[table(newtaxa$Spcode)>1]
dupcodes <- names(table(newtaxa$Spcode)[table(newtaxa$Spcode)>1])

table(newtaxa$Liana)

table(newtaxa$Order==trimws(newtaxa$Order))
table(newtaxa$Family==trimws(newtaxa$Family))
table(newtaxa$Genus==trimws(newtaxa$Genus))
table(newtaxa$Species==trimws(newtaxa$Species))

# check for duplicate species names
newtaxa$binomial <- paste(newtaxa$Genus,newtaxa$Species)
table(table(newtaxa$binomial))
table(newtaxa$binomial)[table(newtaxa$binomial)>1]
newtaxa$fullname <- ifelse(is.na(newtaxa$Subspecies),newtaxa$binomial,
                           paste(newtaxa$binomial," ",newtaxa$Subspecies))
table(table(newtaxa$fullname))
table(newtaxa$fullname)[table(newtaxa$fullname)>1]
duptaxa <- names(table(newtaxa$fullname)[table(newtaxa$fullname)>1])
temp <- subset(newtaxa,fullname %in% duptaxa) %>% arrange(fullname)
write_xlsx(temp,"tocheck/tempfullnamepansp.xlsx")

namestocheck <- sort(unique(newtaxa$binomial))

# find any names with question marks in them
names_with_qmark <- grep("\\?", namestocheck, value = TRUE)
names_with_qmark

# find any names with "sp." in them
names_with_sp. <- grep("sp\\.", namestocheck, value = TRUE)
names_with_sp.

# using TNRS to check names
newtnrs <- TNRS(namestocheck)
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
temp2$dateTNRS <- Sys.Date()
write_xlsx(temp2,"tocheck/temptnrsprobpansp.xlsx")

# had trouble using taxize because of length of dataset
# instead just doing this on the ones that were flagged by TNRS, for a second opinion
taxadatasources <- c(1,12,165,167,197) # 1 and 12 are defaults - Catalogue of Life and Encyclopedia of Life
# 165 is Tropicos, 167 is International PLant Names Index, 197 is World Checklist of Vascular Plants
countsbydatasource <- data.frame(datasource=taxadatasources,namesmatched=NA,namesaccepted=NA)
for (j in 1:length(taxadatasources)) {
  for (i in 1:nrow(temp2)) {
    tempi <- gna_verifier(temp2$Name_submitted[i],data_sources=taxadatasources[j])
    if (i==1) temp2t <- tempi else temp2t <- rbind(temp2t, tempi)
  }
  temp2t$name_matched_in_taxize <- temp2t$submittedName==temp2t$matchedCanonicalSimple
  temp2t$name_matched_is_accepted <- temp2t$matchedCanonicalSimple==temp2t$currentCanonicalSimple
  
  # reorder column names
  firstcols <- c("submittedName", "matchedCanonicalSimple", "currentCanonicalSimple",
                 "name_matched_in_taxize","name_matched_is_accepted")
  others <- setdiff(names(temp2t), firstcols)
  temp2t <- temp2t[c(firstcols, others)]
#  temp2t <- temp2t %>%
#    arrange(name_matched_in_taxize,
#            name_matched_is_accepted,
#            submittedName)
  countsbydatasource$namesmatched[j]=length(temp2t$name_matched_in_taxize[temp2t$name_matched_in_taxize==T])
  countsbydatasource$namesaccepted[j]=length(temp2t$name_matched_is_accepted[temp2t$name_matched_is_accepted==T])
  write_xlsx(temp2t,paste0("tocheck/temptaxizeprobpansp",j,".xlsx"))
}
countsbydatasource
# for 17 names that didn't pass TNRS on Sept 8, 2025
#datasource namesmatched namesaccepted
#1          1           15             9
#2         12           16             0
#3        165           14             0
#4        167           17             0
#5        197           16            13

# just 10 names not current according to taxize, and looking at these in more detail
# it seems these are all debatable.  

# 1  Catalogue of Life 
# 12 Encyclopedia of Life
# 165 is Tropicos, 
# 167 is International PLant Names Index, 
# 197 is World Checklist of Vascular Plants

# check that a single genus always has the same family:
genus_check1 <- newtaxa %>%
  group_by(Genus) %>%
  summarise(n_families = n_distinct(Family), .groups = "drop") %>%
  filter(n_families > 1)
genus_check1
# yes it does

# check that a single family always has the same order:
family_check1 <- newtaxa %>%
  group_by(Family) %>%
  summarise(n_orders = n_distinct(Order), .groups = "drop") %>%
  filter(n_orders > 1)
family_check1

table(newtaxa$Spcode==tolower(newtaxa$Spcode))

table(nchar(newtaxa$Spcode))
newtaxa$Spcode[nchar(newtaxa$Spcode)!=6]

newtaxa$genuscode <- substr(newtaxa$Spcode,1,4)


############ checking prior list ##########################

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
write_xlsx(temp,"tocheck/tempdupbinomialfgeo.xlsx")

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
write_xlsx(temp2,"tocheck/temptnrsprobfgeo.xlsx")

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
