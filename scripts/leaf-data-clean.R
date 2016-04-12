# Read leaf mass and areas and elemental composition data, merge with
# tagged_trees, merge with portein data (oaks only)


library(plyr)
library(stringr)


###############################################################################
## LMA calculations
###############################################################################
trees <- read.csv("../data/tagged_trees.csv", stringsAsFactors=FALSE)
CNleaves <- read.csv("../data/leaves/CN-leaves.csv", stringsAsFactors=FALSE)
pines <- read.csv("../data/leaves/CN-leaves-pines-dimensions.csv", stringsAsFactors=FALSE)
pines.special <-read.csv("../data/leaves/CN-leaves-pines-dimensions-special-cases.csv", stringsAsFactors=FALSE)

needleArea <- function(diam, length, nNeedles) {
    arc.area <- (pi * diam * length) / nNeedles
    facet.area <- diam * length
    return( (arc.area + facet.area) / 2 ) # one-sided
}
    
## calculate equivalent 1-sided leaf area for pines
fascicleArea <- function(diam, length, nNeedles) {
    return( nNeedles * needleArea(diam, length, nNeedles))
}

# calculate total one-sided area for each tree (tag) for LMA
pine.areas <- ddply(pines, .(tag), summarize,
                    needle.area = sum(fascicleArea((diam1+diam2)/2,
                    length, needles.per.fascicle))  )

# handle special cases:
# first ones that are same as regular data:
# calculate total one-sided area for each tree (tag) for LMA
pine.areas2 <- ddply(subset(pines.special, used.fascicle==1), .(tag),
                     summarize,
                     needle.area = sum(fascicleArea((diam1+diam2)/2,
                     length,
                     needles.per.fascicle)))

# Now needle cases:
# calculate total one-sided area for each tree (tag) for LMA
pine.areas3 <- ddply(subset(pines.special, ! is.na(used.needle)),
                     .(tag),
                     summarize,
                     needle.area = sum(used.needle * needleArea((diam1+diam2)/2,
                                       length, needles.per.fascicle)))

# add to regular pine data:
pine.areas <- rbind(pine.areas, pine.areas2, pine.areas3)
rm(list = c("pine.areas2", "pine.areas3"))

# merge with broadleaf data
CNleaves <- merge(CNleaves, pine.areas, by = "tag", all.x=TRUE)
CNleaves <- merge(trees, CNleaves, by="tag", all.x = TRUE)

# use needle area for pines:
CNleaves[is.na(CNleaves$area),]$area <- CNleaves[is.na(CNleaves$area),]$needle.area
CNleaves$LMA <- CNleaves$mass / CNleaves$area

# clean up:
rm(fascicleArea, needleArea, pine.areas, pines, pines.special)

###############################################################################
## Elemental composition and isotopes
###############################################################################

## takes a bit to get the id variables lined up.
leaves.ec <- read.csv("../data/leaves/elemental-analysis-raw.csv", stringsAsFactors=FALSE)

locations <- data.frame(str_match(leaves.ec$file.name,
                                  "schwilk([0-9]+) ([a-h][0-9]{2})")[,2:3])
names(locations) <- c("tray", "well")
leaves.ec <- cbind(locations, leaves.ec)
rm(locations)


leaves.wells <- read.csv("../data/leaves/CN-leaves-trays-wells.csv",
                         stringsAsFactors=FALSE)
locations <- str_match(leaves.wells$well, "([A-H])([0-9]+)")
leaves.wells$well <- paste(tolower(locations[,2]),
                           sprintf("%02d", as.integer(locations[,3])),
                           sep="")
leaves.wells$tray <- str_match(leaves.wells$tray, "Schwilk-([0-9]+)")[,2]

## ok, all lined up, merge!
leaves.ec <- merge(leaves.wells, leaves.ec, all.x=TRUE)
CNleaves <- merge(CNleaves, leaves.ec, by = "tag", all = TRUE)

# all we need is CNleaves data frame
rm(leaves.ec, leaves.wells, locations)


# In global namespace: CNLeaves, trees


