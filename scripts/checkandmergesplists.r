# checkandmergesplists.r

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

# input files # all in director DIRINSP
FNWRIGHTSPLISTIN <- "Wright/nomenclature_R_20210224_Rready_fixed.xlsx"
FNFGEOSPLISTIN <- "Forestgeo/2025-11-17FromSuzanne/ViewTaxonomy_bci.xlsx"
FNPANAMASPLISTIN <- "PanamaWoodySpLists/2025-09-08FromSuzanne/FloraPanama_8Sept25.xlsx"

# output files 
FNWRIGHTSPLISTTNRS <- paste0(DIRMIDSP,tools::file_path_sans_ext(basename(FNWRIGHTSPLISTIN)),"_tnrs.xlsx")
FNFGEOSPLISTTNRS <- paste0(DIRMIDSP,tools::file_path_sans_ext(basename(FNFGEOSPLISTIN)),"_tnrs.xlsx")
FNPANAMASPLISTTNRS <- paste0(DIRMIDSP,tools::file_path_sans_ext(basename(FNPANAMASPLISTIN)),"_tnrs.xlsx")
FNPANAMASPCOMB <- paste0(DIROUTSP,"PanamaSpCombined_",Sys.Date(),".xlsx")
FNSYNONYMS <- paste0(DIROUTSP,"Synonyms_",Sys.Date(),".xlsx")
FNPANAMATAXA <- paste0(DIROUTSP,"AllTaxa_",Sys.Date(),".xlsx")
# the last is the list of all unique accepted species, genera, and families for photo labeling

tnrscols <- c("Name_matched","Name_matched_rank","Accepted_name","Accepted_name_author",
              "Accepted_name_rank","Accepted_family")
tnrscols2 <- c("Name_submitted",tnrscols)
tnrscols3 <- c("binomial",tnrscols)
tnrscols4 <- c("Current_name",tnrscols)

###########################################

# Joe Wright's taxonomy dataset (includes 4-letter codes and some non-woody species as well as trees and lianas)
if (file.exists(FNWRIGHTSPLISTTNRS) & !redotnrs) {
  usejoetaxa <- read_excel(FNWRIGHTSPLISTTNRS) 
} else {
  joetaxa <- read_excel(paste0(DIRINSP,FNWRIGHTSPLISTIN))
  joetaxa <- joetaxa[,1:21]
  joetaxa <- mutate(joetaxa,
                    sp6=ifelse(sp6=="na",NA,sp6),
                    binomialorig=gsub("_"," ",binomialorig))
  joetaxa <- rename(joetaxa,
                    binomial=binomialorig)
  sp6dupsj <- joetaxa %>% filter(!is.na(sp6)) %>% group_by(sp6) %>% filter(n()>1) %>% ungroup()
  binomialdupsj <- joetaxa %>% group_by(binomial) %>% filter(n()>1) %>% 
    ungroup() %>% arrange(binomial)
  # no duplicates
  joetaxatnrs <- TNRS(joetaxa$binomial)
  joetaxatnrs <-rename(joetaxatnrs,binomial=Name_submitted)
  usejoetaxa <- left_join(joetaxa,joetaxatnrs[,tnrscols3],by="binomial")
  usejoetaxa$tnrsdate <- Sys.Date()
  write_xlsx(usejoetaxa,FNWRIGHTSPLISTTNRS)
  rm(joetaxa,sp6dupsj,binomialdupsj,joetaxatnrs)
}

#################################################

