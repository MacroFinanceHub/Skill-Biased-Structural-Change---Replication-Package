*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following Katz & Murhpy (1992) 
*and using the WordKLEMS 2013 Labour File as Main Data Source.

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : WorldKLEMS
*Sectoral Aggregation             : Two Sectors
*Methodology for Efficiency Units : KM 
*Age/Expirience                   : Age
*Measure of Sector Size           : Employment Measured in KM Efficiency Units
*Results Reported in              : Table 7 row (i) & Table 2, Column H, row (vi) Online Appendix for 1977-2005 
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

* Start a Log File
log using Table7_row_i, replace

*Choose the time period
global Initial_Year 1977
global Final_Year   2005
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
* High Skill (College Complete or More)
gen     skill_group = 1 if Education   >= 5

* Low Skill
replace skill_group = 2 if Education   < 5

label define labor_skill_labels 1 "HS_Labor" 2 "LS_Labor" 
label values skill_group labor_skill_labels

order Year Industry Sex Class Education skill_group
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 2: Generate the Fixed Employment Weights Used in KM's Methodology
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
save   dta_files/fixed_weights_${Initial_Year}_${Final_Year}.dta, replace
restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Build the Wage Premium Following KM's Methodology
* See Note 2 in the bottom of the code

preserve
keep if Year >= $Initial_Year & Year <= $Final_Year 
drop if Class == 2
drop Class

collapse (sum) comp_* tot_h*, by(Year Sex Education)

foreach i of num 3/8 {
gen	            w_Age`i'        = (comp_Age`i'/tot_h_Age`i') 
by Year Sex: gen  w_HS_Age`i'       = w_Age`i' if Education == 5
by Year Sex: gen  w_LS_Age`i'       = w_Age`i' if Education == 3
by Year Sex: egen w_HS_Age`i'_prime = max(w_HS_Age`i')
by Year Sex: egen w_LS_Age`i'_prime = max(w_LS_Age`i')
}

foreach i of num 3/8 {
drop w_HS_Age`i' 
rename w_HS_Age`i'_prime w_HS_Age`i'
}

