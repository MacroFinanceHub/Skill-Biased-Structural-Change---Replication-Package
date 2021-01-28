*-------------------------------------------------------------------------------
* Chain Price Indeces

* File Description: This .do file Produces Chain Price Indices for the High- and Low-Skill Sector and a Relative Price Index for 15 Countries 

*Countries are selected using the criterion in Buera-Kaboski 2012: they should have an income per-capita  of at least $9,200 in  Gheary-Khamis  1990 international dollars in 1970.
*Countries are Austria, Australia, Belgium, Denmark, Spain, France, United Kingdom, Germany, Greece, Irland, Italy, Japan, The Netherlands, Sweden, and the U.S.

*Inputs: one Excel spreadsheet per country corresponding to the EU KLEMS basic file, November 2009 release, revised in June 2010, from EU KLEMS database (http://www.euklems.net/),

*Output: a .dta file per country with the chain price index for the High-Skill Sector, the Low-Skill Sector, and the Relative Chain Price Index. These Indices are used to produce Figure2 in .do file Figure2.do and to produce the cross-country calibration targets in \Cross-Country\Cross_Country_Calibration_Targets\CC_cali_targets.do

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up, Set the Working Directory and Define the Set of Countries Used in Figures 1 and 2
cls 
clear all
macro drop _all
global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud

cd $dir\Figures1&2\Figure2\
global EU_KLEMS_countries "aus aut bel dnk esp fra uk ger grc irl ita jpn nld swe usa-naics"
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*  Define The Industries in The High- and the Low-Skill Sector
** Benchmark    : HS Sector includes industries Financial Intermediation(J), Education(M), Health and Social Work(N), Renting of m&eq and other business activities (71t74)
** Alternative 1: Adding Real Estate (70) and Chemicals (24) to the HS Sector 
** Alternative 2: Adding Real Estate (70), Chemicals (24), Public Adm (L), and Elec and Opt Equip (30t33) to the HS Sector 

global set "benchmark"
*global set "Alt1"
*global set "Alt2"
*-----------------
** Low-Skill Industries

if "$set" == "benchmark"{
global LS_ind "AtB C D E F G H I 70 L O P"
}
if "$set" == "Alt1"{
global LS_ind "AtB C 15t16 17t19 20 21t22 23 25 26 27t28 29 30t33 34t35 36t37 E F G H I L O P"
}
if "$set" == "Alt2"{
global LS_ind "AtB C 15t16 17t19 20 21t22 23 25 26 27t28 29 34t35 36t37 E F G H I O P"
}

*-----------------
** High-Skill Industries

if "$set" == "benchmark"{
global HS_ind "J M N 71t74"
}
if "$set" == "Alt1"{
global HS_ind "J M N 71t74 70 24"
}
if "$set" == "Alt2"{
global HS_ind "J M N 71t74 70 24  L 30t33"
}
macro list

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Import the Price Levels for Each Country and Compute the Gross Annual Change by Industry
cd ..	
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

* Save the Price Indeces and their Gross Annual Change in an Auxiliary .dta File for Each Country 
save dta_files/Prices/HS_Sector_$set/`x'_VA_P.dta,replace

*-------------------------------------------------------------------------------

cls
clear all

* Import VA data to use as chain weights
import excel excel_files/basic_files_09/`x'_output_09I.xls, sheet("VA") firstrow

gen   country_code = upper("`x'")
rename _* VA_*

* Combine With Price Data
merge 1:1 country_code code using dta_files/`x'_VA_P.dta
drop _merge

* Generate the Components of the Chain
forval i = 1971(1)2005 {
        local    j =  `i'-1
	    display `j'
        gen chain_lag_`i'  = P_ratio_`i'*VA_`j'
	gen chain_lead_`i' = P_ratio_`i'*VA_`i'
}

* Create an Industry Indicator
gen   ind_type = 0 if code == "TOT"
			
foreach j of global LS_ind { 
replace ind_type = 1 if code == "`j'"
			   }
						
foreach j of global HS_ind { 				
replace ind_type = 2 if code == "`j'"
			   }

drop if ind_type == .

* Aggregate Variables at the Sector Level
collapse (sum) VA_* chain_lag_* chain_lead_*, by(ind_type)

* Generate the Chain Indices
forval   i = 1971(1)2005 {
local    j =  `i'-1
gen P_chain_`i' = sqrt((chain_lag_`i'/VA_`j')*(chain_lead_`i'/VA_`i'))

** This Line is Used for Japan and US to Fill Out Years With Missing Values
replace P_chain_`i' = 1.0 if P_chain_`i' == .
}

keep ind_type P_chain_*

gen 	P_chain_1970 = 1
order   ind_type P_chain_1970, first

gen accum_P_chain_1970 = 100

* Accumulate the Computed Price Changes in Indices
forval   i = 1971/2005 {
local    j =  `i'-1
gen accum_P_chain_`i'= (P_chain_`i')*(accum_P_chain_`j')
}

* Clean Up and Compute the Relative Price Index
keep 	ind_type  accum_P_chain_*
rename  accum_P_chain_* P_chain_*

reshape long P_chain_ ,i(ind_type) j(Year)
reshape wide P_chain_ ,i(Year)     j(ind_type)

rename P_chain_0 P_chain_Total
rename P_chain_1 P_chain_LS
rename P_chain_2 P_chain_HS

drop P_chain_Total
gen  P_chain_relative    = (P_chain_HS/P_chain_LS)*100

* Save the Price Indices in the Cross Country Calibration Target File for Each Country
*export excel using /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Figures1&2/Cross_Country_Calibration_Targets/CrossCountry_cal_targets_BKRV.xlsx, sheet("`x'") cell(M1) sheetmodify firstrow(variables)

* Define 1995 as the Base Year
gen     P_chain_base_prelim  =  P_chain_relative if Year == 1995
egen    P_chain_base         =  max(P_chain_base_prelim)
replace P_chain_relative     = (P_chain_relative/P_chain_base)*100

keep   Year P_chain_relative 
gen    country_code = upper("`x'")

order  country_code Year, first

* Save the Data in an Auxiliary .dta File for Each Country
save dta_files/Prices/HS_Sector_$set/`x'_VA_P_for_merge.dta,replace

clear all
}

* Final Housekeeping: Replace Years With no Data With Missing Values for Japan and the US

use     dta_files/Prices/HS_Sector_$set/jpn_VA_P_for_merge.dta,replace
replace P_chain_relative = . if Year < 1973
save    dta_files/Prices/HS_Sector_$set/jpn_VA_P_for_merge.dta,replace

use     dta_files/Prices/HS_Sector_$set/usa-naics_VA_P_for_merge.dta,replace
replace P_chain_relative = . if Year < 1977
save 	dta_files/Prices/HS_Sector_$set/usa-naics_VA_P_for_merge.dta,replace

cd $dir\Figures1&2\Figure2\
*-------------------------------------------------------------------------------
