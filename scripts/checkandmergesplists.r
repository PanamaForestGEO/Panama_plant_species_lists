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
FNWRIGHTSPLISTIN <- paste0(DIRINSP,"Wright/nomenclature_R_20210224_Rready_fixed.xlsx")
FNWRIGHTSPLISTTNRS <- paste0(DIRMIDSP,"nomenclature_R_20100224_Rready_fixed_tnrs.xlsx")
FGEOSPLISTIN <- paste0(DIRINSP,"Forestgeo/ViewTaxonomy_2024-09-10HM.xlsx")
FGEOSPLISTTNRS <- paste0(DIRMIDSP,"ViewTaxonomy_2024-09-10HM_tnrs.xlsx")
PANAMASPLISTIN <- paste0(DIRINSP,"Forestgeo/Perez-et-al_PanamaPlantSp_2025-03.xlsx")
PANAMASPLISTTNRS <- paste0(DIRMIDSP,"Perez-et-al_PanamaPlantSp_2025-03tnrs.xlsx")
PANAMASPLISTTNRSHM <- paste0(DIROUTSP,"Perez-et-al_PanamaPlantSp_2025-03tnrsHM.xlsx")
SYNONYMOUT <- paste0(DIROUTSP,"Synonyms_2025-03.xlsx")
PANAMATAXA <- paste0(DIROUTSP,"Perez-et-al_PanamaTaxa_2025-03.xlsx")
# the last is the list of all unique accepted species, genera, and families for photo labeling

tnrscols <- c("Name_matched","Name_matched_rank","Accepted_name","Accepted_name_author",
              "Accepted_name_rank","Accepted_family")
tnrscols2 <- c("Name_submitted",tnrscols)
tnrscols3 <- c("binomial",tnrscols)
tnrscols4 <- c("Current_name",tnrscols)

# Joe Wright's taxonomy dataset (includes lianas)
if (file.exists(FNWRIGHTSPLISTTNRS) & !redotnrs) {
  usejoetaxa <- read_excel(FNWRIGHTSPLISTTNRS) 
} else {
  joetaxa <- read_excel(FNWRIGHTSPLISTIN)
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
  write_xlsx(usejoetaxa,FNWRIGHTSPLISTTNRS)
  rm(joetaxa,sp6dupsj,binomialdupsj,joetaxatnrs)
}


# old ForestGEO tree taxonomy dataset 
if (file.exists(FGEOSPLISTTNRS) & !redotnrs) {
  fgeotaxa <- read_excel(FGEOSPLISTTNRS) 
} else {
  treetaxa <- read_excel(FGEOSPLISTIN)
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
  write_xlsx(fgeotaxa,FGEOSPLISTTNRS)
  rm(treetaxa,sp6dups,binomialdups,treetaxauniqbinomial,treetaxatnrs)
}

#####################

read_excel(PANAMASPLISTIN) %>%
  rename(Current_order=ORDEN,
         Current_family=FAMILIA_APG,
         Current_name=ESPECIE,
         Current_name_author=AUTORIDAD,
         synonyms=SINONIMOS,
         sp6curr=CODIGO,
         vouchers=HERBARIO_PMA_SCZ,
         habit=Habit) %>%
  mutate(sp6prior=fgeotaxa$sp6[match(Current_name,fgeotaxa$binomial)],
         sp6curr=tolower(sp6curr)) -> 
  alltaxa

# fix problems matching on binomial for these subspecies
alltaxa$sp6prior[alltaxa$sp6curr=="swars1"] <- "swars1"
alltaxa$sp6prior[alltaxa$sp6curr=="swars2"] <- "swars2"


bindups <- alltaxa %>% group_by(Current_name) %>% arrange(Current_name) %>% filter(n()>1) %>% ungroup()
write_xlsx(bindups,paste0(DIRCHECK,"Perezlistnombreduplicado.xlsx"))
# I manually went through and picked one of the entries as correct for each duplicated Current_name
# exception is Swartzia simplex, where both are good
alltaxa <- filter(alltaxa, !Current_name %in% bindups$Current_name)
gooddups <- read_excel(paste0(DIRCHECK,"Perezlistnombredup_touse.xlsx"))
alltaxa <- rbind(alltaxa,gooddups)

sp6dif <- subset(alltaxa,!is.na(sp6curr) & !is.na(sp6prior) & sp6curr!=sp6prior)
write_xlsx(sp6dif,paste0(DIRCHECK,"Perezlistcodigocambio.xlsx"))

sp6dups <- alltaxa %>% filter(!is.na(sp6curr)) %>% group_by(sp6curr) %>% 
  arrange(sp6curr) %>% filter(n()>1) %>% ungroup()
write_xlsx(sp6dups,paste0(DIRCHECK,"Perezlistcodigoduplicado.xlsx"))

sp6not6char <- subset(alltaxa,nchar(sp6curr)!=6&!is.na(sp6curr))
write_xlsx(sp6not6char,paste0(DIRCHECK,"Perezlistsp6not6char.xlsx"))

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
write_xlsx(sp6probleft,paste0(DIRCHECK,"Perezlistsp6prob.xlsx"))


# I, Helene, reviewed these problem codes and make the following revisions
alltaxa$sp6[alltaxa$Current_name=="Quararibea asterolepis"] <- "quaras" # was "quaras no en BCI"
alltaxa$sp6[alltaxa$Current_name=="Beilschmiedia pendula"] <- NA  # was "no en bci"
alltaxa$sp6[alltaxa$Current_name=="Diospyros juruensis"] <- "dio2ha"  # was dio22ha
alltaxa$sp6[alltaxa$Current_name=="Sorocea pubivena"] <- "soropu" # accidental change?  there are no other species in the genus that start with p and are in the list
alltaxa$sp6[alltaxa$Current_name=="Siparuna thecaphora"] <- "sipath" #accidental change to sipate? change doesn't make sense

sp6dupsleft <- alltaxa %>% 
  filter(!is.na(sp6)) %>% 
  group_by(sp6) %>% 
  arrange(sp6) %>% 
  filter(n()>1) %>% ungroup()
# there are still no duplicated sp6 codes after this  

sp6dropped <- subset(fgeotaxa,!sp6 %in% alltaxa$sp6 & 
                       Accepted_name_rank %in% c("species","subspecies","variety")
                     &IDLevel=="species")
write_xlsx(sp6dropped,paste0(DIRCHECK,"Perezlistcodigosperdidos.xlsx"))

# there is one typo in a species name that prevents matching in TNRS - fix this before running TNRS
alltaxa$Current_name[alltaxa$sp6=="pleuhe"] <- "Pleurothyrium hexaglandulosumvan"
alltaxa$Current_name_author[alltaxa$sp6=="pleuhe"] <- "van der Werff"

if (file.exists(PANAMASPLISTTNRS) & !redotnrs) {
  alltaxaplus <- read_excel(PANAMASPLISTTNRS) 
} else {
  alltaxatnrs <- TNRS(alltaxa$Current_name)
  table(alltaxatnrs$Name_submitted==alltaxatnrs$Name_matched)
  alltaxatnrs <-rename(alltaxatnrs,Current_name=Name_submitted)
  alltaxaplus <- left_join(alltaxa,alltaxatnrs[,tnrscols4],by="Current_name")
  write_xlsx(alltaxaplus,PANAMASPLISTTNRS)
#  rm(alltaxatnrs)
} 

namedifsp <- alltaxaplus %>% 
  filter(Current_name!=Name_matched & 
           Name_matched_rank %in% c("species","subspecies","variety")) %>%
  dplyr::select(Current_name,Name_matched,Accepted_name,sp6curr,sp6prior,sp6) 
write_xlsx(namedifsp,paste0(DIRCHECK,"Perezlistnombreserrores.xlsx"))
# 7 of these look like typos
# CAUTION - occasionally more than 7 pop up, for mysterious reasons - the others indicate a problem. 
# in this case, do rm(list=ls()), restart R, and rerun.  
alltaxaplus <- alltaxaplus %>% 
  mutate(currnamechanged=Current_name %in% namedifsp$Current_name) %>%
  mutate(Current_name=ifelse(Current_name %in% namedifsp$Current_name, Name_matched, Current_name))

# adjust species names of the Swartzia simplex 
alltaxaplus$Current_name[alltaxaplus$sp6curr=="swars1"] <- "Swartzia simplex var. grandiflora"
alltaxaplus$Current_name[alltaxaplus$sp6curr=="swars2"] <- "Swartzia simplex var. continentalis"
bindups2 <- alltaxaplus %>% group_by(Current_name) %>% arrange(Current_name) %>% filter(n()>1) %>% ungroup()
# no duplicates left 

sp6added <- subset(alltaxaplus,!sp6 %in% fgeotaxa$sp6 & 
                     !is.na(sp6) & 
                     Accepted_name_rank %in% c("species","subspecies","variety"))

# In some few cases, for mysterious reasons, TNRS matches the name but does not associated an accepted name. 
# In these cases, use the matched name as the accepted name.
inc <- alltaxaplus$Accepted_name==""
if (length(inc[inc==T&!is.na(inc)])>0) {
  table(inc)
  alltaxaplus$Accepted_name[inc] <- alltaxaplus$Name_matched[inc]
  alltaxaplus$Accepted_name_rank[inc] <- alltaxaplus$Name_matched_rank[inc]
  alltaxaplus$Accepted_name_author[inc] <- NA
}

# add sp4 codes from Joe's data
table(table(usejoetaxa$sp4)) # 938 unique sp4 codes
table(usejoetaxa$Accepted_name_rank,is.na(usejoetaxa$sp4)) # most of them for taxa with species-level IDs

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
alltaxaplus$sp4[alltaxaplus$sp6=="quaras"] <- NA  # this name and code were previously used for BCI Quararibea
alltaxaplus$sp4[alltaxaplus$sp6=="quara1"] <- "QUA1"  # this is the new name and 6-letter code for the BCI Quararibea
sp4dups <- names(table(alltaxaplus$sp4)[table(alltaxaplus$sp4)>1])
table(table(alltaxaplus$sp4))
# no longer any duplicates

