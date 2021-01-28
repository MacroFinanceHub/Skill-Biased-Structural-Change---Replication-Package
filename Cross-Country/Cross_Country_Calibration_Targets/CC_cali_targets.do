*Buera-Kaboski-Rogerson-Vizcaino

/*
File Description: This .do file produces the the data used for cross country calibration.
Countries are selected using the criterion in Buera-Kaboski 2012: they should have an income per-capita  of at least $9,200 in  Gheary-Khamis  1990 international dollars in 1970.
Countries are Austria, Australia, Belgium, Denmark, Spain, United Kingdom, Germany, Italy, Japan, Luxembourg, The Netherlands, and the U.S.
Here, compared to the countries in figure1 and figure2, we loose France, Greece, Ireland, Luxembourg and Sweden beacuse they do not have a labor input file available.
*/

*Inputs: 
*1) an Excel spreadsheet per country from the EUKlems basic files. The source is the EUKlems database (http://www.euklems.net/), November 2009 release.
*2) an Excel spreadsheet per country from the EUKlems labor input files. The source is the EUKlems database (http://www.euklems.net/), March 2008 release.

*Output: an excel spreadsheet with the data. One country per sheet.

/*
Note:
There is no labour file for the US-NAICS EUKLEMS version. We use the US's SIC labour file.
In order to produce everything with the same .do file we rename the US-SIC labour file "usa-sic_labour_input_09I" to "usa-naics_labour_input_08I" 
*/

*-------------------------------------------------------------------------------
cls
clear all
set more off
*-------------------------------------------------------------------------------
*Set the working directory 
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Cross-Country/Cross_Country_Calibration_Targets

*Select the countries that follow the BK criterion
global EU_KLEMS_group1 "aus aut bel dnk esp fra uk ger grc irl ita jpn lux nld swe usa-naics"

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*High-Skill and Low-Skill Sectoral VA Shares
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

clear all

foreach i of global EU_KLEMS_group1 {	
					cd ..
					import excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("VA") firstrow
					keep if code == "TOT" | code == "J" | code == "M" | code == "N" | code == "71t74"
					gen 	skill_ind = 0 if code == "TOT"
					replace skill_ind = 1 if skill_ind == .
					collapse (sum) _* (last) code, by(skill_ind)
					
					reshape long _ , i(skill_ind) j(Year)
					drop code
					reshape wide _ , i(Year) j(skill_ind)
					rename _0 Tot_VA
					rename _1 HS_Ind_VA
					gen  HS_ind_VA_share = HS_Ind_VA/Tot_VA
					gen  LS_ind_VA_share = 1 - HS_ind_VA_share
					gen country_code = upper("`i'")
					keep Year country_code HS_ind_VA_share LS_ind_VA_share
					order country_code Year HS_ind_VA_share LS_ind_VA_share
					cd Cross_Country_Calibration_Targets
					export excel using CrossCountry_cal_targets_BKRV.xlsx, sheet("`i'") sheetmodify firstrow(variables)
					clear all
}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*High Skill Share of Labor Compensation
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
clear all
set more off

global EU_KLEMS_group1 "aus aut bel dnk esp     uk ger         ita jpn nld     usa-naics"
global EU_KLEMS_group2 "LAB_HS_29_M LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"                        

cd ..
				
foreach i of global EU_KLEMS_group1 {
	foreach j of global EU_KLEMS_group2 {
					
					import excel excel_files/LI_files/`i'_labour_input_08I.xls, sheet("`j'") firstrow
					gen   country_code = upper("`i'")	
					order country_code, first
					rename _* `j'_*
					save dta_files/`i'_`j'.dta, replace
					clear all				
}
}

global EU_KLEMS_group3 "LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"                        

foreach i of global EU_KLEMS_group1 {

					use    dta_files/`i'_LAB_HS_29_M.dta
					save   dta_files/`i'_labor_input.dta, replace	
									
	foreach q of global EU_KLEMS_group3 {
					clear all 
					use 	dta_files/`i'_labor_input.dta
					merge  1:1 country_code code  using dta_files/`i'_`q'.dta
					drop   _merge
					save   dta_files/`i'_labor_input.dta, replace
}
}

foreach i of global EU_KLEMS_group1 {
	foreach j of global EU_KLEMS_group2 {
						rm dta_files/`i'_`j'.dta
						}
						}

foreach i of global EU_KLEMS_group1 {
					use dta_files/`i'_labor_input.dta
					
					gen ind_type = 0 if code == "TOT"

					local LS_ind "AtB C D E F G H I 70 L O P"

					foreach j of local LS_ind { 
						replace ind_type = 1 if code == "`j'"
						}
					
					local HS_ind "J 71t74 M N"
					 	
					foreach j of local HS_ind { 
						replace ind_type = 2 if code == "`j'"
						}
					
					drop if ind_type == .
					
					label define ind_type_label 0 "Total" 1 "LS" 2 "HS"
					label values ind_type ind_type_label
					
					save   dta_files/`i'_labor_input.dta, replace
}

*-------------------------------------------------------------------------------

cls
clear all 

foreach i of global EU_KLEMS_group1 {
					import  excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("LAB") firstrow
					gen 	country_code = upper("`i'")
					rename _* LAB_*
					order   country_code, first
					
					merge 1:1 country_code code using  dta_files/`i'_labor_input.dta
					keep if _merge == 3	
					drop _merge
					order country_code desc code ind_type, first				
					save         dta_files/`i'.dta, replace
					clear all
}


