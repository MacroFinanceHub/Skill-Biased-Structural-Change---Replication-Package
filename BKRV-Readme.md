# Skill-Biased Structural Change - Replication Package

This readme file describes the structure of the directories of the replication package containing the data and code needed to replicate the results in "Skill-Biased Structural Change". When necessary, readme files within the subdirectories provide additional information about the individual files and procedures used (we reproduce the information in these additional readme files below).

---

## Bridging_WorldKLEMS

This folder contains the files used to *bridge* or produce consistent time series for labor compensation, hours worked, and employment in the World KLEMS data. The correction is needed to overcome the *discrete jumps* that arise in the data as a consequence of the change in the way the CPS, World KLEMS main data source, started measuring educational attainment in 1992 and classifying industries in 2002.

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

The *bridged* files are intermediate inputs that we use in the following folders:
* Data for Calibration
* Shift_Share_KM_Methodology - World KLEMS
* Ex 3


---
## Table1 - PRELIMINARY; CODE HASN'T BEEN CHECKED OR EDITED
The exercises performed through the files in this folder constitute the analysis described in Table 1 of Section 2.4.  
    
* **Table1regressions.do:** Creates the regression results in Table 1, as well as the results without controls.

    * **Inputs:**
        - *Mapping Instruction.docx:* Instructions for mapping U.S. industrial skill intensity data to U.S. CEX consumption data through the U.S. input-output structure.
        - *CEXtoVAdocumentation.xlsx:* Contains all of the necessary matrices and cross-walks to reproduce the analysis in Section 2.2, including Table 1, as explained in the file *Mapping Instructions.docx*. The explanation of each worksheet is given in the first sheet entitled *ReadMe*.
        - *CEXdemographicdata.dta:* The demographic data by household which is merged with the value-added in the expenditure bundle data in the Stats .do file *Table1regressions.do*.
        - *CombinedVADataforRegressions.dta:* Contains value-added in the CEX consumption bundle of each household in the CEX.  Based on the CEX data from 2012.
        - *MatlabManipulations.m:* Matlab matrix manipulation codes for constructing the matrix *dataforCEXmerge* in *CEXtoVAdcoumentation.xlsx*.
    * **Output:** 
        * *Table1Results.log:* an ASCII log file containing the regression results in Table 1. It calls the data files: *CombinedVADataforRegressions.dta* and *CEXdemographicdata.dta*

---
## HS_Sector_Definition
This folder contains the files needed to compute the shares of high-skill labor by industry under different employment measures.

* **HS_Shares_by_Industry.do:** 
This .do file computes the share of High-Skill Labor's Compensation, Employment, and Hours Worked by Industry, for the US, between 1977 and 2005. These shares are used to define the High-Skill Intensive Sector in Section 2.2 of the paper. It is also used to compute the supporting numbers provided in Section 2 of the Online Appendix.

    * **Inputs:** *excel_files/usa_wk_apr_2013_labour.xlsx* -> the 2013 version of the World KLEMS' labor input file .

    * **Output:** *dta_files/HS_labor_shares_1977_2005.dta* -> a .dta file containing the time series and the average for the period of the high-skill labor shares for the 31 Industries in the World KLEMS database.

---
## Figures1&2
This folder contains the files needed to produce Figure 1 in section 2.3 and Figure 2 in section 2.4 of the paper. Each subfolder contains the corresponding *.do* file needed to produce the figure. They take as inputs files contained in the folders called *excel_files* and/or *dta_files*.

### Subfolder: Figure 1

* **Figure1.do:** produces Figure 1 in Section 2.3. It also produces the two alternative versions of Figure 1 in the Online Appendix under two broader definition of the high-skill sector. Additionally, this routine computes the regressions in the figure and their corresponding $R^{2}$s with and without country-specific fixed effects.

    * **Inputs:** 
        * *excel excel_files/basic_files_09/'i'_output_09I.xls* -> one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
        * *dta_files/pwt90.dta* -> the Penn World Table, version 9.0.
    * **Output:**
        * *Figure1/figure1.dta:* a file containing the data in Figure 1.
        * *Figure1/Figures/figure1_benchmark.pdf:* Figure 1 in the paper.  


### Subfolder: Figure 2

* **chain_price_indice.do:**  produces the Chain Price Indices for the High- and Low-Skill Sector and a Relative Price Index for the 15 countries in Figure 2.
    * **Inputs:** 
        * *excel excel_files/basic_files_09/'i'_output_09I.xls* one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
    * **Output:**
        * *dta_files/Prices/HS_Sector_Benchmark/P_indices_combined.dta:* a *.dta* file containing time series of the chain-weighted price indices for the countries in Figure 2.

