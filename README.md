# Algorithmic_Portfolio_Management
This is the note to the Algorithmic Portfolio Management course by Prof. Pawlowski in NYU Tandon where we apply R programming language to various trading strategies such as Rebalancing Strategies, Momentum Strategies, and Moving Average Crossover Strategies as well as techniques to optimize portfolio. This course will apply machine learning techniques, such as backtesting (cross-validation) and feature engineering.
## Following are some interesting strategies worth mentioning


### Case 1: Stock and Bond Portfolio With Risk Parity Strategy
Construct a portfolio with stock(VTI) and bond(IEF) and backtest the *risk parity strategy* performance. It has higher Sharpe ratio due to higher weight to bond but lower absolute returns. Risk Parity strategy works better for assets with low correlation and very different volatilities.
Moreover, this strategy could be used to time market i.e. sell when prices are about to drop and buy when prices are about to rise. 

![Risk_Parity](https://user-images.githubusercontent.com/83149091/149602338-07957e57-4288-4a3c-a46a-d29984425093.png)
![Risk_Parity_Timing](https://user-images.githubusercontent.com/83149091/149602297-dbc7019f-817f-4f9b-b98f-c56050f49a51.png)

### Case 2:
