*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following the Shift-Share
*Methodology in Katz & Murhpy (1992) and using EUKLEMS data. 

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : EUKLEMS -> usa-sic_labour_input_08I.xls & usa-naics_output_09I.xls
*Sectoral Aggregation             : Two Sectors
*Methodology for Efficiency Units : BKRV and KM, respectively 
*Age/Expirience                   : Age

*See notes in the bottom for clarification on methodology for the wage premium,
*and variable differences between EUKLEMS and WorldKLEMS
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Data Structure

*Two Variables     : Share in *Total Hours Worked*, Share in *Total Labor Compensation*
 
*Three Skill Groups: HS, MS, LS
*Two Sex Groups    : M , F
*Three Age Groups  : 15-29,30-49,50-

*Years             : 1970-2005
*-------------------------------------------------------------------------------

cls
clear all
macro drop _all
set more off

*Choose the Working Directory
cd  /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Shift_Share_KM_Methodology/EUKLEMS

*Choose the time period

global Initial_Year 1977
global Final_Year   2005

*-------------------------------------------------------------------------------
*STEP 1: Pull the data, merge, and clean files, and compute basic variables
*Import the Data

**Labor Input Data by Skill, Sex, Age
global vars         "H LAB"
global skill_groups "HS MS LS"
global age_groups   "29 49 50PLUS"
global sex_groups   "M F"

foreach v of global vars         {
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
				
				import  excel excel_files/usa-naics_labour_input_08I.xls, sheet(`v'_`s'_`a'_`g') firstrow
				rename  _* share_`v'_`s'_`a'_`g'_*
				save    dta_files/share_`v'_`s'_`a'_`g'.dta, replace
				clear all				
}
}
}
} 

use dta_files/share_H_HS_29_M.dta
foreach v of global vars         {
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
				
				
				merge m:m code  using dta_files/share_`v'_`s'_`a'_`g'.dta
				drop _merge				
}
}
}
} 

save    dta_files/euklems_USA_labor_input.dta, replace

