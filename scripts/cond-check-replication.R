##  bit fo code to aid in seelecting trees that have not yet had stems
##  collected

source("cond-read-data.R")

# data checks
treesNoCurves <- function(tmtn) {
    subset(taggedtrees, (! tag %in% subset(treecurves, Use)$tag) & (mtn == tmtn ) )
}


# check data, replication
ddply(subset(treecurves, Use), .(mtn, spcode), summarize, N = length(unique(tag)))
ddply(treecurves, .(spcode), summarize, N = length(unique(tag)))
