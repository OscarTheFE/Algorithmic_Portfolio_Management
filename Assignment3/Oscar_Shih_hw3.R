#################################
### FRE7241 Homework #3 due at 6AM Thursday October 21st, 2021
#################################
# Max score 100pts

# Please write in this file the R code needed to perform the tasks below, 
# rename it to your_name_hw3.R
# and upload the file to NYU Classes


############## Part I
# Summary: Calculate the number of trades in an EWMA 
# strategy, and plot the number of trades as a function 
# of the lambda decay parameter.

## Run the setup code below.

# Specify EWMA strategy parameters
library(rutils)
oh_lc <- rutils::etf_env$VTI
look_back <- 333
lamb_da <- 0.01
bid_offer <- 0

# Define EWMA strategy simulation function
sim_ewma <- function(ohlc, lambda=0.01, look_back=333, bid_offer=0.001, 
                     trend=1, lagg=1) {
  close <- log(quantmod::Cl(ohlc))
  returns <- rutils::diff_it(close)
  n_rows <- NROW(ohlc)
  # Calculate EWMA prices
  weights <- exp(-lambda*(1:look_back))
  weights <- weights/sum(weights)
  ewma <- HighFreq::roll_wsum(close, weights=weights)
  # Calculate the indicator
  indic <- trend*sign(close - ewma)
  if (lagg > 1) {
    indic <- roll::roll_sum(indic, width=lagg, min_obs=1)
    indic[1:lagg] <- 0
  }  # end if
  # Calculate positions, either: -1, 0, or 1
  pos <- rep(NA_integer_, n_rows)
  pos[1] <- 0
  pos <- ifelse(indic == lagg, 1, pos)
  pos <- ifelse(indic == (-lagg), -1, pos)
  pos <- zoo::na.locf(pos, na.rm=FALSE)
  pos <- xts::xts(pos, order.by=index(close))
  # Lag the positions to trade on next day
  pos <- rutils::lag_it(pos, lagg=1)
  # Calculate PnLs of strategy
  pnls <- returns*pos
  costs <- 0.5*bid_offer*abs(rutils::diff_it(pos))*close
  pnls <- (pnls - costs)
  # Calculate strategy returns
  pnls <- cbind(pos, pnls)
  colnames(pnls) <- c("positions", "pnls")
  pnls
}  # end sim_ewma

## End of setup.


# 1. (20pts) 
# Simulate the EWMA strategy calling sim_ewma() with the 
# setup parameters, and extract the output time series 
# position_s.

### write your code here
position_s <- sim_ewma(ohlc = oh_lc)[,1]

# You should get the following outputs:
class(position_s)
# [1] "xts" "zoo"
dim(position_s)
# [1] 4987    1
sum(position_s)
# [1] 2822
tail(position_s)
#            positions
# 2021-03-19         1
# 2021-03-22         1
# 2021-03-23         1
# 2021-03-24         1
# 2021-03-25         1
# 2021-03-26         1


# Calculate the number of trades in the EWMA strategy 
# from the time series position_s.
# The number of trades is equal to the number of 
# times the EWMA strategy changes its risk position,
# including the first trade when the strategy trades
# out of the initial zero risk position.
# You can use the functions sum(), rutils::diff_it(),
# and abs().

### write your code here
chg <- rutils::diff_it(position_s) != 0
sum(chg)
# You should get the following output:
# [1] 160


# 2. (20pts) 
# Calculate a vector of parameters called lamb_das.
# You can use the function seq().

### write your code here
lamb_das <- seq(0.01, 0.4, 0.01)

# You should get the following output:
#  [1] 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14
# [15] 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28
# [29] 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40

# Perform an sapply() loop over the lamb_das parameters, 
# to calculate the number of trades as a function of the 
# lambda decay parameter.

### write your code here
n_trades <- sapply(lamb_das, function(x) {pos <- sim_ewma(oh_lc, lambda = x)[,1]
return (sum(rutils::diff_it(pos) != 0))})

# You should get the following output:
n_trades
#  [1]  160  222  286  324  400  434  451  509  553  581  609  627  657  687
# [15]  713  741  777  789  817  849  859  883  901  937  955  973  987 1003
# [29] 1009 1021 1035 1053 1073 1081 1097 1121 1133 1147 1153 1171

# The data shows that the number of trades increases with 
# the lambda decay parameter, because the EWMA follows the 
# prices more closely, so it crosses them more often.


# Plot the number of trades using plot().

### write your code here
plot(y = n_trades,x = lamb_das,t='l',col='blue',lwd=2,xlab='Decay Parameter Lambda',ylab='Number of Trades'
     ,main='Number of Trades as Function of the Decay Parameter Lambda')


# Your plot should be similar to ewma_number_trades.png



############## Part II
# Summary: Simulate the Hampel strategy to find 
# the best values of the look-back and threshold 
# parameters.

## Run the setup code below.

# Calculate VTI percentage returns
clos_e <- log(quantmod::Cl(rutils::etf_env$VTI))
colnames(clos_e) <- "VTI"
re_turns <- rutils::diff_it(clos_e)
# Define look-back window
look_back <- 11
# Define threshold value
thresh_old <- 2.5

## End of setup.


# 1. (20pts)
# Create a function called sim_hampel(), which simulates 
# the Hampel strategy, and produces its returns.
# The function sim_hampel() should accept two arguments: 
# - look_back = the look-back interval
# - threshold = the threshold level
# 
# Hint: Copy code from the lecture slides.

