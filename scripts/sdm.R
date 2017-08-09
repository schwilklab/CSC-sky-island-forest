## 
# Base script by H. Poulos

library(sp)
library(raster)
library(rgdal)
library(dplyr)

clim_data_2_brick <- function(df) {
  sp::coordinates(df) <- ~ x + y # converts object to "SpatialPointsDataFrame"
  #let's be explicit about projections:
  projection(df) <- CRS("+proj=longlat +ellps=WGS84") 
  df <- as(df, "SpatialPixelsDataFrame")
  return <- raster::brick(df)
}

# read all mtn ranges reference period summaries and store each range as a
# separate raster "brick" (like a raster stack).
CM <- data.frame(readRDS("../../skyisland-climate/results/reconstructions/CM____19612000.RDS"))
CM <- clim_data_2_brick(CM)
DM <- data.frame(readRDS("../../skyisland-climate/results/reconstructions/DM____19612000.RDS"))
DM <- clim_data_2_brick(DM)
GM <- data.frame(readRDS("../../skyisland-climate/results/reconstructions/GM____19612000.RDS"))
GM <- clim_data_2_brick(GM)

# we could then merge all of these into a single raster, eg
# clim_data_all <- merge(CM, DM, tolerance = 1)
# but I am worried about rounding accuracy. So for now, leave separate raster
# bricks for each mtn range, but we can always combine extracted locaiton data
# to run a model on all occurrence locations across all mtn ranges at once. But
# we will need to run predicitions spearately for each range. I think this is
# best solution as it allows breaking up the porblem for easier running on
# workstatons or the computer cluster.

# Read species distribution data
source("./read-distribution-data.R")

# begin example. QUEM in CM
 QUEM <- distribution_data %>%
   filter(spcode == "QUEM" & mtn=="CM") %>% select(long, lat, present)
QUEM_longlat <- select(QUEM, long, lat)
coordinates(QUEM_longlat) <- ~long+lat
projection(QUEM_longlat) <- CRS("+proj=longlat +ellps=WGS84") 
locations <- raster::extract(CM, coordinates(QUEM_longlat)) # careful. Must be explicit
                                                # about which extract function
# presence/absence true false
sdmdata <- mutate(as.data.frame(locations), present = QUEM$present)



# HP: SDM models want names in text. Won't work with as.factor specification

## DWS: I don't get this --- this makes no sense and must refer to some other
## issue or misunderstanding. Names can't have anything to do with it. WHen we
## have an issue like this it is important to find root cause and not use a
## workaround that masks the problem. I suspect the problem is that your code
## is making assumptions about factor level order somewhere.

## The various models below all work on factors and classify. BUt named fctors
## are easier to interpret.


## sdmdata$pb<- as.factor(sdmdata$pb)
## levels(sdmdata$pb) <- gsub("0", "absent", levels(sdmdata$pb))
## levels(sdmdata$pb) <- gsub("1", "present", levels(sdmdata$pb))
## head(sdmdata)

# pairs plot of the values of the climate data
# at the species occurrence sites.
  
pairs(sdmdata[,-13], cex=0.1, fig=TRUE)


# Fit xgboost: model with 5-fold cross-validation
library(caret)
library(xgboost)

#control set with 5 fold cv and 1 repeat for speed right now. Should change repeats to betweeen 3 and 5 later
control <- trainControl(method="repeatedcv", number=5, repeats=1)
seed <- 7
metric <- "Accuracy"

set.seed(seed)
boost <- train(as.factor(present) ~ ., data=sdmdata, method='xgbTree', metric=metric, trControl=control)
# Print model to console
boost

# Plot model
plot(boost)

# variable importance
boostImp <- varImp(boost, scale=TRUE)
boostImp

#make the SDM
Boost <- predict(CM, boost)
plot(Boost)


# SVM model--support vector machines with radial basis function
library(kernlab)

svm <- train(as.factor(present)~., data=sdmdata, method = 'svmRadial', metric=metric, trControl=control)
# Print model to console
svm
# Plot model
plot(svm)

# variable importance
svmImp <- varImp(svm, scale=TRUE)
svmImp

#make the SDM
SVM <- predict(GM, svm)
plot(SVM)

# random forest
library(randomForest)

rf <- train(as.factor(present) ~ ., data=sdmdata,  method = 'rf', metric=metric, trControl=control)
# Print model to console
rf

# Plot model
plot(rf)

# variable importance
rfImp <- varImp(rf, scale=TRUE)
rfImp

#make the SDM
RF <- predict(CM, rf)
plot(RF)

#compare accuracy among models
resamps <- resamples(list(rf = rf, boost = boost, svm=svm))
summary(resamps)
print(resamps)
diffs <- diff(resamps)
summary(diffs)
print(diffs)

#reclassify rasters so that grids have binary values of 0 for absent or 1 for present
# reclassify the values into three groups
boostbin <- reclassify(Boost, c(0,1.98,0,1.99,2,1))
svmbin <- reclassify(SVM, c(0,1.98,0,1.99,2,1))
rfbin <- reclassify(RF, c(0,1.98,0,1.99,2,1))

#make the ensemble model: values of 0--no model predicts presence, 1--1 model predicts presence, etc.

ensemble<-boostbin+svmbin+rfbin
plot(ensemble)

#writeRaster(ensemble, filename = "ensemble.tif", format="GTiff", overwrite=TRUE)