# ForestGEO dataset of taxonomy for species codes used in Panama plot censuses - includes morphospecies
if (file.exists(FNFGEOSPLISTTNRS) & !redotnrs) {
  fgeotaxa <- read_excel(FNFGEOSPLISTTNRS) 
} else {
  treetaxa <- read_excel(paste0(DIRINSP,FNFGEOSPLISTIN))
  treetaxa <- rename(treetaxa,
                     sp6=Mnemonic)
  sp6dups <- treetaxa %>% group_by(sp6) %>% filter(n()>1) %>% ungroup()
  # these sp6dups are all cases of subspecies, so ignore
  treetaxa <- subset(treetaxa, !duplicated(sp6))
  treetaxa <- mutate(treetaxa,
                     binomial=paste(Genus,SpeciesName))
  treetaxa <- mutate(treetaxa,
                     binomial=ifelse(Genus=="Unidentified",paste(Genus,sp6),binomial))
  treetaxa$binomial <- stri_trans_general(treetaxa$binomial,"Latin-ASCII")
  binomialdups <- treetaxa %>% group_by(binomial) %>% filter(n()>1) %>% ungroup() %>% arrange(binomial)
  treetaxauniqbinomial <- subset(treetaxa,!duplicated(binomial)) # for matching on binomials 
  
  treetaxatnrs <- TNRS(treetaxauniqbinomial$binomial)
  treetaxatnrs <-rename(treetaxatnrs,binomial=Name_submitted)
  fgeotaxa <- left_join(treetaxauniqbinomial,treetaxatnrs[,tnrscols3],by="binomial")
  fgeotaxa$tnrsdate <- Sys.Date()
  write_xlsx(fgeotaxa,FNFGEOSPLISTTNRS)
  rm(treetaxa,sp6dups,binomialdups,treetaxauniqbinomial,treetaxatnrs)
}

#####################
# ForestGEO Panama woody plant species list 
read_excel(paste0(DIRINSP,FNPANAMASPLISTIN),col_types="text")  %>%
  rename(Current_order=Order,
         Current_family=Family,
         Current_genus=Genus,
         Current_species=Species,
         Current_name_author=Authority,
         Current_subspecies=Subspecies,
         synonyms=Synonyms,
         sp6curr=Spcode,
         vouchers=Herbarium,
         habit=Liana) %>%
  mutate(sp6curr=tolower(sp6curr),
         habit=ifelse(habit=="l","Climbing","Freestanding"),
         Current_name=ifelse(is.na(Current_subspecies),
                                paste0(Current_genus," ",Current_species),
                                paste0(Current_genus," ",Current_species," ",Current_subspecies))) %>%
  mutate(habit=ifelse(is.na(habit),"Freestanding",habit),
         sp6prior=fgeotaxa$sp6[match(Current_name,fgeotaxa$binomial)]) -> 
  alltaxa

# fix problems matching on binomial for these subspecies
alltaxa$sp6prior[alltaxa$sp6curr=="swars1"] <- "swars1"
alltaxa$sp6prior[alltaxa$sp6curr=="swars2"] <- "swars2"

# check for duplicate binomials and address if needed
bindups <- alltaxa %>% group_by(Current_name) %>% arrange(Current_name) %>% filter(n()>1) %>% ungroup()
if (nrow(bindups)>0) 
  {
  write_xlsx(bindups,paste0(DIRCHECK,"FloraPanamanombreduplicado.xlsx"))
# currently no duplicates!
# previously, I manually went through and picked one of the entries as correct for each duplicated Current_name
# exception is Swartzia simplex, where both are good
  alltaxa <- filter(alltaxa, !Current_name %in% bindups$Current_name)
  gooddups <- read_excel(paste0(DIRCHECK,"FloraPanamanombredup_touse.xlsx"))
  alltaxa <- rbind(alltaxa,gooddups)
}

# check for changed sp6 codes
sp6dif <- subset(alltaxa,!is.na(sp6curr) & !is.na(sp6prior) & sp6curr!=sp6prior)
write_xlsx(sp6dif,paste0(DIRCHECK,"FloraPanamacodigocambio.xlsx"))

# check for duplicate sp6 codes
sp6dups <- alltaxa %>% filter(!is.na(sp6curr)) %>% group_by(sp6curr) %>% 
  arrange(sp6curr) %>% filter(n()>1) %>% ungroup()
write_xlsx(sp6dups,paste0(DIRCHECK,"FloraPanamacodigoduplicado.xlsx"))

# check for sp6 codes not 6 letters (typos or morphospecies)
sp6not6char <- subset(alltaxa,nchar(sp6curr)!=6&!is.na(sp6curr))
write_xlsx(sp6not6char,paste0(DIRCHECK,"FloraPanamasp6not6char.xlsx"))