alltaxaplus <- rename(alltaxaplus,sp6=sp6)
alltaxaplus %>%
  mutate() -> alltaxaplus


outtaxaplus <- alltaxaplus %>% 
  mutate(acceptednamedif = Current_name!=Accepted_name,
         sp6changed = sp6!= sp6curr | sp6 != sp6prior) %>%
  dplyr::select("sp6","sp6curr","sp6prior","sp4",
                "Current_order","Current_family","Current_name","Current_name_author",
                "synonyms","vouchers","habit",
                "Accepted_name","Accepted_name_author","Accepted_name_rank",
                "Accepted_family","currnamechanged","sp6changed","acceptednamedif") %>%
  arrange(Current_name) %>%
  mutate(notes=paste0(ifelse(is.na(currnamechanged) | !currnamechanged,
                            "","Spelling corrected in Current_name. "),
                     ifelse(is.na(sp6changed) | ! sp6changed,
                            "","Code sp6 changed from sp6curr or sp6prior. "),
                     ifelse(is.na(acceptednamedif) | !acceptednamedif,
                            "","Current_name differs from Accepted_name returned by TNRS. "))) 
write_xlsx(outtaxaplus,PANAMASPLISTTNRSHM)


# remove taxa that are genera or higher rather than species
allsp <- subset(alltaxaplus,
                Accepted_name_rank %in% c("species","subspecies","variety"))
                  
acceptednamedups <- allsp %>% 
  group_by(Accepted_name) %>% 
  arrange(Accepted_name) %>% filter(n()>1) %>% ungroup()

namenotaccepted <- subset(allsp,Name_matched!=Accepted_name)
write_xlsx(namenotaccepted,paste0(DIRCHECK,"Perezlistnombrenoacceptado.xlsx"))
# only 15 are different from current accepted name.  So use the Current name in this list.  
table(allsp$Name_matched==allsp$Accepted_name,
      allsp$Accepted_name %in% acceptednamedups$Accepted_name)

allsp %>% mutate(Accepted_genus=word(Accepted_name,1),
       orig_genus=word(Current_name,1),
       genuscode=ifelse(is.na(sp6),NA,substr(sp6,1,4))) -> allsp

# check that a single genus always has the same family:
genus_check1 <- allsp %>%
  group_by(Accepted_genus) %>%
  summarise(n_families = n_distinct(Accepted_family), .groups = "drop") %>%
  filter(n_families > 1)
# yes it does

# check whether a single genus always has the same lifeform:
genus_check2 <- allsp %>%
  group_by(Accepted_genus) %>%
  summarise(n_families = n_distinct(Current_family), .groups = "drop") %>%
  filter(n_families > 1)
# not always, no

# check that a single genus always has the same first 4 letters of species code:
genus_check3 <- allsp %>%
  group_by(Accepted_genus) %>%
  summarise(n_genuscode = n_distinct(genuscode), .groups = "drop") %>%
  filter(n_genuscode > 1)

genus_violations <- allsp %>%
  filter(!is.na(genuscode)) %>%
  group_by(Accepted_genus) %>%
  filter(n_distinct(genuscode) > 1) %>%
  distinct(Accepted_genus,genuscode) %>%
  arrange(Accepted_genus) %>%
  dplyr::select(Accepted_genus,genuscode)


# looks like most of these related to species name changes where code is kept
# except following look problematic
# Bauhinia bauh, bahu
# Henriettea henr, hen1
# Sicydium sicy, sisy

genus_violations2 <- allsp %>%
  filter(!is.na(genuscode)) %>%
  group_by(genuscode) %>%
  filter(n_distinct(Accepted_genus) > 1) %>%
  distinct(Accepted_genus,genuscode) %>%
  arrange(genuscode) %>%
  dplyr::select(genuscode,Accepted_genus)

# again looks like most are related to species name changes where code is kept
# following look potentially problematic
# acac Acacia, Acaciella
# oreo Oreopanax, Oreomunnea
# teco Tecoma, Tecomaria  # this turns out to just be a name change of one, so okay


genusdf <- allsp %>%
  #filter(!duplicated(Accepted_genus)) %>%
  group_by(Accepted_genus) %>%
  summarize(nsptree=sum(habit=="Freestanding"),
            nspliana=sum(habit=="Climbing")) %>%
  ungroup() %>% 
  mutate(Accepted_name=Accepted_genus,
         Accepted_name_rank="genus")  %>%
  dplyr::select(Accepted_name,Accepted_name_rank,nsptree,nspliana)

genusdf2 <- allsp %>%
  #filter(!duplicated(Accepted_genus)) %>%
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

write_xlsx(outtaxa,PANAMATAXA)



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

write_xlsx(synonymdfout,SYNONYMOUT)




