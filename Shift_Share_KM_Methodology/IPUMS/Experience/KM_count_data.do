*-------------------------------------------------------------------------------
*This .do Reproduces the Count Data in Katz & Murhpy (1992) 
*Using US Census Data from IPUMS USA as Main Data Source.

*Data                             : IPUMS USA
*Age/Experience                   : Experience
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
*replace educ_group2 = 1 if educ  > 02 | educ <= 05
replace educ_group2 = 1 if educ <= 05
replace educ_group2 = 2 if educ == 06
replace educ_group2 = 3 if educ  > 06 & educ <= 09
replace educ_group2 = 4 if educ == 10  

*-------------------------------------------------------------------------------
*We have a problem with the educational data fro 1990
*In the Census, even though the question changed only in 1992, the use highest grade 
*attained instead of years of schooling in 1990. To make 1990 and 1980 comparable we use
*the procdeure in Jaeger (1997)

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
save Experience/IPUMS_SomeCollege_bridged.dta, replace
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
save Experience/IPUMS_HS_bridged.dta, replace
drop rannum
restore

drop if educ_group2 == 2 & year == 1990 | educ_group2 == 3 & year == 1990

append using Experience/IPUMS_HS_bridged.dta
append using Experience/IPUMS_SomeCollege_bridged.dta

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
*Generate Experience Groups

*Gen a proxy if experince as in KM
*2. Potential experience is calculated as min(age - years of schooling - 7, age - 17) 
*where age is the age at the survey date.

gen 	school_yrs = 0 if educ == 00
replace school_yrs = 4 if educ == 01
replace school_yrs = 8 if educ == 02
replace school_yrs = 9 if educ == 03
replace school_yrs =10 if educ == 04
replace school_yrs =11 if educ == 05
replace school_yrs =12 if educ == 06
replace school_yrs =13 if educ == 07
replace school_yrs =14 if educ == 08
replace school_yrs =15 if educ == 09
replace school_yrs =16 if educ == 10
replace school_yrs =18 if educ == 11

gen exp1 = age-school_yrs-7
gen exp2 = age-17

gen experience = min(exp1,exp2)

*-------------------------------------------------------------------------------
*Clean the data
drop exp1 exp2
drop if experience <= 0 | experience > 40

*-------------------------------------------------------------------------------
*Generate experience groups
gen     exp_group = 1 if experience >= 1  & experience <= 5
replace exp_group = 2 if experience >= 6  & experience <= 10
replace exp_group = 3 if experience >= 11 & experience <= 15
replace exp_group = 4 if experience >= 16 & experience <= 20
replace exp_group = 5 if experience >= 21 & experience <= 25
replace exp_group = 6 if experience >= 26 & experience <= 30
replace exp_group = 7 if experience >= 31 & experience <= 35
replace exp_group = 8 if experience >= 36 & experience <= 40

do bridge_ind1990_eu31

gen     skill_group = "HS Labor" if educ_group >= 4
replace skill_group = "LS Labor" if educ_group <  4

gen     sector = "HS Sector" if ind_eu31 == 28 | ind_eu31 == 29 | ind_eu31 == 26 | ind_eu31 == 24
replace sector = "LS Sector" if sector != "HS Sector"
*-------------------------------------------------------------------------------
*Total Hours: product of weeks worked, weekly hours, and sample weights
gen hours   = wkswork1*hrswork1*perwt
gen comp    = incwage*perwt

collapse (sum) hours comp, by(year skill_group sector)
replace comp  = comp/1000000
replace hours = hours/1000000

egen id = concat(year sex educ_group exp_group), punct("_")

save Experience/KM_count_data.dta, replace

*-------------------------------------------------------------------------------------------------------------------------------------------------------------
