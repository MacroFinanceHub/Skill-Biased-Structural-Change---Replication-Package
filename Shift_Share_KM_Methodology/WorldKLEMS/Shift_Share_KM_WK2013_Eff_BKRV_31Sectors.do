*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following Katz & Murhpy (1992) 
*and using the WordKLEMS 2013 Labour File as Main Data Source.

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : WorldKLEMS
*Sectoral Aggregation             : 31 Sectors
*Methodology for Efficiency Units : BKRV
*Age/Expirience                   : Age
*Measure of Sector Size           : Employment Measured in BKRV Efficiency Units/Compensation
*Results Reported in              : Table 2, Column E, row (vi) Online Appendix for 1980-1990 
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

*Choose the time period
global Initial_Year 1980
global Final_Year   1990
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
sort  Year Industry Sex Class Education Age id

rm dta_files/WK_2013_COMP.dta
rm dta_files/WK_2013_EMP.dta
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Generate Annual Compensation by Age group

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

*Generate annual compensation by Age group

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

label define labor_skill_labels 1 "HS" 2 "LS" 
label values skill_group labor_skill_labels

order Year Industry Sex Class Education skill_group
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 2: Generate the Wage Premium in the BKRV Methodology

preserve
collapse (sum) comp_Age*  emp_Age* tot_h_Age*, by(Year Sex Class Education)
drop if Class == 2

gen     W_HS     = (comp_Age5)/(tot_h_Age5) if Education == 5 & Sex == 1 
gen     W_LS     = (comp_Age5)/(tot_h_Age5) if Education == 3 & Sex == 1 
 
by Year: egen w_HS = max(W_HS) 
by Year: egen w_LS = max(W_LS) 
drop W_HS W_LS
gen w_prem         = w_HS/w_LS

keep Year Sex Class Education w_HS w_LS w_prem 
save    dta_files/wage_data_BKRV.dta, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 3: Transform Hours Worked Into Equivalent HS and LS Efficiency Units

merge m:m Year Sex Class Education using dta_files/wage_data_BKRV.dta

sort Year Industry Sex Class Education
drop if Class == 2
drop _merge

foreach i of num 1/8 {
gen	eff_Age`i'  = (comp_Age`i'/w_HS) if Education >= 5
replace eff_Age`i'  = (comp_Age`i'/w_LS) if Education <  5
replace eff_Age`i'  = 0 if eff_Age`i' == .
}

gen eff_BKRV = eff_Age1 + eff_Age2 + eff_Age3 + eff_Age4 + eff_Age5 + eff_Age6 + eff_Age7 + eff_Age8 

*-------------------------------------------------------------------------------
*STEP 3: Aggregate HS and LS Efficiency Units at The Sectoral Level

collapse (sum) eff_BKRV (last) w_HS w_LS w_prem, by(Year skill_group Industry)
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 4: Transform Efficiency Units into Equivalent HS Efficiency Units

keep if Year >= $Initial_Year & Year <= $Final_Year 
reshape wide eff_BKRV w_HS w_LS w_prem, i(Year Industry) j(skill_group)
rename eff_BKRV1 eff_BKRV_HS
rename eff_BKRV2 eff_BKRV_LS
rename w_prem1   w_prem_BKRV
rename w_HS1     w_HS
rename w_LS1     w_LS
drop   w_HS2 w_LS2 w_prem2

keep Year Industry eff_BKRV_HS eff_BKRV_LS w_prem_BKRV 

preserve
collapse (sum) eff_BKRV_HS eff_BKRV_LS (last) w_prem, by(Year)
gen eff_ratio_HS_LS =  eff_BKRV_HS/eff_BKRV_LS
keep Year eff_ratio_HS_LS w_prem_BKRV
save dta_files/eff_and_premium_BKRV_${Initial_Year}_${Final_Year}.dta, replace
restore

*Express Eff Unit Into HS Equivalent Efficiency Units
replace eff_BKRV_LS  = eff_BKRV_LS/w_prem_BKRV
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 5: Compute the Demand Shifts

