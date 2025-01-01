#Chap03_further analysis of x

#06 x and rolling x

#head(globalCOVOL_Fit$x)
#print(head(sort(globalCOVOL_Fit$x, decreasing = TRUE)))
#plot(globalCOVOL_Fit$x, type = "b")

x <- data.frame(Date = globalCOVOL_Fit$dates, 
                x = globalCOVOL_Fit$x,
                centered_x = globalCOVOL_Fit$x -1)
colnames(x) <- c("Date","x_hat","centered_x")
#class(x$Date) #"Date"

#Calculate rolling x
library(zoo)
x$Rolling <- rollmean(x$x_hat, k = 3, fill = NA)


#06.1 Calculate monthly x
xMonthly <- aggregate(x$x_hat,
                      by = list(format(globalCOVOL_Fit$dates, "%Y-%m")),
                      FUN = mean)
colnames(xMonthly) <-c("Date","x_mo")
xMonthly$Date <- as.Date(paste0(xMonthly$Date, "-01"))
#class(xMonthly$Date) == "Date"


###06.2 save variables
save(x, file = "/Users/Zjxi/Desktop/中证行业分类/x.RData")
save(xMonthly, file = "/Users/Zjxi/Desktop/中证行业分类/xMonthly.RData")
