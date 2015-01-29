#!/usr/bin/env bash

# create field sheets
Rscript ./tagged-trees.R
# load result into GPS connected via USB
gpsbabel -i unicsv -f ../results-plots/trees-to-upload.csv -o garmin -F usb:
