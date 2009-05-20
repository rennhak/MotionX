#!/usr/bin/R

library(grDevices)
library(graphics)



x <- c(0, 0.4,  2.0,  6.5, 0, 1.8, 0,   0.4, 0.2)
y <- c(0, -0.9, -0.3, 4.5, 0.8, 1.5, 0.6, 4.4, 1.6)

# weighting
#w <- rep(0, 10)

#z <- glm.fit( x, y )
# plot(x,y, col = "red", type = "b" ) 

#s <- smooth.spline( x, y, df = 10 )
#lines <- lines(s, lty=2, col = "red")
#plot( smooth.spline( x, y ) )
#true <- ((exp(1.2*x)+1.5*sin(7*x))-1)/3 #true function in this simulation

#library(pspline) #load the package containing the smooth.Pspline function
#fit <- smooth.Pspline(x, y, method=1)
#fit2 <- smooth.Pspline(x, y, method=3)

#fit smoothing spline on noisy data using GCV score (method=3). use method=1
#with a user specified smoothing parameter (spar) if you want to try different
#degree of smoothing.

#plot(x, y, xlab="Keyposes", ylab="time in seconds", cex=0.5) #plot data point
#lines(x, true, lty=2) #plot true function
#lines(fit$x, fit$y) #plot smooth spline fit
#lines(fit2$x, fit2$y, col = "red", type = "b") #plot smooth spline fit
plot( x, y )
abline( h = 0 )
abline( v = 0 )

lines( x, y, col = 2 ) 

#postscript( "Golden_ratio.eps", width = 9, height = 7, horizontal = FALSE, onefile = FALSE, paper = "special", family = "ComputerModern", encoding = "TeXtext.enc" )

#plot( x, y )
