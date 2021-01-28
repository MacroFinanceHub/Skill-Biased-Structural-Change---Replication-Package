*-------------------------------------------------------------------------------
/*
This .do file produces the the data used for cross country calibration.
Countries are selected using the criterion in Buera-Kaboski 2012: they should have an income per-capita  of at least $9,200 
in  Gheary-Khamis  1990 international dollars in 1970.
Countries are Austria, Australia, Belgium, Denmark, Spain, United Kingdom, Germany, Italy, Japan, Luxembourg, The Netherlands, and the U.S.
Compared to the countries in figure1 and figure2, we loose France, Greece, Ireland, Luxembourg and Sweden beacuse they do not have a labor input file available.

Inputs: 
1) an Excel spreadsheet per country from the EUKlems basic files. The source is the EUKlems database (http://www.euklems.net/), November 2009 release.
2) an Excel spreadsheet per country from the EUKlems labor input files. The source is the EUKlems database (http://www.euklems.net/), March 2008 release.

*Output: one .dta and one .csv file per country with the data (e.g. dta_files/aus.dta & csv_files/aus.csv)

Output:

We produce 8 (eight) series for the US:
1. The share of the HS Sector in Total VA
2. The Share of HS Labor in the Labor Compensation of the HS Sector
2. The Share of HS Labor in the Labor Compensation of the LS Sector  
4. The chained relative price index of the HS Sector relative to the LS Sector
5. GDP per-capita
6. The Skill Premium (w_HS/w_LS)
7. The Share of HS Sector's Labor Compensation in Total Labor Compensation

Note:
There is no labour file for the US-NAICS EUKLEMS version. We use the US's SIC labour file.
In order to produce everything with the same .do file we rename the US-SIC labour file "usa-sic_labour_input_09I" to "usa-naics_labour_input_08I" 
*/
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
set more off
macro drop _all

*global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
global dir /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/

cd $dir/Cross-Country/Cross_Country_Calibration_Targets/

* Start a Log File
*log using cross_country_calibration_data, replace

*Select the countries that follow the BK criterion and have Labor Input Files
*global EU_KLEMS_BK           "aus aut bel dnk esp fra uk ger grc irl ita jpn lux nld swe usa-naics"
global EU_KLEMS_countries    "aus aut bel dnk esp     uk ger         ita jpn     nld     usa-naics"
global EU_KLEMS_lab_groups   "LAB_HS_29_M LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"

global EU_KLEMS_lab_groups2  "            LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"

global EU_KLEMS_lab_HS 	     "LAB_HS_29_M LAB_HS_29_F LAB_HS_49_M LAB_HS_49_F LAB_HS_50PLUS_M LAB_HS_50PLUS_F"
global EU_KLEMS_lab_LS 	     "LAB_MS_29_M LAB_MS_29_F LAB_MS_49_M LAB_MS_49_F LAB_MS_50PLUS_M LAB_MS_50PLUS_F LAB_LS_29_M LAB_LS_29_F LAB_LS_49_M LAB_LS_49_F LAB_LS_50PLUS_M LAB_LS_50PLUS_F"

global PPP_countries         "AUS AUT BEL DNK GER ITA JAP NLD ESP UK USA"
global PWT_countries         "AUS AUT BEL DNK DEU ITA JPN NLD ESP GBR USA"
global LS_ind                "AtB C D E F G H I 70 L O P"
*global LS_ind               "AtB C 15t16 17t19 20 21t22 23    25 26 27t28 29       34t35 36t37 E F G H I      O P"
global HS_ind                "J 71t74 M N"         
*global HS_ind               "J M N 71t74 L 70 24 30t33"      
*-------------------------------------------------------------------------------
		     
*--------------------------------------------------------------------------------------------------------------------------
*1. High-Skill Sector Value Added Share

