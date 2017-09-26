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

# TODO: restrict list to just those with enough distribution data?
SPCODES <- c("JUDE2", "JUFL",  "JUPI",  "PICE",  "PIPO",  "PSME",  "QUEM",  "QUGR2", "QUGR3",
             "QUMU",  "PIST3", "QUGA",  "QUHY",  "PIED")


gcms  <-  c("CCSM4.r6i1p1", "CNRM-CM5.r1i1p1", "CSIRO-Mk3-6-0.r2i1p1",
        "HadGEM2-CC.r1i1p1", "inmcm4.r1i1p1", "IPSL-CM5A-LR.r1i1p1",
        "MIROC5.r1i1p1", "MPI-ESM-LR.r1i1p1", "MRI-CGCM3.r1i1p1")
scenarios <- c("rcp45", "rcp85")

BIOCLIM_RECS_DIR <- "../../skyisland-climate/results/reconstructions/"
SOIL_RECS_DIR <- "../../skyisland-climate/results/soil/"

OUT_DIR <- "../results/sdms/"

# take a data frame with x y coords in WGS84 and turn into a raster brick
clim_data_2_brick <- function(df) {
  sp::coordinates(df) <- ~ x + y # converts object to "SpatialPointsDataFrame"
  #let's be explicit about projections:
  projection(df) <- CRS("+proj=longlat +ellps=WGS84") 
  df <- as(df, "SpatialPixelsDataFrame")
  return <- raster::brick(df)
}

# function to retrieve bioclim and gswc projections by mtn range, gcm, scenario
# and time period. These data to retrieve are all stored as rds files in the
# skyisland-climate repo. Return as a raster brick.
retrieve_reconstruction <- function(mtn, gcm=NULL, scenario=NULL, timep=NULL) {

  base_name <- paste(mtn, gcm, scenario, timep, sep="_")

  if(is.null(gcm) ) {
    base_name <- paste(base_name, "_19612000", ".RDS", sep="")
  } else {
    base_name <- paste(base_name, ".RDS", sep="")
  }

  res <- data.frame(readRDS(file.path(BIOCLIM_RECS_DIR, base_name)))
  soild <- data.frame(readRDS(file.path(SOIL_RECS_DIR, base_name)))
  res <- dplyr::left_join(res, soild) # merge in gswc column
  res <- clim_data_2_brick(res)
  return(res)
}

# historical reconstruction raster bricks
CM <- retrieve_reconstruction("CM")
DM <- retrieve_reconstruction("DM")
GM <- retrieve_reconstruction("GM")

# we could then merge all of these into a single raster, eg
# clim_data_all <- merge(CM, DM, tolerance = 1)
# but I am worried about rounding accuracy. So for now, leave separate raster
# bricks for each mtn range, but we can always combine extracted location data
# to run a model on all occurrence locations across all mtn ranges at once. But
# we will need to run predictions spearately for each range. I think this is
# best solution as it allows breaking up the porblem for easier running on
# workstatons or the computer cluster.

# Read species distribution data
source("./read-distribution-data.R")


# get a data frame of all bioclim variables with each row represneting an
# occurrence location for the species. Extracts data from the raster blocks for
# each mtn range and then concatenates the results.

getLocations <- function(species_code) {
  loclist <- list()
  
  for (m in c("CM")) {#, "DM", "GM") ) { # temporarilly get only CM
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


fitMods <- function(sdmd) {
  mods <- list()
  # don't use mtn range as a predictor for now
  sdmd <- select(sdmd, -mtn)
  for (mt in MODEL_TYPES) {
    mod <- caret::train(as.factor(present) ~ ., data=sdmd, method=mt,
                        metric=METRIC, trControl=CONTROL)
    mods[[mt]] <- mod
  }
  return(mods)
}

# Model comparison and summaries
checkMods <- function(themods, spcode) {
  # save stats on each model
  for (modt in names(themods)) { # iterate by name
    mod <- themods[[modt]]
    # Print model to console or sink
    print(mod)
    ## TODO save plot and name correctly:
    oname <- file.path(OUT_DIR, paste(spcode, "_", modt, "_model_plot.pdf", sep=""))
    pdf(oname)
    plot(mod)
    dev.off()
    # variable importance
    print(paste("VARIABLE IMPORTANCE", modt))
    modImp <- varImp(mod, scale=TRUE)
    print(modImp)
  }
  # compare accuracy among models
  print("MODEL_COMPARISON")
  resamps <- resamples(themods)
  summary(resamps)
  print(resamps)
  diffs <- diff(resamps)
  print(summary(diffs))
  print(diffs)
}


makePrediction <- function(mod, mtn, spcode, gcm=NULL, scenario=NULL, timep=NULL) {
  if(is.null(gcm)) { # get historical
    env_raster <- eval(parse(text = mtn))
  } else {
    env_raster <- retrieve_reconstruction( mtn, gcm, scenario, timep )
  }
  p <- raster::predict(env_raster, mod)
  return(p)
}

   
    


# take a list of models that predict the same species' distribution as a
# function of bioclim vars. Create predictions for each of three mtn ranges and
# save these as well as visualization.
## makePredictions <- function(tmods, spcode) {
##   for (mtype in names(tmods)) {
##     for (mountain in c("CM", "DM", "GM") ) {
##       fname =  paste(spcode, mtype, mountain, sep="_")
##       p <- raster::predict(env_rastertmods[[mtype]])
##       saveRDS(p, file.path(OUT_DIR, paste(fname, ".RDS", sep="")))
##       pdf(file.path(OUT_DIR, paste(fname, ".pdf", sep="")))
##       plot(p)
##       dev.off()
##     }
##   }
## }

## test
qugr3_mods <- fitMods(getLocations("QUGR3"))
checkMods(qugr3_mods, "QUGR3")

qugr3_hist <- makePrediction(qugr3_mods[["xgbTree"]], "CM", "QUGR3")

qugr3_proj <- makePrediction(qugr3_mods[["xgbTree"]], "CM", "QUGR3", "HadGEM2-CC.r1i1p1", "rcp85", "2080s")



quem_mods <- fitMods(getLocations("QUEM"))
checkMods(quem_mods, "QUEM")

quem_hist <- makePrediction(quem_mods[["xgbTree"]], "CM", "QUEM")

quem_proj <- makePrediction(quem_mods[["xgbTree"]], "CM", "QUEM", "HadGEM2-CC.r1i1p1", "rcp85", "2080s")

png("../results/sdms/quem_hist_dist.png")
plot(quem_hist-1.0)
dev.off()

png("../results/sdms/quem_hadgem2080s_dist.png")
plot(quem_proj-1.0)
dev.off()

## TODO: reclassify step?
#reclassify rasters so that grids have binary values of 0 for absent or 1 for present
# reclassify the values into three groups
## boostbin <- reclassify(Boost, c(0,1.98,0,1.99,2,1))
## svmbin <- reclassify(SVM, c(0,1.98,0,1.99,2,1))
## rfbin <- reclassify(RF, c(0,1.98,0,1.99,2,1))

## #make the ensemble model: values of 0--no model predicts presence, 1--1 model predicts presence, etc.

## ensemble<-boostbin+svmbin+rfbin
## plot(ensemble)
#writeRaster(ensemble, filename = "ensemble.tif", format="GTiff", overwrite=TRUE)



#### Command line script ###

