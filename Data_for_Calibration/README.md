## Data_for_Calibration

This folder contains the files needed to compute the time series used to calibrate the model, as described in Section 4 of the paper.

* **data_for_calibration.do:**  This .do file produces the time series (1977-2005) for the variables used to calibrate the model. The time series computed, all for the US, are the following:

    1. The share of the HS Sector in Total VA
    2. The Share of HS Labor in the Labor Compensation of the HS Sector
    3. The Share of HS Labor in the Labor Compensation of the LS Sector  
    4. The chained relative price index of the HS Sector relative to the LS Sector
    5. GDP per-capita
    6. The Skill Premium (w_HS/w_LS)
    7. The share of Efficiency Units that Correspond to HS Labor
    8. The Share of HS Sector's Labor Compensation in Total Labor Compensation

    * **Inputs:**
        * *excel_files/usa_wk_apr_2013.xlsx* -> the World KLEMS database for the US, 2013, basic file: used for VA shares by sector, the chained relative price index, and the labor productivity indices.
        * *excel_files/usa_wk_apr_2013_labour.xlsx* -> used for VA shares by sector, the chained relative price index, and the labor productivity indices.
        * *dta_files/emp_bridged.dta* & *dta_files/h_emp_bridged.dta* & *dta_files/comp_bridged.dta*-> these files correspond to the *bridged* version of the World KLEMS labor input file (see section Bridging World KLEMS). Used to produce compensation share of the high- and the low-skill intensive sectors, the skill intensity by sector, and the skill-premium. 

        * *dta_files/pwt90.dta* -> the Penn World Table, version 9.0. Used to compute GDP growth for the US.

    * **Outputs:**
        * *Data_for_Calibration.dta:* a *.dta* containing the eight series used in the calibration.
        * *Data_for_Calibration.csv:* a *.csv* containing the eight series used in the calibration.
