# weibull.R

###############################################################################
# Vulnerability curves
###############################################################################

### Using nonlinear (weibull) curves
library(nlme)

# create Ogle et al New Phyto 2009 reparameterized Weibull function for plc
# (found in suplementary information) In this function mpa is the negative
# signed xylem tension, x is the plc that defines px and sx, px is the negative
# signed xylem tension at x, and sx is the slope of the curve at x
oglwei<-function (mpa, x, px, sx) {
    100*(1-(1-(x/100))^((-mpa/-px)^((px*sx)/((x-100)*log(1-(x/100))))))
}

# some reasonable starting parameter estimates:
# starts = data.frame(px=c(0,6), sx = c(-0.5,-50))

fitweibull <- function(df) {
    nls(fc.PLCp ~ oglwei(psi.real, 50, px, sx),
        start=list(px=-2, sx=-11), data = df,
        algorithm="port",upper=c(-0.001,-5),trace=TRUE,
        control=nls.control(maxiter=5000,warnOnly=TRUE))
}