clear all
cd ..
foreach i of global EU_KLEMS_countries {	
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
					save dta_files/`i'.dta, replace
					clear all
}
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*2 and 3. High-Skill Labor Share of Compensation in the High- and Low-Skill Sectors

*The data in the EU KLEMS comes in shares. We first combine the data on shares together in the same file.
cls
clear all		
	foreach i of global EU_KLEMS_countries  {
	foreach j of global EU_KLEMS_lab_groups {
					
					import excel excel_files/LI_files/`i'_labour_input_08I.xls, sheet("`j'") firstrow
					gen   country_code = upper("`i'")	
					order country_code, first
					rename _* `j'_*
					save dta_files/`i'_`j'.dta, replace
					clear all				
}
}


foreach i of global EU_KLEMS_countries   {

					  use    dta_files/`i'_LAB_HS_29_M.dta
					  save   dta_files/`i'_labor_input.dta, replace	
									
foreach q of global EU_KLEMS_lab_groups2 {
					  clear  all 
					  use 	 dta_files/`i'_labor_input.dta
					  merge  1:1 country_code code  using dta_files/`i'_`q'.dta
					  drop   _merge
					  save   dta_files/`i'_labor_input.dta, replace
}
}

foreach i of global EU_KLEMS_countries {
	foreach j of global EU_KLEMS_lab_groups {
						rm dta_files/`i'_`j'.dta
						}
						}

foreach i of global EU_KLEMS_countries {
					 use dta_files/`i'_labor_input.dta
					
					 gen ind_type = 0 if code == "TOT"
					 
					 foreach j of global LS_ind { 
						replace ind_type = 1 if code == "`j'"
						}
					 	
					 foreach j of global HS_ind { 
						replace ind_type = 2 if code == "`j'"
						}
					
					 drop if ind_type == .
					
  					 label define ind_type_label 0 "Total" 1 "LS" 2 "HS"
					 label values ind_type ind_type_label
					
					 save   dta_files/`i'_labor_input.dta, replace
}

*-------------------------------------------------------------------------------
* And now we merge the data on labor compensation shares with the data on total compensation

cls
clear all 

foreach i of global EU_KLEMS_countries {
					import  excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("LAB") firstrow
					gen 	country_code = upper("`i'")
					rename _* LAB_*
					order   country_code, first
					
					merge 1:1 country_code code using  dta_files/`i'_labor_input.dta
					keep if _merge == 3	
					drop _merge
					order country_code desc code ind_type, first				
					save         dta_files/`i'_LAB.dta, replace
					clear all
}


cls
clear all

foreach i of global EU_KLEMS_countries {
					 use dta_files/`i'_LAB.dta

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

merge 1:1 Year using dta_files/`i'.dta
drop _merge 
save dta_files/`i'.dta, replace
order country_code Year, first
}
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*4. Chain Price Indeces

cls 
clear all
	
foreach x of global EU_KLEMS_countries {
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
			


			foreach j of global LS_ind { 
				replace ind_type = 1 if code == "`j'"
						}


						
			foreach j of global HS_ind { 
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

forval   i = 1971/2005 {
replace  P_chain_`i'= 1  if P_chain_`i' == .
	}


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

*export excel using Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`x'") cell(M1) sheetmodify firstrow(variables)

gen     P_chain_base_prelim  =  P_chain_relative if Year == 2003
egen    P_chain_base         =  max(P_chain_base_prelim)
replace P_chain_relative     = (P_chain_relative/P_chain_base)

keep   Year P_chain_relative 
gen    country_code = upper("`x'")
order  country_code Year, first

replace P_chain_relative = . if country_code == "JPN"       & Year < 1973
replace P_chain_relative = . if country_code == "USA-NAICS" & Year < 1977


save dta_files/`x'_VA_P_for_merge.dta,replace
merge 1:1 Year using dta_files/`x'.dta
drop _merge 
order country_code Year, first
save dta_files/`x'.dta, replace
save ${dir}/Figures1&2/dta_files/`x'_VA_P_for_merge.dta,replace

clear all
}
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*5. GDP per-capita

cls
clear all

use  dta_files/pwt90.dta
keep if year > 1969
keep year countrycode country rgdpna pop
gen  gdp_pc = rgdpna/pop
drop pop rgdpna country

gen keep_indi = .
foreach country of global PWT_countries {
				    replace keep_indi = 1 if countrycode == "`country'"
				   }
keep if keep_indi == 1						   
drop keep_indi

