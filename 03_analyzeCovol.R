# 06 Visualize common volatility, covol -----
rm(list = ls())
x <- read.csv("~/Desktop/common_vol/covol.csv")
x$X <- as.Date(x$X)
is.xts(x)

x <- xts(x[, -1], order.by = x$X)
is.xts(x)
colnames(x) <- c('covol')

plot(x$covol, type='p', xlab = "Date", 
     ylab = "Estimated COVOL Value",
     main='Magnitude of Volatility Comovement')

# # calculate rolling x
# library(zoo)
# x$rolling <- rollmean(x$covol, k = 3, fill = NA)
# plot(x$rolling, type='p', xlab = "Date", 
#      ylab = "Rolling COVOL Value", 
#     main='Magnitude of Volatility Comovement (Rolling)')



# 07 Identify top 5 risk events -----
# that shook most sectors in the stock market

# 2011-01-21 69.6707 
  # Canadian Stock Market Attractive Escape From Falling U.S. Dollar (moneymorning.com)
# 2020-11-09 55.7644
  # Canada Stocks Surge on Vaccine Breakthrough, Led by Energy (bloomberg.com)
# 2020-03-09 44.9155
  # TSX sinks 10.3 per cent to 14-month low on plunging oil prices (toronto.citynews.ca)
# 2016-11-10 40.3995
  # Surprise U.S. Election Result in the Nov. 8 (marketwatch.com)
# 2020-03-13 31.5448
  # COVID-19 and plummeting oil prices (bloomberg.com)
