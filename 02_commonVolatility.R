rm(list = ls())
library(xts)
library(rugarch)
library(geovol)

# 01 Exploratory data analysis & data cleaning -----
data <- read.csv("~/Desktop/common_vol/logreturn.csv")
data$Date <- as.Date(data$Date)
is.xts(data)

data <- xts(data[, -1], order.by = data$Date)
is.xts(data)

## plot each return series
# Generate plots for each column in the xts object
plotreturns <- function(){
  # mar: bottom, left, top, right
  par(mfrow = c(5, 2), mar = c(4, 4, 2, 2))
  for (col_name in colnames(data)) {
    plot(index(data), data[, col_name], type = "l", 
      main = paste("Return of", col_name), xlab = "Date", 
      ylab = "Return", col = "blue")
    }
  par(mfrow = c(1, 1))  #Reset plotting parameters to default
  }

plotreturns()

# replace incorrect return values due to stock split with 0
data["2024-08-08", "XST.TO"] <- 0
data["2024-08-09", "XST.TO"] <- 0

data["2008-08-06", "XIC.TO"] <- 0
data["2008-08-06", "XFN.TO"] <- 0
data["2008-08-06", "XMA.TO"] <- 0
data["2008-08-06", "XEG.TO"] <- 0

plotreturns()


xic <- data$XIC.TO  #extracts the market return 
data <- data[, -1]  #removes xic, making 'data' consisting of sector returns only

# 02 Fit an AR(1)-GARCH(1,1)-X model to each series & save std. residuals -----
garch_model <- "sGARCH"
dist_type <- "norm"

data <- data[-1, ]  #remove the first row 
xic <- xic[-1, ]

# calculates the row-wise means of the data object (matrix or a data frame),
#   na.rm = TRUE: missing values (NA) should be removed before calculating the mean.
means <- rowMeans(data, na.rm = TRUE)

# data for principal component analysis, pc
pc.data <- data

# replacing any missing values (NA) in that row with the corresponding mean value calculated earlier
#  is.na() function in R is used to determine 
#  whether each element in an object is missing (NA) or not. 
#  It returns a logical vector of the same length as the input, 
#  where each element is TRUE if the corresponding element in the input is NA 
#  and FALSE otherwise.
for (t in 1 : nrow(data)) {
  pc.data[t, which(is.na(data[t, ]))] <- means[t]
}

# using the princomp function in R to perform PCA on the data stored in the pc.data variable
#   cor = TRUE specifies that the PCA should be based on the correlation matrix
#   instead of the covariance matrix.
#   fix_sign = TRUE ensures that the signs of the principal components are fixed,
#   making the results more reproducible
pc.r <- princomp(pc.data, cor = TRUE, fix_sign = TRUE)

scores <- pc.r$scores  #data in the rotated coordinate system
# loadings: the matrix of variable loadings 
#   i.e., a matrix whose columns contain the eigenvectors
loadings <- pc.r$loadings

pc1 <- xts(-scores[, 1], order.by = index(data))
X <- cbind(pc1, xic)

# NA_real_ is a special constant in R representing a missing value (NA) of type double.
#   It is used to initialize a matrix filled with missing values.
# The 'order.by' parameter specifies the time index for the time series.
#   In this case, it's set to the time index of the original data object, index(data)
e_ETFs <- xts(matrix(NA_real_, nrow(data), ncol(data)), order.by = index(data))
colnames(e_ETFs) <- colnames(data)

u_ETFs <- xts(matrix(NA_real_, nrow(data), ncol(data)), order.by = index(data))
colnames(u_ETFs) <- colnames(data)

vol_ETFs <- xts(matrix(NA_real_, nrow(data), ncol(data)), order.by = index(data))
colnames(vol_ETFs) <- colnames(data)

for (i in 1:ncol(data)) {
  # !is.na(data[, i]): creates a logical vector of the same length as the i-th column of data, 
  # where each element is FALSE('!') if the corresponding element in data[, i] is NA
  y_rmna <- data[!is.na(data[, i]), i]
  
  # extracts the rows from X where there are non-missing values
  # in the i-th column of 'data'
  x_rmna <- as.matrix(X[!is.na(data[, i])])
  
  # 'external.regressors' specifies that the external variables that should be used 
  # in the mean equation of the GARCH model.
  spec = ugarchspec(variance.model = list(model = garch_model,
                                          garchOrder = c(1, 1)),
                    mean.model = list(armaOrder = c(1, 0), include.mean = TRUE,
                                      external.regressors = x_rmna),
                    distribution.model = dist_type)
  
  garch_est <- ugarchfit(data = y_rmna, spec = spec, solver = "hybrid")
  e_ETFs[!is.na(data[, i]), i] <- residuals(garch_est, standardize = TRUE)  #standardized residual, e
  u_ETFs[!is.na(data[, i]), i] <- residuals(garch_est, standardize = FALSE)  #residual, u
  vol_ETFs[!is.na(data[, i]), i] <- sigma(garch_est)  #conditional volatility (i.e., sigma_t), vol
}

