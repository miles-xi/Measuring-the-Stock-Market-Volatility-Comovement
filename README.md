# Measuring-the-Stock-Market-Volatility-Comovement

In this project, I 

•	Retrieved 200K+ OHLC data of 10 market/sector ETFs using Alpha Vantage API, and transformed closing prices into log-return series; performed exploratory data analysis on closing prices and log-returns; corrected inaccurate return values caused by stock splits, ensuring data accuracy

•	Constructed an AR(1) model with two external regressors for each return series, where residuals were fitted with the GARCH(1,1) model to derive residuals standardized by GARCH estimates; found a significant cross-sectional correlation of the squared standardized residuals 

•	Applied a novel financial risk measure proposed in a top academic journal, global Common Volatility, to the standardized residuals to estimate the volatility comovement across sectors that caused such cross-sectional correlation, identifying and quantifying significant risk events

