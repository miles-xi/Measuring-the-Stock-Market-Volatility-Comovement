#Chap02_common volatility
rm(list = ls())
library(xts)
library(rugarch)
library(geovol)
load("~/Desktop/中证行业分类/stockReturn_CSI800.RData")

#library(openxlsx)
#write.xlsx(data, file="~/Desktop/Stata/describeData/industryLogReturnsDescribe.xlsx")

is.xts(data)
data <- xts(data[, -1], order.by = data$date)
csi800 <- data$csi800 ##extracts csi800
data <- data[, -1] ##removes csi800

#### 02 Fit an AR(1)-GARCH(1,1)-X model to each series & save std. residuals
garch_model <- "sGARCH"
dist_type <- "norm"

data <- data[-c(1,2), ] #remove the first 2 rows
csi800 <- csi800[-c(1,2), ]

#calculates the row-wise means of the data object (matrix or a data frame),
# na.rm = TRUE specifies that
# missing values (NA) should be removed before calculating the mean.
means <- rowMeans(data, na.rm = TRUE)

#data for principal component analysis, pc
pc.data <- data

#replacing any missing values (NA) in that row 
#with the corresponding mean value calculated earlier
#  is.na() function in R is used to determine 
#  whether each element in an object is missing (NA) or not. 
#  It returns a logical vector of the same length as the input, 
#  where each element is TRUE if the corresponding element in the input is NA 
#  and FALSE otherwise.
for (t in 1 : nrow(data)) {
  pc.data[t, which(is.na(data[t, ]))] <- means[t]
}

#using the princomp function in R to perform PCA
#on the data stored in the pc.data variable
# cor = TRUE specifies that the PCA should be based on the correlation matrix
# instead of the covariance matrix.
# fix_sign = TRUE ensures that the signs of the principal components are fixed,
# making the results more reproducible.
pc.r <- princomp(pc.data, cor = TRUE, fix_sign = TRUE)

scores <- pc.r$scores #data in the rotated coordinate system
#loadings: the matrix of variable loadings 
#(i.e., a matrix whose columns contain the eigenvectors)
loadings <- pc.r$loadings

pc1 <- xts(-scores[, 1], order.by = index(data))
X <- cbind(pc1, csi800)

#NA_real_ is a special constant in R
#representing a missing value (NA) of type double.
#It is used to initialize a matrix filled with missing values.
# The order.by parameter specifies the time index for the time series.
# In this case, it's set to the time index of the original data object, index(data)
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
  
  #extracts the rows from X where there are non-missing values
  #in the i-th column of 'data'
  x_rmna <- as.matrix(X[!is.na(data[, i])])
  
  #specifies that the external variables that should be used 
  #in the mean equation of the GARCH model.
  spec = ugarchspec(variance.model = list(model = garch_model,
                                          garchOrder = c(1, 1)),
                    mean.model = list(armaOrder = c(1, 0), include.mean = TRUE,
                                      external.regressors = x_rmna),
                    distribution.model = dist_type)
  garch_est <- ugarchfit(data = y_rmna, spec = spec, solver = "hybrid")
  e_ETFs[!is.na(data[, i]), i] <- residuals(garch_est, standardize = TRUE)
  u_ETFs[!is.na(data[, i]), i] <- residuals(garch_est, standardize = FALSE)
  vol_ETFs[!is.na(data[, i]), i] <- sigma(garch_est)
}
u_ETFs$rowMeans <- rowMeans(u_ETFs, na.rm = TRUE)
#plot u_ETFs$rowMeans. see 05_plot.R

vol_ETFs$rowMeans <- sqrt(rowMeans(vol_ETFs^2, na.rm = TRUE))
#plot vol_ETFs$rowMeans. see 05_plot.R


spec <- ugarchspec(variance.model = list(model = garch_model,
                                         garchOrder = c(1, 1)),
                   mean.model = list(armaOrder = c(1, 0), include.mean = TRUE),
                   distribution.model = dist_type)
garch_est <- ugarchfit(data = csi800, spec = spec, solver = "hybrid")
e_csi800 <- residuals(garch_est, standardize = TRUE)
vol_csi800 <- sigma(garch_est) # sigma = conditional vol, sigma^2 = conditional var.
#plot vol_csi800. see 05_plot.R

pc1 <- as.matrix(scale(pc.data) %*% loadings[, 1])
pc1 <- xts(pc1, order.by = index(data))
garch_est <- ugarchfit(data = pc1, spec = spec, solver = "hybrid")
e_pc1 <- residuals(garch_est, standardize = TRUE)

e_global <- xts(as.matrix(cbind(e_ETFs, e_csi800, e_pc1)), order.by = index(data))
colnames(e_global) <- c(colnames(data), "csi800", "pc1")
n <- ncol(e_global)
nT <- nrow(e_global)

#### 03 Test for global COVOL using squared std. residuals
geovolTest(e = e_global^2 - 1)
#Correlation Statistic p-value
#Value 0.108   53.9262       0

#### 04 Estimate global COVOL and loadings
globalCOVOL_Fit <- geovol(e = e_global)
globalCOVOL_Fit

#Date: Sun Apr 14 21:26:48 2024 
#Model: GEOVOL 
#Method: maximization-maximization (algorithm stopped after 19 iterations) 
#No. of observations: 3583 
#No. of time series: 13 
#
#Estimated GEOVOL factor (20 most extreme values): 
#  
#  GEOVOL
#2020-02-03 20.9576
#2010-10-11 16.0634
#2014-12-08 13.2555
#2011-12-15 13.0747
#2014-12-22 12.6005
#2020-02-24 12.3500
#2021-02-18 12.3191
#2014-12-04 11.7009
#2023-07-25 11.5416
#2015-08-26 11.3069
#2013-12-02 10.8981
#2016-02-29 10.7169
#2016-01-04 10.6780
#2019-11-25 10.4697
#2020-02-26 10.3764
#2015-01-19 10.2276
#2012-09-07 10.1880
#2012-12-03 10.1874
#2020-07-06 10.1863
#2021-05-06 10.0760
#
#Estimated GEOVOL loadings: 
#  
#csi800   pc1  finance   energy   property   utility 
#0.3959  0.3929  0.3236  0.3042  0.2826     0.2800 
#medicine it    telecommunication consumer discretionary  industry 
#0.2562 0.2309         0.2237    0.2156     0.2101        0.2014 
#material 
#0.1820 

#### 05 Check goodness-of-fit
e_global_Post <- e_global
for (i in 1:ncol(e_global_Post)) {
  e_global_Post[!is.na(e_global_Post[, i]), i] <-
    e_global_Post[!is.na(e_global_Post[, i]), i] /
    sqrt(globalCOVOL_Fit$geovol2[!is.na(e_global_Post[, i]), i])
}

geovolTest(e = e_global_Post^2-1)
#Correlation Statistic p-value
#Value  -0.022   -9.5401    1