replace countrycode = "UK"  	   if countrycode == "GBR"
replace countrycode = "GER" 	   if countrycode == "DEU"
replace countrycode = "USA-NAICS"  if countrycode == "USA"
rename year Year
rename countrycode country_code

save dta_files/GDP_pc_merge.dta, replace

cls 
clear all
foreach i of global EU_KLEMS_countries   {
					  use dta_files/GDP_pc_merge.dta
					  merge 1:1 Year country_code using dta_files/`i'.dta
					  keep if _merge == 3
                                          drop _merge 
                                          order country_code Year, first
                                          save dta_files/`i'.dta, replace
}

rm  dta_files/GDP_pc_merge.dta
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*6. Skill-Premium

cls
clear all

global   w_prem_groups "LAB_HS_49_M LAB_MS_49_M H_HS_49_M H_MS_49_M"

foreach i of global EU_KLEMS_countries {
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

foreach i of global EU_KLEMS_countries {
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
									
merge 1:1 Year using dta_files/`i'.dta
drop _merge 
save dta_files/`i'.dta, replace
order country_code Year, first

}


foreach i of global EU_KLEMS_countries {
	foreach j of global w_prem_groups {
						rm dta_files/`i'_`j'.dta
						}
						}
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*7. Share of Labor Compensation of the High-Skill and the Low-Skill Sector

cls
clear all

foreach i of global EU_KLEMS_countries {
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
					merge 1:1 Year using dta_files/`i'.dta
					drop _merge 
					order country_code Year, first
					save dta_files/`i'.dta, replace
					clear all
}
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------------
*PPPs

cls
clear all

import excel excel_files/benchmark_1997.xls, sheet("VA") firstrow
drop EA EU15 EU25 EAex EU15ex EU25ex

foreach i of global PPP_countries {
					rename `i' VA_`i'
} 

save  dta_files/benchmark_1997_VA.dta, replace

clear all
import excel excel_files/benchmark_1997.xls, sheet("PPP_VA") firstrow

drop EA EU15 EU25 EAex EU15ex EU25ex

foreach i of global PPP_countries {
					rename `i' PPP_VA_`i'
} 

merge 1:1 EUK using dta_files/benchmark_1997_VA.dta
drop  _merge


foreach i of global PPP_countries {
					gen ratio_`i' = (VA_`i')/(PPP_VA_`i')
} 


gen     sector_indi = 1 if EUK == "FINBU"  | EUK == "M"     | EUK == "N"     

replace sector_indi = 2 if EUK == "ELECOM" | EUK == "GOODS" | EUK == "DISTR" | EUK == "PERS" | EUK == "L" | | EUK == "70"

drop if sector_indi == .

collapse (sum) VA_* ratio_* (last) EUKLEMSindustries EUK, by(sector_indi)

foreach i of global PPP_countries {
					gen P_PPP_`i' =(VA_`i')/(ratio_`i')
} 

keep sector_indi P_PPP_*
label define sector_label 1 "HS" 2 "LS"
label values sector_indi sector_label

foreach i of global PPP_countries {
					rename P_PPP_`i'  `i'
} 

save dta_files/PPPs.dta, replace
rm   dta_files/benchmark_1997_VA.dta
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean up and Organize the .dta files and produce a .txt file for each country
foreach i of global EU_KLEMS_countries {
use dta_files/`i'.dta, replace
keep  country_code Year HS_ind_VA_share HS_comp_share_HS HS_comp_share_LS P_chain_relative gdp_pc Relative_Wage HS_ind_Comp_share 
order country_code      HS_ind_VA_share HS_comp_share_HS HS_comp_share_LS P_chain_relative gdp_pc Relative_Wage HS_ind_Comp_share Year
drop if HS_comp_share_HS == .
save dta_files/`i'.dta, replace
export delimited using csv_files/data_`i'_with_varnames, replace
export delimited using csv_files/data_`i', novarnames replace

rm    dta_files/`i'_labor_input.dta
rm    dta_files/`i'_LAB.dta
rm    dta_files/`i'_VA_P.dta
rm    dta_files/`i'_VA_P_for_merge.dta	                                       
}