sp6dupscurr <- names(table(alltaxa$sp6curr))[table(alltaxa$sp6curr)>1]
sp6dupsprior <- names(table(alltaxa$sp6prior))[table(alltaxa$sp6prior)>1]

alltaxa <- alltaxa %>% 
  mutate(sp6=ifelse((sp6curr %in% sp6dupscurr & !sp6prior %in% sp6dupscurr) | 
                      (nchar(sp6curr)!=6 & nchar(sp6prior)==6 & !is.na(sp6prior)),
                    sp6prior,sp6curr)) 
sp6dupsnew <- names(table(alltaxa$sp6))[table(alltaxa$sp6)>1]

sp6probleft <- subset(alltaxa,
                      !is.na(sp6) & ((!is.na(sp6prior) & sp6curr!=sp6prior) | 
                                          nchar(sp6)!=6 | sp6 %in% sp6dupsnew)) %>%
  arrange(sp6)
write_xlsx(sp6probleft,paste0(DIRCHECK,"FloraPanamasp6prob.xlsx"))

# following not currently needed because there were no sp6dups to begin with
sp6dupsleft <- alltaxa %>% 
  filter(!is.na(sp6)) %>% 
  group_by(sp6) %>% 
  arrange(sp6) %>% 
  filter(n()>1) %>% ungroup()
# there are still no duplicated sp6 codes after this  


if (file.exists(FNPANAMASPLISTTNRS) & !redotnrs) {
  alltaxaplus <- read_excel(FNPANAMASPLISTTNRS) 
} else {
  alltaxatnrs <- TNRS(alltaxa$Current_name)
  table(alltaxatnrs$Name_submitted==alltaxatnrs$Name_matched)
  alltaxatnrs <-rename(alltaxatnrs,Current_name=Name_submitted)
  alltaxaplus <- left_join(alltaxa,alltaxatnrs[,tnrscols4],by="Current_name")
  alltaxaplus$tnrsdate <- Sys.Date()
  write_xlsx(alltaxaplus,FNPANAMASPLISTTNRS)
} 
as.data.frame(alltaxaplus[alltaxaplus$Current_name!=alltaxaplus$Name_matched,])

namedifsp <- alltaxaplus %>% 
  filter(Current_name!=Name_matched & 
           Name_matched_rank %in% c("species","subspecies","variety")) %>%
  dplyr::select(Current_name,Name_matched,Accepted_name,sp6curr,sp6prior,sp6) 
write_xlsx(namedifsp,paste0(DIRCHECK,"FloraPanamanombreserrores.xlsx"))
# none at present  
if (nrow(namedifsp)>0) {
  alltaxaplus <- alltaxaplus %>% 
    mutate(currnamechanged=Current_name %in% namedifsp$Current_name) %>%
    mutate(Current_name=ifelse(Current_name %in% namedifsp$Current_name, Name_matched, Current_name))

} else
  alltaxaplus <- mutate(alltaxaplus,currnamechanged=F)

sp6added <- subset(alltaxaplus,!sp6 %in% fgeotaxa$sp6 & 
                     !is.na(sp6) & 
                     Accepted_name_rank %in% c("species","subspecies","variety"))

# In some few cases, for mysterious reasons, TNRS matches the name but does not associate an accepted name. 
# In these cases, use the matched name as the accepted name.
inc <- alltaxaplus$Accepted_name==""
if (length(inc[inc==T&!is.na(inc)])>0) {
  table(inc)
  temp <- alltaxaplus[inc,]
  alltaxaplus$Accepted_name[inc] <- alltaxaplus$Name_matched[inc]
  alltaxaplus$Accepted_name_rank[inc] <- alltaxaplus$Name_matched_rank[inc]
  alltaxaplus$Accepted_name_author[inc] <- ifelse(alltaxaplus$Accepted_name[inc]==alltaxaplus$Name_matched[inc],
                                                  alltaxaplus$Current_name_author[inc],NA)
}


