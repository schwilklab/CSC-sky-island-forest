CSC-sky-island-forest
=====================

USGS Climate Science Center funded project 

Project Title: Predicting sky island forest vulnerability to climate change: fine scale climate variability, drought tolerance, and fire response.

Data
----

Each data file referred to has an associated machine readable metadata file.  IF the file is named file.csv, the metadata file is file-metadata.csv.  The metadata files describe each variable (column) in the data files.

### Tagged trees ###

We plan to tag 10 individuals per species per mountain range.  We will stratify across elevation, aspect and relative slope position by selecting trees from Poulos's plots when possible as described in the proposal methods.

The tree tag numbers, latitude and longitude, etc are stored in data/tagged_trees.csv

### Leaf data ###

From each tagged tree we collected ~10 sun leaves.  Five of these were designated "CN leaves" for C:N analysis.  The total area and dry mass of these leaves are both stored in data/leaves/CN-leaves.csv with one row per tagged tree. From these data we will calculate LMA. Note that areas are missing for all pines in this file. For pines, we did not use porjected area but instead measured fascicle diameter and needle length.  These data are in CN-leaves-pines-dimensions.csv with one row per fascicle.  We will summarize these dimensions per tagged tree to calculate equivalent area.


### Conductance data ###

Stem conductance data are stored in two files: 

- csc-trees-curves.csv : contains one row per conductance measurement
- csc-trees-stems.csv : contains one row per stem measured

The code to calculate conductivities and to create xylem vulnerability curves from these data are in the scripts directory: 

1. hydro.R: contains functions for making curve calculations.

2. cond-read-data.R: run our source this file to read in your current data.  It hard-codes the paths to your stem and curves files. It also defines a function called "simpleCurve()" which takes on argument which is a tag id (string, not numeric). So, after sourcing our running this file, you can type:

```R
simpleCurve("1012")
```

To produce a curve for that stem.  So this is what you will want to do while running curves.  first, start an R session in the scripts directory, then type:

```R
source("cond-read-data.R")
simpleCurve("tag")
```

If you change the data, resource by rerunning simpleCurve("1012")

3. The final script is cond-make-figs.R produces cleaner figs for curves by
species. It sources cond-read-data.R which in turn sources hydro.R.



Reports
-------

Quarterly SC-CSC reports are in SC-CSC-reports folder, named by year and quarter.
