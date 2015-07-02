# Read conductance data for 2014-2015 CSC trees

library(plyr)
library(lubridate)

# read in library for calculations and curves
# NOTE: set working dir to dir of the current file!
source("./hydro.R")


###############################################################################
## Functions
###############################################################################

# Cleans up any 2 digit dates which should be in 21st century, not first
# century AD
fixDates <- function(x) {
    year(x)[x < mdy("1/1/2000")] <- year(x[x < mdy("1/1/2000")])  + 2000
    return(x)
}

###############################################################################
## Read and merge curves and stems data
###############################################################################

## Read in curves file and stems file
curves <- read.csv("../data/conductance/csc-trees-curves.csv",
                             stringsAsFactors=FALSE)
curves$date.collected <- mdy(curves$date.collected)
curves$date.spun <- mdy(curves$date.spun)

# fix 2 letter years, eg "1/1/14" did not occur in AD 14
curves$date.collected <- fixDates(curves$date.collected)
curves$date.spun <- fixDates(curves$date.spun)

# stems file (1 row per stem):
stems <- read.csv("../data/conductance/csc-trees-stems.csv",
                  stringsAsFactors=FALSE)
stems$date.collected <- mdy(stems$date.collected)

# merge stems and curves files, check for mismatches, clean up names
treecurves <- merge(stems, curves, by = c("date.collected", "tag"),
                    all.y=TRUE)

# Check that the spcodes match (tagged trees and stems file) and find mismatches if necessary
stopifnot(all(treecurves$spcode.x == treecurves$spcode.y))
## ddply(subset(treecurves, (spcode.x != spcode.y) | is.na(spcode.y)),
##       .(tag, spcode.x, spcode.y, date.collected),
##       summarize, nchar(spcode.x[1]), nchar(spcode.y[1]))

names(treecurves)[3] <- "spcode"
treecurves$spcode.y <- NULL
treecurves <- plyr::rename(treecurves, c("notes.x" = "notes.stem", "notes.y" = "notes.curve"))

###############################################################################
## Do vulnerbaility curve calculations
###############################################################################

## TODO: use correct pipette correction depnding on date (we changed reservoirs
## in summer 2015).
treecurves <- curveCalcs(treecurves)

###############################################################################
## Data consistency checks
###############################################################################

# We only need the tagged_trees.csv data if we want waypoint location or to
# check that species code match across the mutliple places they were recorded.
taggedtrees <- read.csv("../data/tagged_trees.csv",
                        stringsAsFactors=FALSE)
taggedtrees$date <- mdy(taggedtrees$date)
treecurves <- merge(treecurves, taggedtrees, by = c("tag"), all.x=TRUE)

# and check again that spcodes match!
stopifnot(all(treecurves$spcode.x == treecurves$spcode.y))
# good, so clean up:
names(treecurves)[3] <- "spcode"
treecurves$spcode.y <- NULL

###############################################################################
## Final cleaning, remove temprary columns and variables
###############################################################################

# merge in full species names according to USDA species code
species <- read.csv("../species.csv")
treecurves <- merge(treecurves, species, by = "spcode", all.x=TRUE)
treecurves$tag <- factor(treecurves$tag)

#treecurves <- subset(treecurves, Use) # only keep stems marked for use

##  Write curve data out to speadsheet
write.csv(treecurves, "../results-plots/treecurves.csv", row.names=FALSE)
