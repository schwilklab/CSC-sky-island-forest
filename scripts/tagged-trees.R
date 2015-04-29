#! /usr/bin/env Rscript

#  checking tagged trees

library(plyr)

trees <- read.csv("../data/tagged_trees.csv", stringsAsFactors=FALSE)

# get more sig digits from raw gps downloads. Still need to do this for late
# July dm trip
## gps <- read.csv("../data/csc-gps-trees.csv")
## m <- merge(trees, gps, all.x=TRUE)
## m$lat[!is.na(m$Latitude)] <- m$Latitude[!is.na(m$Latitude)]
## m$lon[!is.na(m$Longitude)] <- m$Longitude[!is.na(m$Longitude)]
## write.csv(m, "new-tagged-trees.csv")


doDataChecks <-  function() {

    print("Number of tagged trees by mtn range and by species")
    print(ddply(trees, .(mtn, spcode), summarize, count = length(tag)))

    ## Check  leaf data for missing values, etc
    CNleaves <- read.csv("../data/leaves/CN-leaves.csv", stringsAsFactors=FALSE)
    pines <- read.csv("../data/leaves/CN-leaves-pines-dimensions.csv", stringsAsFactors=FALSE)
    pines.special <- read.csv("../data/leaves/CN-leaves-pines-dimensions-special-cases.csv",
                             stringsAsFactors=FALSE)

    protein <- read.csv("../data/leaves/leaf-protein.csv")
    #print("trees without protein data")
    #trees[! trees$tag %in% protein$tag ,1:2]

    print("oaks without protein data")
    print(subset(trees[! trees$tag %in% protein$tag ,c(1,2,7)], substr(spcode,1,2) == "QU"))


    have.area <- subset(CNleaves,  ! is.na(area))$tag
    have.area.pines <- unique(pines$tag[! is.na(pines$diam1)])
    have.area.pines <- c(have.area.pines, unique(pines.special$tag[! is.na(pines.special$diam1)]))
    have.area <- c(have.area, have.area.pines)
    ## missing areas?
    print("Which trees are missing leaf areas?")
    print(subset(trees, ! tag %in% have.area)[,c(1,2,7,9)])

    ## missing or duplicated masses?
    have.mass <- subset(CNleaves,  ! is.na(mass))$tag
    have.mass[duplicated(have.mass)] # 1 dupes
    print("Trees missing or duplicated leaf dry mass:")
    print(subset(trees, ! tag %in% have.mass)[,c(1,2,7,9)])

    # missing mass but have area:
    print("Trees missing dry mass but have area:")
    print(subset(trees, tag %in% have.area & ! tag %in% have.mass)[,c(1,2,7,9)]) ## No missing!
}

## Take tree and output a csv file in correct format for uploading to the
## garmin gps units
clean.df <- data.frame(name=trees$tag,
                       lat=trees$lat,
                       lon=trees$lon,
                       desc=trees$spcode)
write.csv(clean.df, "../results-plots/trees-to-upload.csv", row.names=FALSE)
