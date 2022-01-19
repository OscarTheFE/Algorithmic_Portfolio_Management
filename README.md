# Algorithmic_Portfolio_Management
This is the note to the Algorithmic Portfolio Management course by Prof. Pawlowski in NYU Tandon where we apply R programming language to various trading strategies such as Rebalancing Strategies, Momentum Strategies, and Moving Average Crossover Strategies as well as techniques to optimize portfolio. This course will apply machine learning techniques, such as backtesting (cross-validation) and feature engineering.
## Following are some interesting strategies worth mentioning


### Case 1: Stock and Bond Portfolio With Risk Parity Strategy
Construct a portfolio with stock(VTI) and bond(IEF) and backtest the *risk parity strategy* performance. It has higher Sharpe ratio due to higher weight to bond but lower absolute returns. Risk Parity strategy works better for assets with low correlation and very different volatilities.
Moreover, this strategy could be used to time market i.e. sell when prices are about to drop and buy when prices are about to rise. 

![Risk_Parity](https://user-images.githubusercontent.com/83149091/149602338-07957e57-4288-4a3c-a46a-d29984425093.png)
![Risk_Parity_Timing](https://user-images.githubusercontent.com/83149091/149602297-dbc7019f-817f-4f9b-b98f-c56050f49a51.png)

### Case 2: Ensemble of EWMA Strategies
Build up an (ensemble) EWMA strategy by combining trend-following EWMA strategy and mean-reverting EWMA strategy based on Sharpe ratio, respectively. 

![EWMA](https://user-images.githubusercontent.com/83149091/150043607-48ec3ae0-b91f-4916-b6c2-4171b0a5c250.png)

In terms of trend following strategies, VWAP is often used as an indicator. If the current price crosses above VWAP, the risk position switches to long risk and vice versa. 
Even though the VWAP strategy underperform static buy-and-hold strategy, it can provide risk reduction when combined with it. In addition, the VWAP strategy performs well in periods of extreme market sell-off like in 2008, so it can provide a hedge for static buy-and-hold strategy. In other words, the VWAP strategy serves as a dynamic put options in extreme market sell-off.

![VWAP+Stock](https://user-images.githubusercontent.com/83149091/150043625-92a19c1b-0034-4152-8cd8-14cc442d1896.png)
