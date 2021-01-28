*-------------------------------------------------------------------------------
*This .do Computes the College/High School Skill Premium Following Katz & Murhpy (1992) 
*We US Census Data from IPUMS USA as Main Data Source.

*Data                             : IPUMS USA
*Age/Experience                   : Age

*See Note 1 at the End of the Code for a Brief Methodology
*-------------------------------------------------------------------------------

cls 
clear all
set more off

cd  /home/nacho/Dropbox/BKR/Nacho/Shift_Share_KM_Methodology/IPUMS/

*use /home/nacho/Dropbox/usa_90_00_10.dta
use  usa_80_90_5pct_sample.dta

*-------------------------------------------------------------------------------
*Generate the wage data
do Age/KM_wage_data

*-------------------------------------------------------------------------------
*Generate the count data
do Age/KM_count_data

*-------------------------------------------------------------------------------
use   Age/KM_wage_data
merge 1:1 id using Age/KM_count_data

keep if educ_group == 2 | educ_group == 4

*-------------------------------------------------------------------------------
*Rename education groups for simplicity
*1= HS Complete
replace educ_group = 1 if educ_group == 2
*2= College Complete
replace educ_group = 2 if educ_group == 4

*-------------------------------------------------------------------------------
*Express employment in efficiency units
gen wage_hours = wage*hours
bys year: egen annual_hours      = total(hours)
bys year: egen annual_wage_hours = total(wage_hours)

gen wage_index = annual_wage_hours/annual_hours

gen w_1 = wage/wage_index

bys sex educ_group age_group: egen eff_weights = mean(w_1)

replace hours = hours*eff_weights
*-------------------------------------------------------------------------------
drop id _merge wage_hours annual_hours annual_wage_hours wage_index eff_weights w_1

egen id = concat(sex educ_group age_group)
destring id, replace

drop educ_group age_group sex
reshape wide hours wage , i(year) j(id) 

egen  tot_hours = rsum(hours*)

global age_groups "3 4 5 6 7 8"

*Males
 foreach age_group of global age_groups {
			gen h_share_`age_group'_M = (hours11`age_group' + hours12`age_group')/tot_hours
}

*Females
 foreach age_group of global age_groups {
			gen h_share_`age_group'_F = (hours21`age_group' + hours22`age_group')/tot_hours
}

foreach group of global age_groups {
	egen avg_h_share_`group'_M = mean(h_share_`group'_M)
}

foreach group of global age_groups {
	egen avg_h_share_`group'_F = mean(h_share_`group'_F)
}

 foreach age_group of global age_groups {
			gen wage_prem_Age`age_group'_M = (wage12`age_group')/(wage11`age_group')
}

 foreach age_group of global age_groups {
			gen wage_prem_Age`age_group'_F = (wage22`age_group')/(wage21`age_group')
}


gen premium =             wage_prem_Age3_M*avg_h_share_3_M + wage_prem_Age4_M*avg_h_share_4_M + ///
			  wage_prem_Age5_M*avg_h_share_5_M + wage_prem_Age6_M*avg_h_share_6_M + ///
			  wage_prem_Age7_M*avg_h_share_7_M + wage_prem_Age8_M*avg_h_share_8_M + ///        
			  wage_prem_Age3_F*avg_h_share_3_F + wage_prem_Age4_F*avg_h_share_4_F + ///
			  wage_prem_Age5_F*avg_h_share_5_F + wage_prem_Age6_F*avg_h_share_6_F + ///
			  wage_prem_Age7_F*avg_h_share_7_F + wage_prem_Age8_F*avg_h_share_8_F

		  
gen log_premium = log(premium)
*-------------------------------------------------------------------------------
/*
Note 1:
The Methodology Applied Here Follows Footnote 20 in KM 1992
It reads:

20. In this section we measure the college/high school wage ratio as the fixed-weight 
average of the ratio of the average weekly wage of college graduates to the average 
weekly wage of high school graduates for sixteen cells defined by sex and five-year 
experience brackets (they have 8 five-year experience brackets). 
The fixed weight for each cell is the cell's average share of 
total employment over the 1963-1987 period. This series is plotted in Panel B of Figure I 
as the college/high school wage ratio for all experience levels.
*/