sort Year Sex Education
foreach i of num 3/8 {
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
* Generate the Wage Index Used in the KM Methodology to Compute Efficiency Units
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

*-------------------------------------------------------------------------------
*STEP 3: Define the Low and High-Skill Sectors
gen   	sector = 1 if Industry == 28 | Industry == 29 | Industry == 26 | Industry == 24 
replace sector = 2 if sector == .
 
*Including Real Estate
*gen   	sector  = 1 if Industry == 28 | Industry == 29 | Industry == 26 | Industry == 24 | Industry == 25
*replace sector = 2 if sector == .

*Including Real Estate and Chemicals
*gen   	sector  = 1 if Industry == 28 | Industry == 29 | Industry == 26 | Industry == 24 | Industry == 25 | Industry == 8	
*replace sector = 2 if sector == .

*Including Real Estate, Chemicals, Electrical and Optical Equipment, and Public Administration
*gen   	sector  = 1 if Industry == 28 | Industry == 29 | Industry == 26 | Industry == 24 | Industry == 25 | Industry == 8 | Industry == 13 | Industry == 27
*replace sector = 2 if sector == .
	
label define sector_skill_labels 1 "HS Sector" 2 "LS Sector"
label values sector sector_skill_labels	
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 4: Put the Data Together

collapse (sum) eff_KM, by(Year sector skill_group)
replace eff_KM = eff_KM/1000000 

merge m:m Year using dta_files/wage_premium_KM_${Initial_Year}_${Final_Year}.dta
drop cum_fixed_weights _merge

rename w_prem wage_premium_KM

*At this Point Data can be Downloaded to Compute Demand Shifts in Excel
*We do that in the spreadhseet Dem_shift_calculations_with_data.xlsx, but also we compute them below
*Notice that until here labor quantities are expressed into equivalent HS and LS 
*efficiency units. To do the shift-share analysis they must be expressed into equivalent
*HS or LS efficiency units
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
keep if Year >= $Initial_Year & Year <= $Final_Year 
keep Year skill_group sector eff_KM wage_premium_KM
reshape wide eff_KM wage_premium_KM, i(Year sector) j(skill_group)
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
egen avg_wage_premium  = mean(wage_premium_KM)
replace eff_KM_LS      = eff_KM_LS/avg_wage_premium

*-------------------------------------------------------------------------------
*STEP 5: Compute the Demand Shifts

*Generate Share of Efficiency Units of Each Group by Year (E_k in KM's Notation)
bys Year: egen total_eff_KM_HS = total(eff_KM_HS)
bys Year: egen total_eff_KM_LS = total(eff_KM_LS) 
gen share_eff_KM_HS = total_eff_KM_HS/(total_eff_KM_HS+total_eff_KM_LS)

*Generate Sector Size. Here Sectors are Measured by Total Employment by Sector in KM Efficiency Units (E_j in KM's Notation) 
gen eff_KM                    = eff_KM_HS + eff_KM_LS
bys Year: egen total_eff_KM   = total(eff_KM)
gen share_eff_KM_sector       = eff_KM/total_eff_KM

*Generate the Share of the HS Group in the Efficiency Units of Each Sector (alpha_j_HS in KM's notation; we have labeled this as theta_jk)
gen alpha_j_HS_KM  = eff_KM_HS/(eff_KM_HS + eff_KM_LS)

*Compute Average Share of Efficiency Units of Each Group Over the Sample Period (average E_k in KM's Notation)
egen avg_share_eff_KM_HS = mean(share_eff_KM_HS)

*-------------------------------------------------------------------------------
*Compute Average Share of Efficiency Units of the High-Skill Group in Each Sector Over the Sample Period (avg_alpha_j_HS_KM in KM's notation)

bys sector: egen avg_alpha_j_HS_KM = mean(alpha_j_HS_KM)

keep Year sector share_eff_KM_HS share_eff_KM_sector avg_share_eff_KM_HS avg_alpha_j_HS_KM
reshape wide  share_eff_KM_HS share_eff_KM_sector avg_share_eff_KM_HS avg_alpha_j_HS_KM, i(Year) j(sector) 

rename avg_share_eff_KM_HS1 avg_share_eff_KM_HS
drop   avg_share_eff_KM_HS2

rename share_eff_KM_sector1 share_eff_KM_HS_sector 
rename share_eff_KM_sector2 share_eff_KM_LS_sector 

rename avg_alpha_j_HS_KM1 avg_alpha_KM_HS_HS_sector
rename avg_alpha_j_HS_KM2 avg_alpha_KM_HS_LS_sector

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Compute the Demand Shifts

gen share_eff_KM_LS_sector_initial = share_eff_KM_LS_sector  if Year == $Initial_Year
gen share_eff_KM_LS_sector_final   = share_eff_KM_LS_sector  if Year == $Final_Year
gen share_eff_KM_HS_sector_initial = share_eff_KM_HS_sector  if Year == $Initial_Year
gen share_eff_KM_HS_sector_final   = share_eff_KM_HS_sector  if Year == $Final_Year

replace share_eff_KM_LS_sector_initial = share_eff_KM_LS_sector_initial[_n-1] if share_eff_KM_LS_sector_initial == .
replace share_eff_KM_HS_sector_initial = share_eff_KM_HS_sector_initial[_n-1] if share_eff_KM_HS_sector_initial == .

gsort - Year
 
replace share_eff_KM_LS_sector_final   = share_eff_KM_LS_sector_final[_n-1] if share_eff_KM_LS_sector_final   == .
replace share_eff_KM_HS_sector_final   = share_eff_KM_HS_sector_final[_n-1] if share_eff_KM_HS_sector_final   == .

gsort + Year 

gen Delta_E_HS_sector_KM = share_eff_KM_HS_sector_final - share_eff_KM_HS_sector_initial
gen Delta_E_LS_sector_KM = share_eff_KM_LS_sector_final - share_eff_KM_LS_sector_initial

gen Delta_Xd_HS_KM = avg_alpha_KM_HS_HS_sector*(Delta_E_HS_sector_KM/avg_share_eff_KM_HS) + avg_alpha_KM_HS_LS_sector*(Delta_E_LS_sector_KM/avg_share_eff_KM_HS)
gen Delta_Xd_LS_KM = (1-avg_alpha_KM_HS_HS_sector)*(Delta_E_HS_sector_KM/(1-avg_share_eff_KM_HS)) + (1-avg_alpha_KM_HS_LS_sector)*(Delta_E_LS_sector_KM/(1-avg_share_eff_KM_HS))
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Comput the Relative Between-Idustry Demand Shift
gen Delta_Xd_KM     = Delta_Xd_HS_KM - Delta_Xd_LS_KM
gen log_Delta_Xd_KM = log(1+Delta_Xd_KM)

disp log_Delta_Xd_KM

* Merge With the Skill-Premium and Relative Supply of Skill Data
merge 1:1 Year using dta_files/eff_and_premium_KM_${Initial_Year}_${Final_Year}.dta
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

log close

*-------------------------------------------------------------------------------
/*
Note 1: 

Because of changes in the methodologies used to measure industries and 
educational attainment there are "jumps" in the WorldKLEMS data and it needs to 
be bridged. The explanation in the WorldKLEMS labor file is as follows:

"The CPS changed over to using NAICS beginning with the 2003 Surveys. 
We found that applying the CES bridge that we constructed for 2-3 digit 
codes to the 2002 SIC based matrices resulted in implausible jumps in 
the employment series. In order to create a better link between the 
2002 SIC based CPS to the 2003 CPS, we first re-read the 2002 CPS March 
Supplement to construct a more accurate NAICS version. For each worker 
in the 2002 Survey we link his/her industry to NAICS industries using the 
CES SIC-NAICS ratios. That is, a share of this particular type of worker 
is allocated to one NAICS industry and another share to another NAICS 
industry, and so on, as defined by the bridge. The information of this 
worker for hours, weeks and compensation are then used to construct 
the corresponding marginal matrices for the detailed set of NAICS codes. 
This detailed list of industries is then aggregated to 12 industry groups 
for the EMP_EI_NAICS(6 educ, 12 indus, 2002) marginal matrix. 
We needed to reduce the EI matrix to 12 industry groups since the 
original 20 groups turned out to be too refined.

In summary, to create a consistent link between the years we have
the following:

year=2002 is SIC data converted to NAICS using the CES ratios,
    this is to be used with year=2001
year=20022 is CPS SIC data read in as NAICS, specially RASed at 12 
     industries and used to calculate labor quality,
     to be used with 20032
year=2003 is CPS NAICS data
     to be used with 2004,2005,...
year=20032 is CPS NAICS data, specially RASed at 12 industries 
     to be used to calculate the change between 20022 and 20032."


Note 2:
Here we follow the methodology of footnote 20 in KM 1992
20. In this section we measure the college/high school wage ratio as the fixed-weight 
average of the ratio of the average weekly wage of college graduates to the average 
weekly wage of high school graduates for sixteen cells defined by sex and five-year 
experience brackets (they have 8 five-year experience brackets). 
The fixed weight for each cell is the cell's average share of 
total employment over the 1963-1987 period. This series is plotted in Panel B of Figure I 
as the college/high school wage ratio for all experience levels.

Note 3: The description of the main variables we use in the WorldKLEMS are:

COMP : total compensation per hour worked (in current U.S. dollars)
EMP  : total number of persons engaged
H_EMP: Average number of hours worked per week

As a reminder, hours in the EUKlems represents the share of hours worked by an age 
and skill group in an industry and a year

Note4: In the EUKLEMS skill groups are defined as:

HS: 	 College complete or more
MS: 	 High School complete and some college
LS: 	 Less tha High School Complete

Note5: In the EUKLEMS the age groups are defined as:

29 or less,
30 to 49,
50 or more,

while in World KLEMS the Age groups are defined as
*Age1 = 14,15 | Age2 = 16,17 | Age3 = 18,24 | Age4 = 25-34 | Age5 = 35-44 | Age6 = 45-54
*Age7 = 55-64 | Age8 = 65-99 
*-------------------------------------------------------------------------------