*-------------------------------------------------------------------------------
cls
clear all

foreach i of global EU_KLEMS_group1 {
						use dta_files/`i'.dta

global HS_groups "LAB_HS_29_M LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F"
global LS_groups "LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"                        

forvalues l = 1970(1)2005 {
				egen HS_comp_share_`l'   = rsum(LAB_HS_*_`l')
				egen LS_comp_share_`l'_2 = rsum(LAB_LS_*_`l') 
				egen MS_comp_share_`l'   = rsum(LAB_MS_*_`l')
				gen  LS_comp_share_`l'   = LS_comp_share_`l'_2 + MS_comp_share_`l'							 
}

drop MS_comp_share_* 
drop LS_comp_share_*_2 
drop LAB_HS_* LAB_MS_* LAB_LS_* 

forvalues l = 1970(1)2005 {
				gen HS_comp_`l'   = LAB_`l'*(HS_comp_share_`l'/100)
				gen LS_comp_`l'   = LAB_`l'*(LS_comp_share_`l'/100)
							 
}

keep country_code desc code ind_type HS_comp_* LS_comp_*
drop HS_comp_share_* LS_comp_share_* 

collapse (sum) HS_comp_* LS_comp_*, by(ind_type)

forvalues l = 1970(1)2005 {
gen HS_comp_share_`l' = HS_comp_`l'/(HS_comp_`l' + LS_comp_`l') 
}

keep ind_type HS_comp_share_*
drop if ind_type == 0

reshape long HS_comp_share_ , i(ind_type) j(Year)
reshape wide HS_comp_share_ , i(Year)     j(ind_type) 

rename HS_comp_share_1 HS_comp_share_LS
rename HS_comp_share_2 HS_comp_share_HS

export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`i'") cell(E1) sheetmodify firstrow(variables)
clear all
}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Wage Premium
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

clear all
set more off

global   w_prem_groups "LAB_HS_49_M LAB_MS_49_M H_HS_49_M H_MS_49_M"

foreach i of global EU_KLEMS_group1 {
		foreach j of global w_prem_groups {

			import excel excel_files/LI_files/`i'_labour_input_08I.xls, sheet("`j'") firstrow
					
					gen   country_code = upper("`i'")	
					order country_code, first
					drop desc
					keep if code == "TOT"
					reshape long _ , i(code) j(Year)
					drop code
					rename _ `j'
					order country_code, first
					
					save dta_files/`i'_`j'.dta, replace
					clear all					
}
}



global   w_prem_groups_reduced "LAB_MS_49_M H_HS_49_M H_MS_49_M"

foreach i of global EU_KLEMS_group1 {
				      clear all
				      use dta_files/`i'_LAB_HS_49_M.dta
				   
		foreach j of global w_prem_groups_reduced {

					merge 1:1 country_code Year using dta_files/`i'_`j'.dta
					drop _merge 										
}
					gen W_HS_49_M     = (LAB_HS_49_M/H_HS_49_M)
					gen W_MS_49_M     = (LAB_MS_49_M/H_MS_49_M)
					gen Relative_Wage =  W_HS_49_M/W_MS_49_M
					
					keep country_code Year W_HS_49_M W_MS_49_M Relative_Wage
					
					
export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`i'") cell(H1) sheetmodify firstrow(variables)

}


foreach i of global EU_KLEMS_group1 {
	foreach j of global w_prem_groups {
						rm dta_files/`i'_`j'.dta
						}
						}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*PPPs
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
cls
clear all
set more off

cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Cross-Country/Cross_Country_Calibration_Targets
cd ..
import excel excel_files/benchmark_1997.xls, sheet("VA") firstrow

drop EA EU15 EU25 EAex EU15ex EU25ex
global EU_KLEMS_countries "AUS AUT BEL DNK GER ITA JAP NLD ESP UK USA"


foreach i of global EU_KLEMS_countries {
					rename `i' VA_`i'
} 

save  dta_files/benchmark_1997_VA.dta, replace
*-------------------------------------------------------------------------------
clear all
import excel excel_files/benchmark_1997.xls, sheet("PPP_VA") firstrow

drop EA EU15 EU25 EAex EU15ex EU25ex

foreach i of global EU_KLEMS_countries {
					rename `i' PPP_VA_`i'
} 

cd dta_files
merge 1:1 EUK using benchmark_1997_VA.dta
drop _merge
*-------------------------------------------------------------------------------
foreach i of global EU_KLEMS_countries {
					gen ratio_`i' = (VA_`i')/(PPP_VA_`i')
} 
*-------------------------------------------------------------------------------
gen     sector_indi = 1 if EUK == "FINBU"  | EUK == "M"     | EUK == "N"     

replace sector_indi = 2 if EUK == "ELECOM" | EUK == "GOODS" | EUK == "DISTR" | EUK == "PERS" | EUK == "L" | | EUK == "70"

drop if sector_indi == .

collapse (sum) VA_* ratio_* (last) EUKLEMSindustries EUK, by(sector_indi)

foreach i of global EU_KLEMS_countries {
					gen P_PPP_`i' =(VA_`i')/(ratio_`i')
} 

keep sector_indi P_PPP_*

label define sector_label 1 "HS" 2 "LS"

label values sector_indi sector_label
*-------------------------------------------------------------------------------
foreach i of global EU_KLEMS_countries {
					rename P_PPP_`i'  `i'
} 

*-------------------------------------------------------------------------------
cd ..
export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("PPPs") cell(B2) sheetmodify firstrow(variables)

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Chain Price Indeces
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
cls 
clear all

cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Cross-Country/Cross_Country_Calibration_Targets
cd ..
	
foreach x of global EU_KLEMS_group1 {
	import excel excel_files/basic_files_09/`x'_output_09I.xls, sheet("VA_P") firstrow

forvalues l = 1971(1)2005 {
        local  j =  `l'-1
	*display `l'
	*display `j'
        gen 	P_ratio_`l' = (_`l')/(_`j')
}

gen   country_code = upper("`x'")	
rename _* VA_P_*

