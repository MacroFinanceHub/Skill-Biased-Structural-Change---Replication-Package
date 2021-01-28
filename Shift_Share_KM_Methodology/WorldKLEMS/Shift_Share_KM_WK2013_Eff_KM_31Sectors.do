*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following Katz & Murhpy (1992) 
*and using the WordKLEMS 2013 Labour File as Main Data Source.

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : WorldKLEMS
*Sectoral Aggregation             : 31 Sectors
*Methodology for Efficiency Units : KM 
*Age/Expirience                   : Age
*Measure of Sector Size           : Employment Measured in BKRV Efficiency Units/Hours
*Results Reported in              : Table 2, Column D, row (vi) Online Appendix for 1979-1989 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
cls
clear all
macro drop _all
set more off

*Choose the working directory
*global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
global dir /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/

*cd $dir\Shift_Share_KM_Methodology\WorldKLEMS\
cd $dir/Shift_Share_KM_Methodology/WorldKLEMS/

*Choose the period
global Initial_Year 1979
global Final_Year   1989
global age_groups "Age1 Age2 Age3 Age4 Age5 Age6 Age7 Age8"
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* STEP 1: Pull the data, merge, and clean files

* Pull the data from the bridged WorldKLEMS Files
* See note 1 in the bottom of this code to see why we use bridged data

cls
clear all
use      dta_files/comp_bridged.dta
keep     Year Industry Sex Class Education Age wage_bridged
rename   wage_bridged wage
egen     id = concat(Year Industry Class Sex Education Age), punct("_")
order    id, first
destring id, replace
save     dta_files/WK_2013_COMP.dta, replace

cls
clear all
use      dta_files/emp_bridged.dta
keep     Year Industry Sex Class Education Age Emp_bridged
rename   Emp_bridged emp
egen     id = concat(Year Industry Class Sex Education Age), punct("_")
order    id, first
destring id, replace
save     dta_files/WK_2013_EMP.dta, replace

cls
clear all
use      dta_files/h_emp_bridged.dta
keep     Year Industry Sex Class Education Age avg_hours_bridged
egen     id = concat(Year Industry Class Sex Education Age), punct("_")
rename   avg_hours_bridged avg_hours
order    id, first
destring id, replace

merge m:m id using dta_files/WK_2013_COMP.dta
drop _merge
merge m:m id using dta_files/WK_2013_EMP.dta
drop _merge
sort Year Industry Sex Class Education Age id

rm dta_files/WK_2013_COMP.dta
rm dta_files/WK_2013_EMP.dta
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Generate Annual Compensation by Age group

drop id 
egen     id = concat(Year Industry Class Sex Education)
order    id, first
destring id, replace

reshape wide avg_hours wage emp, i(id) j(Age)

foreach i of num 1/8 {
rename avg_hours`i' avg_hours_Age`i'
rename emp`i'       emp_Age`i'
rename wage`i'      wage_Age`i'
}

order id Year Industry Sex Class Education emp_Age* avg_hours_Age* wage_Age* 

 foreach age of global age_groups {
	gen comp_`age'   = (  wage_`age' )*( avg_hours_`age')*( emp_`age' )*52
	gen tot_h_`age'  = ( avg_hours_`age' )*(  emp_`age' )*52
}

keep Year Industry Sex Class Education comp_* emp_*  tot_h_* 									  
drop if Year == 19922 | Year == 20022 | Year == 20032									  									  
sort Year Industry 
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Define the Skill Groups

*High Skill (College Complete or More)
gen     skill_group = 1 if Education   >= 5

*Low Skill
replace skill_group = 2 if Education   < 5

label define labor_skill_labels 1 "HS_Labor" 2 "LS_Labor" 
label values skill_group labor_skill_labels

order Year Industry Sex Class Education skill_group
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 2: Generate Fixed Weights and the Wage Premium Following KM's Methodology
preserve
collapse (sum) comp_Age*  emp_Age* tot_h_Age* (last) skill_group, by(Year Sex Class Education)

keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class
 
foreach i of num 1/8 {
by Year:  egen      cum_hours_Age`i'  = total(tot_h_Age`i')
}

