*----------------------------------------------------------------------------------------------------------------------
/*
This .do file produces the time series used to calibrate the model. 

Output:

We produce 8 (eight) series for the US:
1. The share of the HS Sector in Total VA
2. The Share of HS Labor in the Labor Compensation of the HS Sector
2. The Share of HS Labor in the Labor Compensation of the LS Sector  
4. The chained relative price index of the HS Sector relative to the LS Sector
5. GDP per-capita
6. The Skill Premium (w_HS/w_LS)
7. The share of Efficiency Units that Correspond to HS Labor
8. The Share of HS Sector's Labor Compensation in Total Labor Compensation

The series are saved in the file Data_for_Calibration.dta and in a .csv file called data_$date_$initial_year_$final_year.csv

Input: 
1. The April 2013 release of the World KLEMS database for the US, Basic File. Available at http://www.worldklems.net/data/basic/usa_wk_apr_2013.xlsx 
2. The April 2013 release of the World KLEMS database for the US, Labor File. Available at http://www.worldklems.net/data/input/usa_wk_apr_2013_labour.xlsx .
The raw time series Hours have been bridged to avoid issues related to industry and education classification. See folder Bridging_World_KLEMS to look at the bridging codes. 

We specify below for each of the series its name and the file used as input to produce it.
*/
*----------------------------------------------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
set more off
macro drop _all

global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud

cd $dir/Data_for_Calibration
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
*ISIC Codes for Redundant Industries that we deleete to avoid duplications
global redundant_ind      D 23t25 G I JtK K LtQ
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*WK Codes for HS Industries
*Benchmark HS Industries: (WK 28- ISIC M) Education, (WK 29 - ISIC N) Health and social work, (WK 26 - ISIC 71t74) Renting of m&eq and other business activities, (WK 24 - ISIC J) Financial intermediation
global HS_benchmark_WK  28 29 26 24 
*Expanded Set 1: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70)
global HS_expanded1_WK  28 29 26 24 25
*Expanded Set 2: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24)
global HS_expanded2_WK  28 29 26 24 25 8
*Expanded Set 3: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24) + Electrical and optical equipment (Ind 13 - ISIC Code 30t33) 
global HS_expanded3_WK  28 29 26 24 25 8 13
*Expanded Set 4: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24) 
*+ Electrical and optical equipment (Ind 13 - ISIC Code 30t33) + Public admin and defence; compulsory social security (Ind 27 - ISIC Code L) 
global HS_expanded4_WK  28 29 26 24 25 8 13 27
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*ISIC Codes for LS Industries
*Benchmark HS Industries: (WK 28- ISIC M) Education, (WK 29 - ISIC N) Health and social work, (WK 26 - ISIC 71t74) Renting of m&eq and other business activities, (WK 24 - ISIC J) Financial intermediation
global HS_benchmark_ISIC  M N J 71t74 
*Expanded Set 1: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70)
global HS_expanded1_ISIC  M N J 71t74 70
*Expanded Set 2: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24)
global HS_expanded2_ISIC  M N J 71t74 70 24
*Expanded Set 3: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24) + Electrical and optical equipment (Ind 13 - ISIC Code 30t33) 
global HS_expanded3_ISIC  M N J 71t74 70 24 30t33
*Expanded Set 4: Benchmark HS Industries + Real Estate (Ind 25- ISIC Code 70) + Chemicals and Chemical Products (Ind 8- ISIC Code 24) 
*+ Electrical and optical equipment (Ind 13 - ISIC Code 30t33) + Public admin and defence; compulsory social security (Ind 27 - ISIC Code L) 
global HS_expanded4_ISIC  M N J 71t74 70 24 30t33 L
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/* 
Value Added Share of the High-Skill Sector.

Input:  the April 2013 release of the World KLEMS database for the US, Basic File. Available at http://www.worldklems.net/data/basic/usa_wk_apr_2013.xlsx
Output: a time series (share_VA_HS) with the percentage of total value added that corresponds to the HS Sector, which is saved in the .dta file Data_for_Calibration.dta .
*/
*-------------------------------------------------------------------------------

import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "VA"

* Drop Redundant Industries
foreach j of global redundant_ind{
drop if code == "`j'"
} 

