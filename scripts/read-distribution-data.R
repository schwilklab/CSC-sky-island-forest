## Read species plot data
##
## exports one new data frame, `distribution_data`, with the following fields:
## "plot"     "easting"  "northing" "long"     "lat"      "mtn"      "spcode"  
## "IV"       "presence"

library(dplyr)
library(tidyr)

# convert the wide format data (species names in column headers) into a long
# format useful for concenating all data
plot_data_to_long <- function(df) {
  res <- gather(df, spcode, IV, -plot, -easting, -northing, -long, -lat, -mtn)
  return(res)
}

# read each mtn range file and convert to long format adding column for mtn
# identifier
CM_dist <-read.csv("../data/distribution/CM_plots.csv", stringsAsFactors=FALSE) %>%
  mutate(mtn = "CM") %>% plot_data_to_long()
DM_dist <-read.csv("../data/distribution/DM_plots.csv", stringsAsFactors=FALSE)  %>%
  mutate(mtn = "DM") %>% plot_data_to_long()
GM_dist <-read.csv("../data/distribution/GM_plots.csv", stringsAsFactors=FALSE)  %>%
  mutate(mtn = "GM") %>% plot_data_to_long()

# row bind these up in one data frame, add presence/absence column and delete
# intermediates
distribution_data <- rbind(CM_dist, DM_dist, GM_dist) %>% mutate(present = IV > 0)
rm(CM_dist, DM_dist, GM_dist)

# Now correct the latlongs. Data in files has accurate utm coordinates (NAD83)
# but inaccurate lat lons). See
# https://github.com/schwilklab/CSC-sky-island-forest/issues/33
library(sp)
library(rgdal)

SP <-SpatialPoints(cbind(distribution_data$easting, distribution_data$northing), proj4string = CRS("+proj=utm +zone=13 +datum=NAD83"))
coordsll <-  as.data.frame(spTransform(SP, CRS("+proj=longlat +datum=WGS84")))
distribution_data <- mutate(distribution_data, long=coordsll[,1], lat =coordsll[,2])

rm(SP, coordsll)
