# Read and clean leaf protein data
# E.F. Waring, Dylan Schwilk

library(dplyr)

OUT_DIR <- "../results/traits/"

source("./leaf-data-clean.R") # provides two data frames: CNLeaves and trees

###############################################################################
## Leaf protein data (oaks only)
###############################################################################

# import file
protein <- read.csv("../data/leaves/leaf-protein.csv", stringsAsFactors=FALSE, strip.white=TRUE)

protein.raw <- protein %>% subset(notes != "PINES") %>% rowwise() %>%
    mutate(A595 = mean(c(A595.1,A595.2,A595.3), na.rm=TRUE), # average absorbances
           # calculate ug of protein per mL solution we dilute the extract by 5
           # folds so we need to multiple protein by 5 all other numbers from
           # standard curve by EFW
           prot.ug.ml = (((A595 - 0.0025) / 0.0015) * 5) / vol.supernatent, 
           prot.ug.cm2 = prot.ug.ml / pair.area, # protein per cm^2 tissue
           prot.LMA = pair.dry.mass / pair.area,
           prot.ug.g =  prot.ug.cm2 * prot.LMA # protein per dry mass
           )

protein <- protein.raw %>% dplyr::select(tag, prot.ug.ml, prot.ug.cm2, prot.LMA, prot.ug.g)

# check for duplicate samples
# max(count(protein$tag)$freq)

# merge and create overall leaf data data frame
leaves <- merge(CNleaves, protein, by="tag", all=TRUE)

# Data checks
ggplot(aes(spcode, prot.ug.g, color=spcode), data=subset(leaves, grepl("^QU", spcode))) +
    geom_jitter()
ggsave(file.path(OUT_DIR, "protein-bymass.png"))

ggplot(aes(spcode, prot.ug.cm2), data=subset(leaves, grepl("^QU", spcode))) +
    geom_boxplot()
ggsave(file.path(OUT_DIR,"protein-byarea.png"))


ggplot(aes(spcode, prot.LMA, color=spcode), data=subset(leaves, grepl("^QU", spcode))) +
    geom_jitter()
ggsave(file.path(OUT_DIR,"protein-lma.png"))

# so some wierd outliers. Caused by area or mass:

ggplot(aes(pair.dry.mass, pair.wet.mass), data=protein.raw) +
    geom_point() + facet_grid(. ~ species)
ggsave(file.path(OUT_DIR,"protein-wet-dry-mass.png"))


p <- ggplot(aes(prot.ug.cm2, prot.ug.g), data=subset(leaves, grepl("^QU", spcode))) +
    geom_point() +
    facet_grid(. ~spcode)
p


p <- ggplot(aes(LMA, prot.LMA), data=subset(leaves, grepl("^QU", spcode))) +
    geom_point() +
    facet_grid(. ~spcode)
p
