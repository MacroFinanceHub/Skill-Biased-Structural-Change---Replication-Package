*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following Katz & Murhpy (1992) 
*and using the WordKLEMS 2013 Labour File as Main Data Source.

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : WorldKLEMS
*Sectoral Aggregation             : Two Sectors
*Methodology for Efficiency Units : BKRV 
*Age/Expirience                   : Age
*Measure of Sector Size           : Employment Measured in BKRV Efficiency Units
*Results Reported in              : Table 2, Column G, row (vi) Online Appendix for 1977-2005  
*Results Reported in              : Table 2, Column F, row (vi) Online Appendix for 1980-1990  

*-------------------------------------------------------------------------------
*See notes in the bottom for clarification on methodology for the wage premium,
*and variable differences between EUKLEMS and WorldKLEMS
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
macro drop _all
*global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
global dir /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/

cd $dir/Shift_Share_KM_Methodology/WorldKLEMS/

*Choose the period
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
save dta_files/wage_data_BKRV.dta, replace
restore

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
*STEP 3: Define the Low and High-Skill Sectors
gen   	sector  = 1 if Industry == 28 | Industry == 29 | Industry == 26 | Industry == 24 
replace sector  = 2 if sector == .

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
collapse (sum) eff_BKRV (last) w_HS w_LS w_prem, by(Year skill_group sector)

*At this Point Data can be Downloaded to Compute Demand Shifts in Excel
*We do that in the spreadhseet Dem_shift_calculations_with_data.xlsx, but also we compute them below
*Notice that until here labor quantities are expressed into equivalent HS and LS 
*efficiency units. To do the shift-share analysis they must be expressed into equivalent
*HS or LS efficiency units
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
keep if Year >= $Initial_Year & Year <= $Final_Year 

reshape wide eff_BKRV w_HS w_LS w_prem, i(Year sector) j(skill_group)
rename eff_BKRV1 eff_BKRV_HS
rename eff_BKRV2 eff_BKRV_LS
rename w_prem1   w_prem_BKRV
rename w_HS1     w_HS
rename w_LS1     w_LS
drop   w_HS2 w_LS2 w_prem2

keep Year sector eff_BKRV_HS eff_BKRV_LS w_prem_BKRV 

preserve
collapse (sum) eff_BKRV_HS eff_BKRV_LS (last) w_prem, by(Year)
gen eff_ratio_HS_LS =  eff_BKRV_HS/eff_BKRV_LS
keep Year eff_ratio_HS_LS w_prem_BKRV
save dta_files/eff_and_premium_BKRV_${Initial_Year}_${Final_Year}.dta, replace
restore

*Express Eff Unit Into HS Equivalent Efficiency Units
replace eff_BKRV_LS  = eff_BKRV_LS/w_prem_BKRV

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


*Compute Average Share of Efficiency Units of the High Skill Group in Each Sector Over the Sample Period

bys sector: egen avg_alpha_j_HS_BKRV = mean(alpha_j_HS_BKRV)

keep Year sector share_eff_BKRV_HS share_eff_BKRV_sector avg_share_eff_BKRV_HS avg_alpha_j_HS_BKRV
reshape wide  share_eff_BKRV_HS share_eff_BKRV_sector avg_share_eff_BKRV_HS avg_alpha_j_HS_BKRV, i(Year) j(sector) 

rename avg_share_eff_BKRV_HS1 avg_share_eff_BKRV_HS
drop   avg_share_eff_BKRV_HS2

rename share_eff_BKRV_sector1 share_eff_BKRV_LS_sector 
rename share_eff_BKRV_sector2 share_eff_BKRV_HS_sector 

rename avg_alpha_j_HS_BKRV1 avg_alpha_BKRV_HS_LS_sector
rename avg_alpha_j_HS_BKRV2 avg_alpha_BKRV_HS_HS_sector

* Compute the Demand Shifts
gen share_eff_BKRV_LS_sector_initial = share_eff_BKRV_LS_sector  if Year == $Initial_Year
gen share_eff_BKRV_LS_sector_final   = share_eff_BKRV_LS_sector  if Year == $Final_Year
gen share_eff_BKRV_HS_sector_initial = share_eff_BKRV_HS_sector  if Year == $Initial_Year
gen share_eff_BKRV_HS_sector_final   = share_eff_BKRV_HS_sector  if Year == $Final_Year

replace share_eff_BKRV_LS_sector_initial = share_eff_BKRV_LS_sector_initial[_n-1] if share_eff_BKRV_LS_sector_initial == .
replace share_eff_BKRV_HS_sector_initial = share_eff_BKRV_HS_sector_initial[_n-1] if share_eff_BKRV_HS_sector_initial == .

gsort - Year
 
replace share_eff_BKRV_LS_sector_final   = share_eff_BKRV_LS_sector_final[_n-1] if share_eff_BKRV_LS_sector_final   == .
replace share_eff_BKRV_HS_sector_final   = share_eff_BKRV_HS_sector_final[_n-1] if share_eff_BKRV_HS_sector_final   == .

gsort + Year 

gen Delta_E_HS_sector_BKRV = share_eff_BKRV_HS_sector_final - share_eff_BKRV_HS_sector_initial
gen Delta_E_LS_sector_BKRV = share_eff_BKRV_LS_sector_final - share_eff_BKRV_LS_sector_initial

gen Delta_Xd_HS_BKRV = avg_alpha_BKRV_HS_HS_sector*(Delta_E_HS_sector_BKRV/avg_share_eff_BKRV_HS) + avg_alpha_BKRV_HS_LS_sector*(Delta_E_LS_sector_BKRV/avg_share_eff_BKRV_HS)
gen Delta_Xd_LS_BKRV = (1-avg_alpha_BKRV_HS_HS_sector)*(Delta_E_HS_sector_BKRV/(1-avg_share_eff_BKRV_HS)) + (1-avg_alpha_BKRV_HS_LS_sector)*(Delta_E_LS_sector_BKRV/(1-avg_share_eff_BKRV_HS))


gen Delta_Xd_BKRV     = Delta_Xd_HS_BKRV - Delta_Xd_LS_BKRV
gen log_Delta_Xd_BKRV = log(1+Delta_Xd_BKRV)

display log_Delta_Xd_BKRV
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
