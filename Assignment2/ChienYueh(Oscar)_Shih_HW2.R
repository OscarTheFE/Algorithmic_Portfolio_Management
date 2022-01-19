#################################
### FRE7241 Homework #2 due at 6AM Tuesday, October 5th, 2021
#################################
# Max score 80pts

# Please write in this file the R code needed to perform the tasks below, 
# rename it to your_name_hw2.R
# and upload the file to NYU Classes

############## Part I
# Summary: Simulate the risk parity strategy to find 
# the best values of the look-back and the weights 
# parameters.

## Run the setup code below.

# Calculate the percentage returns for VTI and IEF.
price_s <- rutils::etf_env$price_s[, c("VTI", "IEF")]
price_s <- na.omit(price_s)
rets_dollar <- rutils::diff_it(price_s)
rets_percent <- rets_dollar/rutils::lag_it(price_s, lagg=1, pad_zeros=FALSE)


## End of setup.


# 1. (20pts)
# Create a function called run_parity(), which simulates 
# the risk parity strategy, and returns the ratio of the 
# sum of the risk parity portfolio returns divided by their
# standard deviation.
# The function run_parity() should accept two arguments: 
# - look_back = the look-back interval
# - weight_stocks = the weight of the stocks (VTI)
# 
# It should calculate the portfolio weights as:
#   c(weight_stocks, 1-weight_stocks)
# Hint: Copy code from the lecture slides.

### write your code here
run_parity <- function(look_back, weight_stocks){
  weight_s <- c(weight_stocks, 1 - weight_stocks)
  # Calculate rolling percentage volatility.
  vo_l <- roll::roll_sd(rets_percent, width=look_back)
  vo_l <- zoo::na.locf(vo_l, na.rm=FALSE)
  vo_l <- zoo::na.locf(vo_l, fromLast=TRUE)
  # Calculate the risk parity portfolio allocations.
  allocation_s <- lapply(1:NCOL(price_s),
                         function(x) weight_s[x]/vo_l[, x])
  allocation_s <- do.call(cbind, allocation_s)
  # Scale allocations to 1 dollar total.
  allocation_s <- allocation_s/rowSums(allocation_s)
  # Lag the allocations
  allocation_s <- rutils::lag_it(allocation_s)
  # Calculate wealth of risk parity.
  rets_weighted <- rowSums(rets_percent * allocation_s)
  return(sum(rets_weighted)/sd(rets_weighted))
} #end function

# Run run_parity() as follows:
run_parity(look_back=21, weight_stocks=0.5)

# You should get the following output:
# [1] 383.661


# 2. (20pts)
# Create a vector of look_backs (run this):
look_backs <- 3:51

# Perform an sapply() loop over look_backs, 
# with weight_stocks=0.5

### write your code here
da_ta <- sapply(look_backs, function(x) {run_parity(x, 0.5)})

# You should get the following output:
da_ta
#  [1] 365.873 353.055 374.858 353.532 361.587 375.463 381.879
#  [8] 382.440 385.591 385.941 380.934 382.060 380.116 382.374
# [15] 382.708 382.834 383.133 384.498 383.661 382.887 381.440
# [22] 382.146 385.331 383.655 385.184 384.451 381.033 382.573
# [29] 382.417 383.772 382.826 383.094 383.866 384.761 383.037
# [36] 381.699 384.594 383.703 382.519 383.818 384.450 382.713
# [43] 382.977 382.452 383.405 383.445 383.542 383.839 384.687

# Calculate the look_back that produces the maximum 
# da_ta value.
# You can use the function which.max().

### write your code here
look_backs[which.max(da_ta)]
# You should get the following output:
# [1] 12

# Plot da_ta using plot().
# Your plot should be similar to strat_parity_lookbacks.png
### write your code here
plot(x=look_backs,y=da_ta,type='l',col='black')

# Create a vector of stock_weights (run this):
stock_weights <- seq(0.1, 0.9, by=0.1)

# Perform an sapply() loop over look_backs, 
# with look_back=12

### write your code here
da_ta <- sapply(stock_weights, function(x) run_parity(12, x))