gen cum_hours = cum_hours_Age1 + cum_hours_Age2 + cum_hours_Age3 + cum_hours_Age4 + cum_hours_Age5 + cum_hours_Age6 + cum_hours_Age7 + cum_hours_Age8
drop cum_hours_Age*

foreach i of num 1/8 {
gen share_h_Age`i' = tot_h_Age`i'/cum_hours 
}

*Generate Fixed Weights
collapse (mean) share_h_* , by(Sex Education)  

*gen check = share_h_Age1 + share_h_Age2 + share_h_Age3 + share_h_Age4 + share_h_Age5 + share_h_Age6 + share_h_Age7 + share_h_Age8
*egen sum_check = total(check)

rename share_h_*  fixed_weights_*
save  dta_files/fixed_weights_${Initial_Year}_${Final_Year}.dta, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Build the Wage Premium Following KM's Methodology
*(see Note 2 in the bottom of the code)

preserve
keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class

collapse (sum) comp_* tot_h*, by(Year Sex Education)

foreach i of num 1/8 {
gen	            w_Age`i'        = (comp_Age`i'/tot_h_Age`i') 
by Year Sex: gen  w_HS_Age`i'       = w_Age`i' if Education == 5
by Year Sex: gen  w_LS_Age`i'       = w_Age`i' if Education == 3
by Year Sex: egen w_HS_Age`i'_prime = max(w_HS_Age`i')
by Year Sex: egen w_LS_Age`i'_prime = max(w_LS_Age`i')
}

foreach i of num 1/8 {
drop   w_HS_Age`i' 
rename w_HS_Age`i'_prime w_HS_Age`i'
}

sort Year Sex Education
foreach i of num 1/8 {
gen w_prem_Age`i' = (w_HS_Age`i'/w_LS_Age`i')
}

merge m:m Sex Education using dta_files/fixed_weights_${Initial_Year}_${Final_Year}.dta
sort Year Sex Education
drop _merge

collapse (sum) fixed_weights_* (max) w_prem_*, by(Year Sex)