* Define High-Skill Industries
gen Sector_Type = .
foreach j of global HS_benchmark_ISIC{
*foreach j of global HS_expanded4_ISIC{
replace  Sector_Type = 1 if code == "`j'"
} 
 
replace Sector_Type = 0 if code  == "TOT"
replace Sector_Type = 2 if Sector_Type == . 

label define Sector_Type_Label 0 "TOT" 1 "HS" 2 "LS"
label values Sector_Type Sector_Type_Label

collapse (sum) _19* _20* (last) Variable, by(Sector_Type)
order Variable, first

drop if Sector_Type == 0

reshape long _ , i(Sector_Type) j(Year)
drop Variable
rename _ VA

reshape wide VA, i(Year) j(Sector_Type)
rename VA1 VA_HS
rename VA2 VA_LS

gen share_VA_HS = VA_HS/(VA_HS+VA_LS)
gen share_VA_LS = VA_LS/(VA_HS+VA_LS)

drop VA_HS VA_LS

export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(A4) firstrow(variables)
save Data_for_Calibration, replace
*-------------------------------------------------------------------------------


*----------------------------------------------------------------------------------------------------------------------
/*
* Compensation Share of High-Skill Labor in the High-Skill and Low-Skill Sectors 
Share of Compensation of Workers with College Complete or More in the High- and Low-Skill Sector

Input:  the April 2013 release of the World KLEMS database for the US, Labor File. Available at http://www.worldklems.net/data/input/usa_wk_apr_2013_labour.xlsx . 
The raw time series for Employment, Hours and Compensation have been bridged to avoid issues related to industry and education classification. See folder Bridging World KLEMS to look at the bridging codes. 
Output: two time series for the share of high skill labor compensation, one for the High-Skill (share_HS_Labor_HS_Sector) and another one for the Low-Skill sector (share_HS_Labor_LS_Sector), 
which are saved in the .dta file Data_for_Calibration.dta .
*/
*-------------------------------------------------------------------------------

cls 
clear all
use  dta_files/h_emp_bridged.dta

keep Year Industry Sex Class Education Age avg_hours_bridged
rename avg_hours_bridged avg_hours
egen id = concat(Year Industry Sex Class Education Age), punct("_")	

tempfile h_emp_temp
save     dta_files/h_emp_temp.dta, replace

*---------------------------------------------
cls 
clear all
use  dta_files/comp_bridged.dta

keep Year Industry Sex Class Education Age wage_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename wage_bridged wage

save     dta_files/comp_temp.dta, replace
*---------------------------------------------
cls 
clear all
use  dta_files/emp_bridged.dta

keep Year Industry Sex Class Education Age Emp_bridged
rename Emp_bridged emp
egen id = concat(Year Industry Sex Class Education Age), punct("_")	

merge 1:1 id using dta_files/h_emp_temp.dta
drop _merge

merge 1:1 id using dta_files/comp_temp.dta
drop _merge

gen Total_Comp = wage*avg_hours*emp

drop emp id avg_hours wage
rm dta_files/comp_temp.dta
rm dta_files/h_emp_temp.dta
*---------------------------------------------

gen     Skill_Type = 1 if Education >= 5
replace Skill_Type = 2 if Skill_Type == .

label define Skill_Type_Label 1 "HS" 2 "LS"
label values Skill_Type Skill_Type_Label

* Define the Industries in the High-Skill Sector
gen Sector_Type = .
foreach j of global HS_benchmark_WK{
*foreach j of global HS_expanded4_WK{
replace  Sector_Type = 1 if Industry == `j'
} 
 
replace Sector_Type = 2 if Sector_Type == . 

label define Sector_Type_Label 1 "HS" 2 "LS"
label values Sector_Type Sector_Type_Label


* Generate the Share of the High-Skill Sector in Total Compensation First
preserve
collapse (sum) Total_Comp, by(Year Sector_Type)
reshape wide Total_Comp, i(Year) j(Sector_Type)

gen comp_share_HS_ind = Total_Comp1/(Total_Comp1 + Total_Comp2)
keep Year comp_share_HS_ind

merge 1:1 Year using Data_for_Calibration.dta
drop _merge
save Data_for_Calibration, replace
restore


* Now Generate the Share of Compensation of High-Skill Labor in Each Sector
rename Total_Comp Comp

collapse (sum) Comp, by(Year Sector_Type Skill_Type)

sort Year Sector_Type Skill_Type
by Year Sector_Type: egen Total_Comp = total(Comp)

drop if Skill_Type == 2

gen share_HS_comp = Comp/Total_Comp
drop Skill_Type Comp Total_Comp

reshape wide share_HS_comp, i(Year) j(Sector_Type)
rename share_HS_comp1 share_HS_Labor_HS_Sector
rename share_HS_comp2 share_HS_Labor_LS_Sector

twoway (connected share_HS_Labor_HS_Sector Year) (connected share_HS_Labor_LS_Sector Year), xlabel(1947(2)2010, angle(vertical))

merge 1:1 Year using Data_for_Calibration.dta
keep if _merge == 3
drop _merge

save Data_for_Calibration, replace
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Chain-Weighted Relative Price Index
The relative price index of the HS Sector with respect to the LS Sector. The price indices are (Value Added) chain-weighted price indices for each of the industries in a broad sector.
NOTICE that the time series produced here differs from the one in Figure 2. In Figure 2 we use EU KLEMS data to be consistent with the other countries in the sample.

Input:  the April 2013 release of the World KLEMS database for the US, Basic File. Available at http://www.worldklems.net/data/basic/usa_wk_apr_2013.xlsx
Output: a time series for the relative price of the HS sector with respect to the LS Sector (P_HS_LS_chain) which we save in the .dta file Data_for_Calibration.dta .
*/
*-------------------------------------------------------------------------------
cls
clear all
import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "VA_P"

forval i = 1948/2010 {
        local  j =  `i'-1
	display `j'
        gen P_ratio_`i' = (_`i')/(_`j')
}

drop _*

*Drop Redundant Industries
foreach j of global redundant_ind{
drop if code == "`j'"
} 

*Define High-Skill Industries
gen Sector_Type = .
foreach j of global HS_benchmark_ISIC{
*foreach j of global HS_expanded4_ISIC{

replace  Sector_Type = 1 if code == "`j'"
}

replace Sector_Type = 0 if code  == "TOT"
replace Sector_Type = 2 if Sector_Type == .  

label define Sector_Type_Label 0 "TOT" 1 "HS" 2 "LS"
label values Sector_Type Sector_Type_Label		

save dta_files/P_ratio_temp.dta, replace		

cls
clear all
import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "VA"

*Drop Redundant Industries
foreach j of global redundant_ind{
drop if code == "`j'"
} 

* Define the Industries in the High-Skill Sector
gen Sector_Type = .
foreach j of global HS_benchmark_ISIC{
*foreach j of global HS_expanded4_ISIC{

replace  Sector_Type = 1 if code == "`j'"
}

replace Sector_Type = 0 if code  == "TOT"
replace Sector_Type = 2 if Sector_Type == .  
*-------------------------------------------------------------------------------

label define Sector_Type_Label 0 "TOT" 1 "HS" 2 "LS"
label values Sector_Type Sector_Type_Label	

merge 1:1 code using dta_files/P_ratio_temp.dta
drop _merge

forval i = 1948/2010 {
        local    j =  `i'-1
	    display `j'
        gen chain_lag_`i'  = P_ratio_`i'*_`j'
		gen chain_lead_`i' = P_ratio_`i'*_`i'
}

order Sector_Type, first
drop if Sector_Type == 0

collapse (sum) _* chain_lag_* chain_lead_*, by(Sector_Type)

forval   i = 1948/2010 {
local    j =  `i'-1
gen P_chain_`i' = sqrt((chain_lag_`i'/_`j')*(chain_lead_`i'/_`i'))
}

drop _* chain_lag_* chain_lead_*

gen accum_P_chain_1947 = 100

order Sector_Type P_chain_1948, first

forval   i = 1948/2010 {
local    j =  `i'-1
gen accum_P_chain_`i'= (P_chain_`i')*(accum_P_chain_`j')
}

drop P_chain_*
reshape long accum_P_chain_ , i(Sector_Type) j(Year)
reshape wide accum_P_chain_ , i(Year) j(Sector_Type)
rename accum_P_chain_1 P_chain_HS
rename accum_P_chain_2 P_chain_LS

gen      HS_1977 = P_chain_HS if Year == 1977
gen      LS_1977 = P_chain_LS if Year == 1977
egen     HS_1977_all = max(HS_1977)
egen     LS_1977_all = max(LS_1977)

replace P_chain_HS = P_chain_HS*100/HS_1977_all
replace P_chain_LS = P_chain_LS*100/LS_1977_all

keep Year P_chain_HS P_chain_LS

twoway (connected P_chain_HS Year) (connected P_chain_LS Year), xlabel(1947 (2) 2010, angle(vertical)) legend(lab(1 "HS Sector") lab(2 "LS Sector"))
export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(I4) firstrow(variables)

gen P_HS_LS_chain = P_chain_HS/P_chain_LS

gen P_HS_LS_base   = P_HS_LS_chain if Year == 1970
egen P_HS_LS_base2 = max(P_HS_LS_base)

replace P_HS_LS_chain = P_HS_LS_chain/P_HS_LS_base2

keep Year P_chain_HS P_chain_LS P_HS_LS_chain

merge 1:1 Year using Data_for_Calibration.dta
drop _merge

rm dta_files/P_ratio_temp.dta
rm 	dta_files/LP_I_temp.dta
rm 	dta_files/VA_P_temp.dta
rm 	dta_files/VA_temp.dta

save Data_for_Calibration, replace

*------------------------------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Labor Productivity

Labor productivity per hour worked in the High- and Low-Skill Sector. Labor productivity is defined as Value Added per hour worked at the broad sector level.
For consistency we deflate VA using the chain price indices defined above.

Input:  the April 2013 release of the World KLEMS database for the US, Basic File. Available at http://www.worldklems.net/data/basic/usa_wk_apr_2013.xlsx
Output: two series for labor productivity indices, one corresponding to the High-Skill sector (LAB_prod_ind_HS) and another one for the Low-Skill sector (LAB_prod_ind_LS)
which we save in the .dta file Data_for_Calibration.dta .
*/
*-------------------------------------------------------------------------------

cls
clear all
import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "VA" 

rename _* VA_*
drop Variable
save dta_files/VA_temp.dta, replace	

cls
clear all
import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "VA_P" 

rename _* VA_P_*
drop Variable

save dta_files/VA_P_temp.dta, replace	

cls
clear all
import excel excel_files/usa_wk_apr_2013.xlsx, sheet("DATA") firstrow
keep if Variable == "LP_I" 

rename _* LP_I_*
drop Variable
save dta_files/LP_I_temp.dta, replace	

merge 1:1 code using dta_files/VA_temp
drop _merge
merge 1:1 code using dta_files/VA_P_temp
drop _merge

*Drop Redundant Industries
foreach j of global redundant_ind{
drop if code == "`j'"
} 

*Define High-Skill Industries
gen Sector_Type = .
foreach j of global HS_benchmark_ISIC{
*foreach j of global HS_expanded4_ISIC{

replace  Sector_Type = 1 if code == "`j'"
} 

replace Sector_Type = 0 if code  == "TOT"
replace Sector_Type = 2 if Sector_Type == .  
*-------------------------------------------------------------------------------

label define Sector_Type_Label 0 "TOT" 1 "HS" 2 "LS"
label values Sector_Type Sector_Type_Label	

forval   i = 1947/2010 {
gen denom_`i' = (VA_`i'/VA_P_`i')/(LP_I_`i')
}

collapse (sum) denom_* VA_*, by(Sector_Type)
drop if Sector_Type == 0
drop VA_P_*

reshape long denom_ VA_ , i(Sector_Type) j(Year)
reshape wide denom_ VA_ , i(Year) j(Sector_Type)

rename denom_1 denom_HS
rename denom_2 denom_LS
rename VA_1 VA_HS
rename VA_2 VA_LS

merge 1:1 Year using Data_for_Calibration.dta
drop _merge

gen LAB_prod_ind_HS = (VA_HS/P_chain_HS)/denom_HS
gen LAB_prod_ind_LS = (VA_LS/P_chain_LS)/denom_LS

keep Year LAB_prod_ind_HS LAB_prod_ind_LS

gen      HS_1977 = LAB_prod_ind_HS if Year == 1977
gen      LS_1977 = LAB_prod_ind_LS if Year == 1977
egen     HS_1977_all = max(HS_1977)
egen     LS_1977_all = max(LS_1977)

replace LAB_prod_ind_HS = LAB_prod_ind_HS*100/HS_1977_all
replace LAB_prod_ind_LS = LAB_prod_ind_LS*100/LS_1977_all

keep Year LAB_prod_ind_HS LAB_prod_ind_LS
export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(M4) firstrow(variables)

merge 1:1 Year using Data_for_Calibration.dta
keep if _merge == 3
drop _merge

rm 	dta_files/emp_temp.dta
rm 	dta_files/h_emp_temp.dta

merge 1:1 Year using Data_for_Calibration.dta
keep if _merge == 3
drop _merge
save Data_for_Calibration, replace
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Share of Total Hours Worked by High-Skill Labor

Share of Total Hours Worked by Workers with College Complete or More.
Input:  the April 2013 release of the World KLEMS database for the US, Labor File. Available at http://www.worldklems.net/data/input/usa_wk_apr_2013_labour.xlsx . 
The raw time series Hours have been bridged to avoid issues related to industry and education classification. See folder Bridging_World_KLEMS to look at the bridging codes. 
Output: a time series corresponding to the share of total hours worked by high-skill workers.
*/
*------------------------------------------------------------------------------

cls 
clear all
use  dta_files/h_emp_bridged.dta
drop id
egen id = concat(Year Industry Sex Class Education Age), punct("_")	

save dta_files/h_emp_temp.dta, replace

cls 
clear all
use  dta_files/emp_bridged.dta

drop id
egen id = concat(Year Industry Sex Class Education Age), punct("_")	

save dta_files/emp_temp.dta, replace

merge 1:1 id using dta_files/h_emp_temp.dta
drop _merge

gen tot_H_Emp = Emp_bridged*avg_hours_bridged

gen     Skill_Type = 1 if Education >= 5
replace Skill_Type = 2 if Skill_Type == .

label define Skill_Type_Label 1 "HS" 2 "LS"
label values Skill_Type Skill_Type_Label

collapse (sum) tot_H_Emp, by(Year Skill_Type)
rename tot_H_Emp H_Emp

by Year: egen tot_H_Emp = total(H_Emp)
gen hours_skill_share = H_Emp/tot_H_Emp

keep if Skill_Type == 1
drop Skill_Type H_Emp tot_H_Emp

rename hours_skill_share HS_labor_hours_share
export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(Q4) firstrow(variables)

merge 1:1 Year using Data_for_Calibration.dta
keep if _merge == 3
drop _merge
save Data_for_Calibration, replace
*------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Skill Premium
Input: the April 2013 release of the World KLEMS database for the US, Labor File. Available at http://www.worldklems.net/data/input/usa_wk_apr_2013_labour.xlsx . 
The raw time series Hours have been bridged to avoid issues related to industry and education classification. See folder Bridging_World_KLEMS to look at the bridging codes. 
Output: a time series for the skill premium (w_prem), computed as w_hs/w_ls, where w_hs is the labor compensation per hour worked for male employees with college graduates and
w_ls is the labor compensation per hour worked for male employees with high school complete. The final series is label (w_prem) and saved .dta file Data_for_Calibration.dta .
*/
*------------------------------------------------------------------------------

cls 
clear all
use  dta_files/h_emp_bridged.dta

keep Year Industry Sex Class Education Age avg_hours_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename avg_hours_bridged avg_hours
save dta_files/h_emp_temp.dta, replace

cls 
clear all
use  dta_files/emp_bridged.dta
keep Year Industry Sex Class Education Age Emp_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename Emp_bridged emp
save dta_files/emp_temp.dta, replace

cls 
clear all
use  dta_files/comp_bridged.dta
keep Year Industry Sex Class Education Age wage_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename wage_bridged wage

merge 1:1 id using dta_files/h_emp_temp.dta
drop _merge

merge 1:1 id using dta_files/emp_temp.dta
drop id _merge

rm dta_files/h_emp_temp.dta
rm dta_files/emp_temp.dta

sort Year Industry Sex Class Education Age

gen tot_comp   = wage*avg_hours*emp
gen tot_h_emp  =      avg_hours*emp

drop if Class == 2
keep if Sex   == 1 & Age == 5 
keep if Education == 3 | Education == 5

collapse (sum) tot_comp tot_h_emp, by(Year Age Education)

*HS Workers
gen     Skill_Type = 1 if Education == 5

*LS Workers
replace Skill_Type = 2 if Education == 3
 
label define Skill_Type_Label 1 "HS" 2 "LS"
label values Skill_Type Skill_Type_Label

egen id = concat(Age Skill_Type)
drop Age Skill_Type Education

reshape wide tot_comp tot_h_emp, i(Year) j(id) string

gen wage_HS = (tot_comp51)/(tot_h_emp51)
gen wage_LS = (tot_comp52)/(tot_h_emp52)

gen w_prem      = wage_HS/wage_LS

keep Year wage_HS wage_LS w_prem

export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(T4) firstrow(variables)

merge 1:1 Year using Data_for_Calibration.dta
keep if _merge == 3
drop _merge

save Data_for_Calibration, replace
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
* GDP per capita

* Input:  the .dta file from PWT 9.0, available at https://www.rug.nl/ggdc/docs/pwt90.dta .
* Output: a series for United States' GDP per capita (gdp_pop) saved in the .dta files called Data_for_Calibration.
*-------------------------------------------------------------------------------

cls
clear all
use dta_files/pwt90.dta

keep if countrycode == "USA"
keep countrycode year rgdpna pop emp

gen gdp_pop = rgdpna/pop
gen gdp_emp = rgdpna/emp

drop pop emp rgdpna

gen gdp_pop_base = gdp_pop if year == 1970
gen gdp_emp_base = gdp_emp if year == 1970

egen gdp_pop_base2 = max(gdp_pop_base)
egen gdp_emp_base2 = max(gdp_emp_base)

replace gdp_pop = gdp_pop/gdp_pop_base2
replace gdp_emp = gdp_emp/gdp_emp_base2

rename year Year
keep Year gdp_pop gdp_emp
drop if Year > 2010
sort Year
export excel using Data_for_Calibration.xls, sheet("STATA_data") sheetmodify cell(AB4) firstrow(variables)

merge 1:1 Year using Data_for_Calibration.dta
drop _merge
sort Year
save Data_for_Calibration, replace
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Share of High_Skill Efficiency Units in Total Efficiency Units

Input: the April 2013 release of the World KLEMS database for the US, Labor File. Available at http://www.worldklems.net/data/input/usa_wk_apr_2013_labour.xlsx . 
The raw time series Hours have been bridged to avoid issues related to industry and education classification. See folder Bridging_World_KLEMS to look at the bridging codes. 
Output: a time series with the share of total hours worked by high-skill workers expressed into efficiency units of labor using the BKRV methodology (eff_HS_share;see the Online Appendix for 
a more detailed description). The final series is label (w_prem) and saved .dta file Data_for_Calibration.dta .

In these line we also run a regression similar to the one in KM but using our definition for the skill premium and our measure of efficiency units to copute the elasticity of substitution between high-
and low-skill labor at the aggregate level. The estimated coefficient is used to calibrate the elasticity of substitution in our two-sector economy.
*/
*-------------------------------------------------------------------------------

cls 
clear all
use  dta_files/h_emp_bridged.dta

keep Year Industry Sex Class Education Age avg_hours_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename avg_hours_bridged avg_hours
save dta_files/h_emp_temp.dta, replace

cls 
clear all
use  dta_files/emp_bridged.dta
keep Year Industry Sex Class Education Age Emp_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename Emp_bridged emp
save dta_files/emp_temp.dta, replace

cls 
clear all
use  dta_files/comp_bridged.dta
keep Year Industry Sex Class Education Age wage_bridged
egen id = concat(Year Industry Sex Class Education Age), punct("_")	
rename wage_bridged wage

merge 1:1 id using dta_files/h_emp_temp.dta
drop _merge

merge 1:1 id using dta_files/emp_temp.dta
drop id _merge

rm dta_files/h_emp_temp.dta
rm dta_files/emp_temp.dta

sort Year Industry Sex Class Education Age

gen tot_comp   = wage*avg_hours*emp
gen tot_h_emp  =      avg_hours*emp

keep Year Industry Sex Class Education Age tot_comp emp tot_h_emp 									  
drop if Year == 19922 | Year == 20022 | Year == 20032									  									  
sort Year Industry 

* To obtain something closer to full-time full-workers, we discard the self-employed
drop if Class == 2

*  Define the Skill Groups
** High Skill (College Complete or More)
gen     skill_group = 1 if Education   >= 5

*  Low Skill
replace skill_group = 2 if Education   < 5

label define labor_skill_labels 1 "HS" 2 "LS" 
label values skill_group labor_skill_labels

order Year Industry Sex Class Education Age skill_group

collapse (sum) tot_comp , by(Year skill_group) 

merge m:1 Year using Data_for_Calibration

keep Year skill_group tot_comp wage_HS wage_LS w_prem

collapse (sum) tot_comp , by(Year skill_group) 
merge m:1 Year using Data_for_Calibration
keep Year skill_group tot_comp wage_HS wage_LS w_prem

gen eff_HS = tot_comp/wage_HS
gen eff_LS = tot_comp/wage_LS

replace eff_HS = 0 if skill_group == 2
replace eff_LS = 0 if skill_group == 1

collapse (sum) eff_HS eff_LS (last) w_prem, by(Year) 
gen eff_HS_share =  eff_HS/(eff_HS+eff_LS) 

gen log_ratio_HS_LS = log(eff_HS/eff_LS)
gen log_w_prem      = log(w_prem)

*----------------------------------------------------------------------------------------------------------------------
/*
The regression below is used to obtain the aggregate substitution coefficient (the inverse of the elasticity) between high- and low-
skill labor using our data and our period of interest.
*/
*-------------------------------------------------------------------------------

reg log_w_prem log_ratio_HS_LS Year if Year >= 1977 & Year <= 2005

/*
. reg log_w_prem log_ratio_HS_LS Year if Year >= 1977 & Year <= 2005

      Source |       SS           df       MS      Number of obs   =        29
-------------+----------------------------------   F(2, 26)        =    716.77
       Model |  .626729063         2  .313364532   Prob > F        =    0.0000
    Residual |  .011366905        26  .000437189   R-squared       =    0.9822
-------------+----------------------------------   Adj R-squared   =    0.9808
       Total |  .638095968        28  .022789142   Root MSE        =    .02091

---------------------------------------------------------------------------------
     log_w_prem |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
----------------+----------------------------------------------------------------
log_ratio_HS_LS |   -.707686   .0723738    -9.78   0.000    -.8564526   -.5589195
           Year |   .0309706   .0015047    20.58   0.000     .0278777    .0340636
          _cons |   -61.8986    3.05982   -20.23   0.000    -68.18815   -55.60905
---------------------------------------------------------------------------------
*/
*-------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------
/*
Here we clean up and save the final dataset, both in a .dta and in a .csv file. The .csv file is used as input 
in the calibration routine we run in Matlab.
*/
keep Year eff_HS_share
merge 1:1 Year using Data_for_Calibration

keep share_VA_HS share_HS_Labor_HS_Sector share_HS_Labor_LS_Sector P_HS_LS_chain gdp_pop w_prem eff_HS_share comp_share_HS_ind Year

order share_VA_HS share_HS_Labor_HS_Sector share_HS_Labor_LS_Sector P_HS_LS_chain gdp_pop w_prem eff_HS_share comp_share_HS_ind Year

keep if Year >= 1970 & Year <= 2010

save Data_for_Calibration, replace
export delimited using "data_2020_05_15_1970_2010", replace
*-------------------------------------------------------------------------------
/*
1. HS Sector VA share
2. HS Labor Comp Share in HS Sector
3. HS Labor Comp Share in LS Sector
4. P_HS/P_LS
5. GDP per-capita
6. w_hs/w_ls
7. E_hs/(E_hs+E_ls)
8. hs_comp_share
9. year 
