# Measuring-the-Stock-Market-Volatility-Comovement

In this project, I 

•	Retrieved 200K+ OHLC data of 10 market/sector ETFs using Alpha Vantage API, and transformed closing prices into log-return series; performed exploratory data analysis of closing prices and log-returns; corrected inaccurate return values caused by stock splits, ensuring data accuracy

•	Constructed an AR(1) model with two external regressors for each return series, where residuals were fitted with the GARCH(1,1) model to derive residuals standardized by GARCH estimates; found a significant cross-sectional correlation of the squared standardized residuals 

•	Applied a novel financial risk measure proposed in a top academic journal, global Common Volatility, to the standardized residuals to estimate the volatility comovement across sectors that caused such cross-sectional correlation, identifying and quantifying significant risk events

### Main result
![image](https://github.com/user-attachments/assets/c2ab3359-0b45-4a5b-a283-ea3a1d199dc1)

### Some intermediate results
![image](https://github.com/user-attachments/assets/a5ca5236-87c9-462a-afa2-86dab9ed4cea)

![image](https://github.com/user-attachments/assets/c435d610-3116-4536-af9c-c40a888095fe)

![image](https://github.com/user-attachments/assets/3e9fbc4b-1be4-4397-9873-9ce970137a75)

![image](https://github.com/user-attachments/assets/8a26acec-c81f-499f-9325-8488683d22db)

### The idea behind the risk measure global common volatility, gloabl COVOL
Please refer to [What are the events that shake our world? Measuring and hedging global COVOL](https://www.sciencedirect.com/science/article/pii/S0304405X22002070).