save dta_files/`x'_VA_P.dta,replace

*-------------------------------------------------------------------------------

cls
clear all

import excel excel_files/basic_files_09/`x'_output_09I.xls, sheet("VA") firstrow

gen   country_code = upper("`x'")	
rename _* VA_*

merge 1:1 country_code code using dta_files/`x'_VA_P.dta
drop _merge

forval i = 1971(1)2005 {
        local    j =  `i'-1
	    display `j'
        gen chain_lag_`i'  = P_ratio_`i'*VA_`j'
		gen chain_lead_`i' = P_ratio_`i'*VA_`i'
}

			 gen   ind_type = 0 if code == "TOT"
			
		        local LS_ind "AtB C D E F G H I 70 L O P"
		       *local LS_ind "AtB C 15t16 17t19 20 21t22 23    25 26 27t28 29       34t35 36t37 E F G H I      O P"

			foreach j of local LS_ind { 
				replace ind_type = 1 if code == "`j'"
						}

		        local HS_ind "J M N 71t74"
		       *local HS_ind "J M N 71t74 L 70 24 30t33"
						
			foreach j of local HS_ind { 
				replace ind_type = 2 if code == "`j'"
						}
					
			drop if ind_type == .

collapse (sum) VA_* chain_lag_* chain_lead_*, by(ind_type)

forval   i = 1971(1)2005 {
local    j =  `i'-1
gen P_chain_`i' = sqrt((chain_lag_`i'/VA_`j')*(chain_lead_`i'/VA_`i'))
}

keep ind_type P_chain_*

gen 	P_chain_1970 = 1
order   ind_type P_chain_1970, first

gen accum_P_chain_1970 = 100

forval   i = 1971/2005 {
local    j =  `i'-1
gen accum_P_chain_`i'= (P_chain_`i')*(accum_P_chain_`j')
}

keep 	ind_type  accum_P_chain_*
rename  accum_P_chain_* P_chain_*

reshape long P_chain_ ,i(ind_type) j(Year)
reshape wide P_chain_ ,i(Year)     j(ind_type)

rename P_chain_0 P_chain_Total
rename P_chain_1 P_chain_LS
rename P_chain_2 P_chain_HS

drop P_chain_Total
gen  P_chain_relative    = (P_chain_HS/P_chain_LS)*100

export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`x'") cell(M1) sheetmodify firstrow(variables)

gen     P_chain_base_prelim  =  P_chain_relative if Year == 1995
egen    P_chain_base         =  max(P_chain_base_prelim)
replace P_chain_relative     = (P_chain_relative/P_chain_base)*100

keep   Year P_chain_relative 
gen    country_code = upper("`x'")
order  country_code Year, first

save dta_files/`x'_VA_P_for_merge.dta,replace
save /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Figures1&2/dta_files/`x'_VA_P_for_merge.dta,replace

clear all
}
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

cls 
clear all

import excel excel_files/basic_files_09/jpn_output_09I.xls, sheet("VA_P") firstrow

forvalues l = 1974(1)2005 {
        local  j =  `l'-1
	*display `l'
	*display `j'
        gen 	P_ratio_`l' = (_`l')/(_`j')
}

gen   country_code = upper("jpn")	
rename _* VA_P_*

save dta_files/jpn_VA_P.dta,replace

*-------------------------------------------------------------------------------

cls
clear all

import excel excel_files/basic_files_09/jpn_output_09I.xls, sheet("VA") firstrow

gen   country_code = upper("jpn")	
rename _* VA_*

merge 1:1 country_code code using dta_files/jpn_VA_P.dta
drop _merge

forval i = 1974(1)2005 {
        local    j =  `i'-1
	    display `j'
        gen chain_lag_`i'  = P_ratio_`i'*VA_`j'
		gen chain_lead_`i' = P_ratio_`i'*VA_`i'
}

			gen   ind_type = 0 if code == "TOT"
			
		        local LS_ind "AtB C D E F G H I 70 L O P"
		       *local LS_ind "AtB C 15t16 17t19 20 21t22 23    25 26 27t28 29       34t35 36t37 E F G H I      O P"

			foreach j of local LS_ind { 
				replace ind_type = 1 if code == "`j'"
						}

		        local HS_ind "J M N 71t74"
		       *local HS_ind "J M N 71t74 L 70 24 30t33"
						
			foreach j of local HS_ind { 
				replace ind_type = 2 if code == "`j'"
						}
					
			drop if ind_type == .

