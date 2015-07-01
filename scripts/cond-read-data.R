# resprouts-vs-adults-2013.R

# Read conductance data for 2014-2015 CSC trees

library(reshape2)
library(ggplot2)
library(lubridate)

# read in library for calculations and curves
# NOTE: set working dir to dir of the current file!
source("./hydro.R")

# Cleans up any 2 digit dates which should be in 21st century, not first
# century AD
fixDates <- function(x) {
    year(x)[x < mdy("1/1/2000")] <- year(x[x < mdy("1/1/2000")])  + 2000
    return(x)
}

## theme
 textsize <- 16
 stextsize <- 14
 themeopts <- theme_bw() +
    theme(panel.border = element_rect(colour = 'gray15', size=1.5),
    panel.background = element_blank(),
    panel.grid = element_blank(),
    # strip.background = element_rect(colour = 'gray15', size=1.5, fill="gray95"),
    axis.title.y = element_text(size = textsize, angle = 90),
    axis.title.x = element_text(size = textsize),
    strip.text.x = element_text(size = textsize),
    strip.text.y = element_text(size = stextsize),
    axis.text.x  = element_text(size = stextsize, colour="gray15"),
    axis.text.y  = element_text(size = stextsize, colour="gray15")
    )

### find plc50
plc50 <- function(modx) {
  x <- seq(0,-6,-0.01)
  y <- predict(modx,newdata = x)
  return(x[which.min(abs(y-0.5))])
}

############################################
## Quick curves only
############################################

## Read in curves file and stems file
curves <- read.csv("../data/conductance/csc-trees-curves.csv",
                             stringsAsFactors=FALSE)
curves$date.collected <- mdy(curves$date.collected)
curves$date.spun <- mdy(curves$date.spun)

# fix 2 letter years, eg "1/1/14" did not occur in AD 14
curves$date.collected <- fixDates(curves$date.collected)
curves$date.spun <- fixDates(curves$date.spun)


taggedtrees <- read.csv("../data/tagged_trees.csv",
                        stringsAsFactors=FALSE)
taggedtrees$date <- mdy(taggedtrees$date)

stems <- read.csv("../data/conductance/csc-trees-stems.csv", stringsAsFactors=FALSE)
stems$date.collected <- mdy(stems$date.collected)
treecurves <- merge(curves, stems, by = c("date.collected", "tag"), all.x=TRUE)#, "spcode"))


# fix spcode.x, spcode.y after merge. TODO: fix this! only need spcode in one
# spot, or merge on spcode
names(treecurves)[5] <- "spcode"
#treecruves <- subset(treecurves, Use) # only keep stems marked for use
#treecurves$tag <- factor(treecurves$tag)

# merge in pretty names
# check
species <- read.csv("../species.csv")
treecurves <- merge(treecurves, species)
treecurves <- merge(treecurves, taggedtrees, by = c("tag", "spcode"), all.x=TRUE)

# to the curve calculations
treecurves <- curveCalcs(treecurves)

write.csv(treecurves, "../results-plots/treecurves.csv", row.names=FALSE)


# data checks

treesNoCurves <- function(tmtn) {
    subset(taggedtrees, (! tag %in% subset(treecurves, Use)$tag) & (mtn == tmtn ) )
}


# check data, replication
ddply(subset(treecurves, Use), .(mtn, spcode), summarize, N = length(unique(tag)))
ddply(treecurves, .(spcode), summarize, N = length(unique(tag)))

# write.csv(CMtnc, "../results-plots/CM-trees-no-curves.csv", row.names=FALSE)