foreach v of global vars         {
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
				
				
				erase dta_files/share_`v'_`s'_`a'_`g'.dta							
}
}
}
} 

order  desc code *_1970, first

*-------------------------------------------------------------------------------
**Labor Compensation, Total Hours Worked, and Total Value Added by Industry

*Create an auxiliary file with BKRV and KM value added shares
clear all
import  excel excel_files/usa-naics_output_09I.xls, sheet("VA") firstrow
rename _* VA_*
keep if code == "TOT" | code == "J" | code == "71t74" | code == "M" | code == "N"    
gen 	sector = 1 if code == "TOT"
replace sector = 2 if sector == .
collapse (sum) VA_*, by(sector)

reshape long VA_, i(sector) j(year)
reshape wide VA_, i(year) j(sector)

rename VA_1 VA_tot
rename VA_2 VA_hs_sector
gen VA_ls_sector = VA_tot - VA_hs_sector
rename year Year
merge Year using dta_files/usa-naics_VA_P_for_merge.dta
drop country_code _merge
keep if Year >= $Initial_Year & Year <= $Final_Year
gen P_chain_relative_base = P_chain_relative if Year == $Initial_Year 
replace P_chain_relative_base = P_chain_relative_base[_n-1] if P_chain_relative_base == .
gen P_HS_LS = (P_chain_relative/P_chain_relative_base)
gen pl_qh = VA_hs_sector/P_HS_LS

gen hs_sector_VA_share_fixed_p = pl_qh/(pl_qh+VA_ls_sector)
gen hs_sector_VA_share = VA_hs_sector/VA_tot
keep Year hs_sector_VA_share_fixed_p hs_sector_VA_share P_HS_LS
rename Year year
save dta_files/VA_shares.dta, replace

clear all
import  excel excel_files/usa-naics_output_09I.xls, sheet("LAB") firstrow
rename _* LAB_*
save    dta_files/LAB.dta, replace

clear all
import  excel excel_files/usa-naics_output_09I.xls, sheet("H_EMP") firstrow
rename _* H_*
save    dta_files/H.dta, replace

merge m:m code using dta_files/LAB.dta
drop _merge

merge m:m code using dta_files/euklems_USA_labor_input.dta
keep if _merge == 3
drop _merge



*REMIDER: Once the sheets are merged, we discard redundant industries 
keep if   code == "TOT"   | code == "AtB"   | code == "C"     ///
	| code == "15t16" | code == "17t19" | code == "20"    ///
	| code == "21t22" | code == "23"    | code == "24"    /// 
	| code == "25"    | code == "26"    | code == "27t28" ///  
	| code == "29"    | code == "30t33" | code == "34t35" ///
	| code == "36t37" | code == "E"     | code == "F"     ///
	| code == "G"     | code == "H"     | code == "I"    ///
	| code == "J"     | code == "70"    | code == "71t74" ///
	| code == "L"     | code == "M"     | code == "N"      ///
	| code == "O"     | code == "P"     | code == "Q"

gen     code_alt = 1 if code == "TOT"
replace code_alt = 2 if code == "AtB"    | code == "C" 
replace code_alt = 3 if code == "15t16"  | code == "17t19" | code == "20" | code == "21t22" | code == "23"    | code == "24"    ///
					 | code == "25"    | code == "26" | code == "27t28" | code == "29"    | code == "30t33" ///
					 | code == "34t35" | code == "36t37"  	
replace code_alt = 4 if code == "E"   | code == "F"     | code == "G"  | code == "H"     | code == "I"     | code == "J"
replace code_alt = 5 if code == "70"  | code == "71t74" 
replace code_alt = 6 if code == "L"   | code == "M"     | code == "N"  | code == "O"     | code == "P"     | code == "Q"

order desc code code_alt, first	
sort code_alt code

reshape long share_H_HS_29_M_ share_H_HS_49_M_ share_H_HS_50PLUS_M_ share_H_HS_29_F_ share_H_HS_49_F_ share_H_HS_50PLUS_F_ ///
	     share_H_MS_29_M_ share_H_MS_49_M_ share_H_MS_50PLUS_M_ share_H_MS_29_F_ share_H_MS_49_F_ share_H_MS_50PLUS_F_ ///
	     share_H_LS_29_M_ share_H_LS_49_M_ share_H_LS_50PLUS_M_ share_H_LS_29_F_ share_H_LS_49_F_ share_H_LS_50PLUS_F_ ///
	     H_ LAB_ ///
	     share_LAB_HS_29_M_ share_LAB_HS_49_M_ share_LAB_HS_50PLUS_M_ share_LAB_HS_29_F_ share_LAB_HS_49_F_ share_LAB_HS_50PLUS_F_ ///
	     share_LAB_MS_29_M_ share_LAB_MS_49_M_ share_LAB_MS_50PLUS_M_ share_LAB_MS_29_F_ share_LAB_MS_49_F_ share_LAB_MS_50PLUS_F_ ///
	     share_LAB_LS_29_M_ share_LAB_LS_49_M_ share_LAB_LS_50PLUS_M_ share_LAB_LS_29_F_ share_LAB_LS_49_F_ share_LAB_LS_50PLUS_F_ ///
 	     , i(code code_alt) j(year)

order year desc code code_alt H_ LAB_, first	
sort year code_alt code 

*Note: sanity checks:
* - Sum of shares of hours worked and labor compensation should add up to 1 at the industry level -> OK
* - Sum of total hours and total labor compensation by industry should add up to total hours and labor compensation in a given year -> OK
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 2: Generate the Wage Premium for both the KM and the BKRV Methodologies 

**STEP 2.1: For the KM Methodology 
*2.1.1) Compute Average Employment Share for Each Group Through Time
preserve
keep if year >= $Initial_Year & year <= $Final_Year
keep if code == "TOT"
collapse (last) code (mean) ///
share_H_HS_29_M share_H_HS_49_M share_H_HS_50PLUS_M share_H_HS_29_F share_H_HS_49_F share_H_HS_50PLUS_F ///
share_H_MS_29_M share_H_MS_49_M share_H_MS_50PLUS_M share_H_MS_29_F share_H_MS_49_F share_H_MS_50PLUS_F ///
share_H_LS_29_M share_H_LS_49_M share_H_LS_50PLUS_M share_H_LS_29_F share_H_LS_49_F share_H_LS_50PLUS_F ///

rename share_H_* avg_share_*
save dta_files/avg_emp_share_${Initial_Year}_${Final_Year}.dta, replace
restore


*Generate Total Hours Worked and Total Labor Compensation by Industry and Skill Group
*(data comes as shares)
foreach v of global vars {
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
gen `v'_`s'_`a'_`g' = ((share_`v'_`s'_`a'_`g'_)/100)*(`v'_)
drop share_`v'_`s'_`a'_`g'
}
}
}
}

