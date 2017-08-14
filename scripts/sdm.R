## sdm.R
########

## Species distribution models

# random number seed
seed <- 10
set.seed(seed)

library(sp)
library(raster)
library(rgdal)
library(dplyr)


OUT_DIR <- "../results/sdms/"

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


# get a data frame of all bioclim variables with each row represneting an
# occurrence location for the species. Extracts data from the raster blocks for
# each mtn range and then concatenates the results.
getLocations <- function(species_code) {
  loclist <- list()
  
  for (m in c("CM", "DM", "GM") ) {
    loc <- distribution_data %>%
      filter(spcode == species_code & mtn==m) %>% select(long, lat, present)
    if (nrow(loc) > 0 ) { # species occurs in that mtn range
      loc_longlat <- select(loc, long, lat)
      coordinates(loc_longlat) <- ~long+lat
      projection(loc_longlat) <- CRS("+proj=longlat +ellps=WGS84") # hard coded. TODO.
      locations <- raster::extract(eval(parse(text = m)), # need to use string
                                                          # 'm' to find out
                                                          # which raster block
                                                          # to access (CM, DM
                                                          # or GM)
                                   coordinates(loc_longlat))
      loclist[[m]] <- mutate(as.data.frame(locations), present = loc$present, mtn=m)
    }  
  }
  res <- bind_rows(loclist)
  return(res)
}

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
  
# pairs(sdmdata[,-13], cex=0.1, fig=TRUE)


## use sink() to redirect output later
    ## sink(file = file.path(TOPO_RES_DIR, paste(mtn, "_", v, ".txt", sep="")),
    ##      append = FALSE, split = TRUE)



########################################
## Species Distribution Model Fitting
########################################

## Model fitting constants
##########################
METRIC <- "Accuracy"
# control set with 5 fold cv and 1 repeat for speed right now. Should change
# repeats to betweeen 3 and 5 later
CONTROL <- caret::trainControl(method="repeatedcv", number=5,
                                 repeats=1)
# Try boosted regression trees, SVM models and RandomForest
MODEL_TYPES <- c("xgbTree", "svmRadial", "rf")

# fit the models and save model output

# The following function expects a set of climate data for a set of locations
# along with a "present" boolean variable (presence absence data). The function
# fits all models in MODEL_TYPES (three currently) and returns the resulting
# models as a list indixed by model type string.

# TODO: save all model summary and comparison output in a structured way. In
# fact, we could simplify the code below to just fitting models and move
# comparison and summaries to later.

fitMods <- function(sdmd) {
  mods <- list()
  # don't use mtn range as a rpedictor for now
  sdmd <- select(sdmd, -mtn)
  for (mt in MODEL_TYPES) {
    mod <- caret::train(as.factor(present) ~ ., data=sdmd, method=mt,
                        metric=METRIC, trControl=CONTROL)
    # Print model to console or sink
    print(mod)
    ## TODO save plot and name correctly:
    plot(mod)

    # variable importance
    modImp <- varImp(mod, scale=TRUE)
    print(modImp)
    mods[[mt]] <- mod
  }

  # compare accuracy among models
  resamps <- resamples(mods)
  summary(resamps)
  print(resamps)
  diffs <- diff(resamps)
  print(summary(diffs))
  print(diffs)
  
  return(mods)
}


makePredictions <- function(tmods) {
  for (mtype in names(tmods)) {
    for (mountain in c("CM", "DM", "GM") ) {
      fname =  paste(mtype, mountain, sep="_")
      p <- raster::predict(eval(parse(text = mountain)), tmods[[mtype]])
      saveRDS(p, file.path(OUT_DIR, paste(fname, ".RDS", sep="")))
      pdf(file.path(OUT_DIR, paste(fname, ".pdf", sep="")))
      plot(p)
      dev.off()
    }
  }
}



## test

qugr3_mods <- fitMods(getLocations("QUGR3"))

makePredictions(qugr3_mods)





  
## #make the SDM
  ## prediction <- predict(CM, boost)
  ## plot(Boost)



#reclassify rasters so that grids have binary values of 0 for absent or 1 for present
# reclassify the values into three groups
boostbin <- reclassify(Boost, c(0,1.98,0,1.99,2,1))
svmbin <- reclassify(SVM, c(0,1.98,0,1.99,2,1))
rfbin <- reclassify(RF, c(0,1.98,0,1.99,2,1))

#make the ensemble model: values of 0--no model predicts presence, 1--1 model predicts presence, etc.

ensemble<-boostbin+svmbin+rfbin
plot(ensemble)

#writeRaster(ensemble, filename = "ensemble.tif", format="GTiff", overwrite=TRUE)