# check for 6-letter codes in the Fgeo codes list that are not in the Panama woody plant species list
# but that are for good species
sp6dropped <- subset(fgeotaxa,!sp6 %in% alltaxa$sp6 & 
                       Accepted_name_rank %in% c("species","subspecies","variety")
                     &IDLevel=="species") %>%
  mutate(binomial_in_flora=binomial %in% alltaxa$Current_name) %>%
  arrange(sp6)
firstcols <- c("sp6", "binomial", "binomial_in_flora")
sp6dropped <- sp6dropped[c(firstcols,setdiff(names(sp6dropped),firstcols))]
write_xlsx(sp6dropped,paste0(DIRCHECK,"FloraPanamacodigosperdidos.xlsx"))


# add sp4 codes from Wright list
table(table(usejoetaxa$sp4)) # 938 unique sp4 codes
table(usejoetaxa$Name_matched_rank,is.na(usejoetaxa$sp4)) # most of them for taxa with species-level IDs
table(usejoetaxa$Accepted_name_rank,is.na(usejoetaxa$sp4)) # most of them for taxa with species-level IDs
as.data.frame(subset(usejoetaxa,Accepted_name_rank %in% c("variety","subspecies") | 
              Name_matched_rank %in% c("variety","subspecies")))
m1 <- ifelse(is.na(alltaxaplus$sp6),NA,
             match(alltaxaplus$sp6,usejoetaxa$sp6))
table(table(m1))
m1dups <- as.numeric(names(table(m1)[table(m1)>1]))
usejoetaxa[m1dups,c("sp4","Accepted_name")]
m2 <-ifelse(is.na(alltaxaplus$Accepted_name),NA,
            match(alltaxaplus$Accepted_name,usejoetaxa$Accepted_name))
table(m1==m2)
m2 <- ifelse(m2 %in% m1 | 
               !usejoetaxa$Accepted_name_rank[m2] %in% c("species","subspecies","variety") ,
             NA,m2)
table(m1==m2)
m2dups <- as.numeric(names(table(m2)[table(m2)>1]))
usejoetaxa[m2dups,c("sp4","Accepted_name","Accepted_name_rank")]
table(table(m2))
table(is.na(m1),is.na(m2))
m3 <- ifelse(!is.na(m1),m1,m2)
m3dups <- as.numeric(names(table(m3)[table(m3)>1]))
usejoetaxa[m3dups,c("sp4","sp6","Accepted_name")]
alltaxaplus$sp4 <-usejoetaxa$sp4[m3]
alltaxaplus$sp4[alltaxaplus$sp6=="swars1"] <- "SWA1"
alltaxaplus$sp4[alltaxaplus$sp6=="swars2"] <- "SWA2"
alltaxaplus$sp4[alltaxaplus$sp6=="guargr"] <- "GUA1"
alltaxaplus$sp4[alltaxaplus$sp6=="guargu"] <- "GUA2"
alltaxaplus$sp4[alltaxaplus$sp6=="quaras"] <- "QUA1"# BCI Quararibea was formerly known as asterolepis, but is now stenophylla
alltaxaplus$sp4[alltaxaplus$sp6=="quara1"] <- NA  # BCI Quararibea was formerly known as asterolepis, but is now stenophylla
sp4dups <- names(table(alltaxaplus$sp4)[table(alltaxaplus$sp4)>1])
table(table(alltaxaplus$sp4))
# no longer any duplicates



outtaxaplus <- alltaxaplus %>% 
  mutate(acceptednamedif = Current_name!=Accepted_name,
         sp6changed = sp6!= sp6curr | sp6 != sp6prior) %>%
  dplyr::select("sp6","sp4","Current_name","Current_name_author",
                "Current_order","Current_family",
                "Current_genus","Current_species","Current_subspecies",
                "Accepted_name","Accepted_name_author","Accepted_name_rank",
                "Accepted_family",
                "habit",
                "synonyms","vouchers",
                "sp6curr","sp6prior",
                "sp6changed","currnamechanged","acceptednamedif",
                "tnrsdate") %>%
  arrange(Current_name) %>%
  mutate(notes=paste0(ifelse(is.na(currnamechanged) | !currnamechanged,
                            "","Spelling corrected in Current_name. "),
                     ifelse(is.na(sp6changed) | ! sp6changed,
                            "","Code sp6 changed from sp6curr or sp6prior. "),
                     ifelse(is.na(acceptednamedif) | !acceptednamedif,
                            "","Current_name differs from Accepted_name returned by TNRS. "))) 
