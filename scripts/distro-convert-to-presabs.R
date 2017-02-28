library(dplyr)
CM <-read.csv("CM_plots.csv", header=TRUE)
CM <- data.frame(CM)

DM <-read.csv("DM_plots.csv", header=TRUE)
DM <- data.frame(DM)

GM <-read.csv("GM_plots.csv", header=TRUE)
GM <- data.frame(GM)

#convert IVs into presence/absence data for each species in CM
CMsub<-CM[, c(2:12)]
CMcoord<-CM[,c(1,15,16)]
CMsub[CMsub>0] <-1 
CMpresabs <- cbind(CMcoord, CMsub)
JUDE2 <- select(CMpresabs, plot, long, lat, JUDE2)
head(JUDE2)
write.csv(JUDE2, "~/dylan_CSC/final_species_csv/CM/JUDE2.csv")

JUFL <- select(CMpresabs, plot, long, lat, JUFL)
head(JUFL)
write.csv(JUFL, "~/dylan_CSC/final_species_csv/CM/JUFL.csv")

JUPI <- select(CMpresabs, plot, long, lat, JUPI)
head(JUPI)
write.csv(JUPI, "~/dylan_CSC/final_species_csv/CM/JUPI.csv")

PICE <- select(CMpresabs, plot, long, lat, PICE)
head(PICE)
write.csv(PICE, "~/dylan_CSC/final_species_csv/CM/PICE.csv")

PIPO <- select(CMpresabs, plot, long, lat, PIPO)
head(PICE)
write.csv(PIPO, "~/dylan_CSC/final_species_csv/CM/PIPO.csv")

PSME <- select(CMpresabs, plot, long, lat, PSME)
head(PSME)
write.csv(PSME, "~/dylan_CSC/final_species_csv/CM/PSME.csv")

QUEM <- select(CMpresabs, plot, long, lat, QUEM)
head(PSME)
write.csv(QUEM, "~/dylan_CSC/final_species_csv/CM/QUEM.csv")

QUGR2 <- select(CMpresabs, plot, long, lat, QUGR2)
head(QUGR2)
write.csv(QUGR2, "~/dylan_CSC/final_species_csv/CM/QUGR2.csv")

QUGR3 <- select(CMpresabs, plot, long, lat, QUGR2)
head(QUGR3)
write.csv(QUGR3, "~/dylan_CSC/final_species_csv/CM/QUGR3.csv")

QUMU <- select(CMpresabs, plot, long, lat, QUMU)
head(QUMU)
write.csv(QUMU, "~/dylan_CSC/final_species_csv/CM/QUMU.csv")

#Do the same for GM
GMsub<-GM[, c(2:8)]
GMcoord<-GM[,c(1,11,12)]
GMsub[GMsub>0] <-1 
GMpresabs <- cbind(GMcoord, GMsub)

JUDE2 <- select(GMpresabs, plot, long, lat, JUDE2)
head(JUDE2)
write.csv(JUDE2, "~/dylan_CSC/final_species_csv/GM/JUDE2.csv")

PIED <- select(GMpresabs, plot, long, lat, PIED)
head(PIED)
write.csv(PIED, "~/dylan_CSC/final_species_csv/GM/PIED")

PIST3 <- select(GMpresabs, plot, long, lat, PIST3)
head(PIST3)
write.csv(PIST3, "~/dylan_CSC/final_species_csv/GM/PIST3.csv")

QUGA <- select(GMpresabs, plot, long, lat, QUGA)
head(QUGA)
write.csv(QUGA, "~/dylan_CSC/final_species_csv/GM/QUGA.csv")

PIPO <- select(GMpresabs, plot, long, lat, PIPO)
head(PICE)
write.csv(PIPO, "~/dylan_CSC/final_species_csv/GM/PIPO.csv")

PSME <- select(GMpresabs, plot, long, lat, PSME)
head(PSME)
write.csv(PSME, "~/dylan_CSC/final_species_csv/GM/PSME.csv")

QUMU <- select(GMpresabs, plot, long, lat, QUMU)
head(QUMU)
write.csv(QUMU, "~/dylan_CSC/final_species_csv/GM/QUMU.csv")

#Do the same for DM
#convert IVs into presence/absence data for each species in CM
DMsub<-DM[, c(2:10)]
DMcoord<-DM[,c(1,13,14)]
DMsub[DMsub>0] <-1 
DMpresabs <- cbind(DMcoord, DMsub)

JUDE2 <- select(DMpresabs, plot, long, lat, JUDE2)
head(JUDE2)
write.csv(JUDE2, "~/dylan_CSC/final_species_csv/DM/JUDE2.csv")

PICE <- select(DMpresabs, plot, long, lat, PICE)
head(PICE)
write.csv(PICE, "~/dylan_CSC/final_species_csv/DM/PICE.csv")

PIPO <- select(DMpresabs, plot, long, lat, PIPO)
head(PICE)
write.csv(PIPO, "~/dylan_CSC/final_species_csv/DM/PIPO.csv")

QUEM <- select(DMpresabs, plot, long, lat, QUEM)
head(PSME)
write.csv(QUEM, "~/dylan_CSC/final_species_csv/DM/QUEM.csv")

QUGR2 <- select(DMpresabs, plot, long, lat, QUGR2)
head(QUGR2)
write.csv(QUGR2, "~/dylan_CSC/final_species_csv/DM/QUGR2.csv")

QUGR3 <- select(DMpresabs, plot, long, lat, QUGR2)
head(QUGR3)
write.csv(QUGR3, "~/dylan_CSC/final_species_csv/DM/QUGR3.csv")

QUHY <- select(DMpresabs, plot, long, lat, QUHY)
head(QUHY)
write.csv(QUHY, "~/dylan_CSC/final_species_csv/DM/QUHY.csv")

PIST3 <- select(DMpresabs, plot, long, lat, PIST3)
head(PIST3)
write.csv(PIST3, "~/dylan_CSC/final_species_csv/DM/PIST3.csv")