gen w_prem            = 0
gen cum_fixed_weights = 0
foreach i of num 3/8 {
replace w_prem  = w_prem + (fixed_weights_Age`i')*(w_prem_Age`i')
replace cum_fixed_weights  = cum_fixed_weights + fixed_weights_Age`i'
}

collapse (sum) w_prem cum_fixed_weights, by(Year)
save   dta_files/wage_premium_KM_${Initial_Year}_${Final_Year}.dta, replace
sort Year
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Generate the Wage Index Used in the KM Methodology to Compute Efficiency Units
preserve
keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class

foreach i of num 1/8 {
gen	w_Age`i'  = (comp_Age`i'/tot_h_Age`i') 
}

sort Year Industry Sex Education
merge m:m Sex Education using dta_files/fixed_weights_${Initial_Year}_${Final_Year}.dta
drop _merge

gen wage_index = 0
gen cum_fixed_weights = 0
foreach i of num 1/8 {
replace w_Age`i' = 0 if w_Age`i' == .
replace wage_index  = wage_index + (fixed_weights_Age`i')*(w_Age`i')
replace cum_fixed_weights  = cum_fixed_weights + fixed_weights_Age`i'
}


collapse (sum) wage_index cum_fixed_weights, by(Year skill_group)
replace wage_index = wage_index/cum_fixed_weights
drop cum_fixed_weights
reshape wide wage_index, i(Year) j(skill_group) 
rename wage_index1 w_index_HS
rename wage_index2 w_index_LS
gen    wage_premium_KM = w_index_HS/w_index_LS

save   dta_files/wage_index_KM_${Initial_Year}_${Final_Year}.dta, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Generate the Weights to Transform Hours Into Efficiency Units Under the KM Methodology
preserve
keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class

foreach i of num 1/8 {
gen	w_Age`i'  = (comp_Age`i'/tot_h_Age`i')
replace w_Age`i'  = 0 if w_Age`i' == . 
}
merge m:m Year using dta_files/wage_index_KM_${Initial_Year}_${Final_Year}.dta
drop _merge

gen     wage_index = w_index_HS if skill_group == 1
replace wage_index = w_index_LS if skill_group == 2

foreach i of num 1/8 {
gen eff_weight_Age`i' = w_Age`i'/wage_index 
}

collapse (mean) eff_weight_Age*, by(Sex Education)
save   dta_files/eff_weights_KM_${Initial_Year}_${Final_Year}.dta, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class

merge m:m Sex Education using dta_files/eff_weights_KM_${Initial_Year}_${Final_Year}.dta
drop _merge

merge m:m Year using dta_files/wage_premium_KM_${Initial_Year}_${Final_Year}.dta
drop _merge

sort Year Industry Sex Education

replace tot_h_Age1 = 0 if tot_h_Age1 == . 
replace tot_h_Age2 = 0 if tot_h_Age2 == . 
gen eff_KM = tot_h_Age1*eff_weight_Age1 + tot_h_Age2*eff_weight_Age2 + tot_h_Age3*eff_weight_Age3 ///
	   + tot_h_Age4*eff_weight_Age4 + tot_h_Age5*eff_weight_Age5 + tot_h_Age6*eff_weight_Age6 ///
	   + tot_h_Age7*eff_weight_Age7 + tot_h_Age8*eff_weight_Age8 

*-------------------------------------------------------------------------------
*STEP 4: Put the Data Together

collapse (sum) eff_KM, by(Year Industry skill_group)
replace eff_KM = eff_KM/1000000 

merge m:m Year using dta_files/wage_premium_KM_${Initial_Year}_${Final_Year}.dta
drop _merge

merge m:m Year using dta_files/wage_index_KM_${Initial_Year}_${Final_Year}.dta
drop _merge

*-------------------------------------------------------------------------------
keep if Year >= $Initial_Year & Year <= $Final_Year 

keep Year skill_group Industry eff_KM wage_premium_KM

reshape wide eff_KM wage_premium_KM, i(Year Industry) j(skill_group)
rename  eff_KM1 eff_KM_HS
rename  eff_KM2 eff_KM_LS
rename  wage_premium_KM1 wage_premium_KM
drop    wage_premium_KM2

*Compute the Ratio of HS to LS Efficiency Units
preserve
collapse (sum) eff_KM_HS eff_KM_LS (last) wage_premium_KM, by(Year)
gen eff_KM_HS_LS = eff_KM_HS/eff_KM_LS
keep Year eff_KM_HS_LS wage_premium_KM
save dta_files/eff_and_premium_KM_${Initial_Year}_${Final_Year}.dta, replace
restore

*Express Eff Unit Into HS Equivalent Efficiency Units
egen avg_wage_premium       = mean(wage_premium_KM)
replace eff_KM_LS           = eff_KM_LS/avg_wage_premium

*-------------------------------------------------------------------------------
*STEP 5: Compute the Demand Shifts

*Generate Share of Efficiency Units of Each Group by Year (E_k in KM's Notation)
bys Year: egen total_eff_KM_HS   = total(eff_KM_HS)
bys Year: egen total_eff_KM_LS   = total(eff_KM_LS) 
gen share_eff_KM_HS              = total_eff_KM_HS/(total_eff_KM_HS+total_eff_KM_LS)

*Generate Share of Efficiency Units of Each Sector by Year (E_j in KM's Notation)
gen eff_KM                    = eff_KM_HS + eff_KM_LS
bys Year: egen total_eff_KM   = total(eff_KM)
gen share_eff_KM_sector       = eff_KM/total_eff_KM

*Generate the Share of the HS Group in the Efficiency Units of Each Sector (alpha_j_HS in KM's notation)
gen alpha_j_HS_KM  = eff_KM_HS/(eff_KM_HS + eff_KM_LS)

*Compute Average Share of Efficiency Units of Each Group Over the Sample Period
egen avg_share_eff_KM_HS = mean(share_eff_KM_HS)

*-------------------------------------------------------------------------------
*Compute Average Share of Efficiency Units of the High Skill Group in Each Sector Over the Sample Period

bys Industry: egen avg_alpha_j_HS_KM = mean(alpha_j_HS_KM)

keep Year Industry share_eff_KM_HS share_eff_KM_sector avg_share_eff_KM_HS avg_alpha_j_HS_KM
reshape wide share_eff_KM_HS share_eff_KM_sector avg_share_eff_KM_HS avg_alpha_j_HS_KM, i(Year) j(Industry) 

rename avg_share_eff_KM_HS1 avg_share_eff_KM_HS
drop   avg_share_eff_KM_HS2

rename avg_share_eff_KM_HS10 temp
drop   avg_share_eff_KM_HS*
rename temp avg_share_eff_KM_HS_labor
*-------------------------------------------------------------------------------
*Compute the Demand Shifts
forvalues i = 1/31 {
gen share_eff_KM_sector`i'_initial = share_eff_KM_sector`i'  if Year == $Initial_Year
gen share_eff_KM_sector`i'_final   = share_eff_KM_sector`i'  if Year == $Final_Year
}

forvalues i = 1/31 {
replace share_eff_KM_sector`i'_initial = share_eff_KM_sector`i'_initial[_n-1] if share_eff_KM_sector`i'_initial == .  
}

gsort - Year

forvalues i = 1/31 {
replace share_eff_KM_sector`i'_final = share_eff_KM_sector`i'_final[_n-1] if share_eff_KM_sector`i'_final == .  
}

gsort + Year

forvalues i = 1/31 {
gen Delta_E_sector`i'_KM = share_eff_KM_sector`i'_final - share_eff_KM_sector`i'_initial
}

gen Delta_Xd_HS_KM = 0 
gen Delta_Xd_LS_KM = 0 
forvalues i = 1/31 {
replace Delta_Xd_HS_KM = Delta_Xd_HS_KM + avg_alpha_j_HS_KM`i'*(Delta_E_sector`i'_KM/avg_share_eff_KM_HS_labor)
replace Delta_Xd_LS_KM = Delta_Xd_LS_KM + (1-avg_alpha_j_HS_KM`i')*(Delta_E_sector`i'_KM/(1-avg_share_eff_KM_HS_labor))
}

*-------------------------------------------------------------------------------
*This is the Between Industry Demand Shift

gen Delta_Xd_KM     = Delta_Xd_HS_KM - Delta_Xd_LS_KM
gen log_Delta_Xd_KM = log(1+Delta_Xd_KM)
 
disp log_Delta_Xd_KM
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Merge With the Skill-Premium and Relative Supply of Skill Data

/* Note:
We use the whole series here (1977-2005) rather than the short one (1979-1989) to be consistent across periods.
If we used 1979-1989 the demand shift contribution would be 10.3 instead of 9.7. The relative supply of skills and wage premium differ
if we use a shorter period due to the way efficiency units are computed */

merge 1:1 Year using dta_files/eff_and_premium_KM_1977_2005.dta
drop _merge

*keep if Year == $Initial_Year | Year == $Final_Year

gen log_eff_KM_HS_LS = log(eff_KM_HS_LS)
gen log_premium      = log(wage_premium_KM)

gen  log_premium_temp_$Initial_Year  = log_premium if Year == $Initial_Year
egen log_premium_$Initial_Year =  max(log_premium_temp_$Initial_Year)

gen  log_eff_KM_HS_LS_temp_$Initial_Year  =  log_eff_KM_HS_LS if Year == $Initial_Year
egen log_eff_KM_HS_LS_$Initial_Year =  max(log_eff_KM_HS_LS_temp_$Initial_Year)

keep if Year == $Final_Year

rename log_premium log_premium_$Final_Year  
rename log_eff_KM_HS_LS log_eff_KM_HS_LS_$Final_Year

gen total_dem_shift = (1.41*(log_premium_$Final_Year - log_premium_$Initial_Year )+(log_eff_KM_HS_LS_$Final_Year -log_eff_KM_HS_LS_$Initial_Year))

gen between_ind_contribution = log_Delta_Xd_KM/total_dem_shift

keep Year log_Delta_Xd_KM  total_dem_shift between_ind_contribution log_premium_$Final_Year log_premium_$Initial_Year log_eff_KM_HS_LS_$Final_Year log_eff_KM_HS_LS_$Initial_Year

disp between_ind_contribution
