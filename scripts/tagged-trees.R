
#  checking tagged trees

library(plyr)

trees <- read.csv("../data/tagged_trees.csv")

# check number of tagged trees by mtn range and by species
ddply(trees, .(mtn, spcode), summarize, count = length(tag))