*Generate Wages by Skill Group
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
gen     w_`s'_`a'_`g'     = (LAB_`s'_`a'_`g')/(H_`s'_`a'_`g') if code == "TOT"
replace w_`s'_`a'_`g'     = w_`s'_`a'_`g'[_n-1] if w_`s'_`a'_`g' == .  
}
}
}

preserve
keep if year >= $Initial_Year & year <= $Final_Year
keep if code == "TOT"
keep code year w_*
gen w_HS = w_HS_49_M
gen w_LS = w_MS_49_M
save dta_files/wages_groups_${Initial_Year}_${Final_Year}.dta, replace

merge m:m code using dta_files/avg_emp_share_${Initial_Year}_${Final_Year}.dta
drop _merge

*2.1.2) Compute the Wage Index by Year in KM
gen wage_index = 0
foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
replace wage_index = wage_index + (w_`s'_`a'_`g')*((avg_share_`s'_`a'_`g')/100) 
}
}
}

*This chart is a sanity check: check that the index is indeed a weighted average -> ok!
/*
twoway (connected w_HS_29_M year) (connected w_HS_29_F year) ///
(connected w_MS_29_M year) (connected w_MS_29_F year) (connected w_LS_29_M year) (connected w_LS_29_F year) ///
(connected w_HS_49_M year) (connected w_HS_49_F year) (connected w_MS_49_M year) (connected w_MS_49_F year) ///
(connected w_LS_49_M year) (connected w_LS_49_F year) (connected w_HS_50PLUS_M year) (connected w_HS_50PLUS_F year) ///
(connected w_MS_50PLUS_M year) (connected w_MS_50PLUS_F year) (connected w_LS_50PLUS_M year) (connected w_LS_50PLUS_F year) ///
(connected wage_index year)

*Check that the shares add up to 100 -> ok!
egen check2 = rsum(avg_share_*)
*/

*2.1.3) Compute the Wage Premium in KM
gen w_HS_KM           = 0
gen sum_HS_weights_KM = 0

foreach a of global age_groups   {
foreach g of global sex_groups   {
replace w_HS_KM           = w_HS_KM + (w_HS_`a'_`g')*((avg_share_HS_`a'_`g')/100) 
replace sum_HS_weights_KM = sum_HS_weights_KM + ((avg_share_HS_`a'_`g')/100)
}
}
replace w_HS_KM = w_HS_KM/sum_HS_weights_KM

gen w_LS_KM           = 0
gen sum_LS_weights_KM = 0