*Generate Share of Efficiency Units of Each Group by Year (E_k in KM's Notation)
bys Year: egen total_eff_BKRV_HS = total(eff_BKRV_HS)
bys Year: egen total_eff_BKRV_LS = total(eff_BKRV_LS) 
gen share_eff_BKRV_HS = total_eff_BKRV_HS/(total_eff_BKRV_HS+total_eff_BKRV_LS)

*Generate Share of Efficiency Units of Each Sector by Year (E_j in KM's Notation)
gen eff_BKRV                    = eff_BKRV_HS + eff_BKRV_LS
bys Year: egen total_eff_BKRV   = total(eff_BKRV)
gen share_eff_BKRV_sector       = eff_BKRV/total_eff_BKRV

*Generate the Share of the HS Group in the Efficiency Units of Each Sector (alpha_j_HS in KM's notation)
gen alpha_j_HS_BKRV  = eff_BKRV_HS/(eff_BKRV_HS + eff_BKRV_LS)

*Compute Average Share of Efficiency Units of Each Group Over the Sample Period
egen avg_share_eff_BKRV_HS = mean(share_eff_BKRV_HS)

*-------------------------------------------------------------------------------
*Compute Average Share of Efficiency Units of the High Skill Group in Each Sector Over the Sample Period

bys Industry: egen avg_alpha_j_HS_BKRV = mean(alpha_j_HS_BKRV)

keep Year Industry share_eff_BKRV_HS share_eff_BKRV_sector avg_share_eff_BKRV_HS avg_alpha_j_HS_BKRV
reshape wide share_eff_BKRV_HS share_eff_BKRV_sector avg_share_eff_BKRV_HS avg_alpha_j_HS_BKRV, i(Year) j(Industry) 

rename avg_share_eff_BKRV_HS1 avg_share_eff_BKRV_HS
drop   avg_share_eff_BKRV_HS2

rename avg_share_eff_BKRV_HS10 temp
drop   avg_share_eff_BKRV_HS*
rename temp avg_share_eff_BKRV_HS_labor
*-------------------------------------------------------------------------------
*Compute the Demand Shifts
forvalues i = 1/31 {
gen share_eff_BKRV_sector`i'_initial = share_eff_BKRV_sector`i'  if Year == $Initial_Year
gen share_eff_BKRV_sector`i'_final   = share_eff_BKRV_sector`i'  if Year == $Final_Year
}

forvalues i = 1/31 {
replace share_eff_BKRV_sector`i'_initial = share_eff_BKRV_sector`i'_initial[_n-1] if share_eff_BKRV_sector`i'_initial == .  
}

gsort - Year

forvalues i = 1/31 {
replace share_eff_BKRV_sector`i'_final = share_eff_BKRV_sector`i'_final[_n-1] if share_eff_BKRV_sector`i'_final == .  
}

gsort + Year

forvalues i = 1/31 {
gen Delta_E_sector`i'_BKRV = share_eff_BKRV_sector`i'_final - share_eff_BKRV_sector`i'_initial
}

gen Delta_Xd_HS_BKRV = 0 
gen Delta_Xd_LS_BKRV = 0 
forvalues i = 1/31 {
replace Delta_Xd_HS_BKRV = Delta_Xd_HS_BKRV + avg_alpha_j_HS_BKRV`i'*(Delta_E_sector`i'_BKRV/avg_share_eff_BKRV_HS_labor)
replace Delta_Xd_LS_BKRV = Delta_Xd_LS_BKRV + (1-avg_alpha_j_HS_BKRV`i')*(Delta_E_sector`i'_BKRV/(1-avg_share_eff_BKRV_HS_labor))
}


*This is the Between Industry Demand Shift
gen Delta_Xd_BKRV     = Delta_Xd_HS_BKRV - Delta_Xd_LS_BKRV
gen log_Delta_Xd_BKRV = log(1+Delta_Xd_BKRV)

disp log_Delta_Xd_BKRV

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Merge the Between Industry Demand Shift with the Relative Supply of Skills and the Skill Premium
* Compute the Total Demand Shift and the Between Industry Demand Shift Contribution

merge 1:1 Year using dta_files/eff_and_premium_BKRV_${Initial_Year}_${Final_Year}.dta
drop _merge

gen log_eff_BKRV_HS_LS = log(eff_ratio_HS_LS)
gen log_premium        = log(w_prem_BKRV)

gen  log_premium_temp_$Initial_Year  = log_premium if Year == $Initial_Year
egen log_premium_$Initial_Year       =  max(log_premium_temp_$Initial_Year)

gen  log_eff_BKRV_HS_LS_temp_$Initial_Year  =  log_eff_BKRV_HS_LS if Year == $Initial_Year
egen log_eff_BKRV_HS_LS_$Initial_Year       =  max(log_eff_BKRV_HS_LS_temp_$Initial_Year)

keep if Year == $Final_Year

rename log_premium log_premium_$Final_Year  
rename log_eff_BKRV_HS_LS log_eff_BKRV_HS_LS_$Final_Year

gen total_dem_shift = (1.41*(log_premium_$Final_Year - log_premium_$Initial_Year )+(log_eff_BKRV_HS_LS_$Final_Year -log_eff_BKRV_HS_LS_$Initial_Year))

gen between_ind_contribution = log_Delta_Xd_BKRV/total_dem_shift

keep Year log_Delta_Xd_BKRV  total_dem_shift between_ind_contribution log_premium_$Final_Year log_premium_$Initial_Year log_eff_BKRV_HS_LS_$Final_Year log_eff_BKRV_HS_LS_$Initial_Year

display log_Delta_Xd_BKRV
disp between_ind_contribution

* Clean Up
rm dta_files/eff_and_premium_BKRV_${Initial_Year}_${Final_Year}.dta
rm dta_files/wage_data_BKRV.dta

*-------------------------------------------------------------------------------


