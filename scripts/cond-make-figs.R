# R code to make pretty xylem vulnerability figures

# clear all objects
rm(list=ls()) 

# first read in the current data. All file names ahrdcoded in the file below.
# This also sources hydro.R
source("./cond-read-data.R")





########################################################################################
## pretty curves
# get list of loess models
# TODO fit a survivorship/saturation curve
models <- dlply(treecurves, "display.name", function(df) loess(PLC ~ psi.real, data = df))
plc50s <- melt(lapply(models, plc50))
names(plc50s) <- c("plc50","display.name")
#plc50s$species.code <- reorder(plc50s$species.code,plc50s$plc50)

# By species with PLC50 lines
p <- ggplot(treecurves, aes(psi.real, PLC)) +
    theme_bw() + themeopts +
    geom_point() +
    geom_smooth(size=1, span=0.9) +
    scale_y_continuous("Percent Loss Conductivity", limits=c(-0.1,1.1)) +
    scale_x_continuous("Xylem tension (MPa)") +
    facet_grid(display.name ~ .) 

p + geom_vline(aes(xintercept = plc50), data = plc50s, color = "black")

ggsave("../results-plots/treecurves-2013-vuln-by-species.pdf")



###############################################################################
# Conductivities
###############################################################################

# plot maximum  K (not stem area specific!)
ggplot(subset(treecurves, psi.real < 0.1 & RPM!=0), aes(spcode, K)) +
    geom_boxplot() +
    scale_y_continuous("Stem-specific conductivity (units)") + # TODO
    scale_x_discrete("") + # TODO
    themeopts

# plot maximum leaf specific K
#ggplot(maxK, aes(spcode, K.leaf)) + geom_boxplot()
#ggsave("K-leaf-by-species.pdf")

# same without QUGR2
#ggplot(subset(maxK, spcode != "QUGR2"), aes(spcode, K.leaf)) +
#    geom_boxplot()






# by species and tag
ggplot(treecurves, aes(psi.real, PLC, color=tag)) +
    geom_point() +
    geom_smooth(aes(group = interaction(tag,date.collected,flushed)), se=FALSE) +
    scale_y_continuous("PLC", limits=c(-0.1,1.1)) +
    facet_grid(spcode ~ .)

ggsave("../results-plots/treecurves-2013-vuln-by-species-tag.pdf")
 