foreach a of global age_groups   {
foreach g of global sex_groups   {
replace w_LS_KM            =  w_LS_KM + (w_MS_`a'_`g')*((avg_share_MS_`a'_`g')/100) + (w_LS_`a'_`g')*((avg_share_LS_`a'_`g')/100) 
replace sum_LS_weights_KM  =  sum_LS_weights_KM + ((avg_share_MS_`a'_`g')/100) + ((avg_share_LS_`a'_`g')/100)
}
}
replace   w_LS_KM     =  w_LS_KM/sum_LS_weights_KM
gen       w_prem_KM   =  w_HS_KM/w_LS_KM
gen       w_prem_BKRV =  w_HS/w_LS

*twoway (connected w_prem year) (connected w_prem_KM year)

save dta_files/wage_premiums.dta, replace

*2.1.4) Generate the relative wages in KM

foreach a of global age_groups   {
foreach g of global sex_groups   {
gen rel_w_HS_`a'_`g'  =   w_HS_`a'_`g'/w_HS_KM
gen rel_w_LS_`a'_`g'  =  (w_LS_`a'_`g'/w_LS_KM )
gen rel_w_MS_`a'_`g'  =  (w_MS_`a'_`g'/w_LS_KM )
}
}

collapse (last) code (mean) rel_w_* w_HS_KM w_LS_KM w_prem_KM 
save dta_files/fixed_weights_KM_${Initial_Year}_${Final_Year}.dta, replace
restore 
 *-------------------------------------------------------------------------------
**STEP 2.1: Forthe BKRV Methodology

*2.2.1) Choose the Base Group and Generate Wage per Efficiency Unit of Labor for the High Skill and the Low Skill Group and the Wage Premium

**Base for HS Group: 49, Males, HS
**Base for LS Group: 49, Males, MS
gen w_HS    = w_HS_49_M
gen w_LS    = w_MS_49_M
gen w_prem  = w_HS/w_LS

*2.2.2) Build Equivalent Efficiency Hours of Labor for the High and Low Skill Groups
foreach a of global age_groups   {
foreach g of global sex_groups   {
gen eff_BKRV_HS_`a'_`g' = (LAB_HS_`a'_`g')/(w_HS)
}
}

foreach a of global age_groups   {
foreach g of global sex_groups   {
gen eff_BKRV_MS_`a'_`g' = (LAB_MS_`a'_`g')/(w_LS)
gen eff_BKRV_LS_`a'_`g' = (LAB_LS_`a'_`g')/(w_LS)
}
}

/*
preserve
keep if code == "TOT"
gen check_HS = eff_BKRV_HS_49_M - H_HS_49_M
gen check_LS = eff_BKRV_MS_49_M - H_MS_49_M
restore
*/

*2.2.3) *Aggregate Efficiency Units for the HS and LS Groups under BKRV Methodology

gen eff_BKRV_HS = 0
gen eff_BKRV_LS = 0

foreach a of global age_groups   {
foreach g of global sex_groups   {
replace eff_BKRV_HS = eff_BKRV_HS + eff_BKRV_HS_`a'_`g'
replace eff_BKRV_LS = eff_BKRV_LS + eff_BKRV_MS_`a'_`g' + eff_BKRV_LS_`a'_`g'
}
}
*-------------------------------------------------------------------------------
 
*-------------------------------------------------------------------------------
*STEP 3: Express Quantities into Equivalent Efficiency Units

*3.1)   For the KM Methodology
*3.1.1) Create the KM Efficiency Units
merge m:m code using dta_files/fixed_weights_KM_${Initial_Year}_${Final_Year}.dta
drop _merge
sort code_alt code 

foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
rename  rel_w_`s'_`a'_`g'  fixed_weight_`s'_`a'_`g' 
replace fixed_weight_`s'_`a'_`g' = fixed_weight_`s'_`a'_`g'[_n-1] if fixed_weight_`s'_`a'_`g' == .  
}
}
}

foreach s of global skill_groups {
foreach a of global age_groups   {
foreach g of global sex_groups   {
gen eff_KM_`s'_`a'_`g'  = (H_`s'_`a'_`g')*(fixed_weight_`s'_`a'_`g')
}
}
}

gen eff_KM_HS     = 0
gen eff_KM_LS     = 0
gen H_HS          = 0
gen H_LS          = 0
gen LAB_HS        = 0
gen LAB_LS        = 0


foreach a of global age_groups   {
foreach g of global sex_groups   {
replace eff_KM_HS  = eff_KM_HS + eff_KM_HS_`a'_`g'
replace eff_KM_LS  = eff_KM_LS + eff_KM_LS_`a'_`g' + eff_KM_MS_`a'_`g'
replace H_HS       = H_HS + H_HS_`a'_`g'
replace H_LS       = H_LS + H_LS_`a'_`g' + H_MS_`a'_`g'
replace LAB_HS     = LAB_HS + LAB_HS_`a'_`g'
replace LAB_LS     = LAB_LS + LAB_LS_`a'_`g' + LAB_MS_`a'_`g'
}
}
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 4: Group Industries into a HS and a LS Sector

keep if year >= $Initial_Year & year <= $Final_Year

drop if code == "TOT"
gen     sector = .

*hs sector = 2
replace sector = 2 if code == "M" | code == "N"  | code == "71t74" | code == "J"
*replace sector = 2 if code == "M" | code == "N"  | code == "71t74" | code == "J" | code == "24" | code == "70"

*ls sector = 1
replace sector = 1 if sector == .

sort year sector code_alt code 
order year desc code code_alt sector
collapse (sum) H_HS H_LS LAB_HS LAB_LS eff_KM_HS eff_KM_LS eff_BKRV_HS eff_BKRV_LS (last) code code_alt w_HS w_LS w_prem w_HS_* w_MS_* w_LS_* , by(year sector)

drop code_alt
order year code sector, first
label define lab_sector 1 "LS_Sector" 2 "HS_Sector"
label value sector lab_sector

order w_HS w_LS w_HS_KM w_LS_KM, last
*-------------------------------------------------------------------------------
*Download the data here if you want to compute Demand Shifts in Excel
*At this point, efficiency units are expressed into equivalent HS and LS hours. 

preserve
keep year sector eff_KM_HS eff_KM_LS eff_BKRV_HS eff_BKRV_LS
collapse (sum) eff_KM_HS eff_KM_LS eff_BKRV_HS eff_BKRV_LS, by(year)
gen eff_KM_HS_LS       = eff_KM_HS/eff_KM_LS
gen log_eff_KM_HS_LS   = log(eff_KM_HS_LS)
gen eff_BKRV_HS_LS     = eff_BKRV_HS/eff_BKRV_LS
gen log_eff_BKRV_HS_LS = log(eff_BKRV_HS_LS)
save dta_files/eff_KM_BKRV_${Initial_Year}_${Final_Year}.dta, replace
restore
*-------------------------------------------------------------------------------
*STEP 5: Transform everything into Equivalent HS Efficiency Units and Compute the Demand Shifts

drop if sector == 0
keep if year >= $Initial_Year & year <= $Final_Year

keep year sector H_* eff_* 
merge m:m year using Auxiliary_Files/wage_premiums.dta
keep year sector H_* eff_* w_prem_BKRV w_prem_KM

egen avg_w_prem_KM  = mean(w_prem_KM)

replace eff_KM_LS   = eff_KM_LS/avg_w_prem_KM
replace eff_BKRV_LS = eff_BKRV_LS/w_prem_BKRV

*-------------------------------------------------------------------------------
*Generate Share of Efficiency Units of Each Group by Year (E_k in KM's Notation)
bys year: egen total_eff_BKRV_HS = total(eff_BKRV_HS)
bys year: egen total_eff_BKRV_LS = total(eff_BKRV_LS) 
gen share_eff_BKRV_HS = total_eff_BKRV_HS/(total_eff_BKRV_HS+total_eff_BKRV_LS)

bys year: egen total_eff_KM_HS = total(eff_KM_HS)
bys year: egen total_eff_KM_LS = total(eff_KM_LS) 
gen share_eff_KM_HS = total_eff_KM_HS/(total_eff_KM_HS+total_eff_KM_LS)

*-------------------------------------------------------------------------------
*Generate Share of Efficiency Units of Each Sector by Year (E_j in KM's Notation)
gen eff_BKRV                  =  eff_BKRV_HS + eff_BKRV_LS
bys year: egen total_eff_BKRV = total(eff_BKRV)
gen share_eff_BKRV_sector     = eff_BKRV/total_eff_BKRV

gen eff_KM                    =  eff_KM_HS + eff_KM_LS
bys year: egen total_eff_KM   = total(eff_KM)
gen share_eff_KM_sector       = eff_KM/total_eff_KM

*-------------------------------------------------------------------------------
*Generate the Share of the HS Group in the Efficiency Units of Each Sector (alpha_j_HS in KM's notation)
gen alpha_j_HS_BKRV = eff_BKRV_HS/(eff_BKRV_HS + eff_BKRV_LS)
gen alpha_j_HS_KM   = eff_KM_HS/(eff_KM_HS + eff_KM_LS)

*-------------------------------------------------------------------------------
*Compute Average Share of Efficiency Units of Each Group Over the Sample Period
egen avg_share_eff_BKRV_HS = mean(share_eff_BKRV_HS)
egen avg_share_eff_KM_HS   = mean(share_eff_KM_HS)

*-------------------------------------------------------------------------------
*Compute Average Share of Efficiency Units of the High Skill Group in Each Sector Over the Sample Period

bys sector: egen avg_alpha_j_HS_BKRV = mean(alpha_j_HS_BKRV)
bys sector: egen avg_alpha_j_HS_KM   = mean(alpha_j_HS_KM)

keep year sector avg_alpha_j_HS_BKRV avg_alpha_j_HS_KM avg_share_eff_BKRV_HS ///
	   avg_share_eff_KM_HS share_eff_BKRV_sector share_eff_KM_sector
	   
reshape wide avg_alpha_j_HS_BKRV avg_alpha_j_HS_KM avg_share_eff_BKRV_HS ///
	     avg_share_eff_KM_HS share_eff_BKRV_sector share_eff_KM_sector, i(year) j(sector) 


rename avg_share_eff_BKRV_HS1 avg_share_eff_BKRV_HS
drop   avg_share_eff_BKRV_HS2

rename avg_share_eff_KM_HS1 avg_share_eff_KM_HS
drop   avg_share_eff_KM_HS2

rename share_eff_BKRV_sector1 share_eff_BKRV_LS_sector 
rename share_eff_BKRV_sector2 share_eff_BKRV_HS_sector 
rename share_eff_KM_sector1   share_eff_KM_LS_sector 
rename share_eff_KM_sector2   share_eff_KM_HS_sector 

rename avg_alpha_j_HS_BKRV1 avg_alpha_BKRV_HS_LS_sector
rename avg_alpha_j_HS_BKRV2 avg_alpha_BKRV_HS_HS_sector
rename avg_alpha_j_HS_KM1   avg_alpha_KM_HS_LS_sector
rename avg_alpha_j_HS_KM2   avg_alpha_KM_HS_HS_sector
*-------------------------------------------------------------------------------
merge 1:1 year using dta_files/VA_shares.dta
drop _merge

*-------------------------------------------------------------------------------
*Compute the Demand Shifts
gen share_eff_BKRV_LS_sector_initial = share_eff_BKRV_LS_sector  if year == $Initial_Year
gen share_eff_BKRV_LS_sector_final   = share_eff_BKRV_LS_sector  if year == $Final_Year
gen share_eff_BKRV_HS_sector_initial = share_eff_BKRV_HS_sector  if year == $Initial_Year
gen share_eff_BKRV_HS_sector_final   = share_eff_BKRV_HS_sector  if year == $Final_Year

replace share_eff_BKRV_LS_sector_initial = share_eff_BKRV_LS_sector_initial[_n-1] if share_eff_BKRV_LS_sector_initial == .
replace share_eff_BKRV_HS_sector_initial = share_eff_BKRV_HS_sector_initial[_n-1] if share_eff_BKRV_HS_sector_initial == .

gsort - year
 
replace share_eff_BKRV_LS_sector_final   = share_eff_BKRV_LS_sector_final[_n-1] if share_eff_BKRV_LS_sector_final   == .
replace share_eff_BKRV_HS_sector_final   = share_eff_BKRV_HS_sector_final[_n-1] if share_eff_BKRV_HS_sector_final   == .

gsort + year 

gen Delta_E_HS_sector_BKRV = share_eff_BKRV_HS_sector_final - share_eff_BKRV_HS_sector_initial
gen Delta_E_LS_sector_BKRV = share_eff_BKRV_LS_sector_final - share_eff_BKRV_LS_sector_initial

gen Delta_Xd_HS_BKRV = avg_alpha_BKRV_HS_HS_sector*(Delta_E_HS_sector_BKRV/avg_share_eff_BKRV_HS) + avg_alpha_BKRV_HS_LS_sector*(Delta_E_LS_sector_BKRV/avg_share_eff_BKRV_HS)
gen Delta_Xd_LS_BKRV = (1-avg_alpha_BKRV_HS_HS_sector)*(Delta_E_HS_sector_BKRV/(1-avg_share_eff_BKRV_HS)) + (1-avg_alpha_BKRV_HS_LS_sector)*(Delta_E_LS_sector_BKRV/(1-avg_share_eff_BKRV_HS))

gen Delta_Xd_BKRV     = Delta_Xd_HS_BKRV - Delta_Xd_LS_BKRV
gen log_Delta_Xd_BKRV = log(1+Delta_Xd_BKRV)
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
gen share_eff_KM_LS_sector_initial = share_eff_KM_LS_sector  if year == $Initial_Year
gen share_eff_KM_LS_sector_final   = share_eff_KM_LS_sector  if year == $Final_Year
gen share_eff_KM_HS_sector_initial = share_eff_KM_HS_sector  if year == $Initial_Year
gen share_eff_KM_HS_sector_final   = share_eff_KM_HS_sector  if year == $Final_Year

replace share_eff_KM_LS_sector_initial = share_eff_KM_LS_sector_initial[_n-1] if share_eff_KM_LS_sector_initial == .
replace share_eff_KM_HS_sector_initial = share_eff_KM_HS_sector_initial[_n-1] if share_eff_KM_HS_sector_initial == .

gsort - year
 
replace share_eff_KM_LS_sector_final   = share_eff_KM_LS_sector_final[_n-1] if share_eff_KM_LS_sector_final   == .
replace share_eff_KM_HS_sector_final   = share_eff_KM_HS_sector_final[_n-1] if share_eff_KM_HS_sector_final   == .

gsort + year 

gen Delta_E_HS_sector_KM  = share_eff_KM_HS_sector_final - share_eff_KM_HS_sector_initial
gen Delta_E_LS_sector_KM  = share_eff_KM_LS_sector_final - share_eff_KM_LS_sector_initial

gen Delta_Xd_HS_KM = avg_alpha_KM_HS_HS_sector*(Delta_E_HS_sector_KM/avg_share_eff_KM_HS)         + avg_alpha_KM_HS_LS_sector*(Delta_E_LS_sector_KM/avg_share_eff_KM_HS)
gen Delta_Xd_LS_KM = (1-avg_alpha_KM_HS_HS_sector)*(Delta_E_HS_sector_KM/(1-avg_share_eff_KM_HS)) + (1-avg_alpha_KM_HS_LS_sector)*(Delta_E_LS_sector_KM/(1-avg_share_eff_KM_HS))

gen Delta_Xd_KM       = Delta_Xd_HS_KM - Delta_Xd_LS_KM
gen log_Delta_Xd_KM   = log(1+Delta_Xd_KM)
*-------------------------------------------------------------------------------
*Using VA as a measure of sector size
*BKRV VA
gen share_VA_BKRV_LS_sector_initial = 1-hs_sector_VA_share if year == $Initial_Year
gen share_VA_BKRV_LS_sector_final   = 1-hs_sector_VA_share if year == $Final_Year
gen share_VA_BKRV_HS_sector_initial = hs_sector_VA_share if year == $Initial_Year
gen share_VA_BKRV_HS_sector_final   = hs_sector_VA_share if year == $Final_Year

replace share_VA_BKRV_LS_sector_initial = share_VA_BKRV_LS_sector_initial[_n-1] if share_VA_BKRV_LS_sector_initial == .
replace share_VA_BKRV_HS_sector_initial = share_VA_BKRV_HS_sector_initial[_n-1] if share_VA_BKRV_HS_sector_initial == .

gsort - year
 
replace share_VA_BKRV_LS_sector_final   = share_VA_BKRV_LS_sector_final[_n-1] if share_VA_BKRV_LS_sector_final   == .
replace share_VA_BKRV_HS_sector_final   = share_VA_BKRV_HS_sector_final[_n-1] if share_VA_BKRV_HS_sector_final   == .

gsort + year 

gen Delta_VA_HS_sector_BKRV  = share_VA_BKRV_HS_sector_final - share_VA_BKRV_HS_sector_initial
gen Delta_VA_LS_sector_BKRV  = share_VA_BKRV_LS_sector_final - share_VA_BKRV_LS_sector_initial

gen Delta_Xd_HS_VA_BKRV = avg_alpha_BKRV_HS_HS_sector*(Delta_VA_HS_sector_BKRV/avg_share_eff_BKRV_HS) + avg_alpha_BKRV_HS_LS_sector*(Delta_VA_LS_sector_BKRV/avg_share_eff_BKRV_HS)
gen Delta_Xd_LS_VA_BKRV = (1-avg_alpha_BKRV_HS_HS_sector)*(Delta_VA_HS_sector_BKRV/(1-avg_share_eff_BKRV_HS)) + (1-avg_alpha_BKRV_HS_LS_sector)*(Delta_VA_LS_sector_BKRV/(1-avg_share_eff_BKRV_HS))

gen Delta_Xd_VA_BKRV    = Delta_Xd_HS_VA_BKRV - Delta_Xd_LS_VA_BKRV
gen log_Delta_Xd_VA_BKRV = log(1+Delta_Xd_VA_BKRV)

*-------------------------------------------------------------------------------
*Using VA as a measure of sector size
*KM VA
gen share_VA_KM_LS_sector_initial = 1-hs_sector_VA_share_fixed_p if year == $Initial_Year
gen share_VA_KM_LS_sector_final   = 1-hs_sector_VA_share_fixed_p if year == $Final_Year
gen share_VA_KM_HS_sector_initial = hs_sector_VA_share_fixed_p if year == $Initial_Year
gen share_VA_KM_HS_sector_final   = hs_sector_VA_share_fixed_p if year == $Final_Year

replace share_VA_KM_LS_sector_initial = share_VA_KM_LS_sector_initial[_n-1] if share_VA_KM_LS_sector_initial == .
replace share_VA_KM_HS_sector_initial = share_VA_KM_HS_sector_initial[_n-1] if share_VA_KM_HS_sector_initial == .

gsort - year
 
replace share_VA_KM_LS_sector_final   = share_VA_KM_LS_sector_final[_n-1] if share_VA_KM_LS_sector_final   == .
replace share_VA_KM_HS_sector_final   = share_VA_KM_HS_sector_final[_n-1] if share_VA_KM_HS_sector_final   == .

gsort + year 

gen Delta_VA_HS_sector_KM  = share_VA_KM_HS_sector_final - share_VA_KM_HS_sector_initial
gen Delta_VA_LS_sector_KM  = share_VA_KM_LS_sector_final - share_VA_KM_LS_sector_initial

gen Delta_Xd_HS_VA_KM = avg_alpha_KM_HS_HS_sector*(Delta_VA_HS_sector_KM/avg_share_eff_KM_HS) + avg_alpha_KM_HS_LS_sector*(Delta_VA_LS_sector_KM/avg_share_eff_KM_HS)
gen Delta_Xd_LS_VA_KM = (1-avg_alpha_KM_HS_HS_sector)*(Delta_VA_HS_sector_KM/(1-avg_share_eff_KM_HS)) + (1-avg_alpha_KM_HS_LS_sector)*(Delta_VA_LS_sector_KM/(1-avg_share_eff_KM_HS))

gen Delta_Xd_VA_KM    = Delta_Xd_HS_VA_KM - Delta_Xd_LS_VA_KM
gen log_Delta_Xd_VA_KM = log(1+Delta_Xd_VA_KM)
*-------------------------------------------------------------------------------
keep year avg_alpha_KM_HS_HS_sector avg_alpha_KM_HS_LS_sector avg_share_eff_KM_HS Delta_Xd_KM avg_alpha_BKRV_HS_HS_sector avg_alpha_BKRV_HS_LS_sector avg_share_eff_BKRV_HS Delta_Xd_BKRV log_Delta_Xd_BKRV log_Delta_Xd_KM Delta_Xd_VA_KM log_Delta_Xd_VA_KM log_Delta_Xd_VA_BKRV log_Delta_Xd_VA_KM
order log_Delta_Xd_BKRV log_Delta_Xd_KM log_Delta_Xd_VA_BKRV log_Delta_Xd_VA_KM, last

rm dta_files/euklems_USA_labor_input.dta
rm dta_files/LAB.dta
rm dta_files/H.dta
rm dta_files/fixed_weights_KM_1977_2005.dta
rm dta_files/avg_emp_share_1977_2005.dta
rm dta_files/wages_groups_1977_2005.dta
