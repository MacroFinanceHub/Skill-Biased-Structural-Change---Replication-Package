
### Subfolder: Trade

* *US Trade Data.xlsx:* this Excel file contains the calculations performed to adjust the shares of value added in the high- and low-skill sector for sectoral net trade flows, as described in Section 7.2 of the paper. 

    * **Inputs:** the exercise uses annual data on trade of goods and services for the U.S. (Balance of Payment Basis) from the U.S. Census Bureau, which is stored in the worksheet *Trade*. It also requires a time series on the U.S. GDP, which we obtain from the Bureau of Economic Analysis and store in the sheet U.S. GDP.
    * **Output:** two time series of the net trade flows for the high- and low-skill sector. Due to data limitations, to compute this series we assume that the net trade in services corresponds to the net trade flow in the high-skill sector, while the net trade in goods represents the trade flow in the low-skill sector. 
    
The Bureau of Economic Analysis provides data for the U.S. trade in services by type of service since 1999. We use these data to validate our assumption that the net trade in services is close to the net trade flow for the high-skill sector. Columns I to L in the Sheet Calculated Series confirm that that is indeed the case.