write_xlsx(outtaxaplus,FNPANAMASPCOMB)


# check taxa that are matched at genera or higher rather than species
as.data.frame(subset(alltaxaplus,!Accepted_name_rank %in% c("species","subspecies","variety")))

# do not remove these at present as current name matched is species level, and this seems to be a TNRS fail
#allsp <- subset(alltaxaplus,
#                Accepted_name_rank %in% c("species","subspecies","variety"))
allsp <- alltaxaplus

acceptednamedups <- allsp %>% 
  group_by(Accepted_name) %>% 
  arrange(Accepted_name) %>% filter(n()>1) %>% ungroup()

namenotaccepted <- subset(allsp,Name_matched!=Accepted_name)
write_xlsx(namenotaccepted,paste0(DIRCHECK,"Perezlistnombrenoacceptado.xlsx"))
namenotaccepted
# few are different from current accepted name.  So use the Current name in this list.  
table(allsp$Name_matched==allsp$Accepted_name,
      allsp$Accepted_name %in% acceptednamedups$Accepted_name)

allsp %>% mutate(Accepted_genus=word(Accepted_name,1),
       orig_genus=word(Current_name,1),
       genuscode=ifelse(is.na(sp6),NA,substr(sp6,1,4))) -> allsp

# check that a single genus always has the same family:
genus_check1 <- allsp %>%
  filter(Accepted_family!="") %>%
  group_by(Accepted_genus) %>%
  summarise(n_families = n_distinct(Accepted_family), .groups = "drop") %>%
  filter(n_families > 1)
genus_check1

# check whether a single genus always has the same lifeform:
genus_check2 <- allsp %>%
  group_by(Accepted_genus) %>%
  summarise(n_families = n_distinct(Current_family), .groups = "drop") %>%
  filter(n_families > 1)
genus_check2

# check that a single genus always has the same first 4 letters of species code:
genus_check3 <- allsp %>%
  group_by(Accepted_genus) %>%
  summarise(n_genuscode = n_distinct(genuscode), 
            genuscode_list = paste(sort(unique(genuscode)), collapse = ", "),
            .groups = "drop") %>%
  filter(n_genuscode > 1)
genus_check3
# in many cases it doesn't but it looks like this is due to name changes for the most part except perhaps
# Maripa: mari and mar2

# find cases where same genuscode corresponds to more than 1 Accepted genus
genus_check4 <- allsp %>%
  group_by(genuscode) %>%
  summarise(
    Accepted_gen4_list = paste(sort(unique(substr(Accepted_genus,1,4))),collapse=", "),
    Accepted_gen3_list = paste(sort(unique(substr(Accepted_genus,1,3))),collapse=", "),
    n_Accepted_genus = n_distinct(Accepted_genus),
    Accepted_genus_list = paste(sort(unique(Accepted_genus)), collapse = ", "),
    .groups = "drop"
  ) %>%
  filter(n_Accepted_genus > 1)

# just get cases in which there are multiple genus names that have the same first 3 letters as the genus code:  
genus_check5 <- allsp %>%
  filter(!is.na(genuscode)) %>%
  mutate(prefix3 = substr(genuscode, 1, 3),
         genus_prefix3 = tolower(substr(Accepted_genus, 1, 3))) %>%
  # keep only genus names matching the first 3 letters of genuscode
  filter(genus_prefix3 == prefix3) %>%
  group_by(genuscode) %>%
  summarise(
    n_distinct_genus = n_distinct(Accepted_genus),
    Accepted_genus_list = paste(sort(unique(Accepted_genus)), collapse = ", "),
    .groups = "drop"
  ) %>%
  filter(n_distinct_genus > 1) %>%
  arrange(genuscode)