* **Figure2.do:** produces Figure 2 in Section 2.4. It also produces the two alternative versions of Figure 2 in the Online Appendix under two broader definition of the high-skill sector. Additionally, this routine computes the regressions in the figure and their corresponding $R^{2}$s with and without country-specific fixed effects.

    * **Inputs:**
        * *dta_files/Prices/HS_Sector_Benchmark/P_indices_combined.dta:* a *.dta* file containing time series of the chain-weighted price indices for the countries in Figure 2. 

        * *excel_files/basic_files_09/'i'_output_09I.xls* -> one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
        * *dta_files/pwt90.dta* -> the Penn World Table, version 9.0.
    * **Output:**
        * *dta_files/figure2.dta:* a file containing the data in Figure 2.
        * *Figure2/Figures/figure2_benchmark.pdf:* Figure 2 in the paper.  
---

## Data_for_Calibration

This folder contains the files needed to compute the time series used to calibrate the model, as described in Section 4 of the paper.

* **data_for_calibration.do:**  This .do file produces the time series (1977-2005) for the variables used to calibrate the model. The time series computed, all fot the US, are the following:

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

---
## Cross-Country

This folder contains the files needed to produce the results in Section 8 of the paper and Section 5 of the Online Appendix.

### Subfolder: Cross_Country_Calibration_Targets

* *CC_cali_targets.do:* This .do file produces the times series used to perform the calibration of the technology parameters for the ten OECD countries in the Cross-Country Analysis presented in Section 8 of the paper and Section 5 of the Online Appendix. The series computed are the same as those in section **Data for Calibration**. The countries used in Figure 1/Figure 2 that have labor input files in the EUKlems database (Austria, Australia, Belgium, Denmark, Spain, Germany, Italy, Japan, The Netherlands, United Kingdom, and the United States).

    * **Inputs:**
        * *excel_files/LI_files/'i'_labour_input_08I.xls:* a series of Excel spreadsheets containing the the EUKLEMS labor input file for each country *i* in the analysis.
        * *excel_files/basic_files_09/'i'_output_09I.xls:* a series of Excel spreadsheets containing the the EUKLEMS basic files for each country *i* in the analysis.
        * *excel_files/benchmark_1997.xls:* an excel spreadsheet containing Internationally comparable PPP for value-added (double deflated) for each country for 1997.
    * **Outputs:**
        * *dta_files:* *'i'.dta* a series of *.dta* files containing the time series above mentioned for each country *'i'* in the analysis.
        * *csv_files:* *data_'i'.csv* a series of *.csv* files containing the time series above mentioned for each country *'i'* in the analysis.

### Subfolder: Cross-Country_Model_Fit

* *cross_country_figures.do:* Produces Figures 7 and 8 in Section 5 the Online Appendix. These figures measure the ability of the model to fit the actual series for the skill premium and the share of the high-skill intensive sector in the ten countries mentioned above.

    * **Inputs:**
        * *excel_files/model_fit_crosscountry.xlsx:* and excel spreadsheet containing series of model-simulated and actual data for the countries in the cross-country analysis.

    * **Outputs:**
        * *dta_files/cross_country_model_fit.dta:* a *.dta* file containing the data in Figures 7 and 8 in Section 5 of the Online Appendix.
        * *Figures/figure7.pdf:* & *Figures/figure8.pdf:* Figures 7 and 8 in Section 5 of the Online Appendix.

---

## Sensitivity
This folder contains the files for the sensitivity exercises carried out in Section 7 of the paper. In particular, we provide the workfiles for Subsections 7.1 and 7.2.

### Subfolder: Consumption_Investment_VA
This folder contains the files used to carry out the sensitivity analysis in Section 7.1 of the paper, called "Consumption Value Added vs Investment Value Added". 

In this excercise we use input-output data for the US to compute time series of the High- and Low-Skill Sectors' shares of Value Added in producer’s prices that are generated by final expenditure on consumption and investment (in producer’s prices). Data are available every five years between 1977 and 2002 and anually between 1997 and 2005. For simplicity, and to be consistent with the period used in our benchamrk results, we use data for 2005, 2002, 1997, 1992, 1987, 1982, 1977.

