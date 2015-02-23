## Figures and stats on CSC leaf data from summer 2014

## D.W. Schwilk

library(ggplot2)

# get CNleaves and trees data frames:
source("./leaf-data-clean.R")

ggplot(subset(CNleaves, substr(spcode,1,2) == "QU"), aes(spcode, LMA) ) + geom_boxplot()

ggplot(subset(CNleaves, substr(spcode,1,2) == "QU"), aes(spcode, N.perc) ) + geom_boxplot()

ggplot(subset(CNleaves, substr(spcode,1,2) == "QU"), aes(LMA,  N.perc, color=spcode) ) +
    geom_point() +
    geom_smooth(method="lm", se=FALSE, aes(group=spcode))
