*-------------------------------------------------------------------------------
/*There are two problems that the World KLEMS Labor Input File has if one wants to produce consistent time series for Compensation, 
Hours, and Employment by Industry and Education Category. These problems come from the source that World KLEMS uses, the CPS.

The first problem comes from the fact that in 1992 education started being by the highest grade attained, while before it 
captured years completed.

The second problem is that industry classification switched from SIC to NAICS in 2002.

To overcome these two problems and obtain consistent employment one needs to use the extra "years" of data provided by World KLEMS,
namely 19922,20022 and 20032 and bridge the data.*/
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*In .do this file we the data on Compensation
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
set more off
macro drop _all

global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
cd $dir\Bridging_WorldKLEMS
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*COMP: Labour compensation per hour worked (U.S. dollars)

import excel excel_files/usa_wk_apr_2013_labour.xlsx, sheet("COMP") firstrow

reshape long Age, i(Year Industry Sex Class Education) j(Age_group)
rename Age Comp
rename Age_group Age

egen id = concat(Industry Sex Class Education Age)
destring id, replace

merge 1:1 Year id using  dta_files\h_emp_bridged.dta
drop _merge

gen  tot_Comp_bridged = Comp*H_Emp_bridged
gen  tot_Comp_raw     = Comp*H_Emp_raw
drop Comp
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
tsset id Year

rename tot_Comp_bridged Comp

gen comp_growth = D.Comp / L.Comp

replace comp_growth =  . if Year == 19922 | Year == 20022 | Year == 20032 

bys id Year: gen comp_19922 = Comp if Year == 19922
bys id Year: gen comp_20022 = Comp if Year == 20022
bys id Year: gen comp_20032 = Comp if Year == 20032

*Place 19922 in 1993 to compute growht rate between 1993 and 19922
replace comp_19922 = comp_19922[_n+18] if comp_19922 == .

*Place 20022 and 20032 together in 2003 to compute the growth rate between 2002 and 2003
replace comp_20022 = comp_20022[_n+9]  if comp_20022 == .
replace comp_20032 = comp_20032[_n+10] if comp_20032 == .

*Compute the growth rate between:
*1993 and 1992
gen g_1993_1992 = (Comp/comp_19922)-1
replace g_1993_1992 = . if Year != 1993

*2003 and 2002
gen g_2003_2002 = (comp_20032/comp_20022)-1

*Replace the growth rates to rescale the series
replace comp_growth = g_1993_1992 if Year == 1993 & g_1993_1992 != .
replace comp_growth = g_2003_2002 if Year == 2003 & g_2003_2002 != .

drop if Year == 19922 | Year == 20022 | Year == 20032

replace comp_growth = . if (Comp > 0 & Comp[_n-1] == 0) | (Comp == 0 & Comp[_n-1] > 0) 
replace comp_growth = 0 if comp_growth == .
replace comp_growth = comp_growth + 1

drop comp_19922 comp_20022 comp_20032 g_1993_1992 g_2003_2002
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Use these lines to create the forward adjustment (i.e. starting from 1947)

replace comp_growth = 1 if Year == 1947

gen     new_Comp = Comp if Year == 1947

*These lines are here because some series start after 1947 and they have zeroes before that
*Thus, one can not compute the growth rates and put the series together unless this step is done
replace new_Comp = Comp if Comp  == 0
replace new_Comp = Comp if Comp[_n-1] == 0 & Comp[_n] != 0

replace comp_growth = 1 if Comp[_n-1] == 0 & Comp[_n] != 0

drop if Year == 19922 | Year == 20022 | Year == 20032

*This line looks complicated, but is actually a great way to compute the new series given the 
*discontinuites in the old one
replace new_Comp = L.new_Comp*comp_growth if comp_growth != . & L.new_Comp !=0 & Year > 1947

replace new_Comp = 0 if Comp == 0
rename new_Comp new_Comp_1947
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
/*summarize comp_growth, detail
                         comp_growth
-------------------------------------------------------------
      Percentiles      Smallest
 1%     .3876538       1.49e-06
 5%     .7258385       1.55e-06
10%     .8463993       3.10e-06       Obs             380,928
25%     .9873722       5.90e-06       Sum of Wgt.     380,928

50%     1.019632                      Mean            3.63672
                        Largest       Std. Dev.      781.5025
75%      1.15234       88988.73
90%     1.358567       104175.5       Variance       610746.1
95%     1.593178       121695.1       Skewness       491.7425
99%     2.956633       440603.1       Kurtosis       268125.8
*/

*Here we smooth the series to correct for these outliers
*replace comp_growth = 1 if comp_growth < 0.38 | comp_growth  > 2.95 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Aggregate data and create a chart by education to see how things look like

preserve
collapse (sum) tot_Comp_raw new_Comp_1947, by(Year Education)

rename tot_Comp_raw Comp_raw

replace Comp_raw       = Comp_raw/1000000
replace new_Comp_1947  = new_Comp_1947/1000000

twoway (connected Comp_raw Year if Education == 1) (connected Comp_raw Year if Education == 2) (connected Comp_raw Year if Education == 3) ///
(connected Comp_raw Year if Education == 4) (connected Comp_raw Year if Education == 5) (connected Comp_raw Year if Education == 6), ///
title("Total Compensation by Education Using Raw World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/Comp_raw.png, replace
graph export     Figures/Comp_raw.pdf, replace
graph save Graph Figures/Comp_raw.gph, replace

twoway (connected new_Comp_1947 Year if Education == 1) (connected new_Comp_1947 Year if Education == 2) (connected new_Comp_1947 Year if Education == 3) ///
(connected new_Comp_1947 Year if Education == 4) (connected new_Comp_1947 Year if Education == 5) (connected new_Comp_1947 Year if Education == 6), ///
title("Total Compensation by Education Using the Bridged World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/Comp_bridged.png, replace
graph export     Figures/Comp_bridged.pdf, replace
graph save Graph Figures/Comp_bridged.gph, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
rename new_Comp_1947 tot_Comp_bridged 

keep Year Industry Sex Class Education Age id H_Emp_raw H_Emp_bridged tot_Comp_raw tot_Comp_bridged

gen wage_bridged = tot_Comp_bridged/H_Emp_bridged
gen wage_raw     = tot_Comp_raw/H_Emp_raw

replace wage_raw     = 0 if wage_raw == . 
replace wage_bridged = 0 if wage_bridged == . 


save dta_files/comp_bridged.dta, replace

cd ..
save Data_for_Calibration/dta_files/comp_bridged.dta, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Note : Education groups
	
* (1960-1992) based on years of schooling	
* 1	Less than HS
* 2	Some high school
* 3	High school grad
* 4	Some college
* 5	College grad
* 6	More than college

*Note 6: Education groups
*The data labeled with year=1992 is to be used with year=1991 to calculate the growth between 91 and 92;
*year=19922 is in the new classification and to be used with year=1993
*year=2002 is SIC data converted to NAICS using the CES ratios, this is to be used with year=2001
*year=20022 and 20032 should be used together to compute a growth rate bewteen 2002 and 2003
*-------------------------------------------------------------------------------


