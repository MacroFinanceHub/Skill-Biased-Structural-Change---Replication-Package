*-------------------------------------------------------------------------------
*This .do Computes the College/High School Skill Premium Following Katz & Murhpy (1992) 
*We US Census Data from IPUMS USA as Main Data Source.

*Data                             : IPUMS USA
*Age/Experience                   : Experience

*See Note 1 at the End of the Code for a Brief Methodology
*-------------------------------------------------------------------------------

cls 
clear all
set more off
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Shift_Share_KM_Methodology/IPUMS/

*use /home/nacho/Dropbox/usa_90_00_10.dta
use  usa_80_90_5pct_sample.dta


*-------------------------------------------------------------------------------
*Generate the wage data
do Experience/KM_wage_data

*-------------------------------------------------------------------------------
*Generate the count data
do Experience/KM_count_data

*-------------------------------------------------------------------------------
use Experience/KM_wage_data
merge 1:1 id using Experience/KM_count_data

keep if educ_group == 2 | educ_group == 4

*-------------------------------------------------------------------------------
*Rename education groups for simplicity
*1= HS Complete
replace educ_group = 1 if educ_group == 2
*2= College Complete
replace educ_group = 2 if educ_group == 4

*-------------------------------------------------------------------------------
*Express emplyment in efficiency units
gen wage_hours = wage*hours
bys year: egen annual_hours      = total(hours)
bys year: egen annual_wage_hours = total(wage_hours)

gen wage_index = annual_wage_hours/annual_hours

gen w_1 = wage/wage_index

bys sex educ_group exp_group: egen eff_weights = mean(w_1)
*gen eff_weights = w_1
replace hours = hours*eff_weights
*-------------------------------------------------------------------------------
drop id _merge wage_hours annual_hours annual_wage_hours wage_index eff_weights w_1
*drop id _merge 

egen id = concat(sex educ_group exp_group)
destring id, replace

drop educ_group exp_group sex
reshape wide hours wage , i(year) j(id) 

egen  tot_hours = rsum(hours*)

global exp_groups "1 2 3 4 5 6 7 8"

*Males
 foreach exp_group of global exp_groups {
			gen h_share_`exp_group'_M = (hours11`exp_group' + hours12`exp_group')/tot_hours
}

*Females
 foreach exp_group of global exp_groups {
			gen h_share_`exp_group'_F = (hours21`exp_group' + hours22`exp_group')/tot_hours
}

foreach group of global exp_groups {
	egen avg_h_share_`group'_M = mean(h_share_`group'_M)
}

foreach group of global exp_groups {
	egen avg_h_share_`group'_F = mean(h_share_`group'_F)
}

 foreach exp_group of global exp_groups {
			gen wage_prem_Exp`exp_group'_M = (wage12`exp_group')/(wage11`exp_group')
}

 foreach exp_group of global exp_groups {
			gen wage_prem_Exp`exp_group'_F = (wage22`exp_group')/(wage21`exp_group')
}


gen premium =             wage_prem_Exp3_M*avg_h_share_3_M + wage_prem_Exp4_M*avg_h_share_4_M + ///
			  wage_prem_Exp5_M*avg_h_share_5_M + wage_prem_Exp6_M*avg_h_share_6_M + ///
			  wage_prem_Exp7_M*avg_h_share_7_M + wage_prem_Exp8_M*avg_h_share_8_M + ///
			  wage_prem_Exp3_F*avg_h_share_3_F + wage_prem_Exp4_F*avg_h_share_4_F + ///
			  wage_prem_Exp5_F*avg_h_share_5_F + wage_prem_Exp6_F*avg_h_share_6_F + ///
			  wage_prem_Exp7_F*avg_h_share_7_F + wage_prem_Exp8_F*avg_h_share_8_F
			  
gen log_premium = log(premium)
