# resprouts-vs-adults-2013.R

# Script to run analyses and create figures for Tailor's 2013 conductivity data

# Authors: Dylan Schwilk Tailor Brown

library(reshape2)
library(ggplot2)
library(stringr)

# clear all objects
rm(list=ls()) 

# read in library for calculations and curves
# NOTE: set working dir to dir of the current file!
source("./hydro.R")

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
## Resprout results, May-August 2013
############################################

## Read in curves file and stems file
curves <- read.csv("../data/conductance/csc-trees-curves.csv",
                             stringsAsFactors=FALSE)

stems <- read.csv("../data/conductance/csc-trees-stems.csv",
                            stringsAsFactors=FALSE)

taggedtrees <- read.csv("../data/tagged-trees.csv",
                        stringsAsFactors=FALSE)

stems <- merge(taggedtrees, stems)

treecurves <- merge(curves, stems, by = c("date.collected", "tag"))
# fix spcode.x, spcode.y after merge. TODO: fix this! only need spcode in one
# spot, or merge on spcode
#names(resprouts)[5] <- "spcode"
treecruves <- subset(treecurves, Use) # only keep stems marked for use
treecurves$tag <- factor(treecurves$tag)

# merge in pretty names
# check
species <- read.csv("../species.csv")
treecurves <- merge(treecurves, species)

# to the curve calculations:
treecurves <- curveCalcs(treecurves)

write.csv(treecurves, "../results-plots/scs-trees-2014-with-curve-calcs.csv", row.names=FALSE)

###############################################################################
# Conductivities
###############################################################################

# plot maximum stem specific K
ggplot(subset(treecurves, psi.real < 0.1 & RPM!=0), aes(display.name, K.stem)) +
    geom_boxplot() +
    scale_y_continuous("Stem-specific conductivity (units)") + # TODO
    scale_x_discrete("") + # TODO
    themeopts

# plot maximum leaf specific K
ggplot(maxK, aes(spcode, K.leaf)) + geom_boxplot()
ggsave("K-leaf-by-species.pdf")

# same without QUGR2
ggplot(subset(maxK, spcode != "QUGR2"), aes(spcode, K.leaf)) +
    geom_boxplot()


###############################################################################
# Vulnerability curves
###############################################################################

## pretty curves
# get list of loess models
# TODO fit a survivorship/saturation curve
models <- dlply(treecurves, "display.name", function(df) loess(PLC ~ psi.real, data = df))
plc50s <- melt(lapply(models, plc50))
names(plc50s) <- c("plc50","display.name")
#plc50s$species.code <- reorder(plc50s$species.code,plc50s$plc50)

# By species with PLC50 lines
p <- ggplot(subset(treecurves, Use), aes(psi.real, PLC)) +
    theme_bw() + themeopts +
    geom_point() +
    geom_smooth(size=1, span=0.9) +
    scale_y_continuous("Percent Loss Conductivity", limits=c(-0.1,1.1)) +
    scale_x_continuous("Xylem tension (MPa)") +
    facet_grid(display.name ~ .) 

p + geom_vline(aes(xintercept = plc50), data = plc50s, color = "black")

ggsave("../results-plots/treecurves-2013-vuln-by-species.pdf")



# by species and tag
ggplot(subset(treecurves, Use), aes(psi.real, PLC, color=tag)) +
    geom_point() +
    geom_smooth(aes(group = interaction(tag,date.collected,flushed)), se=FALSE) +
    scale_y_continuous("PLC", limits=c(-0.1,1.1)) +
    facet_grid(spcode ~ .)

ggsave("../results-plots/treecurves-2013-vuln-by-species-tag.pdf")
