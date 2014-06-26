# 2014-06-16
# code to take tree location files Helen sent and convert to one file for gps upload

library(reshape2)
library(plyr)
library(rgdal)
library(sp)


strip.extension <- function(s){
  temp<-strsplit(s,".", fixed=TRUE)
  #return(unlist(temp)[index(unlist(temp))%%2==1 ])
  #print( temp)
  temp <-lapply(temp, function(x)x[1])
  return(unlist(temp))
  }



merge.data <- function(fl) {
    treelist <- data.frame()
    for (tf in fl) {
        d <- read.csv(tf, stringsAsFactors=FALSE)
        n <- strip.extension(basename(tf))[1]
    # fix names as file header hsa some trailing underscores, etc
#    names(d) <- c("plot", "UTM.E", "UTM.N", "IV", "NEAR.FID", "NEAR.DIST", "lon", "lat", "map.label")
        
        # Helen's data is in really inconsistent formats, need to manually
        # check order of northing and easting.
        r <- data.frame(plot = d$PLOT, northing = d$NORTHING, easting = d$EASTING, spcode = n)
        print( n)
        treelist <- rbind.fill(treelist, r)
    }

    return(treelist)
}



# CM
CMfiles <- list.files(path="./CM/plots", pattern="*.csv",full.names=TRUE)
CMdata <- merge.data(CMfiles)
CMdata$mtn <- "CM"

DMfiles <- list.files(path="./DM/plots", pattern="*.csv",full.names=TRUE)
DMdata <- merge.data(DMfiles)
DMdata$mtn <- "DM"

allplots <- rbind.fill(CMdata, DMdata)


#species <- strip.extension(basename(tfiles))

# convert from UTM zone 13 to lat lon
points <- SpatialPoints(allplots[,2:3], proj4string=CRS("+proj=utm +zone=13"))
latlon <- spTransform(points, CRS("+proj=longlat"))
allplots$lon <- coordinates(latlon)[,1]
allplots$lat <- coordinates(latlon)[,2]


write.csv(allplots, "CM-DM-tree-plots.csv", row.names=FALSE)

# redo lat/lon because data in csv files does not look to ahve correct precision?
gpsexport <- data.frame(Name=paste(allplots$spcode, allplots$plot, sep="_"), Latitude=allplots$lat, Longitude=allplots$lon, Description=allplots$mtn)
write.csv(gpsexport, "CM-DM-tree-plots-gps-export.csv", row.names=FALSE)

# now upload to gps using command
# gpsbabel -i unicsv -o garmin -f gumo-tree-plots-gps-export.csv -F usb:
