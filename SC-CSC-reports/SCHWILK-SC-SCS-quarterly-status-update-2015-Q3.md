Quarterly Status Update:  July - September, 2015
====================================================

Project Name:  *Predicting Sky Island Forest Vulnerability to Climate Change: Fine Scale Climate Variability, Drought Tolerance, and Fire Response*

| Principal Investigator  | Project Begin Date | Project End Date   | Institution |
| ----------------------- | ------------------ | ------------------ | ----------- |
| Dylan Schwilk           | March 1, 2014      | September 24, 2016 | Texas Tech  |

## Objectives and scope: ##

The objectives of this research are to: 1) identify the key functional traits influencing contemporary distributions and environmental affinities of keystone forest tree species (oaks, pines and junipers) in the northern Sierra Madre Oriental in western Texas, including the Guadalupe Mountains, the Davis Mountains, and the Chisos Mountains; 2) collect micro-climate and soil moisture measurements and use these to conduct fine-scale climate downscaling (to 3m DEM) across three replicated mountain ranges that host important US Department of Interior and private forest resources; and thereby 3) predict how species and trait distributions might shift under future warmer and drier climates.

## Work performed during reporting period: ##

1. We finished all xylem vulnerability measurements. 

3. We made progress on the models of microclimate modeling over topography (Schwilk and Poulos). We ran into some issues in setting up perfect reproducibility across platforms (with Poulos working on MS windows and Schwilk working on Linux).  But we now have a reproducible workflow in which all analyses can be run from a clean code of our git repositories.

Regarding the science: our central problem to solve is fitting microclimate models to the iButton time series which has both spatial and temporal extent.  The main predictors, however, each only have one dimension (spatial in case of topography) and temporal (in case of weather station data).  We have a PCA-based approach working and have completed the fitting to topographic predictors using random-forest models.

4. We received reviews on our manuscript submitted to *Plant Ecology* and submitted a revised version.

5. Schwilk wrote code for re-parameterized Weibull curve fitting for vulnerability curves.  We have a full trait matrix for our target species, but have not used that yet to ask any questions.

## Problems encountered during reporting period: ##

Many issues getting a reproducible workflow set up for Poulos and Schwilk collaboration using version control.

## Work planned for next reporting period: ##

1. Finish microclimate models based on topography and local station daily data (Schwilk and Poulos). We have the topography step working, but now must complete the weather station data step and then back-predict our daily time series across all locations for a quasi historical time series and then the projected time series based on the regional downscaling.  After that, we can use climate summaries in the trait-species niche models.
5. Use results of (1) above with the full trait matrix  to produce trait and climate niche models.
 
## Budget expenditures: ##

This project contributed to the education of 5 undergraduate or recent graduate student researchers this quarter, 3 women and 4 from an underrepresented minority (Hispanic/Latino). This, assistantships for two graduate students who worked on the xylem vulnerability curves, and summer salary for Schwilk were the main expenditures.


| Name            | Rank        | Age group | Work Status    |
| --------------- | ----------  | --------- | -------------- |
| Helen Poulos    | Co PI       |           | Co PI          |
| Tailor Brown    | recent grad |     19-22 | Hired 6/1/15   |
| Gabrielle Plata | recent grad |     19-22 | Hired 6/15/15  |
| Jonathan Galvez | undergrad   |     19-22 | Research credit |
| Juan Aragon     | undergrad   |     19-22 | Research credit |
| Xiulin Gao      | graduate    |     22-26 | RA             |
| Erik Lindberg   | graduate    |     22-26 | RA             |

List significant expenditures during this quarter.

| Type                                 | Expense |
| ------------------------------------ | ------- |
| Undergraduate labor and fringe       |    2165 |
| Field site travel                    |     600 |
| Graduate RAs (fee waivers)           |    3250 |
|                                      |         |

Total expenses: $6015.  Note that some of the expenses I reported last quarter only posted this quarter.

## Interim results / deliverables: ##

1. We update the GitHub repository continuously with the raw data and the conductance results: https://github.com/schwilklab/CSC-sky-island-forest
2. Revised manuscript submitted: Schwilk, D.W., T.E. Brown, R. Lackey and J. Willms. "Post-fire resprouting oaks (genus: Quercus) exhibit plasticity in xylem vulnerability to drought." Submitted to *Plant Ecology* on Oct 10, 2015.
