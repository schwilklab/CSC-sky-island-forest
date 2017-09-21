# Read conductance data for 2014-2015 CSC trees

library(plyr)
library(lubridate)
library(reshape2)

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
## Do vulnerability curve calculations
###############################################################################

## TODO: use correct pipette correction depending on date (we changed reservoirs
## in summer 2015).
treecurves <- curveCalcs(treecurves, TRUE, TRUE)

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


# create column for trial
treecurves$tag.date <- paste(treecurves$tag, "." , treecurves$date.collected, sep="")

## remove faulty runs based on our run report folder. Probably should never have
## become actual data but ok to remove here.
badtags <- c("1001", "1002", "1004", "1008", "1016", "1017", "1018", "1019", "1020", "1051",
             "1053", "1056", "1101", "1102", "1111", "1136", "1137", "1139", "1140", "1210",
             "1211", "1220", "1221", "1257", "1259", "12XXE", "12XXE2", "12XXE3", "256",
             "501", "901", "P3307")

treecurves <- subset(treecurves, ! tag %in% badtags)



###############################################################################
## Final cleaning, remove temporary columns and variables
###############################################################################

# merge in full species names according to USDA species code
species <- read.csv("../species.csv")
treecurves <- merge(treecurves, species, by = "spcode", all.x=TRUE)
treecurves$tag <- factor(treecurves$tag)

#treecurves <- subset(treecurves, Use) # only keep stems marked for use

##  Write curve data out to speadsheet
write.csv(treecurves, "../results/figs/treecurves.csv", row.names=FALSE)



### summarize PLC50 by stem ###

## Fit a weibull curve to each stem (useful for plotting)
stem.models <- dlply(treecurves, c("tag.date"), fitweibull)

# predicted values for figures
stem.nd <- expand.grid(unique(treecurves$tag.date), seq(0,-7,-0.01))
names(stem.nd) <- c("tag.date", "psi.real")

stem.dataList <- dlply(stem.nd, c("tag.date"))
pred <- function(df) {
     predict(stem.models[[tag.date]], newdata = df)
}

stem.preds <- mdply(cbind(mod = stem.models, df = stem.dataList), function(mod, df) {
  mutate(df, fc.PLC = predict(mod, newdata = df))
})


stem.traits <- ldply(stem.models, function(x) coef(x)[1])
names(stem.traits) <- c("tag.date", "plc50")
stem.traits$tag <-  colsplit(stem.traits$tag.date, pattern="\\.", names=c("tag", "date"))[,1]


## calculate Kmax by stem ##
stem.k <- treecurves %>% group_by(tag, spcode, tag.date) %>%
  summarize(K.stem.max =  K.stem[closest(psi.real, -0.25)],
            K.leaf.max =  K.leaf[closest(psi.real, -0.25)])

stem.traits <- left_join(stem.k, stem.traits) %>% select(-tag.date)