collapse (sum) VA_* chain_lag_* chain_lead_*, by(ind_type)

forval   i = 1974(1)2005 {
local    j =  `i'-1
gen P_chain_`i' = sqrt((chain_lag_`i'/VA_`j')*(chain_lead_`i'/VA_`i'))
}

keep ind_type P_chain_*

gen 	P_chain_1973 = 1
order   ind_type P_chain_1973, first

gen accum_P_chain_1973 = 100

forval   i = 1974/2005 {
local    j =  `i'-1
gen accum_P_chain_`i'= (P_chain_`i')*(accum_P_chain_`j')
}

keep 	ind_type  accum_P_chain_*
rename  accum_P_chain_* P_chain_*

reshape long P_chain_ ,i(ind_type) j(Year)
reshape wide P_chain_ ,i(Year)     j(ind_type)

rename P_chain_0 P_chain_Total
rename P_chain_1 P_chain_LS
rename P_chain_2 P_chain_HS

expand 4 in 1

sort Year
replace Year = 1970 in 1
replace Year = 1971 in 2
replace Year = 1972 in 3

drop P_chain_Total
gen  P_chain_relative    = (P_chain_HS/P_chain_LS)*100

export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("jpn") cell(M1) sheetmodify firstrow(variables)

gen     P_chain_base_prelim  =  P_chain_relative if Year == 1995
egen    P_chain_base         =  max(P_chain_base_prelim)
replace P_chain_relative     = (P_chain_relative/P_chain_base)*100

keep   Year P_chain_relative 
gen    country_code = upper("jpn")
order  country_code Year, first

save dta_files/jpn_VA_P_for_merge.dta,replace
save /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Figures1&2/dta_files/jpn_VA_P_for_merge.dta,replace

*-------------------------------------------------------------------------------
cls 
clear all

import excel excel_files/basic_files_09/usa-naics_output_09I.xls, sheet("VA_P") firstrow

forvalues l = 1974(1)2005 {
        local  j =  `l'-1
	*display `l'
	*display `j'
        gen 	P_ratio_`l' = (_`l')/(_`j')
}

gen   country_code = upper("usa-naics")	
rename _* VA_P_*

save dta_files/usa-naics_VA_P.dta,replace

*-------------------------------------------------------------------------------
cls
clear all

import excel excel_files/basic_files_09/usa-naics_output_09I.xls, sheet("VA") firstrow

gen   country_code = upper("usa-naics")	
rename _* VA_*

merge 1:1 country_code code using dta_files/usa-naics_VA_P.dta
drop _merge

forval i = 1978(1)2005 {
        local    j =  `i'-1
	    display `j'
        gen chain_lag_`i'  = P_ratio_`i'*VA_`j'
		gen chain_lead_`i' = P_ratio_`i'*VA_`i'
}

			gen   ind_type = 0 if code == "TOT"
			
		        local LS_ind "AtB C D E F G H I 70 L O P"
		       *local LS_ind "AtB C 15t16 17t19 20 21t22 23    25 26 27t28 29       34t35 36t37 E F G H I      O P"

			foreach j of local LS_ind { 
				replace ind_type = 1 if code == "`j'"
						}

		        local HS_ind "J M N 71t74"
		       *local HS_ind "J M N 71t74 L 70 24 30t33"
						
			foreach j of local HS_ind { 
				replace ind_type = 2 if code == "`j'"
						}
					
			drop if ind_type == .

