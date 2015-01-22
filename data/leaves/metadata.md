Leaf trait data
===============

Leaves were collected from permanently tagged trees during June-August 2014. See tree selection protocol.

## data files ##

- CN-leaves.csv :: fresh area and dry mass on leaf samples.  Use for LMA calculations. These areas include petiole. This file has dry mass for all individuals but areas for oaks and junipers only.
- CN-leaves-pines-dimensions :: leaf dimensions for area calculations of leaf (needle) area for pines.  The [...]-special-cases.csv file contains data on a few individuals for which exceptions to the normal assumptions had to be made. See code under ../scripts for details.
- CN-leaves-trays-wells.csv :: lookup table to match tag numbers to tray and well locations for elemental analysis samples sent to Ray Lee.
- elemental-analysis-raw.csv :: data returned by Ray Lee with C, N and isotope data. Note that these samples are from the same leaves recorded in CN-leaves.csv
- laminar-LMA.csv :: separate fresh area and dry mass measurements taken on leaf punches from exact leaves used for leaf protein extraction. Oaks only. These punches exclude the midrib and therefore can be used to calculate laminar LMA.

