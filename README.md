# Measuring-the-Stock-Market-Volatility-Comovement

In this project, I 

•	Retrieved 200K+ OHLC data of 10 market/sector ETFs using Alpha Vantage API, and transformed closing prices into log-return series; performed exploratory data analysis on closing prices and log-returns; corrected inaccurate return values caused by stock splits, ensuring data accuracy

•	Constructed an AR(1) model with two external regressors for each return series, where residuals were fitted with the GARCH(1,1) model to derive residuals standardized by GARCH estimates; found a significant cross-sectional correlation of the squared standardized residuals 

•	Applied a novel financial risk measure proposed in a top academic journal, global Common Volatility, to the standardized residuals to estimate the volatility comovement across sectors that caused such cross-sectional correlation, identifying and quantifying significant risk events

#### The process and some results
![image](https://github.com/user-attachments/assets/ce660edb-641d-49e6-8a6e-9d2ad2c63331)

![image](https://github.com/user-attachments/assets/afe7cfe7-daec-4a99-93f0-c0900552fce6)

![image](https://github.com/user-attachments/assets/a55611de-70e3-43b5-91b3-b756cdd7f2e4)

![image](https://github.com/user-attachments/assets/368f05cd-7138-4248-b4e7-044f1d3a6237)

![image](https://github.com/user-attachments/assets/c2ab3359-0b45-4a5b-a283-ea3a1d199dc1)