## can make some plots for the results above
rowmeans_u <- rowMeans(u_ETFs, na.rm = TRUE)
rowmeans_u <- xts(rowmeans_u, order.by = index(u_ETFs))
plot(rowmeans_u, main='Average of sector return residuals')

rowmeans_e <- rowMeans(e_ETFs, na.rm = TRUE)
rowmeans_e <- xts(rowmeans_e, order.by = index(e_ETFs))
plot(rowmeans_e, main='Average of standardized residuals from sector returns')

rowmeans_vol <- rowMeans(vol_ETFs, na.rm = TRUE)
rowmeans_vol <- xts(rowmeans_vol, order.by = index(vol_ETFs))
plot(rowmeans_vol, main='Average volatility of sector returns')


# the above was only for sector ETFs
# still have two return series left which are
# the market return 'xic', and the first principal component
spec <- ugarchspec(variance.model = list(model = garch_model,
                                         garchOrder = c(1, 1)),
                   mean.model = list(armaOrder = c(1, 0), include.mean = TRUE),
                   distribution.model = dist_type)
garch_est <- ugarchfit(data = xic, spec = spec, solver = "hybrid")
e_xic <- residuals(garch_est, standardize = TRUE)
vol_xic <- sigma(garch_est)  #sigma = conditional vol, sigma^2 = conditional var.

plot(vol_xic, main='Market Volatility')

# the final return series is the first principal component
pc1 <- as.matrix(scale(pc.data) %*% loadings[, 1])
pc1 <- xts(pc1, order.by = index(data))
garch_est <- ugarchfit(data = pc1, spec = spec, solver = "hybrid")
e_pc1 <- residuals(garch_est, standardize = TRUE)

e_global <- cbind(e_ETFs, e_xic, e_pc1)
sector_names <- c('consumer', 'industrials', 'financial', 'materials', 'utilities',
                  'IT', 'energy', 'REIT')
colnames(e_global) <- c(sector_names, "xic", "pc1")
n <- ncol(e_global)
nT <- nrow(e_global)

# 03 Test for global COVOL using squared std. residuals -----
geovolTest(e = e_global^2 - 1)
#       Correlation Statistic p-value
# Value      0.1495   60.2886       0

# 04 Estimate global COVOL and loadings -----
globalCOVOL_Fit <- geovol(e = e_global)
globalCOVOL_Fit

# Estimated GEOVOL factor (20 most extreme values): 
#   
# GEOVOL
# 2011-01-21 69.6707
# 2020-11-09 55.7644
# 2020-03-09 44.9155
# 2016-11-10 40.3995
# 2020-03-13 31.5448
# 2016-05-31 29.2721
# 2010-01-07 29.0019
# 2013-07-15 25.8489
# 2008-09-17 24.1621
# 2013-06-28 20.1363
# 2007-02-27 19.4235
# 2009-09-09 18.0360
# 2023-12-13 16.4053
# 2020-03-18 15.5149
# 2010-01-08 15.3738
# 2019-09-16 15.0940
# 2012-12-21 14.5057
# 2013-04-15 13.8775
# 2020-03-23 13.7671
# 2020-03-12 12.8194
# 
# Estimated GEOVOL loadings: 
#   
#   pc1         xic industrials   financial   utilities      energy   materials 
# 0.4085      0.4080      0.3376      0.2949      0.2871      0.2863      0.2836 
# IT    consumer        REIT 
# 0.2781      0.2685      0.2673 

# 05 Check goodness-of-fit -----
e_global_Post <- e_global
for (i in 1:ncol(e_global_Post)) {
  e_global_Post[!is.na(e_global_Post[, i]), i] <-
    e_global_Post[!is.na(e_global_Post[, i]), i] /
    sqrt(globalCOVOL_Fit$geovol2[!is.na(e_global_Post[, i]), i])
}

geovolTest(e = e_global_Post^2-1)
#         Correlation Statistic p-value
# Value     -0.0386   -13.789       1

# save the results
x <- data.frame(x = globalCOVOL_Fit$x)
colnames(x) <- c('covol')
write.csv(x, '~/Desktop/common_vol/covol.csv')
