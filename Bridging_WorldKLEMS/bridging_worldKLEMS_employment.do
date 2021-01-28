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
*-------------------------------------------------------------------------------
*In .do this file we Bridge the Employment Data
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
set more off
macro drop _all

global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
*global dir /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/

cd $dir/Bridging_WorldKLEMS
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*EMP: Total persons engaged
import excel excel_files/usa_wk_apr_2013_labour.xlsx, sheet("EMP") firstrow

reshape long Age, i(Year Industry Sex Class Education) j(Age_group)
rename Age Emp
rename Age_group Age

egen id = concat(Industry Sex Class Education Age)
destring id, replace

tsset id Year

gen emp_growth = D.Emp / L.Emp

replace emp_growth =  . if Year == 19922 | Year == 20022 | Year == 20032 

bys id Year: gen Emp_19922 = Emp if Year == 19922
bys id Year: gen Emp_20022 = Emp if Year == 20022
bys id Year: gen Emp_20032 = Emp if Year == 20032

*Place 19922 in 1993 to compute growht rate between 1993 and 19922
replace Emp_19922 = Emp_19922[_n+18] if Emp_19922 == .

*Place 20022 and 20032 together in 2003 to compute the growth rate between 2002 and 2003
replace Emp_20022 = Emp_20022[_n+9]  if Emp_20022 == .
replace Emp_20032 = Emp_20032[_n+10] if Emp_20032 == .

*Compute the growth rate between:
*1993 and 1992
gen g_1993_1992 = (Emp/Emp_19922)-1
replace g_1993_1992 = . if Year != 1993

*2003 and 2002
gen g_2003_2002 = (Emp_20032/Emp_20022)-1

*Replace the growth rates to rescale the series

replace emp_growth = g_1993_1992 if Year == 1993 & g_1993_1992 != .
replace emp_growth = g_2003_2002 if Year == 2003 & g_2003_2002 != .

drop if Year == 19922 | Year == 20022 | Year == 20032

replace emp_growth = . if (Emp > 0 & Emp[_n-1] == 0) | (Emp == 0 & Emp[_n-1] > 0) 
replace emp_growth = 0 if emp_growth == .
replace emp_growth = emp_growth + 1

drop Emp_1992 Emp_20022 Emp_20032 g_* 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*There are some absolutely weird outliers; Here is a summary of the growth rates
/*
. summarize emp_growth, detail

emp_growth
		
Percentiles      Smallest
1%     .4095525       1.43e-06
5%      .740638       1.49e-06
10%     .8433611       1.49e-06	Obs	380,928
25%     .9516692       3.16e-06	Sum of Wgt.	380,928

50%            1	Mean	3.279259
Largest	Std. Dev.	676.042
75%     1.083915       73194.67
90%     1.241686       91993.19	Variance	457032.8
95%     1.426727       107087.3	Skewness	491.4483
99%     2.563332       380989.7	Kurtosis	267780.8
*/
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Here we smooth the series to correct for these outliers
replace emp_growth = 1 if emp_growth < 0.40 | emp_growth > 2.56 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Use these lines to create the forward adjustment (i.e. starting from 1947)
replace emp_growth = 1 if Year == 1947

gen     new_Emp = Emp if Year == 1947

*These lines are here because some series start after 1947 and they have zeroes before that
*Thus, one can not compute the growth rates and put the series together unless this step is done
replace new_Emp = Emp if Emp  == 0
replace new_Emp = Emp if Emp[_n-1] == 0 & Emp[_n] != 0

replace emp_growth = 1 if Emp[_n-1] == 0 & Emp[_n] != 0

drop if Year == 19922 | Year == 20022 | Year == 20032

*This line looks complicated, but is actually a great way to compute the new series given the 
*discontinuites in the old one
replace new_Emp = L.new_Emp*emp_growth if emp_growth != . & L.new_Emp !=0 & Year > 1947

replace new_Emp = 0 if Emp == 0
rename new_Emp new_Emp_1947
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Aggregate data by year and create a chart by education to compare with the raw data

preserve
collapse (sum) Emp new_Emp_1947, by(Year Education)

replace Emp          =          Emp/1000000
replace new_Emp_1947 = new_Emp_1947/1000000

twoway (connected Emp Year if Education == 1) (connected Emp Year if Education == 2) (connected Emp Year if Education == 3) ///
(connected Emp Year if Education == 4) (connected Emp Year if Education == 5) (connected Emp Year if Education == 6), ///
title("Employment by Education Using Raw World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/Emp_raw.png, replace
graph export     Figures/Emp_raw.pdf, replace
graph save Graph Figures/Emp_raw.gph, replace

twoway (connected new_Emp_1947 Year if Education == 1) (connected new_Emp_1947 Year if Education == 2) (connected new_Emp_1947 Year if Education == 3) ///
(connected new_Emp_1947 Year if Education == 4) (connected new_Emp_1947 Year if Education == 5) (connected new_Emp_1947 Year if Education == 6), ///
title("Employment by Education Using the Bridged World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/Emp_bridged.png, replace
graph export     Figures/Emp_bridged.pdf, replace
graph save Graph Figures/Emp_bridged.gph, replace
restore
*-------------------------------------------------------------------------------
rename Emp Emp_raw
rename new_Emp_1947 Emp_bridged
keep Year Industry Sex Class Education Age id Emp_raw Emp_bridged
order Emp_raw Emp_bridged, last
save dta_files/emp_bridged.dta, replace

cd ..
save Data_for_Calibration/dta_files/emp_bridged.dta, replace
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
