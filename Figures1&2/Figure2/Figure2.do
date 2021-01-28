*-------------------------------------------------------------------------------
*File Description: This .do file produces Figure 2 in the paper. 

*Figure2 plots the relative price of High-Skill Intensive to Low-Skill Intensive sectors. It is normalized such that, for each country, the index equals 100 in 1995.
*Both series have been demeaned to take out country-specific fixed effects. We consider 16 countries over 1970-2005.

*Countries are selected using the criterion in Buera-Kaboski 2012: they should have an income per-capita  of at least $9,200 in  Gheary-Khamis  1990 international dollars in 1970.
*Countries are Austria, Australia, Belgium, Denmark, Spain, France, United Kingdom, Germany, Greece, Irland, Italy, Japan, The Netherlands, Sweden, and the U.S.

*Inputs: one Excel spreadsheet per country, from EUKlems database (http://www.euklems.net/), November 2009 release, revised in June 2010.

*Output: a .dta file with the data final data to produce Figure2 (figure1.dta) and two charts (figure2.png; figure2.gph).
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
macro drop _all
global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud

cd $dir\Figures1&2\Figure2\

* Start a Log File
log using Figure2, replace

* Define the Countries in the Analysis
global EU_KLEMS_countries "aus aut bel dnk esp fra uk ger grc irl ita jpn nld swe usa-naics"

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*  Define The Industries in The High- and the Low-Skill Sector
** Benchmark    : HS Sector includes industries Financial Intermediation(J), Education(M), Health and Social Work(N), Renting of m&eq and other business activities (71t74)
** Alternative 1: Adding Real Estate (70) and Chemicals (24) to the HS Sector 
** Alternative 2: Adding Real Estate (70), Chemicals (24), Public Adm (L), and Elec and Opt Equip (30t33) to the HS Sector 

** Note: Make sure to define the set of HS Industries Accordingly in the chain_price_indices.do file.

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
* Run the .do file that produces Chain Price Indices at the Country Level

*do chain_price_indices
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Create a .dta File that Combines All the Price Indices
cd ..
cd 	$dir\Figures1&2\dta_files\Prices\HS_Sector_$set

use    aus_VA_P_for_merge.dta

foreach i of global EU_KLEMS_countries {
				     append using `i'_VA_P_for_merge.dta
}

duplicates drop
sort country_code Year
save  P_indices_combined.dta, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Merge the Price Indices with GDP per capita Data
cls
clear all

cd .. 
cd .. 
use pwt90.dta

keep countrycode year rgdpna pop

gen gdp_pc = rgdpna/pop
rename countrycode country_code

rename year Year
replace country_code = "USA-NAICS" if country_code == "USA"
replace country_code = "UK"        if country_code == "GBR"

merge 1:1 Year country_code using Prices\HS_Sector_$set\P_indices_combined.dta

keep if _merge == 3 | _merge == 2
sort country_code Year
drop _merge

rename country_code countrycode
gen log_gdp_pc = ln(gdp_pc)
save  Prices\HS_Sector_$set\raw_P_Ind_$set.dta, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Demean the Data to Remove Country Fixed Effects 


                 egen         avg_log_gdp_pc   =  mean(log_gdp_pc)
bys countrycode: egen country_avg_log_gdp_pc   =  mean(log_gdp_pc)

gen demeaned_log_gdp_pc         = log_gdp_pc + avg_log_gdp_pc - country_avg_log_gdp_pc
gen demeaned_gdp_pc             = exp(demeaned_log_gdp_pc)


                 egen         avg_P_chain_relative   =  mean(P_chain_relative)
bys countrycode: egen country_avg_P_chain_relative   =  mean(P_chain_relative)

gen demeaned_P_chain_relative    = P_chain_relative + avg_P_chain_relative - country_avg_P_chain_relative

replace countrycode = "USA" if countrycode == "USA-NAICS"
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
sort countrycode Year
reg demeaned_P_chain_relative demeaned_log_gdp_pc
/*
. reg demeaned_P_chain_relative demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       494
-------------+----------------------------------   F(1, 492)       =   1313.31
       Model |  57642.0358         1  57642.0358   Prob > F        =    0.0000
    Residual |  21594.1839       492  43.8906178   R-squared       =    0.7275
-------------+----------------------------------   Adj R-squared   =    0.7269
       Total |  79236.2198       493  160.722555   Root MSE        =     6.625

-------------------------------------------------------------------------------------
demeaned_P_chain_~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   47.10868   1.299921    36.24   0.000     44.55459    49.66276
              _cons |  -386.6907   13.24643   -29.19   0.000    -412.7173   -360.6642
-------------------------------------------------------------------------------------
*/

twoway (scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_P_chain_relative demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)), ///
leg(off) title("High-Skill Intensive Sector Relative Price") ytitle("P{sub:HS Sectors} / P{sub:LS Sectors}" "{sub:(1995 = 100)}" , size(medlarge)) xtitle("Real GDP per-capita" "(log scale)" , size(medlarge)) ///
text(120 9.75 "y = 47.11 ln(x) - 386.69",size(small)) 

cd ..
graph save Graph Figure2\Figures\figure2_$set.gph, replace
graph export     Figure2\Figures\figure2_$set.png, replace
graph export     Figure2\Figures\figure2_$set.pdf, replace

*Clean up and save figure2.dta
save dta_files\Prices\HS_Sector_$set\figure2_$set.dta, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*SENSITIVITY ANALYSIS
cls
clear all
use dta_files\Prices\HS_Sector_$set\raw_P_Ind_$set.dta

encode countrycode, generate(country)
reg P_chain_relative log_gdp_pc ib15.country

reg P_chain_relative log_gdp_pc 

reg P_chain_relative ib15.country

*-------------------------------------------------------------------------------

*  R2 of Regressions With and Without Fixed Effects: Summary

** With FE and log GDP per capita the R2 is: 0.7612
** With FE only                   the R2 is: 0.1031
** With log GDP per capita only   the R2 is: 0.5233

*-------------------------------------------------------------------------------
log close

*---------------------------------------------------------------------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*  These Extra Lines are Used to Produce the Figures in the Online Appendix.
** Note: the figures can be produced using the lines above, here we save these extra lines to have the footnote with the extra industries easily available.


*Here we re do Figure 1 considering an expanded set of high-skill industries

/*
*Expanding the HS Sector to Include Real Estate and Chemicals

reg demeaned_P_chain_relative demeaned_log_gdp_pc
/*
. reg demeaned_P_chain_relative demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       494
-------------+----------------------------------   F(1, 492)       =    941.97
       Model |  48124.4076         1  48124.4076   Prob > F        =    0.0000
    Residual |  25135.8009       492  51.0890262   R-squared       =    0.6569
-------------+----------------------------------   Adj R-squared   =    0.6562
       Total |  73260.2085       493  148.600829   Root MSE        =    7.1477

-------------------------------------------------------------------------------------
demeaned_P_chain_~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   43.04413   1.402475    30.69   0.000     40.28855    45.79971
              _cons |  -345.6977   14.29147   -24.19   0.000    -373.7775   -317.6178
-------------------------------------------------------------------------------------
*/

twoway (scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_P_chain_relative demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)), ///
leg(off) title("High-Skill Intensive Sector Relative Price") ytitle("P{sub:HS Sectors} / P{sub:LS Sectors}" "{sub:(1995 = 100)}" , size(medlarge)) xtitle("Real GDP per-capita" "(log scale)" , size(medlarge)) ///
text(120 9.75 "y = 43.04 ln(x) - 345.69") /// 
ylabel(60 (20) 140) ///
note("{bf: Note:} The High-Skill sectors includes the EU KLEMS industries {it:Education}, {it:Health and Social Work}, {it:Financial Intermediation}," "{it:Real Estate}, {it:Renting of M&Eq and Other Business Activities}, and {it:Chemicals and Chemical Products}." , size(vsmall))

cd ..

graph save Graph Figure2\Figures\figure2_$set.gph, replace
graph export     Figure2\Figures\figure2_$set.png, replace
graph export     Figure2\Figures\figure2_$set.pdf, replace

*/
*-------------------------------------------------------------------------------
 
 *-------------------------------------------------------------------------------
*Expanding the HS Sector to Include Real Estate, Chemicals, Electrical and optical equipment and Public Admin 

/*
reg demeaned_P_chain_relative demeaned_log_gdp_pc

/*
. reg demeaned_P_chain_relative demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       494
-------------+----------------------------------   F(1, 492)       =    627.91
       Model |  29847.2023         1  29847.2023   Prob > F        =    0.0000
    Residual |  23386.7307       492  47.5340055   R-squared       =    0.5607
-------------+----------------------------------   Adj R-squared   =    0.5598
       Total |   53233.933       493   107.97958   Root MSE        =    6.8945

-------------------------------------------------------------------------------------
demeaned_P_chain_~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |    33.8987     1.3528    25.06   0.000     31.24072    36.55668
              _cons |  -251.3673   13.78527   -18.23   0.000    -278.4526    -224.282
-------------------------------------------------------------------------------------
*/

twoway (scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_P_chain_relative demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_P_chain_relative demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)), ///
leg(off) title("High-Skill Intensive Sector Relative Price") ytitle("P{sub:HS Sectors} / P{sub:LS Sectors}" "{sub:(1995 = 100)}" , size(medlarge)) xtitle("Real GDP per-capita" "(log scale)" , size(medlarge)) ///
text(120 9.75 "y = 33.90 ln(x) - 251.37",size(small)) /// 
ylabel(60 (20) 140) ///
note("{bf: Note:} The High-Skill sectors includes the EU KLEMS industries {it:Education}, {it:Health and Social Work}, {it:Financial Intermediation}," "{it:Real Estate}, {it:Renting of M&Eq and Other Business Activities}, {it:Chemicals and Chemical Products}," "{it:Electrical and Optical Equipment}, and {it:Public Administration and Defense}." , size(vsmall))

cd ..

graph save Graph Figure2\Figures\figure2_$set.gph, replace
graph export     Figure2\Figures\figure2_$set.png, replace
graph export     Figure2\Figures\figure2_$set.pdf, replace


*-------------------------------------------------------------------------------