### write your code here
sim_hampel <- function(look_back, threshold) {
  medi_an <- roll::roll_median(clos_e, width=look_back)
  # Calculate time series of MAD
  ma_d <- HighFreq::roll_var(clos_e, look_back=look_back, method="quantile")
  # Calculate time series of z-scores
  z_scores <- (clos_e - medi_an)/ma_d
  z_scores[1:look_back, ] <- 0
  
  position_s <- rep(NA_integer_, NROW(clos_e))
  position_s[1] <- 0
  position_s[z_scores < -threshold] <- 1
  position_s[z_scores > threshold] <- (-1)
  position_s <- zoo::na.locf(position_s)
  position_s <- rutils::lag_it(position_s)
  return(re_turns*position_s)
}

# Run sim_hampel() as follows:
pnl_s <- sim_hampel(look_back=look_back, threshold=thresh_old)

# You should get the following outputs:
class(pnl_s)
# [1] "xts" "zoo"
dim(pnl_s)
# [1] 4987    1
sum(pnl_s)/sd(pnl_s)
# [1] 100.7618


# 2. (20pts)
# Create a vector of thresholds (run this):
threshold_s <- seq(1.0, 4.0, 0.1)

# Perform an lapply() loop over the thresholds, 
# with look_back = 11.  Collapse the list into an
# xts time series called pnl_s.
# You can use the functions do.call() and cbind().

### write your code here
pnl_s <- lapply(threshold_s, function(x) {sim_hampel(look_back,threshold = x)})
pnl_s <- do.call(cbind,pnl_s)
# You should get the following outputs:
class(pnl_s)
# [1] "xts" "zoo"
dim(pnl_s)
# [1] 4987    31


# Calculate the ratios: sum(x)/sd(x)
# for all the columns of pnl_s.
# You can use the functions sapply(), sum(), and sd().

### write your code here
ratio_s <- sapply(seq(1,31),function(x) {sum(pnl_s[,x])/sd(pnl_s[,x])})

# You should get the following output:
ratio_s
#       VTI     VTI.1     VTI.2     VTI.3     VTI.4     VTI.5     VTI.6     VTI.7 
#  74.34208  62.80924  88.75945  22.60875  56.48698 107.09551 112.49136  88.19398 
#     VTI.8     VTI.9    VTI.10    VTI.11    VTI.12    VTI.13    VTI.14    VTI.15 
#  60.51225 133.79112 183.47656 152.71469 119.01355  94.28866 103.01026 100.76183 
#    VTI.16    VTI.17    VTI.18    VTI.19    VTI.20    VTI.21    VTI.22    VTI.23 
#  75.86443  97.87866 126.94488 137.79967 157.71980 137.88032 137.88032 146.13690 
#   VTI.24    VTI.25    VTI.26    VTI.27    VTI.28    VTI.29    VTI.30 
# 146.13690 160.44326 158.10056 158.10056  84.17036  41.75497  41.75497 

# Plot ratio_s using plot().
# Your plot should be similar to strat_hampel_thresholds.png

### write your code here
plot(threshold_s,ratio_s,t='l',col='blue',lwd=2,xlab='threshold_s',ylab='ratio_s')

# Calculate the threshold value that produces the 
# maximum ratio.
# You can use the functions which.max() and max().

### write your code here
threshold_s[which.max(ratio_s)]
# You should get the following output:
# [1] 2

# Calculate the the second largest ratio_s value.
# You can use the function sort().
# Or you can use the functions which.max() and max().

### write your code here
max2 <- sort(ratio_s,decreasing=TRUE)[2]
# You should get the following output:
max2
# [1] 160.4433

# Calculate the threshold value that produces the 
# second largest ratio_s value.
# You can use the function which().

### write your code here
threshold_s[which(ratio_s==max2)]
# You should get the following output:
# [1] 3.5


# 3. (20pts)
# Create a vector of look_backs (run this):
look_backs <- 5:20

# Perform an lapply() loop over the look_backs, 
# with threshold = 2.  Collapse the list into an
# xts time series called pnl_s.
# You can use the functions do.call() and cbind().

### write your code here
pnl_s <- lapply(look_backs,function(x) {sim_hampel(x,threshold=2 )})
pnl_s <- do.call(cbind,pnl_s)
# You should get the following outputs:
class(pnl_s)
# [1] "xts" "zoo"
dim(pnl_s)
# [1] 4987    16


# Calculate the ratios: sum(x)/sd(x)
# for all the columns of pnl_s.
# You can use the functions sapply(), sum(), and sd().

### write your code here
ratio_s <- sapply(seq(1,16),function(x) {sum(pnl_s[,x])/sd(pnl_s[,x])})

# You should get the following output:
ratio_s
#        VTI      VTI.1      VTI.2      VTI.3      VTI.4      VTI.5      VTI.6      VTI.7 
#  -6.885715  90.489818  59.157119  81.866072 124.851367 105.494924 183.476557 130.348041 
#      VTI.8      VTI.9     VTI.10     VTI.11     VTI.12     VTI.13     VTI.14     VTI.15 
# 156.864052  31.509211 127.897124 112.210350  64.492719  35.225316  41.559408  65.741980

# Calculate the look_back value that produces the 
# maximum ratio.
# You can use the functions which.max() and max().

### write your code here
look_backs[which.max(ratio_s)]
# You should get the following output:
# [1] 11

# Calculate the Hampel pnl_s for the optimal parameters 
# using function sim_hampel().

### write your code here
pnl_s <- sim_hampel(11, 2)

# Plot dygraph of Hampel strategy pnl_s.
# Your plot should be similar to strat_hampel_optim.png

### write your code here
weal_th <- cbind(re_turns, pnl_s)
colnames(weal_th) <- c("VTI", "Strategy")
dygraphs::dygraph(cumsum(weal_th), main="VTI Hampel Strategy") %>%
  dyOptions(colors=c("blue", "red"), strokeWidth=2) %>%
  dyLegend(show="always", width=500)