# You should get the following output:
da_ta
# [1] 247.774 288.881 333.582 371.577 385.941 367.778
# [7] 327.265 280.201 234.818

# Calculate the stock_weights that produces the maximum 
# da_ta value.
# You can use the function which.max().

### write your code here
stock_weights[which.max(da_ta)]

# You should get the following output:
# [1] 0.5

# Plot da_ta using plot().
# Your plot should be similar to strat_parity_weights.png

### write your code here
plot(x=stock_weights,y=da_ta,type='l',col='black')



############## Part II
# Summary: Simulate the CPPI strategy to find 
# the best values of the bond floor and leverage 
# multiplier.

## Run the setup code below.

# Calculate VTI returns
re_turns <- na.omit(rutils::etf_env$re_turns$VTI["2008/2012"])
date_s <- index(re_turns)
n_rows <- NROW(re_turns)
re_turns <- drop(zoo::coredata(re_turns))

bfloor <- 60  # bond floor
co_eff <- 2  # multiplier

portf_value <- numeric(n_rows)
portf_value[1] <- 100  # principal
stock_value <- numeric(n_rows)
bond_value <- numeric(n_rows)

## End of setup.


# 1. (20pts)
# Create a function called run_cppi(), which simulates 
# the CPPI strategy, and returns the final portfolio
# value.
# The function run_cppi() should accept two arguments: 
# - bfloor = the bond floor
# - co_eff = the leverage multiplier
# Hint: Copy code from the lecture slides.

### write your code here
run_cppi <- function(bfloor, co_eff){
  stock_value[1] <- co_eff*(portf_value[1] - bfloor)
  bond_value[1] <- (portf_value[1] - stock_value[1])
  
  for (t in 2:n_rows) {
    portf_value[t] <- portf_value[t-1] + stock_value[t-1]*re_turns[t]
    stock_value[t] <- co_eff*(portf_value[t] - bfloor)
    bond_value[t] <- (portf_value[t] - stock_value[t])
  } #end for
  return(portf_value[n_rows])
} # end run_cppi

# Run run_cppi() as follows:
run_cppi(bfloor=60, co_eff=2)

# You should get the following output:
# [1] 85.8352


# 2. (20pts)
# Create a vector of bfloors (run this):
bfloors <- 40:90

# Perform an sapply() loop over bfloors, 
# with co_eff=2

### write your code here
da_ta <- sapply(bfloors, function(x) run_cppi(x,co_eff = 2))

# You should get the following output:
da_ta
#  [1] 78.75279 79.10691 79.46103 79.81515 80.16927 80.52339 80.87751 81.23163 81.58575
# [10] 81.93987 82.29399 82.64811 83.00224 83.35636 83.71048 84.06460 84.41872 84.77284
# [19] 85.12696 85.48108 85.83520 86.18932 86.54344 86.89756 87.25168 87.60580 87.95992
# [28] 88.31404 88.66816 89.02228 89.37640 89.73052 90.08464 90.43876 90.79288 91.14700
# [37] 91.50112 91.85524 92.20936 92.56348 92.91760 93.27172 93.62584 93.97996 94.33408
# [46] 94.68820 95.04232 95.39644 95.75056 96.10468 96.45880

# Calculate the look_back that produces the maximum 
# da_ta value.
# You can use the function which.max().

### write your code here
bfloors[which.max(da_ta)]
# You should get the following output:
# [1] 90

# Create a vector of co_effs (run this):
co_effs <- 2:6

# Perform an sapply() loop over co_effs, 
# with bfloor=90

### write your code here
da_ta <- sapply(co_effs, function(x) run_cppi(bfloor = 90,co_eff = x))

# You should get the following output:
da_ta
# [1] 96.45880 93.05392 90.99388 90.21703 90.03059

# Calculate the look_back that produces the maximum 
# da_ta value.
# You can use the function which.max().

### write your code here
co_effs[which.max(da_ta)]
# You should get the following output:
# [1] 2

# This demonstrates that if stocks are in a 
# bear market (they underperform) then the best 
# parameters for the CPPI strategy are a high 
# bond floor and low leverage.
