
#  checking tagged trees

library(plyr)

trees <- read.csv("../data/tagged_trees.csv")

# check number of tagged trees by mtn range and by species
ddply(trees, .(mtn, spcode), summarize, count = length(tag))



# get more sig digits from raw gps downlaods. Still need to do this for late
# July dm trip
## gps <- read.csv("../data/csc-gps-trees.csv")
## m <- merge(trees, gps, all.x=TRUE)
## m$lat[!is.na(m$Latitude)] <- m$Latitude[!is.na(m$Latitude)]
## m$lon[!is.na(m$Longitude)] <- m$Longitude[!is.na(m$Longitude)]

## write.csv(m, "new-tagged-trees.csv")

