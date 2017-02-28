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
CM <-read.csv("../data/distribution/CM_plots.csv", stringsAsFactors=FALSE) %>%
  mutate(mtn = "CM") %>% plot_data_to_long()
DM <-read.csv("../data/distribution/DM_plots.csv", stringsAsFactors=FALSE)  %>%
  mutate(mtn = "DM") %>% plot_data_to_long()
GM <-read.csv("../data/distribution/GM_plots.csv", stringsAsFactors=FALSE)  %>%
  mutate(mtn = "GM") %>% plot_data_to_long()

# row bind these up in one data frame, add presence/absence column and delete
# intermediates
distribution_data <- rbind(CM, DM, GM) %>% mutate(presence = IV > 0)
rm(CM, DM, GM)
