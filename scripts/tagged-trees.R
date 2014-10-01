
#  checking tagged trees

library(plyr)

trees <- read.csv("../data/tagged_trees.csv", stringsAsFactors=FALSE)

# check number of tagged trees by mtn range and by species
ddply(trees, .(mtn, spcode), summarize, count = length(tag))



# get more sig digits from raw gps downloads. Still need to do this for late
# July dm trip
## gps <- read.csv("../data/csc-gps-trees.csv")
## m <- merge(trees, gps, all.x=TRUE)
## m$lat[!is.na(m$Latitude)] <- m$Latitude[!is.na(m$Latitude)]
## m$lon[!is.na(m$Longitude)] <- m$Longitude[!is.na(m$Longitude)]

## write.csv(m, "new-tagged-trees.csv")


## Check  leaf data for missing values, etc
CNleaves <- read.csv("../data/leaves/CN-leaves.csv", stringsAsFactors=FALSE)
pines <- read.csv("../data/leaves/CN-leaves-pines-dimensions.csv", stringsAsFactors=FALSE)
pines.special <-read.csv("../data/leaves/CN-leaves-pines-dimensions-special-cases.csv", stringsAsFactors=FALSE)


have.area <- subset(CNleaves,  ! is.na(area))$tag
have.area.pines <- unique(pines$tag[! is.na(pines$diam1)])
have.area.pines <- c(have.area.pines, unique(pines.special$tag[! is.na(pines.special$diam1)]))
have.area <- c(have.area, have.area.pines)
## missing areas?
subset(trees, ! tag %in% have.area)[,c(1,2,7,9)]

## missing or duplicated masses?
have.mass <- subset(CNleaves,  ! is.na(mass))$tag
have.mass[duplicated(have.mass)] # 1 dupes
subset(trees, ! tag %in% have.mass)[,c(1,2,7,9)]

# missing mass but have area:
subset(trees, tag %in% have.area & ! tag %in% have.mass)[,c(1,2,7,9)] ## No missing!