collapse (sum) VA_* chain_lag_* chain_lead_*, by(ind_type)

forval   i = 1978(1)2005 {
local    j =  `i'-1
gen P_chain_`i' = sqrt((chain_lag_`i'/VA_`j')*(chain_lead_`i'/VA_`i'))
}

keep ind_type P_chain_*

gen 	P_chain_1977 = 1
order   ind_type P_chain_1977, first

gen accum_P_chain_1977 = 100

forval   i = 1978/2005 {
local    j =  `i'-1
gen accum_P_chain_`i'= (P_chain_`i')*(accum_P_chain_`j')
}

keep 	ind_type  accum_P_chain_*
rename  accum_P_chain_* P_chain_*

reshape long P_chain_ ,i(ind_type) j(Year)
reshape wide P_chain_ ,i(Year)     j(ind_type)

rename P_chain_0 P_chain_Total
rename P_chain_1 P_chain_LS
rename P_chain_2 P_chain_HS

expand 8 in 1

sort Year
replace Year = 1970 in 1
replace Year = 1971 in 2
replace Year = 1972 in 3
replace Year = 1973 in 4
replace Year = 1974 in 5
replace Year = 1975 in 6
replace Year = 1976 in 7

drop P_chain_Total
gen  P_chain_relative    = (P_chain_HS/P_chain_LS)*100

export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("usa-naics") cell(M1) sheetmodify firstrow(variables)

gen     P_chain_base_prelim  =  P_chain_relative if Year == 1995
egen    P_chain_base         =  max(P_chain_base_prelim)
replace P_chain_relative     = (P_chain_relative/P_chain_base)*100

keep   Year P_chain_relative 
gen    country_code = upper("usa-naics")
order  country_code Year, first

save dta_files/usa-naics_VA_P_for_merge.dta,replace
save /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Figures1&2/dta_files/usa-naics_VA_P_for_merge.dta,replace

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Sectoral Compensation Shares
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
cls
clear all
set more off

foreach i of global EU_KLEMS_group1 {
					import excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("LAB") firstrow
					keep if code == "TOT" | code == "J" | code == "M" | code == "N" | code == "71t74"
					gen 	skill_ind = 0 if code == "TOT"
					replace skill_ind = 1 if skill_ind == .
					collapse (sum) _* (last) code, by(skill_ind)
					
					reshape long _ , i(skill_ind) j(Year)
					drop code
					reshape wide _ , i(Year) j(skill_ind)
					
					rename _0 Tot_Comp
					rename _1 HS_Ind_Comp
					gen  HS_ind_Comp_share = HS_Ind_Comp/Tot_Comp
					gen  LS_ind_Comp_share = 1 - HS_ind_Comp_share
					gen country_code = upper("`i'")
					keep Year country_code HS_ind_Comp_share LS_ind_Comp_share
					order country_code Year HS_ind_Comp_share LS_ind_Comp_share
					export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`i'") cell(Q1) sheetmodify firstrow(variables)
					clear all
}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*GDP per-capita
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
clear all
cls
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Cross-Country/Cross_Country_Calibration_Targets
cd ..

global EUKLEMS_PWT_group "AUS AUT BEL DNK ESP UK GER ITA JPN NLD USA"

foreach i of global EUKLEMS_PWT_group {
					use dta_files/pwt90.dta
					keep if year > 1969
					keep year countrycode country rgdpna pop
					replace countrycode = "UK"  	   if countrycode == "GBR"
					replace countrycode = "GER" 	   if countrycode == "DEU"
					replace countrycode = "USA-NAICS"  if countrycode == "USA"
					gen gdp_pc = rgdpna/pop
					drop pop rgdpna country
					
					keep if countrycode == "`i'"
					replace countrycode = lower(countrycode)
					export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`i'") cell(U1) sheetmodify firstrow(variables)
					clear all
}
