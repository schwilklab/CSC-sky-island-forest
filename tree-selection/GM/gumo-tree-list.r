# 2014-03-18
# code to take GUMO tree location files Helen sent and convert to one file for gps upload

library(reshape2)
library(rgdal)
library(sp)

strip.extension <- function(s){
  temp<-strsplit(s,".", fixed=TRUE)
  #return(unlist(temp)[index(unlist(temp))%%2==1 ])
  #print( temp)
  temp <-lapply(temp, function(x)x[1])
  return(unlist(temp))
  }


#tfiles <- list.files(path="./taylor-data", pattern="*.csv",full.names=TRUE)

# new data filtered on 15m from trail sent by Helen 2014-03-19
tfiles <- list.files(path="./plot_latlon", pattern="*.csv",full.names=TRUE)

species <- strip.extension(basename(tfiles))

treelist <- data.frame()

for (tf in tfiles) {
    d <- read.csv(tf, stringsAsFactors=FALSE)
    n <- strip.extension(basename(tf))[1]
    # fix names as file header hsa some trailing underscores, etc
    names(d) <- c("plot", "UTM.E", "UTM.N", "IV", "NEAR.FID", "NEAR.DIST", "lon", "lat", "map.label")
    d$spcode <- n
    print( n)
    treelist <- rbind(treelist, d)
}
    
# convert from UTM zone 13 to lat lon
points <- SpatialPoints(treelist[,2:3], proj4string=CRS("+proj=utm +zone=13"))
latlon <- spTransform(points, CRS("+proj=longlat"))
treelist$newlon <- coordinates(latlon)[,1]
treelist$newlat <- coordinates(latlon)[,2]

# map label is plot if it does not yet exist (everything except JUDE2)
treelist$map.label[is.na(treelist$map.label)] <- treelist$plot[is.na(treelist$map.label)]

write.csv(treelist, "gumo-tree-plots.csv", row.names=FALSE)

# redo lat/lon because data in csv files does not look to ahve correct precision?
gpsexport <- data.frame(Name=paste(treelist$spcode,treelist$plot, sep=""), Latitude=treelist$newlat, Longitude=treelist$newlon)
write.csv(gpsexport, "gumo-tree-plots-gps-export.csv", row.names=FALSE)

# now upload to gps using command
# gpsbabel -i unicsv -o garmin -f gumo-tree-plots-gps-export.csv -F usb:
