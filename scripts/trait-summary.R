
# get conductance data
source("./cond-read-data.R")

# coductance traits
traits <- left_join(taggedtrees, stem.traits) %>% select(-date, -note,
                                                                   -trail.area,
                                                                   -stem.collected)

# leaf traits
source("./leaf-protein-analysis.R")

# merge in just elemetnal and pretein data of interest
traits <- left_join(traits, select(CNleaves, tag, delta.13C, C.perc, N.perc))
traits <- left_join(traits, select(protein, tag, prot.ug.g, prot.ug.cm2))


# git rid of species we don't really ahve data for

traits <- traits %>% filter(! spcode %in% c("JUPI", "PSME", "QUPU"))

# by species summary

species.traits <- traits %>% group_by(spcode) %>% select(-mtn, -lat, -lon, -tag) %>%
  summarize_each(funs(mean(. , na.rm=TRUE)))

# TODO: get extra QUHY data we ahve from DM
