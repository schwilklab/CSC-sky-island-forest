## exploring protein data 
# E.F. Waring

library(plyr)
library(ggplot2)

# set directory to the leaves data
setwd("./data/leaves")

# import file
proData <- read.csv("leaf-protein.csv", stringsAsFactors=T, strip.white=T)


# remove the pines
proData <- subset(proData, notes!="PINES")

# calculate average absorbances plus sd

proData$A595.total <- (proData$A595.1 +proData$A595.2 +proData$A595.3) / 3

# caluclate ug of protein per mL solution
# we dilute the extract by 5 folds so we need to multiple protein by 5
# all other numbers from standard curve by EFW

proData$ug.ml <- (((proData$A595.total-0.0025)/0.0015)*5)/proData$vol.supernatent



#calculate ug protein per cm^2 tissue

proData$ug.cm2 <- proData$ug.ml/proData$pair.area


# now doing some exploration
# note:  I have no idea what tag goes with what mountain range.  So this is 
# purely on species alone.

# check for NA
list(proData$ug.cm2)

# removing numbers that are too low right now

proData2 <- subset(proData, ug.cm2>50)
redo <-subset(proData, ug.cm2<=50)
# find means and sd for species

proMean <- ddply(proData2, .(species), summarize,
                 protein_sd=sd(ug.cm2),
                 protein=mean(ug.cm2))

# plot protein levels as ug/cm^2
ggplot(proMean, aes(species, protein)) +
  geom_pointrange(aes(ymin=protein-protein_sd, ymax=protein+protein_sd)) +
  labs(y = "protein ug protein / cm^2")


