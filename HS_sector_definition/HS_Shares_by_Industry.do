*-------------------------------------------------------------------------------
*This .do File Computes the Share of High-Skill Labor Compensation, Employment,
*and Hours Worked by Industry

*Data                             : USA WorldKLEMS Labor Input File Version 2013
*This  Version                    : December 12 2020
*-------------------------------------------------------------------------------
*Quick Reminder of the Definition of the Variables
*COMP:  Labour compensation per hour worked (U.S. dollars per hour)
*EMP:   Total persons engaged
*H_EMP: Average hours worked per week
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Clean Up and Set the working directory
cls
clear all
macro drop _all
set more off
cd C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\HS_sector_definition

*Start a Log File
log using HS_Shares_by_Industry, replace

*Define the Period of Study and Other Global Variables 
global Initial_Year 1977
global Final_Year   2005
global age_groups "Age1 Age2 Age3 Age4 Age5 Age6 Age7 Age8"
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*The Data in the WorldKLEMS Excel File comes in three different sheets (COMP,EMP,H_EMP). 
*Here we pull the data from each sheet and combine them together in the same dataset 

*COMP: Labour compensation per hour worked (U.S. dollars per hour)
import excel Auxiliary_Files/usa_wk_apr_2013_labour.xlsx,  sheet("COMP") firstrow

**Drop from the sample the years including for bridging purposes (they cause problems when merging the data sometimes)
drop if Year == 19922 | Year == 20022 | Year == 20032

foreach age of global age_groups {
	rename `age' wage_`age'
}

egen     id = concat(Year Industry Class Sex Education)
order    id, first
destring id, replace

save Auxiliary_Files/WK_2013_COMP.dta, replace

*EMP: Total persons engaged
cls
clear all
import excel Auxiliary_Files/usa_wk_apr_2013_labour.xlsx, sheet("EMP") firstrow
**Drop from the sample the years including for bridging purposes (they cause problems when merging the data sometimes)
drop if Year == 19922 | Year == 20022 | Year == 20032

foreach age of global age_groups {
	rename `age' emp_`age'
}

egen     id = concat(Year Industry Class Sex Education)
order    id, first
destring id, replace

save Auxiliary_Files/WK_2013_EMP.dta, replace

*H_EMP: Average number of hours worked per week
cls
clear all
import excel Auxiliary_Files/usa_wk_apr_2013_labour.xlsx, sheet("H_EMP") firstrow

**Drop from the sample the years including for bridging purposes (they cause problems when merging the data sometimes)
drop if Year == 19922 | Year == 20022 | Year == 20032

foreach age of global age_groups {
	rename `age' h_emp_`age'
}

egen     id = concat(Year Industry Class Sex Education)
order    id, first
destring id, replace

save Auxiliary_Files/WK_2013_H_EMP.dta, replace

merge m:m id using Auxiliary_Files/WK_2013_COMP.dta
drop _merge
merge m:m id using Auxiliary_Files/WK_2013_EMP.dta
drop _merge
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*All the variables are in the same dataset now. Here we perform some basic calculations.

*Keep Employees Only (Discard Self-Employed Workers)
** The ranking is not affected if all workers are used, at least for the top six industries.  
keep if Class == 1

