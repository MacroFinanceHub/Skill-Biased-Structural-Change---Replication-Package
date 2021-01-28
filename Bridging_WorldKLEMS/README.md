## Bridging_WorldKLEMS

This folder contains the files used to *bridge* or produce consistent time series for labor compensation, hours worked, and employment in the World KLEMS data. The correction is needed as a consequence of the changes in the measurement of educational attainment and in industry classification applied by the CPS in 1992 and 2002, respectively. The CPS is the main data source of the World KLEMS.

* **bridging_worldKLEMS_employment.do:** This .do file produces the *bridged* series for total employment.
    * **Inputs:**
        * *excel_files/usa_wk_apr_2013_labour.xlsx* -> the 2013 version of the World KLEMS' labor input file .
    * **Output:** 
        * *dta_files/emp_bridged.dta* -> a .dta file containing the bridged time series for employment.
        * *Figures/Emp_bridged.pdf* and *Figures/Emp_raw.pdf* -> two figures containing the bridged and raw time series for employment aggregated at the ecucational attainment level.  

* **bridging_worldKLEMS_hours.do:** This .do file produces the *bridged* series for average hours worked per person.
    * **Inputs:** 
        * *excel_files/usa_wk_apr_2013_labour.xlsx* -> the 2013 version of the World KLEMS' labor input file .
    * **Output:** 
        * *dta_files/h_emp_bridged.dta* -> a .dta file containing the bridged time series for hours.
        * *Figures/H_Emp_bridged.pdf* and *Figures/H_Emp_raw.pdf* -> two figures containing the bridged and raw time series for hours worked aggregated at the ecucational attainment level.  

* **bridging_worldKLEMS_compensation.do:** This .do file produces the *bridged* series for average compensation per hour worked.
    * **Inputs:** 
        * *excel_files/usa_wk_apr_2013_labour.xlsx* -> the 2013 version of the World KLEMS' labor input file .
    * **Output:** 
        * *dta_files/comp_bridged.dta* -> a .dta file containing the bridged time series for compensation.
        * *Figures/Comp_bridged.pdf* and *Figures/Comp_raw.pdf* -> two figures containing the bridged and raw time series for compensation aggregated at the ecucational attainment level.  

The *bridged* files are intermediate inputs that we use in the following folders **Data for Calibration** and **Shift_Share_KM_Methodology/World KLEMS**.
