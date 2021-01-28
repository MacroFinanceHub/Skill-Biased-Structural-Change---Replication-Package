*-------------------------------------------------------------------------------
*This .do File Computes the Between Industry Demand Shift Following Katz & Murhpy (1992) 
*and Using US Census Data from IPUMS USA as Main Data Source.

*Methodology for Demand Shift     : Katz and Murhpy (KM)
*Data                             : IPUMS USA
*Sectoral Aggregation             : 31 Sectors
*Methodology for Efficiency Units : KM
*Age/Expirience                   : Age
*See notes at the end of the code
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*STEP 1: Upload, Clean, and Adjust the Data

*Upload the Data
cls 
clear all
set more off
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Shift_Share_KM_Methodology/IPUMS/

*use /home/nacho/Dropbox/usa_90_00_10.dta
use  usa_80_90_5pct_sample.dta

*Generate Broad Groups for Education, Age, Experience
*KM work with 4 education groups, based on years of schooling
*less than 12, 12, 13-15, 16 and more
gen educ_group2 = .
drop if educ == 00
replace educ_group2 = 1 if educ > 02 | educ <= 05
replace educ_group2 = 2 if educ == 06
replace educ_group2 = 3 if educ > 06 & educ <= 09
replace educ_group2 = 4 if educ >= 10  

*Keep all individuals who worked at least one week in the preceding year
keep if wkswork1 >= 1

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

*Bridge Industries in the Census to the 31 Industries in EUKLEMS
do bridge_ind1990_eu31

*Generate Employment Measured in Total Hours Worked
gen hours = wkswork1*hrswork1*perwt

*Generate Experience Groups
*Gen a proxy of experince as in KM
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
*STEP 2: Aggregate Data at the Cell Level and Transform it Into Equivalent Efficiency Units

*Aggregate Hours at the Cell Level
collapse (sum) hours, by(year ind_eu31 sex educ_group age_group)
egen id = concat(year sex educ_group age_group), punct("_")
destring id, replace

*Merge the KM Wage Data
merge m:m id using Age/KM_wage_data.dta
drop id _merge

*Express Employment in Efficiency Units
gen wage_hours = wage*hours
bys year: egen annual_hours      = total(hours)
bys year: egen annual_wage_hours = total(wage_hours)

gen  wage_index  = (annual_wage_hours/annual_hours)
gen  eff_weights = (wage/wage_index)
bys  sex educ_group age_group: egen avg_eff_weights = mean(eff_weights)
gen  Eff         = hours*avg_eff_weights

*-------------------------------------------------------------------------------
*STEP 3: Compute the Demand Shifts
*First Build the KM Mesures of HS and College Equivalents

gen	 hs_equiv_weights  =  0.932 if educ_group == 1
replace  hs_equiv_weights  =  1.000 if educ_group == 2
replace  hs_equiv_weights  =  0.686 if educ_group == 3
replace  hs_equiv_weights  =  0.000 if educ_group == 4

gen	coll_equiv_weights = -0.048 if educ_group == 1
replace coll_equiv_weights =  0.000 if educ_group == 2
replace coll_equiv_weights =  0.293 if educ_group == 3
replace coll_equiv_weights =  1.000 if educ_group == 4

gen hs_equiv   = Eff*hs_equiv_weights/1000000
gen coll_equiv = Eff*coll_equiv_weights/1000000

collapse (sum) hs_equiv coll_equiv, by(year ind_eu31)

*-------------------------------------------------------------------------------
*Here we Compute the Ratio of College to HS Equivalents
preserve
collapse (sum) hs_equiv coll_equiv, by(year)
gen ratio     = coll_equiv/hs_equiv
gen log_ratio = log(ratio)
restore
*-------------------------------------------------------------------------------

*alpha_j_k: average share of group k of employment in sector j over 1969-1987 (1980-1990 in this case)
gen Eff_j_t        = hs_equiv + coll_equiv
gen alpha_j_coll_t = coll_equiv/Eff_j_t
bys     ind_eu31: egen alpha_j_coll  = mean(alpha_j_coll_t)   

*Ej       : share of aggregate employment in sector j and period t
bys year                   : egen Eff_t      = sum(Eff_j_t)
gen share_Eff_j_t          = Eff_j_t/Eff_t 

*Ek       : average share of total employment of group k
bys year :egen Eff_coll_t  = sum(coll_equiv)
gen share_coll_equiv_t     = Eff_coll_t/Eff_t
egen Eff_coll              = mean(share_coll_equiv_t)

sort year ind_eu31

keep year ind_eu31 alpha_j_coll share_Eff_j_t share_coll_equiv_t Eff_coll

reshape wide alpha_j_coll share_Eff_j_t share_coll_equiv_t Eff_coll, i(ind_eu31) j(year)

rename alpha_j_coll1980 avg_alpha_j_coll 
drop   alpha_j_coll1990 

rename Eff_coll1980 avg_Eff_coll
drop   Eff_coll1990

drop share_coll_equiv_t1990 share_coll_equiv_t1980 

gen Delta_Xd_coll_j   =     avg_alpha_j_coll*(share_Eff_j_t1990-share_Eff_j_t1980)/avg_Eff_coll
gen Delta_Xd_hs_j     = (1-avg_alpha_j_coll)*(share_Eff_j_t1990-share_Eff_j_t1980)/(1-avg_Eff_coll)

*Aggregate Over Groups
collapse (sum) Delta_Xd_coll_j  Delta_Xd_hs_j
 
gen Delta_Xd = Delta_Xd_coll_j - Delta_Xd_hs_j
gen Delta  = log(1+Delta_Xd)

disp Delta
*-------------------------------------------------------------------------------

rm Age/IPUMS_SomeCollege_bridged.dta
rm Age/IPUMS_HS_bridged.dta

*-------------------------------------------------------------------------------
/*
Note 1: to obtain the actual results reported in the paper and in the Online Appendix
download Census data from IPUMS International
We do not provide the full dataset because it is too heavy (around 1.1 GB).
We provide a 5 percent sample of the data (using stata's sample 5 command)
The obtain the full version of the data, the user should select the following variables 
and samples

VARIABLES
H	YEAR	Census year
H	SAMPLE	IPUMS sample identifier
H	SERIAL	Household serial number
H	HHWT	Household weight
H	GQ	Group quarters status
P	PERNUM	Person number in sample unit
P	PERWT	Person weight
P	SEX	Sex
P	AGE	Age
P	SCHOOL	School attendance
P	EDUC (general)	Educational attainment [general version]
P	EDUCD (detailed)	Educational attainment [detailed version]
P	EMPSTAT (general)	Employment status [general version]
P	EMPSTATD (detailed)	Employment status [detailed version]
P	LABFORCE	Labor force status
P	IND	Industry
P	IND1950	Industry, 1950 basis
P	IND1990	Industry, 1990 basis
P	CLASSWKR (general)	Class of worker [general version]
P	CLASSWKRD (detailed)	Class of worker [detailed version]
P	INDNAICS	Industry, NAICS classification
P	WKSWORK1	Weeks worked last year
P	WKSWORK2	Weeks worked last year, intervalled
P	HRSWORK1	Hours worked last week
P	UHRSWORK	Usual hours worked per week
P	INCTOT	Total personal income
P	INCWAGE	Wage and salary income

SAMPLES
Sample	Density	Note
1980 5% state	5.0%	
1990 5% state	5.0%	
2000 5%	5.0%	
2007 ACS	1.0%	


Note 2: 
In the Census the question about Educational Attainment changed from highest grade 
attained instead of years of schooling in 1992
We have a problem with the educational data for 1990. 
In the Census, even though the question changed only in 1992, the use highest grade 
attained instead of years of schooling in 1990. To make 1990 and 1980 comparable
we follow the bridging procedure in Jaeger (1997)
*/
