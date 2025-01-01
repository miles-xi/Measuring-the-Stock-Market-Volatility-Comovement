#####论文4.1节，绘制daily epu index
#library(zoo)
# A. plot函数无法设置xlable，日期间隔太大
#plot(epuDaily$Date, epuDaily$CNEPU_Daily, type = "p", col = "gray", 
#     xlim = c(min(epuDaily$Date), max(epuDaily$Date)),
#     ylim = range(epuDaily$CNEPU_Daily), 
#     xlab = "Date", ylab = "Value", main = "Daily EPU index", axis = FALSE)
## Add the second line
#lines(epuDaily$Date, rollmean(epuDaily$CNEPU_Daily, k = 3, fill = NA), 
#      type = "l", col = "black")
#legend("topright", legend=c("Daily EPU index", "Rolling daily EPU index"),
#       col=c("gray", "black"), lty=1, cex=0.8)

# B. ggplot无法设置legend
library(ggplot2)
# Create a data frame
df <- data.frame(Date = epuDaily$Date,
                 CNEPU_Daily = epuDaily$CNEPU_Daily,
                 Rolling_mean = rollmean(epuDaily$CNEPU_Daily, k = 3, fill = NA))
# Plot using ggplot2
ggplot(df, aes(x = Date)) +
  geom_point(aes(y = CNEPU_Daily), color = "gray") +
  geom_line(aes(y = Rolling_mean), color = "black") +
  scale_x_date(date_breaks = "11 month", date_labels="%Y-%m") +
  labs(x = "Date", y = "Value", title = "Daily EPU index") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = -40)) 

ggplot(df, aes(x = Date)) +
  geom_point(aes(y = CNEPU_Daily, color = "Daily EPU"), size = 1) +
  geom_line(aes(y = Rolling_mean, color = "Rolling EPU")) +
  scale_x_date(date_breaks = "11 months", date_labels="%Y-%m") +
  labs(x = "Date", y = "Value", title = "Daily EPU index") +
  scale_color_manual(values = c("gray", "black"),
                     labels = c("Daily EPU", "Rolling EPU")) +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = -40)) +
  theme(legend.position = "topright")

rm(df)
#####


#02 plot u_ETFs$rowMeans  (xts object)
plot(u_ETFs$rowMeans, type = "l", col = "black", 
     ylim = range(u_ETFs$rowMeans), 
     ylab = "Value", main = "Residuals")

#02.1 plot vol_ETFs$rowMeans with vol_csi800
# Plot the first line
plot(vol_ETFs$rowMeans, type = "l", col = "black", 
     ylim = c(0,0.05), 
     ylab = "Value", main = "Volatility")

# Add the second line
lines(vol_csi800, type = "l", col = "gray")
 #legend(0, 0.04, 
 #      legend=c("mean vol.", "Vol. CSI800"),
 #      col=c("black", "gray"), 
 #      lty=1, 
 #      cex=18)

#06 plot x:
library(ggplot2)
plotCommonVol <- ggplot(x, aes(x = Date, y = x_hat)) +
  geom_line() +
  scale_x_date(date_breaks = "10 month", date_labels="%Y-%m") +
  labs(x = "Date", y = "x_hat", title = "CN Common Volatility") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = -45)) 

#plot the rolling x along with x:

# Plot the first line
plot(x$Date, x$x_hat, type = "p", col = "gray", 
     xlim = c(min(x$Date), max(x$Date)),
     ylim = range(x$x_hat), 
     xlab = "Date", ylab = "Value", main = "Squared CNCOVOL")

# Add the second line
lines(x$Date, x$Rolling, type = "l", col = "black")
legend("topright", legend=c("Daily", "Rolling"),
       col=c("gray", "black"), lty=1, cex=0.8)

#06.1 plot monthly x:

#plot(xMonthly$x_hat_mo, type = "l")
plotCommonVolMo <- ggplot(xMonthly, aes(x = Date, y = x_hat_mo)) +
  geom_line() +
  scale_x_date(date_breaks = "10 month", date_labels="%Y-%m") +  
  labs(x = "Date", y = "x_mo_hat", title = "CN Monthly Common Volatility") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = -45))  



