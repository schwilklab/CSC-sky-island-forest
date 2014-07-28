# hydro.R
# =======

# Authors:
# Dylan Schwilk
# Tailor Brown

## TODOs:
## 1. Still missing constants and code for pipette correction
## 2. Code to fit 3-parameter curve to PLC FOR STATS!

library(ggplot2)
library(plyr)

# Constants
ELEVATION <- 992  # lubbock
G0 <- 9.80665
ER <- 6371000  # earth mean radius
GRAV <- G0 * (ER / (ER+ELEVATION)  )^2  # gravity in lubbock
RADIUS <- 0.12654 / 2.0  # well top to well top
PIPETTE_CORR <- 0.00481697   # flow_true = flow_measured - (flow_measured x PIPETTE_CORR)

# Utility functions

# return index of v that is value closest to x
closest <- function(v, x) {
  return(which(abs(v-x)==min(abs(v-x)))[1]) 
}
 

# Function: waterDensity
# Calculate fluid density from temperature. Argument t
# is temperature (C), returns density in kg per m^3. Note: we are ignoring mass
# of KCL. Change?
waterDensity <- function(t){
  # see http://metgen.pagesperso-orange.fr/metrologieen19.htm
  # TANAKA M. and MASUI R., "Measurement of the Thermal Expansion of Pure Water
  # in the Temperature Range 0 °C - 85 °C", Metrologia, 1990, 27, 165-171. 
  # WATANABEE H., "Thermal Dilatation of Water between 0 °C and 44 °C",
  # Metrologia, 1991, 28, 33-43.
  a1 <- -3.983035
  a2 <- 301.797
  a3 <- 522528.9
  a4 <- 69.34881 	  	
  a5 <- 999.974950
  return(a5 * ( 1 - ( ( (t+a1)^2 * (t+a2)) / (a3 * (t + a4)) ) ) )
}

# Calculate applied tension from RPM
# from Alder et al and Jacobsen
rpm2mpa <- function(RPM, r, den) {
    v <- -0.000001 * ( (RPM*2*pi / 60)^2 * r^2 * den) / 2
    v[RPM==0] <- 0
    return(v)
}

# and reverse:
mpa2rpm <- function(x, r, den) {
  x <- -x*10^6
  rps <- sqrt( (2 * x) / (r^2 * den) )
  return (rps * 60/(2*pi))
}

## Function curveCalcs
## produce all calculated values from a vulnerability curve data frame
curveCalcs <- function(df, getKstem = FALSE, getKLeaf =FALSE) {
   # water density at temperature
   df$water.den <- waterDensity(df$temp)
   df$cent.water.den <- waterDensity(df$cent.temp)
   # assume room temp if centrifuge temp is missing
   df$cent.water.den[is.na(df$cent.water.den)] <- df$water.den[is.na(df$cent.water.den)]
   
   # actual tension applied

   # centrifgue method:
   df$psi.real <-  rpm2mpa(df$RPM, RADIUS, df$cent.water.den)
   # or, if RPM is missing then we know that we used air injection:
   df$psi.real[is.na(df$psi.real)] <- df$air.MPa[is.na(df$psi.real)]

   # Calculate pressure differential in MPa:
   df$headp <- (  (df$height.head - (df$height.balance.post + df$height.balance.pre)/2) *.01)  *
   df$water.den * GRAV * 0.000001
   
   # pipette correction
   df$flow <- df$flow - (df$flow*PIPETTE_CORR)
   df$flow.bg.pre <- df$flow.bg.pre - (df$flow.bg.pre*PIPETTE_CORR)
   df$flow.bg.post <- df$flow.bg.post - (df$flow.bg.post*PIPETTE_CORR)
   # substract background flow
   df$flow.true <- (df$flow - (df$flow.bg.pre + df$flow.bg.post)/2) * 0.001 * 0.001  # kg/s

   # Calculate K in kg s^-1 m^-1 MPa^1:
   df$K <-  (df$flow.true / df$headp ) * df$stem.length * 0.01

   if(getKstem) {
       # get stem specific K in  kg s^-1 m^-3 MPa^1:
       df$K.stem <- df$K / (((df$stem.diam1 + df$stem.diam2)/200.0)^2 * pi) # stem diam convert cm to m and divide by 2 for radius
   }

   if(getKLeaf) {
       df$K.leaf <- df$K / (df$leaf.area / 1000.0)  # leaf area in square meters
   }


   # temp fix
   df$psi.real[is.na(df$psi.real)] <- -0.05  # TODO: fix this

   # fatigue corr point
   df <- ddply(df, .(tag, date.collected, flushed), transform,
          fc.point = K ==  K[closest(psi.real, -0.25)])

   # calculate PLC by dividing each K by the K at highest Psi. Assumes that a
   # single curve is distinguished by tag, date.collected, and flushed (T/F)
   df <- ddply(df, .(tag, date.collected, flushed), transform,
          PLC = 1.0 - (K / ( K[closest(psi.real, 0.0)])) )

   # calculate fatigue corrected PLC by dividing each K by the K at Psi = -0.25
   # MPa:
   df <- ddply(df, .(tag, date.collected, flushed), transform,
               fc.PLC = 1.0 - K / K[closest(psi.real, -0.25)] )
   return(df)
 }