*Generate Weekly Compensation and Weekly Hours Worked at the Cell Level
foreach age of global age_groups {
	gen comp_`age'       = ( wage_`age' )*( h_emp_`age')*( emp_`age' )
	gen tot_hours_`age'  = ( h_emp_`age')*( emp_`age' )
}

drop h_emp_* wage_* 

*Aggregate Hours, Employment, and Compensation Across Age Groups

gen tot_comp  = comp_Age1 + comp_Age2 + comp_Age3 + comp_Age4 + comp_Age5 + comp_Age6 + comp_Age7 + comp_Age8

gen tot_hours = tot_hours_Age1 + tot_hours_Age2 + tot_hours_Age3 + tot_hours_Age4 + tot_hours_Age5 + tot_hours_Age6 + tot_hours_Age7 + tot_hours_Age8

gen tot_emp   = emp_Age1 + emp_Age2 + emp_Age3 + emp_Age4 + emp_Age5 + emp_Age6 + emp_Age7 + emp_Age8
*-------------------------------------------------------------------------------			 

*-------------------------------------------------------------------------------
*Define the Sets of HS and LS Workers

*High-Skill Labor (College Complete and Above)
gen     skill_group = 1 if Education   >= 5

*Low-Skill Labor (Less than College Complete)
replace skill_group = 2 if skill_group == .

label define labor_skill_labels 1 "HS" 2 "LS"
label values skill_group labor_skill_labels
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------			 
*Compute the Shares of High-Skill Labor in Compensation, Hours, and Employment at the Industry Level for the Period of 1977-2005
keep if Year >= $Initial_Year & Year <= $Final_Year

drop comp_* emp_* tot_hours_*
order Year Industry Sex Class Education skill_group,first
drop id

** Compute Total Compensation, Employment, and Hours by Skill Group for each Year and Industry
collapse (sum) tot_comp tot_hours tot_emp, by(Year Industry skill_group)

bys Year Industry: egen tot_comp_ind   = total(tot_comp)
bys Year Industry: egen tot_hours_ind  = total(tot_hours)
bys Year Industry: egen tot_emp_ind    = total(tot_emp)

** Compute the Share of Total Compensation, Employment, and Hours by Skill Group for each Year and Industry
gen hs_comp_share_ind  = tot_comp/tot_comp_ind
gen hs_hours_share_ind = tot_hours/tot_hours_ind
gen hs_emp_share_ind   = tot_emp/tot_emp_ind

** Keep the Shares of High-Skill Labor Only
keep if skill_group == 1
gsort + Year Industry 
gsort + Year - hs_comp_share_ind

rename tot_comp      HS_comp
rename tot_hours     HS_hours
rename tot_emp       HS_emp
rename tot_comp_ind  tot_comp_by_ind  
rename tot_hours_ind tot_hours_by_ind 
rename tot_emp_ind   tot_emp_by_ind
drop skill_group

** Create and Auxiliary .dta file with the shares of High-Skill Labor's Compensation, Hours, and Employment by Year and Industry
save Auxiliary_Files/HS_labor_shares_${Initial_Year}_${Final_Year}.dta, replace

** Add Industry Labels to the .dta file created in the line above
import excel Auxiliary_Files/usa_wk_apr_2013_labour.xlsx, sheet("Notes") cellrange(A18:C49) firstrow clear
rename Number Industry
save Auxiliary_Files/Industry_Labels.dta, replace

use Auxiliary_Files/HS_labor_shares_${Initial_Year}_${Final_Year}.dta
merge m:m Industry using "Auxiliary_Files/Industry_Labels.dta"
gsort + Year Industry 
order Year Industry ISICRev3code Description
drop _merge
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Generate Rankings of High-Skill Labor Intensity for Each Employment Measure
bys Year     : egen rank_comp       = rank(-hs_comp_share_ind)
bys Year     : egen rank_hours      = rank(-hs_hours_share_ind)
bys Year     : egen rank_emp        = rank(-hs_emp_share_ind)

*Generate Average High-Skill Labor Intensity for Each Employment Measure
bys Industry : egen avg_rank_comp   = mean(rank_comp)
bys Industry : egen avg_rank_hours  = mean(rank_hours)
bys Industry : egen avg_rank_emp    = mean(rank_emp)

*Generate Average Rankins of High-Skill Labor Intensity for Each Employment Measure
bys Industry : egen avg_share_comp  = mean(hs_comp_share_ind)
bys Industry : egen avg_share_hours = mean(hs_hours_share_ind)
bys Industry : egen avg_share_emp   = mean(hs_emp_share_ind)
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Before producing the final table with the average shares and ranks between 1977 and 2005, we produce a .dta file to ease data exploration at the annual level, 
** This file contains total compensation, employment, and hours by Industry and Year, the shares of high skill compensation, hours, and employment by Industry and Year, and the Industry ranks in terms of high-skill intensity under these three employment measures

sort Year Industry
save Auxiliary_Files/HS_labor_shares_${Initial_Year}_${Final_Year}.dta, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Here we Produce the Final Table with the Average High-Skill Labor Shares by Industry the and Average Industry Ranks in terms of High-Skill Intensity between 1977 and 2005
** The Data in Section 2.2 of the Paper and the Table in Section 2 of the Online Appendix are based on the Following Table

keep if Year == 1977
keep Industry ISICRev3code Description avg_share_comp avg_rank_comp avg_share_hours avg_rank_hours avg_share_emp avg_rank_emp
order Industry ISICRev3code Description avg_share_comp avg_rank_comp avg_share_hours avg_rank_hours avg_share_emp avg_rank_emp
sort avg_rank_comp
list

log close