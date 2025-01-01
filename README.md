# Measuring-the-Stock-Market-Volatility-Comovement

In this project, I 

•	Extracted 67K+ OHLC data of 12 sector ETFs using Alpha Vantage API, and transformed closing prices into log-return series; performed descriptive analysis including the tests for time dependence

•	Constructed a three-factor statistical model for each return series, where residuals were fitted with the GARCH model to derive residuals standardized by GARCH estimates; found a significant cross-sectional correlation of the squared standardized residuals 

•	Applied a novel financial risk measure proposed in a top academic journal, global Common Volatility, to the standardized residuals to estimate the volatility comovement across sectors that caused such cross-sectional correlation, identifying and quantifying significant risk events

