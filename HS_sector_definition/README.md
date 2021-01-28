## HS_Sector_Definition
This folder contains the files needed to compute the shares of high-skill labor by industry under different employment measures.

* **HS_Shares_by_Industry.do:** 
This .do file computes the share of High-Skill Labor's Compensation, Employment, and Hours Worked by Industry, for the US, between 1977 and 2005. These shares are used to define the High-Skill Intensive Sector in Section 2.2 of the paper. It is also used to compute the supporting numbers provided in Section 2 of the Online Appendix.

    * **Inputs:** *excel_files/usa_wk_apr_2013_labour.xlsx:*the 2013 version of the World KLEMS' labor input file .

    * **Output:** *dta_files/HS_labor_shares_1977_2005.dta:* a .dta file containing the time series and the average for the period of the high-skill labor shares for the 31 Industries in the World KLEMS database.
