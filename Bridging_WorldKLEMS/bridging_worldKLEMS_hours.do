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
*In .do this file we Bridge Hours Data
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
set more off
macro drop _all

global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud

cd $dir/Bridging_WorldKLEMS
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*H EMP: Average number of hours worked per week
import excel excel_files/usa_wk_apr_2013_labour.xlsx, sheet("H_EMP") firstrow

reshape long Age, i(Year Industry Sex Class Education) j(Age_group)
rename Age H_Emp
rename Age_group Age

egen id = concat(Industry Sex Class Education Age)
destring id, replace

merge 1:1 Year id using  dta_files/emp_bridged.dta
drop _merge

* Generate Total Hours Under the Corrected Employment Measure
gen tot_H_Emp  = H_Emp*Emp_bridged

* Generate Total Hours Under the Raw Employment Measure
gen tot_H_Emp_raw = H_Emp*Emp_raw

drop H_Emp
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
tsset id Year

rename tot_H_Emp     H_Emp
rename tot_H_Emp_raw H_Emp_raw

gen emp_growth = D.H_Emp / L.H_Emp

replace emp_growth =  . if Year == 19922 | Year == 20022 | Year == 20032 

bys id Year: gen H_Emp_19922 = H_Emp if Year == 19922
bys id Year: gen H_Emp_20022 = H_Emp if Year == 20022
bys id Year: gen H_Emp_20032 = H_Emp if Year == 20032

*Place 19922 in 1993 to compute growht rate between 1993 and 19922
replace H_Emp_19922 = H_Emp_19922[_n+18] if H_Emp_19922 == .

*Place 20022 and 20032 together in 2003 to compute the growth rate between 2002 and 2003
replace H_Emp_20022 = H_Emp_20022[_n+9]  if H_Emp_20022 == .
replace H_Emp_20032 = H_Emp_20032[_n+10] if H_Emp_20032 == .

*Compute the growth rate between:
*1993 and 1992
gen g_1993_1992 = (H_Emp/H_Emp_19922)-1
replace g_1993_1992 = . if Year != 1993

*2003 and 2002
gen g_2003_2002 = (H_Emp_20032/H_Emp_20022)-1

*Replace the growth rates to rescale the series
replace emp_growth = g_1993_1992 if Year == 1993 & g_1993_1992 != .
replace emp_growth = g_2003_2002 if Year == 2003 & g_2003_2002 != .

drop if Year == 19922 | Year == 20022 | Year == 20032

replace emp_growth = . if (H_Emp > 0 & H_Emp[_n-1] == 0) | (H_Emp == 0 & H_Emp[_n-1] > 0) 
replace emp_growth = 0 if emp_growth == .
replace emp_growth = emp_growth + 1

drop H_Emp_1992 H_Emp_20022 H_Emp_20032 g_* 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Use these lines to create the forward adjustment (i.e. starting from 1947)

replace emp_growth = 1 if Year == 1947
gen     new_H_Emp = H_Emp if Year == 1947

*These lines are here because some series start after 1947 and they have zeroes before that
*Thus, one can not compute the growth rates and put the series together unless this step is done
replace new_H_Emp = H_Emp if H_Emp  == 0
replace new_H_Emp = H_Emp if H_Emp[_n-1] == 0 & H_Emp[_n] != 0

replace emp_growth = 1 if H_Emp[_n-1] == 0 & H_Emp[_n] != 0

drop if Year == 19922 | Year == 20022 | Year == 20032

*This line looks complicated, but is actually a great way to compute the new series given the 
*discontinuites in the old one
replace new_H_Emp = L.new_H_Emp*emp_growth if emp_growth != . & L.new_H_Emp !=0 & Year > 1947

replace new_H_Emp = 0 if H_Emp == 0

rename new_H_Emp new_H_Emp_1947
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Use these lines to create the backwards adjustment (i.e. starting from 2010)
/*
gen     aux_2010 = new_Emp_1947 if Year == 2010 & Emp != 0

replace aux_2010 = new_Emp_1947 if aux_2010 == . & Emp > 0 & Emp[_n+1] == 0
replace aux_2010 = 0            if Emp > 0 & Emp[_n+1] == 0 & Emp[_n-1] == 0

by id: egen aux_2010_2 = max(aux_2010)

gen     emp_index_2010 = new_Emp_1947/aux_2010_2
replace emp_index_2010 = 0 if emp_index_2010 == .

gen new_Emp_2010 = Emp*emp_index_2010

drop aux_2010 aux_2010_2 emp_index_2010
*/
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Aggregate data and create a chart by education to see how things look like
preserve
collapse (sum) H_Emp_raw new_H_Emp_1947, by(Year Education)

rename H_Emp_raw H_Emp

replace H_Emp          =          H_Emp/1000000
replace new_H_Emp_1947 = new_H_Emp_1947/1000000

twoway (connected H_Emp Year if Education == 1) (connected H_Emp Year if Education == 2) (connected H_Emp Year if Education == 3) ///
(connected H_Emp Year if Education == 4) (connected H_Emp Year if Education == 5) (connected H_Emp Year if Education == 6), ///
title("Total Hours by Education Using Raw World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/H_Emp_raw.png, replace
graph export     Figures/H_Emp_raw.pdf, replace
graph save Graph Figures/H_Emp_raw.gph, replace

twoway (connected new_H_Emp_1947 Year if Education == 1) (connected new_H_Emp_1947 Year if Education == 2) (connected new_H_Emp_1947 Year if Education == 3) ///
(connected new_H_Emp_1947 Year if Education == 4) (connected new_H_Emp_1947 Year if Education == 5) (connected new_H_Emp_1947 Year if Education == 6), ///
title("Total Hours by Education Using the Bridged World KLEMS Data") ///
legend (lab(1 "Less than HS") lab(2 "Some HS") lab(3 "HS") lab(4 "Some College") lab(5 "College") lab(6 "More than College")) ///
xlabel(1940 (10) 2010) 

graph export     Figures/H_Emp_bridged.png, replace
graph export     Figures/H_Emp_bridged.pdf, replace
graph save Graph Figures/H_Emp_bridged.gph, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
rename new_H_Emp_1947 H_Emp_bridged

keep Year Industry Sex Class Education Age id Emp_raw H_Emp_raw Emp_bridged H_Emp_bridged

gen avg_hours_raw     = H_Emp_raw/Emp_raw
gen avg_hours_bridged = H_Emp_bridged/Emp_bridged

replace avg_hours_raw     = 0 if avg_hours_raw == . 
replace avg_hours_bridged = 0 if avg_hours_bridged == . 

save dta_files/h_emp_bridged.dta, replace

cd ..
save Data_for_Calibration/dta_files/h_emp_bridged.dta, replace
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
