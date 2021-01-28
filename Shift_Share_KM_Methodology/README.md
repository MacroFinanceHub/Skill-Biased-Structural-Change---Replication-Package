## Shift_Share_KM_Methodology
In this folder, we perform a series of shift-share analyses following the methodology proposed in Katz and Murphy 1992. The results are presented in Section 6.1 of the paper, and more extensively in Section 1.4 of the Online Appendix.

### Subfolder: World KLEMS
In this subfolder, we perform a series of shift-share analyses using bridged World KLEMS data for the US. The exercises performed in the *.do* files here differ in either the way human capital is measured (BKRV or KM efficiency units), the way sectors are measured (value added or employment), and/or the level of sectoral aggregation (2 or the 31 sectors). These different features are reflected in the name of the *.do* files. Additionally, the period of study and the set of industries in the high-skill sector can be easily changed within each file. All the *.do* files in the folder use the following files as inputs:

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
In this subfolder we perform a series of shift-share analyses using IPUMS US data. We do this exercise under two different grouping criteria for workers: experience (as in KM) and age (as in the World KLEMS database). The files for each of these exercises are presented in the folders Experience and Age, respectively. The results of these exercises are presented in Columns B and C of the Online Appendix. 

*Note:* the results reported in the Online Appendix require a dataset that is too heavy (around 1.3 GB). We include here a five percent sample of the data instead (using Stata's sample 5 command). The .*do* files *Age/Demand_Shift_KM_IPUMS_E_KM_Age.do* and *Experience/Demand_Shift_KM_IPUMS_E_KM_Experience.do* provide a description on how to download the data from the IPUMS website. The dataset is also available upon request.

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
In this subfolder, we perform a series of shift-share analyses using EUKLEMS data for the US. We here produce four different between-industry demand shifts and demand-shift contributions. They vary in the way employment is measured, which could be either in BKRV or KM efficiency units and on if we measure the size of sectors using the corresponding employment measure or value added. The results are presented in Columns I and J of Table 2 and in Columns O and P of Table 3 in the Online Appendix.

* *Shift_Share_KM_EUKLEMS_2Sectors.do:* this *.do* file computes the between-industry demand shift and its contribution to the total demand shift in favor of high-skill labor using EUKLEMS data for the US. Industries are aggregated at the two-sector level, at the cell level workers are grouped according to age, and the analysis is performed for our benchmark period, 1977-2005. 

* *Inputs:*
    * *excel_files/usa-naics_labour_input_08I.xls:* the EU KLEMS labor input file for the US, release March 2009.
    * *excel_files/usa-naics_output_09I.xls:* the EU KLEMS basic file for the US, released in November 2009 and revised in June 2010.

* *Output:* The file produces four different between-industry demand shifts: 
    * *log_Delta_Xd_BKRV:* measuring employment in BKRV efficiency units and using employment in BKRV efficiency units as a measure of sector size. This result is presented in row (i) of Column I in Table 2 of the Online Appendix. 
    * *log_Delta_Xd_KM:* measuring employment in KM efficiency units and using employment in KM efficiency units as a measure of sector size (BKRV Value Added). This result is presented in row (i) of Column J in Table 2 of the Online Appendix.
    * *log_Delta_Xd_VA_BKRV:* measuring employment in BKRV efficiency units and using value added as a measure of sector size (BKRV Value Added). This result is presented in row (i) of Column O in Table 3 of the Online Appendix.
    * *log_Delta_Xd_VA_KM:* measuring employment in BKRV efficiency units and using value added at fixed prices as a measure of sector size (KM Value Added). This result is presented in row (i) of Column P in Table 3 of the Online Appendix.
    
    This *.do* file also produces two auxiliary *.dta* files that are required to compute the between-industry demand shift contribution to the total change in demand of high-skill workers: *eff_KM_BKRV_1977_2005.dta* and *wage_premiums.dta*. These files have the data to compute the log change in the relative supply of skills under the KM and the BKRV measure and the log change in the skill-premium, which are presented in rows (ii) and (iii), respectively, of columns I, J,O, and P.