#### 1977
**IOprocessing1977.m:** a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 
* **Inputs:**

    * *2digit_tables1977/IOuse.xlsx:* the industry by commodity use table, which is built by unstacking columns A, B, and C from the file *77IO85-levelexcel/1977 Transactions 85-level Data.xls*.
    * *2digit_tables1977/IxCTR.xlsx:* the industry by commodity total requirement table, which is built by unstacking columns A, B, and G from the file *77IO85-levelexcel/1977 Transactions 85-level Data.xls*.
    
* **Output:** A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *1977* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 1982
**IOprocessing1982.m:**  a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *2digit_tables1982/ndn0125/82-2dall.txt*: a file containing all the transactions to build the Industry by Commodity Total Requirements and Industry by Commodity Use Tables.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *1982* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 1987
**IOprocessing1987.m:**  a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *2digit_tables1987/ndn0019/IOUSE.xlsx:* the industry by commodity use table, which is built by combining the files *ndn0019/TBL1-87.DTA* to *ndn0019/TBL8-87.DTA*.
    * *2digit_tables1987/ndn0019/IXCTR.xlsx:* the industry by commodity total requirements table, which is built by combining the files *ndn0019/TBL1-87.DTA* to *ndn0019/TBL8-87.DTA*.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *1987* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 1992
**IOprocessing1992.m:**  a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *2digit_tables1992/ndn0180/IXCTR.txt:* a file containing the data for the total requirements table.
    * *2digit_tables1992/ndn0180/IOUSE.txt:* a file containing the data for the industry by commodity use table.
    * *2digit_tables1992/ndn0180/io-code.txt:* a file containing the indsutry codes to build the tables.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *1992* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 1997
**IOprocessing1997.m:** a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *summarytables1997/IOUseSummary.xlsx:* a file containing the data for the industry by commodity use table.
    * *summarytables1997/IndByComTRSum.xlsx:* a file containing the data for the industry by commodity total requirements table.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *1997* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 2002
**IOprocessing2002.m:** a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *summarytables2002/2002_Requirements_summary.xlsx:* a file containing the data for the industry by commodity total requirements table.
    * *summarytables1997/2002_IOMakeUse_summary.xlsx:* a file containing the data for the industry by commodity make and use tables.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *2002* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

#### 2005
**IOprocessing2005.m:** a matlab code that takes data from the input-output table and produces data on value added by industry generated by final expenditures in consumption and investment. 

* **Inputs:**
    * *summarytables2005/IxC_TR_2005_AR_PROD_SUM.xls:*  a file containing the data for the industry by commodity total requirements table.
    * *summarytables2005/IO_Use_2005_AR_PROD_SUM.xls:* a file containing the data for the industry by commodity use tables.
    * *summarytables2005/IO_Make_2005_AR_PROD_SUM.xls:* a file containing the data for the industry by commodity make tables.

* **Output:**  A table with the data on the value added generated by consumption and investment expenditures by industry. This talbe is exported to the excel spreadsheet *Historical_IO_Results_Summary.xlsx* sheet *2005* where industries are classified into High- and Low-Skill and the consumption and investment value added shares are computed.

**Historical_IO_Results_Summary.xlsx:** this spredsheet takes the data on value added generated by final expenditures on consumption and investment, assigns industries to the High- and Low-Skill sector and computes the share of value added generated by consumption and investment expednitures that corresponds to the High-Skill sector. A time series with the results is presented on the worksheet *Summary and Figures*.

### Subfolder: Trade

* *US Trade Data.xlsx:* this Excel file contains the calculations performed to adjust the shares of value added in the high- and low-skill sector for sectoral net trade flows, as described in Section 7.2 of the paper. 

    * **Inputs:** the exercise uses annual data on trade of goods and services for the U.S. (Balance of Payment Basis) from the U.S. Census Bureau, which is stored in the worksheet *Trade*. It also requires a time series on the U.S. GDP, which we obtain from the Bureau of Economic Analysis and store in the sheet U.S. GDP.
    * **Output:** two time series of the net trade flows for the high- and low-skill sector. Due to data limitations, to compute this series we assume that the net trade in services corresponds to the net trade flow in the high-skill sector, while the net trade in goods represents the trade flow in the low-skill sector. 
    
        The Bureau of Economic Analysis provides data for the U.S. trade in services by type of service since 1999. We use these data to validate our assumption that the net trade in services is close to the net trade flow for the high-skill sector. Columns I to L in the Sheet Calculated Series confirm that that is indeed the case.


---

## Shift_Share_KM_Methodology
In this folder, we perform a series of shift-share analyses following the methodology proposed in Katz and Murphy 1992. The results are presented in Section 6.1 of the paper, and more extensively in Section 1.4 of the Online Appendix.

