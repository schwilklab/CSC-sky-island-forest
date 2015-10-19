## exploring protein data 
# E.F. Waring

library(plyr)
library(ggplot2)

# import file
proData <- read.csv("../data/leaves/leaf-protein.csv", stringsAsFactors=T, strip.white=T)
taggedTrees <- read.csv("../data/tagged_trees.csv")

# remove the pines
proData <- subset(proData, notes!="PINES")
proData <- subset(proData, notes!="Bad run. Toss")

# calculate average absorbances plus sd

proData$A595.total <- (proData$A595.1 +proData$A595.2 +proData$A595.3) / 3

# caluclate ug of protein per mL solution
# we dilute the extract by 5 folds so we need to multiple protein by 5
# all other numbers from standard curve by EFW

proData$ug.ml <- (((proData$A595.total-0.0025)/0.0015)*5)/proData$vol.supernatent



#calculate ug protein per cm^2 tissue

proData$ug.cm2 <- proData$ug.ml/proData$pair.area

# check for duplicate samples

count(proData$tag)

# merge in mountain range data

proDataM <- merge(proData, taggedTrees, by="tag")

# now doing some exploration
# note:  I have no idea what tag goes with what mountain range.  So this is 
# purely on species alone.

# check for NA
list(proData$ug.cm2)


# find means and sd for species

proMean <- ddply(proDataM, .(species, mtn), summarize,
                 protein_sd=sd(ug.cm2),
                 protein=mean(ug.cm2))

# plot protein levels as ug/cm^2
ggplot(proDataM, aes(species, ug.cm2, shape=mtn, color=mtn, position=mtn)) +
  geom_point() +
  labs(y = "protein ug protein / cm^2")


