# R code to make xylem vulnerability figures

# clear all objects
rm(list=ls()) 

# first read in the current data. All file names hardcoded in the file below.
# This also sources hydro.R
source("./cond-read-data.R")
source("./weibull.R") # Reparameterized Weibull curves

## The ggplot theme for all figures.
bestfit <- geom_smooth(method="lm",se = F, color = "black", size=1.5)
textsize <- 12
smsize <- textsize-2
pt2mm <- 0.35146
smsize.mm <- smsize*pt2mm
fontfamily = "Arial"
col2 <- 17.5 # cm
col1 <- 8.0 # cm
themeopts <-   theme(axis.title.y = element_text(family=fontfamily,
                       size = textsize, angle = 90, vjust=0.3),
               axis.title.x = element_text(family=fontfamily, size = textsize, vjust=-0.3),
               axis.ticks = element_line(colour = "black"),
               panel.background = element_rect(size = 1.6, fill = NA),
               panel.border = element_rect(size = 1.6, fill=NA),
               axis.text.x  = element_text(family=fontfamily, size=smsize, color="black"),
               axis.text.y  = element_text(family=fontfamily, size=smsize, color = "black"),
               ## strip.text.x = element_text(family=fontfamily, size = smsize, face="italic"),
               ## strip.text.y = element_text(family=fontfamily, size = smsize, face="italic"),
               legend.title = element_text(family=fontfamily, size=textsize),
               legend.text = element_text(family=fontfamily, size=smsize, face="italic"),
               legend.key = element_rect(fill=NA),
               panel.grid.minor = element_blank(),
               panel.grid.major = element_blank(), #element_line(colour = "grey90", size = 0.2),
               strip.background = element_rect(fill = "grey80", colour = "grey50")      
               #panel.grid.major = element_line(colour = NA)
                )


########################################################################################
# Quick curves by individuals
models <- dlply(treecurves, "display.name", function(df) loess(PLC ~ psi.real, data = df))
plc50s <- melt(lapply(models, plc50))
names(plc50s) <- c("plc50","display.name")
#plc50s$species.code <- reorder(plc50s$species.code,plc50s$plc50)

# By species with PLC50 lines
p <- ggplot(treecurves, aes(psi.real, fc.PLC)) +
    theme_bw() + themeopts +
    geom_point() +
    geom_smooth(size=1, span=0.9) +
    scale_y_continuous("Percent Loss Conductivity", limits=c(-0.1,1.1)) +
    scale_x_continuous("Xylem tension (MPa)") +
    facet_grid(display.name ~ .) 

p + geom_vline(aes(xintercept = plc50), data = plc50s, color = "black")

ggsave("../results-plots/treecurves-2014-vuln-by-species.pdf")

# By tag and species with PLC50 lines 2015 only
p <- ggplot(subset(treecurves, date.collected > mdy("5/1/2015")), aes(psi.real, fc.PLC, color=spcode)) +
    theme_bw() + themeopts +
    geom_point() +
    geom_smooth(size=1, span=0.9) +
    scale_y_continuous("Percent Loss Conductivity", limits=c(-0.1,1.1)) +
    scale_x_continuous("Xylem tension (MPa)") +
    facet_wrap(~ tag) 
p
#p + geom_vline(aes(xintercept = plc50), data = plc50s, color = "black")

ggsave("../results-plots/treecurves-2014-vuln-by-species.pdf")

###################################################################
# Weibull fits
# models per spcode / type

## TODO

## wmodels <- dlply(allplants, c("type", "display.name"), fitweibull)
## species.type.nd <- expand.grid(unique(allplants$type),
##                                unique(allplants$display.name), seq(0,-7,-0.01))
## names(species.type.nd) <- c("type", "display.name", "psi.real")

## pred <- function(df) {
##      predict(wmodels[[paste(type, ".", display.name, sep="")]], newdata = df)
## }
## species.type.dataList <- dlply(species.type.nd, c("type", "display.name"))

## preds <- mdply(cbind(mod = wmodels, df = species.type.dataList), function(mod, df) {
##   mutate(df, fc.PLC = predict(mod, newdata = df))
## })

## # get per spcode/type P50s
## plc50s <- ldply(wmodels, function(x) coef(x)[1])
## names(plc50s) <- c("type", "display.name", "plc50")


## p3 <- ggplot(allplants, aes(psi.real, fc.PLCp)) +
##     geom_line(aes(psi.real, fc.PLC, group=tag.trial.type), data=stem.preds,
##              color="gray80", size=0.7, alpha=0.8) +
##     geom_line(aes(psi.real, fc.PLC), data=preds, color="black", size=1) +
##     geom_point(size = 2, aes(position="jitter")) +        
##     scale_y_continuous("Percent Loss Conductivity", limits=c(-10,110)) +
##     scale_x_continuous("Xylem tension (MPa)") +
##     facet_grid(display.name ~ type) +
##     geom_vline(aes(xintercept = plc50), data = plc50s, color = "black") +
##     themeopts +
##     theme(strip.text.y = element_text(family=fontfamily, size = smsize, face="italic"))
## ggsave("../results/fig-3-resprouts-adults-vuln-by-species-2col.pdf", plot=p3,
##        width=col2, height=col2, units="cm")




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
 