### Subfolder: World KLEMS
In this subfolder we perform a series of shift-share analyses using bridged World KLEMS data for the US. The excercises performed in the *.do* files here differ in either the way human capital is measured (BKRV or KM efficiency units), the way sectors are measured (value added or employment), and/or the level of sectoral aggregation (2 or the 31 sectors). These different features are reflected in the name of the *.do* files. Additionally, the period of study and the set of industries in the high-skill sector can easily changed within each file. All the *.do* files in the folder use the following files as inputs:

**Inputs:** the bridged files for the US's World KLEMS 2013 labor input files (see folder Bridging_WorldKLEMS), contained in the following files:
        * *dta_files/comp_bridged.dta*
        * *dta_files/h_emp_bridged.dta*
        * *dta_files/emp_bridged.dta*

* *Shift_Share_KM_WK2013_Eff_KM_2sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in KM efficiency units, aggregating industries at the two-sector level, and using employment measured in KM efficiency units as a measure of sector size. The result of this exercise is presented in Row (i) of Table 7 of the paper and in Column H of Table 2 in the Online Appendix. 

    * **Output:** 
        * *Table7_row_i.smcl:* a *log* file that containes the output of the code.

* *Shift_Share_KM_WK2013_VA_KM_2sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in KM efficiency units, aggregating industries at the two-sector level, and using value added as a measure of sector size. The result of this exercise is presented in Row (ii) of Table 7 of the paper and in Column N of Table 3 in the Online Appendix.

    * **Input:** 
      * *dta_files/VA_shares.dta:* a file containing time series with the share of value added for the high- and low-skill sectors.

    * **Output:** 
        * *Table7_row_ii.smcl:* a *log* file that containes the output of the code.

* *Shift_Share_KM_WK2013_VA_BKRV_2sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in BKRV efficiency units, aggregating industries at the two-sector level, and using value added as a measure of sector size. The result of this exercise is presented in Row (iii) of Table 7 of the paper and in Column M of Table 3 in the Online Appendix.

    * **Input:** 
      * *dta_files/VA_shares.dta:* a file containing time series with the share of value added for the high- and low-skill sectors.

    * **Output:** 
        * *Table7_row_iii.smcl:* a *log* file that containes the output of the code.

* *Shift_Share_KM_WK2013_Eff_BKRV_2Sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in BKRV efficiency units, aggregating industries at the two-sector level, and using employment measured in BKRV efficiency units as a measure of sector size. The results of this exercise are presented in Column G (1977-2005) and Column F (1980-1990) of Table 3 in the Online Appendix.

* *Shift_Share_KM_WK2013_Eff_BKRV_31Sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in BKRV efficiency units, aggregating industries at the 31 sector level, and using employment measured in BKRV efficiency units as a measure of sector size. The result of this exercise is presented in Column E (1980-1990) of Table 3 in the Online Appendix.

* *Shift_Share_KM_WK2013_Eff_KM_31Sectors.do:* computes the between-industry relative demand shift in favor of high-skill labor using World KLEMS data for the US, measuring human capital in KM efficiency units, aggregating industries at the 31 sector level, and using employment measured in KM efficiency units as a measure of sector size. The result of this exercise is presented in Column D (1979-1989) of Table 3 in the Online Appendix.

### Subfolder: IPUMS
In this subfolder we perform a series of shift-share analyses using IPUMS US data. We do this exercise under two different grouing criteria for workers: experience (as in KM) and age (as in the World KLEMS database). The files for each of these excercises are presented in the folders Experience and Age, respectively. The results of these excercises are presented in Columns B and C of the Online Appendix. 