genusdf <- allsp %>%
  group_by(Accepted_genus) %>%
  summarize(nsptree=sum(habit=="Freestanding"),
            nspliana=sum(habit=="Climbing")) %>%
  ungroup() %>% 
  mutate(Accepted_name=Accepted_genus,
         Accepted_name_rank="genus")  %>%
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)

genusdf2 <- allsp %>%
  group_by(orig_genus) %>%
  summarize(nsptree=sum(habit=="Freestanding"),
            nspliana=sum(habit=="Climbing")) %>%
  ungroup() %>% 
  filter(! orig_genus %in% allsp$Accepted_genus) %>%
  mutate(Accepted_name=orig_genus,
         Accepted_name_rank="genus")  %>%
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)

genusdfall <- bind_rows(genusdf,genusdf2) %>% 
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)


familydf <- allsp %>%
  group_by(Accepted_family) %>%
  summarize(nsptree=sum(habit=="Freestanding"),
            nspliana=sum(habit=="Climbing")) %>%
  ungroup() %>% 
  mutate(Accepted_name=Accepted_family,
         Accepted_name_rank="family")  %>%
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)

familydf2 <- allsp %>%
  group_by(Current_family) %>%
  summarize(nsptree=sum(habit=="Freestanding"),
            nspliana=sum(habit=="Climbing")) %>%
  ungroup() %>% 
  filter(! Current_family %in% allsp$Accepted_family) %>%
  mutate(Accepted_name=Current_family,
         Accepted_name_rank="family")  %>%
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)

familydfall <- bind_rows(familydf,familydf2) %>% 
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana) %>%
  filter(Accepted_name!="")

allhighertaxa <- rbind(genusdfall,familydfall) %>%
  mutate(lifeform=paste0(ifelse(nsptree>0,"A",""),ifelse(nspliana>0,"L",""))) %>%
  dplyr::select(Accepted_name,Accepted_name_rank,lifeform)
table(allhighertaxa$Accepted_name_rank,allhighertaxa$lifeform)

spdfall <- allsp %>%
  mutate(lifeform=ifelse(habit=="Freestanding","A","L")) %>%
  dplyr::select(Current_name,sp6,sp4,Accepted_name_rank,lifeform) %>%
  rename(Accepted_name=Current_name,sp6=sp6)

outtaxa <- bind_rows(spdfall,allhighertaxa) %>%
  rename(namerank=Accepted_name_rank,taxaname=Accepted_name) %>%
  arrange(taxaname)
table(outtaxa$namerank)

write_xlsx(outtaxa,FNPANAMATAXA)



# make a file that gives the synonyms as 1-to-1 list
synonymdf <- outtaxaplus %>%
  drop_na(synonyms) %>%  # Remove rows where there are no synonyms
  separate_rows(synonyms, sep = ", ") %>%  # Split synonyms into separate rows
  rename(Old_name = synonyms)  %>% # Rename column
  dplyr::select(Old_name,Current_name,sp6,sp6curr,sp6prior,sp4) %>%
  arrange(Old_name)

synonymdftnrs <- TNRS(synonymdf$Old_name)
table(synonymdftnrs$Name_matched_rank,synonymdftnrs$Name_submitted!=synonymdftnrs$Name_matched)
# there are 5 that don't match up 
subset(synonymdftnrs,Name_submitted!=Name_matched)

names(synonymdftnrs) <- paste0("Old_",names(synonymdftnrs))
synonymdftnrs <-rename(synonymdftnrs,Old_name=Old_Name_submitted)
synonymdfout <- left_join(synonymdf,synonymdftnrs[,c("Old_name",paste0("Old_",tnrscols))],
                       by="Old_name") %>% 
  mutate(currnameequalsaccepted=Current_name==Old_Accepted_name)

table(synonymdfout$Current_name==synonymdfout$Old_Accepted_name)

write_xlsx(synonymdfout,FNSYNONYMS)




