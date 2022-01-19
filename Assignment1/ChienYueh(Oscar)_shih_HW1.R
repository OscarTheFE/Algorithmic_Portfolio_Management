#################################
### FRE7241 Homework #1 due at 6AM Tuesday September 28, 2021
#################################
# Max score 70pts

# Please write in this file the R code needed to perform 
# the tasks below, rename it to your_name_hw1.R,
# and upload the file to NYU Classes


############## Part I
# Summary: Calculate the maximum drawdown of a time series.

## Run the setup code below, which was taken from the slide 
# Drawdown Risk.

library(rutils)

# Calculate time series of VTI drawdowns
clos_e <- log(quantmod::Cl(rutils::etf_env$VTI))
draw_downs <- (clos_e - cummax(clos_e))
# Extract the date index from the time series clos_e 
date_s <- zoo::index(clos_e)

## End of setup code.

# 1. (20pts) 
# Calculate the maximum drawdown depth (the minimum 
# value of draw_downs), and call it max_drawdown. 
# Calculate the integer index corresponding to the 
# minimum value (call it index_min), and calculate
# the date when it reaches its minimum (call it 
# date_min). 
# You can use date_s and the functions min(), 
# which(), or which.min().

### write your code here
max_drawdown <- min(draw_downs)
index_min <- which(draw_downs == max_drawdown)
date_min <- date_s[index_min]

# You should get the following outputs:
max_drawdown
# [1] -0.809
index_min
# [1] 1953
date_min
# [1] "2009-03-09"


# 2. (20pts)
# Calculate the dates when the drawdown started and ended. 
# The drawdown started on the last date when draw_downs was 
# still zero before it starts decreasing (call it date_from).
# The drawdown ended on the first date when draw_downs 
# recovered to zero after it reached its low (call it date_to).
# Hint: Perform logical operations on the date_s vector.
# You can use date_s and the functions max() and min().

### write your code here
date_start <- date_s[max(which(date_s < date_min & draw_downs==0))]
date_end <- date_s[min(which(date_s > date_min & draw_downs==0))]
# You should get the following outputs:
date_start
# [1] "2007-10-09"
date_end
# [1] "2012-03-13"



############## Part II
# Summary: Fit t-distributions with different degrees 
# of freedom into VTI returns.

## Run the setup code below:

# Calculate VTI percentage returns.
re_turns <- rutils::diff_it(log(quantmod::Cl(rutils::etf_env$VTI)))

# Define the log-likelihood objective function:
likeli_hood <- function(par, dfree, data) {
  -sum(log(dt(x=(data-par[1])/par[2], df=dfree)/par[2]))
}  # end likeli_hood


## End of setup code. 

# 1. (30pts) 

# Define a vector of degrees of freedom parameters:

dfree_vec <- 2:5

# Perform an sapply() loop over dfree_vec.
# For each value of dfree, fit the t-distribution into VTI 
# returns using function optim().
# Extract and return the log-likelihood value: optim_fit$value
# 
# Hint: copy code from the slide: 
#  Fitting Asset Returns into Student’s t-distribution
# 
# You can use the functions c(), optim(), pt(), diff(), t(), 
# cbind(), rt(), NROW(), chisq.test(), and ks.test().

### write your code here
par_init <- c(mean=0, scale=0.01)
optim_fit <- sapply(dfree_vec,function(df) optim(par=par_init,
                       fn=likeli_hood, # Log-likelihood function
                       data=re_turns,
                       dfree = df, # Degrees of freedom
                       method="L-BFGS-B", # quasi-Newton method
                       upper=c(1, 0.1), # upper constraint
                       lower=c(-1, 1e-7)))

l_vals <- unlist(optim_fit[2,])
# You should get output similar to this:
l_vals
# [1] -15652.32 -15655.89 -15617.56 -15573.26

# Plot the log-likelihood values.
# You can use the function plot().

### write your code here
plot(x = dfree_vec,y = l_vals,xlab="degrees of freedom",ylab="likelihood",
     main = "Likelihood vs Degrees of Freedom",type="l", col="blue", lwd=2)

# Your plot should be similar to fit_tlike.png

# The plot shows that the best fit for VTI returns 
# is for t-distributions with either 2 or 3 
# degrees of freedom.