*Note:* the results reported in the Online Appendix require a dataset that is too heavy (around 1.3 GB). We include here a five percent sample of the data instead (using stata's sample 5 command). The .*do* files *Age/Demand_Shift_KM_IPUMS_E_KM_Age.do* and *Experience/Demand_Shift_KM_IPUMS_E_KM_Experience.do* provide a description on how to download the data from the IPUMS website. The dataset is also available upon request.

#### **Age**

* *Age/KM_count_data.do:* this file creates the count sample in KM 1992 (file *KM_count_data.dta*), following the description in section II of their paper. It uses as input the file *usa_80_90_5pct_sample.dta* (see Note above).
* *Age/KM_wage_data.do:* this file creates the wage sample in KM 1992 (file *KM_wage_data.dta*), following the description in section II of their paper. It uses as input the file *usa_80_90_5pct_sample.dta* (see Note above).
* *Age/KM_skill_prem_age_ipums.do:* this file computes the skill premium under KM's methodology (see footnote 20 in KM 1992), using as inputs the count and the wage samples created by the files above (*KM_count_data.dta*,*KM_wage_data.dta*).
* *Age/Demand_Shift_KM_IPUMS_E_KM_Age.do:* this *.do* file computes the between industry demand shift in favor of high-skill labor following the methodology in KM 1992. It uses as inputs the count and wage samples created above (*KM_count_data.dta*,*KM_wage_data.dta*), and the *.do* file *bridge_ind1990_eu31.do*, which bridges the NAICS industries in IPUMS into the 31 industries in the World KLEMS data. The results obtained are presented in Column C of Table 1 in the Online Appendix.

#### **Experience**

* *Experience/KM_count_data.do:* this file creates the count sample in KM 1992 (file *KM_count_data.dta*), following the description in section II of their paper. It uses as input the file *usa_80_90_5pct_sample.dta* (see Note above).
* *Experience/KM_wage_data.do:* this file creates the wage sample in KM 1992 (file *KM_wage_data.dta*), following the description in section II of their paper. It uses as input the file *usa_80_90_5pct_sample.dta* (see Note above).
* *Experience/KM_skill_prem_age_ipums.do:* this file computes the skill premium under KM's methodology (see footnote 20 in KM 1992), using as inputs the count and the wage samples created by the files above (*KM_count_data.dta*,*KM_wage_data.dta*).
* *Experience/Demand_Shift_KM_IPUMS_E_KM_Experience.do:* this *.do* file computes the between industry demand shift in favor of high-skill labor following the methodology in KM 1992. It uses as inputs the count and wage samples created above (*KM_count_data.dta*,*KM_wage_data.dta*), and the *.do* file *bridge_ind1990_eu31.do*, which bridges the NAICS industries in IPUMS into the 31 industries in the World KLEMS data. The results obtained are presented in Column B of Table 1 in the Online Appendix.

### Subfolder: EUKLEMS
In this subfolder we perform a series of shift-share analyses using EUKLEMS data for the US. We here produce four different between-industry demand shifts and demand-shift contributions. They vary in the way employment is measured, which could be either in BKRV or KM efficiency units, and on if we measure the size of sectors using the corresponding employment measure or value added. The results are presented in Columns I and J of Table 2 and in Columns O and P of Table 3 in the Online Appendix.

* *Shift_Share_KM_EUKLEMS_2Sectors.do:* this *.do* file computes the between-industry demand shift and its contribution to the total demand shift in favor of high-skill labor using EUKLEMS data for the US. Industries are aggregated at the two-sector level, at the cell level workers are grouped according to age, and the analysis is performed for our benchmark period, 1977-2005. 

* *Inputs:*
    * *excel_files/usa-naics_labour_input_08I.xls:* the EU KLEMS labor input file for the US, release March 2009.
    * *excel_files/usa-naics_output_09I.xls:* the EU KLEMS basic file for the US, released in November 2009 and revised in June 2010.

* *Output:* The file produces four different between-industry demand shifts: 
    * *log_Delta_Xd_BKRV:* measuring employment in BKRV efficiency units and using employment in BKRV efficiency units as a measure of sector size. This results is presented in row (i) of Column I in Table 2 of the Online Appendix. 
    * *log_Delta_Xd_KM:* measuring employment in KM efficiency units and using employment in KM efficiency units as a measure of sector size (BKRV Value Added). This results is presented in row (i) of Column J in Table 2 of the Online Appendix.
    * *log_Delta_Xd_VA_BKRV:* measuring employment in BKRV efficiency units and using value added as a measure of sector size (BKRV Value Added). This results is presented in row (i) of Column O in Table 3 of the Online Appendix.
    * *log_Delta_Xd_VA_KM:* measuring employment in BKRV efficiency units and using value added at fixed prices as a measure of sector size (KM Value Added). his results is presented in row (i) of Column P in Table 3 of the Online Appendix.
    
    This *.do* file also produces two auxiliary *.dta* files that are required to compute the between-industry demand shift contribution to the total change in demand of high-skill workers: *eff_KM_BKRV_1977_2005.dta* and *wage_premiums.dta*. These files have the data to compute the log change in the relative supply of skills under the KM and the BKRV measure and the log change in the skill-premium, which are presented in rows (ii) and (iii), respectively, of columns I,J,O, and P.
---
