*-------------------------------------------------------------------------------
*This .do Creates the Count Data in Katz & Murhpy (1992) 
*Using US Census Data from IPUMS USA as Main Data Source.

*Data                             : IPUMS USA
*Age/Experience                   : Age
*-------------------------------------------------------------------------------

cls 
clear all
set more off
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Shift_Share_KM_Methodology/IPUMS/

*use /home/nacho/Dropbox/usa_90_00_10.dta
use  usa_80_90_5pct_sample.dta

*-------------------------------------------------------------------------------
*Keep all individuals who worked at least one week in the preceding year
keep if wkswork1 >= 1

*-------------------------------------------------------------------------------
*Generate Broad Groups for Education, Age, Experience

*KM work with 4 education groups, based on years of schooling
* less than 12, 12, 13-15, 16 and more
gen educ_group2 = .
drop if educ == 00
replace educ_group2 = 1 if educ <= 05
replace educ_group2 = 2 if educ == 06
replace educ_group2 = 3 if educ  > 06 & educ <= 09
replace educ_group2 = 4 if educ == 10  

*-------------------------------------------------------------------------------
*Here we perform the adjustment in Jaeger (1997)

preserve
keep if year == 1990
gen educ_group = educ_group2
keep if educ_group2 == 3
set seed 12345
generate rannum = uniform()
sort rannum
*Now I assign the bottom (it could be the top) 21.83% of individuals with some college to HS
replace educ_group = 2 if rannum <= 0.2183
save Age/IPUMS_SomeCollege_bridged.dta, replace
drop rannum
restore

preserve
keep if year == 1990
gen educ_group = educ_group2
keep if educ_group2 == 2
set seed 12346
generate rannum = uniform()
sort rannum
*Now I assign the bottom (it could be the top) 4.19% of individuals HS to Some College
replace educ_group = 3 if rannum <= 0.0419
save Age/IPUMS_HS_bridged.dta, replace
drop rannum
restore

drop if educ_group2 == 2 & year == 1990 | educ_group2 == 3 & year == 1990

append using Age/IPUMS_HS_bridged.dta
append using Age/IPUMS_SomeCollege_bridged.dta

replace educ_group = educ_group2 if educ_group == .
drop rannum educ_group2

*-------------------------------------------------------------------------------
* Create Age groups
gen age_group = .
replace age_group = 1 if age == 14 | age == 15
replace age_group = 2 if age == 16 | age == 17
replace age_group = 3 if age >= 18 & age <= 24
replace age_group = 4 if age >= 25 & age <= 34
replace age_group = 5 if age >= 35 & age <= 44
replace age_group = 6 if age >= 45 & age <= 54
replace age_group = 7 if age >= 55 & age <= 64
replace age_group = 8 if age >= 65 
*-------------------------------------------------------------------------------
*Total Hours: product of weeks worked, weekly hours, and sample weights
gen hours = wkswork1*hrswork1*perwt

collapse (sum) hours, by(year sex age_group educ_group)
egen id = concat(year sex educ_group age_group), punct("_")

save Age/KM_count_data.dta, replace

*-------------------------------------------------------------------------------------------------------------------------------------------------------------