###07.1 plot DAILY data:

# Plot the first line
plot(epuDaily$Date, epuDaily$CNEPU_Daily, type = "l", col = "blue", 
     xlim = c(min(epuDaily$Date, x$Date), max(epuDaily$Date, x$Date)),
     ylim = range(epuDaily$CNEPU_Daily, x$x_hat), # Adjust ylim based on both datasets
     xlab = "Date", ylab = "Value", main = "Daily EPU vs. COVOL")

# Add the second line
#library(scales)
xRescaled <- rescale(x$x_hat, to = range(epuDaily$CNEPU_Daily))

lines(x$Date, xRescaled, type = "l", col = "green")
legend("topright", legend=c("Daily EPU", "Common Volatility (Scaled)"),
       col=c("blue", "green"), lty=1, cex=0.8)


###07.2 plot MONTHLY data:

# Plot the first line
plot(epuMo$Date, epuMo$CNEPU, type = "l", col ="blue", 
     xlim = c(min(epuMo$Date, xMonthly$Date), max(epuMo$Date, xMonthly$Date)),
     ylim = range(epuMo$CNEPU, xMonthly$x_hat_mo), # Adjust ylim based on both datasets
     xlab = "Date", ylab = "Value", main = "monthly EPU vs. monthly COVOL")

# Add the second line
lines(xMonthly$Date, 100 * xMonthly$x_hat_mo, type = "l", col = "green")
legend("topright", legend=c("Monthly EPU", "Monthly COVOL (Scaled, * 100)"),
       col=c("blue", "green"), lty=1, cex=0.8)


#plot daily US EPU with daily CN EPU:
# Plot the first line
plot(epuDaily$Date, epuDaily$CNEPU_Daily, type = "l", col = "blue", 
     xlim = c(min(epuDaily$Date, epuUSDaily$Date), max(epuDaily$Date, epuUSDaily$Date)),
     ylim = range(epuDaily$CNEPU_Daily, epuUSDaily$epuUSDaily), # Adjust ylim based on both datasets
     xlab = "Date", ylab = "Value", main = "Daily CN EPU vs. Daily US EPU")

# Add the second line
lines(epuUSDaily$Date, epuUSDaily$epuUSDaily, type = "l", col = "green")
legend("topright", legend=c("Daily CN EPU", "Daily US EPU"),
       col=c("blue", "green"), lty=1, cex=0.8)


#plot daily US EPU with monthly US EPU:
US_DailyEPU <- read_csv("Desktop/US_DailyEPU.csv")
US_MonthlyEPU <- read_excel("Desktop/US_MonthlyEPU.xlsx")

US_DailyEPU$date <- paste(US_DailyEPU$year, US_DailyEPU$month, 
                          US_DailyEPU$day, sep = "-")
US_DailyEPU$date <- as.Date(US_DailyEPU$date)

US_MonthlyEPU$date <- paste(US_MonthlyEPU$Year, US_MonthlyEPU$Month, sep = "-")
US_MonthlyEPU$date <- ym(US_MonthlyEPU$date) #class == "Date"

# Plot the first line
plot(US_DailyEPU$date, US_DailyEPU$daily_policy_index, type = "l", col = "blue", 
     xlim = c(min(US_DailyEPU$date, US_MonthlyEPU$date), max(US_DailyEPU$date)),
     ylim = range(US_DailyEPU$daily_policy_index, US_MonthlyEPU$News_Based_Policy_Uncert_Index), # Adjust ylim based on both datasets
     xlab = "Date", ylab = "Value", main = "daily US EPU vs. monthly US EPU")

# Add the second line
lines(US_MonthlyEPU$date, US_MonthlyEPU$News_Based_Policy_Uncert_Index, type = "l", col = "green")
legend("topright", legend=c("daily US EPU", "monthly US EPU"),
       col=c("blue", "green"), lty=1, cex=0.8)

