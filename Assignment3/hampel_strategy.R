# Calculate VTI percentage returns
clos_e <- log(na.omit(rutils::etf_env$price_s$VTI))
re_turns <- rutils::diff_it(clos_e)
# Define look-back window
look_back <- 11
# Calculate time series of medians
medi_an <- roll::roll_median(clos_e, width=look_back)
# Calculate time series of MAD
ma_d <- HighFreq::roll_var(clos_e, look_back=look_back, method="quantile")
# Calculate time series of z-scores
z_scores <- (clos_e - medi_an)/ma_d
z_scores[1:look_back, ] <- 0
tail(z_scores, look_back)
range(z_scores)
# Define threshold value
thresh_old <- sum(abs(range(z_scores)))/8
# Simulate VTI strategy
position_s <- rep(NA_integer_, NROW(clos_e))
position_s[1] <- 0
position_s[z_scores < -thresh_old] <- 1
position_s[z_scores > thresh_old] <- (-1)
position_s <- zoo::na.locf(position_s)
position_s <- rutils::lag_it(position_s)
pnl_s <- re_turns*position_s

# Plot dygraph of Hampel strategy pnl_s
weal_th <- cbind(re_turns, pnl_s)
colnames(weal_th) <- c("VTI", "Strategy")
dygraphs::dygraph(cumsum(weal_th), main="VTI Hampel Strategy") %>%
  dyOptions(colors=c("blue", "red"), strokeWidth=2) %>%
  dyLegend(show="always", width=500)
