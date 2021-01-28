
/*
File Description: This .do file produces Figure 1 in the paper. 
Figure 1 plots on the left panel (right panel) the share of Labor Compensation (Value-Added) in the high skill-intensive and low-skill intensive sectors vs. real GDP per-capita at constant 2011 national prices (in US$).
Both series have been demeaned to take out country-specific fixed effects. We consider 15 countries over 1970-2005.
Countries are selected using the criterion in Buera-Kaboski 2012: they should have an income per-capita  of at least $9,200 in  Gheary-Khamis  1990 international dollars in 1970.
Countries are Austria, Australia, Belgium, Denmark, Spain, France, United Kingdom, Germany, Greece, Irland, Italy, Japan, Luxembourg, The Netherlands, and the U.S.
*/

*Inputs: one Excel spreadsheet per country, from EUKlems database (http://www.euklems.net/), November 2009 release, revised in June 2010.
*Output: a .dta file with the data to produce Figure1 (figure1.dta) and two charts (figure1.png; figure1.gph).

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Clean Up the Environenment and Set the Working Directory
cls 
clear all
macro drop _all
*global dir C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud
global dir /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/

*cd $dir\Figures1&2\Figure1\
cd $dir/Figures1&2/

* Start a Log File
log using Figure1, replace

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

* Pull the data from the Excel Files and Create Two Auxiliary .dta files per country, one for Value Added and one for Labor Compensation


foreach i of global EU_KLEMS_countries {
					import excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("VA") firstrow
					gen 	country_code = "`i'"
					order   country_code, first
					save    dta_files/VA/HS_Sector_$set/`i'_VA.dta, replace
					clear all
					}


foreach i of global EU_KLEMS_countries {
					clear all
					import excel excel_files/basic_files_09/`i'_output_09I.xls, sheet("LAB") firstrow
					gen 	country_code = "`i'"
					order   country_code, first
					save    dta_files/LAB/HS_Sector_$set/`i'_LAB.dta, replace
}
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Pull the .dta files for VA and keep Total VA and HS Industries. Compute the HS Sector's Share of VA for each country

clear all
foreach i of global EU_KLEMS_countries {
					use  dta_files/VA/HS_Sector_$set/`i'_VA.dta

					gen 	skill_ind = 0 if code == "TOT"
				
					foreach j of global HS_ind { 
					replace skill_ind = 1 if code == "`j'"
								   }	
					drop if skill_ind == .
					collapse (sum) _* (last) country_code, by(skill_ind)
					reshape long _ , i(skill_ind) j(Year)
					reshape wide _ , i(Year) j(skill_ind)
					rename _0 Tot_VA
					rename _1 HS_Ind_VA
					gen HS_ind_share = HS_Ind_VA/Tot_VA
					keep country_code Year HS_ind_share
					save dta_files/VA/HS_Sector_$set/`i'_HS_ind_VA_share.dta, replace
					}
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Pull the .dta files for LAB and keep Total LAB and HS Industries. Compute the HS Sector's Share of LAB for each country

clear all
foreach i of global EU_KLEMS_countries {
					use  dta_files/LAB/HS_Sector_$set/`i'_LAB.dta

					gen 	skill_ind = 0 if code == "TOT"
				
					foreach j of global HS_ind { 
					replace skill_ind = 1 if code == "`j'"
								   }	
					drop if skill_ind == .
					collapse (sum) _* (last) country_code, by(skill_ind)
					reshape long _ , i(skill_ind) j(Year)
					reshape wide _ , i(Year) j(skill_ind)
					rename _0 Tot_LAB
					rename _1 HS_Ind_LAB
					gen HS_ind_share = HS_Ind_LAB/Tot_LAB
					keep country_code Year HS_ind_share
					save dta_files/LAB/HS_Sector_$set/`i'_HS_ind_LAB_share.dta, replace
					}
									
*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
*  Put the data together in two Auxiliary files: one for VA and one for LAB compensation

*------------------------------------------------------------------------------- 
** LAB file

clear all
use dta_files/LAB/HS_Sector_$set/aus_HS_ind_LAB_share.dta, replace

foreach i of global EU_KLEMS_countries {
					append using dta_files/LAB/HS_Sector_$set/`i'_HS_ind_LAB_share.dta								
}

duplicates drop

gen countrycode2 = upper(country_code)
replace countrycode2 = "USA" if countrycode2 == "USA-NAICS" 
replace countrycode2 = "GBR" if countrycode2 == "UK" 

drop country_code
rename countrycode2 countrycode
rename Year year

rename HS_ind_share HS_ind_LAB_share

save dta_files/LAB/HS_Sector_$set/HS_ind_LAB_share.dta, replace

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
** VA file

clear all
use dta_files/VA/HS_Sector_$set/aus_HS_ind_VA_share.dta, replace

foreach i of global EU_KLEMS_countries {
					append using dta_files/VA/HS_Sector_$set/`i'_HS_ind_VA_share.dta															
}

duplicates drop

gen countrycode2 = upper(country_code)
replace countrycode2 = "USA" if countrycode2 == "USA-NAICS" 
replace countrycode2 = "GBR" if countrycode2 == "UK" 

drop   country_code
rename countrycode2 countrycode
rename Year year

rename HS_ind_share HS_ind_VA_share

save dta_files/VA/HS_Sector_$set/HS_ind_VA_share.dta, replace

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Pull the real GDP and Population Data From the PWT 9.0 .dta file and Compute GDP per capita

cls
clear all

use dta_files/pwt90.dta

keep countrycode year rgdpna pop
gen gdp_pc = rgdpna/pop

*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------

* Merge GDP per capita data with the HS Sector VA and LAB Shares

sort countrycode year
merge m:1 year countrycode using dta_files/VA/HS_Sector_$set/HS_ind_VA_share.dta

keep if _merge == 3 | _merge == 2
sort countrycode year
drop _merge

merge m:m year countrycode using dta_files/LAB/HS_Sector_$set/HS_ind_LAB_share.dta

keep if _merge == 3 | _merge == 2
sort countrycode year
drop _merge

gen log_gdp_pc = ln(gdp_pc)

* Save the data to an auxiliary .dta file
save dta_files/VA/raw_CrossCountry_VA_LAB_shares_$set.dta, replace

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Demean the data to take out country fixed effects

keep if 	countrycode == "AUS" | countrycode == "AUT" | countrycode == "BEL" | countrycode == "DNK" | countrycode == "ESP" ///
	      | countrycode == "FRA" | countrycode == "GBR" | countrycode == "GER" | countrycode == "GRC" | countrycode == "IRL" ///
	      | countrycode == "ITA" | countrycode == "JPN" | countrycode == "NLD" | countrycode == "SWE" | countrycode == "USA"

                 egen         avg_log_gdp_pc   =  mean(log_gdp_pc)
bys countrycode: egen country_avg_log_gdp_pc   =  mean(log_gdp_pc)

gen demeaned_log_gdp_pc         = log_gdp_pc + avg_log_gdp_pc - country_avg_log_gdp_pc
gen demeaned_gdp_pc             = exp(demeaned_log_gdp_pc)


                 egen         avg_HS_ind_VA_share   =  mean(HS_ind_VA_share)
bys countrycode: egen country_avg_HS_ind_VA_share   =  mean(HS_ind_VA_share)

gen demeaned_HS_ind_VA_share    = HS_ind_VA_share + avg_HS_ind_VA_share - country_avg_HS_ind_VA_share

gen demeaned_LS_ind_VA_share    = 1 - demeaned_HS_ind_VA_share

                 egen         avg_HS_ind_LAB_share   =  mean(HS_ind_LAB_share)
bys countrycode: egen country_avg_HS_ind_LAB_share   =  mean(HS_ind_LAB_share)

gen demeaned_HS_ind_LAB_share    = HS_ind_LAB_share + avg_HS_ind_LAB_share - country_avg_HS_ind_LAB_share

gen demeaned_LS_ind_LAB_share    = 1 - demeaned_HS_ind_LAB_share

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*  Make the Figures

** VALUE ADDED Shares

** Run the Regressions First
reg demeaned_HS_ind_VA_share demeaned_log_gdp_pc

 
twoway (scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(khaki) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Value Added" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Value Added" , size(medlarge)) ///
text(0.30 9.85 "High-Skill Intensive Sectors" "y = 0.144 ln(x) -1.237",size(small)) text(0.70 9.85 "Low-Skill Intensive Sectors" "y = -0.144 ln(x) + 2.237", size(small)) ///
text(0.15 10.75 , size(small))

graph save Graph Figure1/Figures/VA_shares_$set.gph, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

** LABOR COMPENSATION Shares

** Run the Regressions First
reg demeaned_HS_ind_LAB_share demeaned_log_gdp_pc

twoway (scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Labor Compensation" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Labor Compensation" , size(medlarge)) ///
text(0.35  9.85 "High-Skill Intensive Sectors" "y = 0.205 ln(x) -1.823",size(small)) text(0.65 9.85 "Low-Skill Intensive Sectors" "y = -0.205 ln(x) + 2.823", size(small))

graph save Graph Figure1/Figures/LAB_shares_$set.gph, replace

*-------------------------------------------------------------------------------
** Combine and Save the Figures

gr combine Figure1/Figures/LAB_shares_$set.gph Figure1/Figures/VA_shares_$set.gph  

graph export Figure1/Figures/figure1_$set.png, replace
graph export Figure1/Figures/figure1_$set.pdf, replace
graph save   Figure1/Figures/figure1_$set.gph, replace

*  Clean up and save figure1.dta
rm Figure1/Figures/LAB_shares_$set.gph 
rm Figure1/Figures/VA_shares_$set.gph

save dta_files/figure1_$set.dta, replace
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  SENSITIVITY ANALYSES
** Regressions With Fixed Effects Using the US as the Base Country

** To Run the Regressions With and Without FE we use the Raw Data (instead of the demeaned data)
cls
clear all
use dta_files/VA/raw_CrossCountry_VA_LAB_shares_$set.dta

encode countrycode, generate(country)

drop if log_gdp_pc == . | HS_ind_VA_share == . | HS_ind_LAB_share == .

*-------------------------------------------------------------------------------
* VALUE ADDED Shares

regress HS_ind_VA_share log_gdp_pc ib15.country
display e(r2)
*0.92899424

regress HS_ind_VA_share ib15.country
display e(r2)
*0.51488325

regress HS_ind_VA_share log_gdp_pc
display e(r2)
*0.66362236
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* LABOR COMPENSATION Shares

reg HS_ind_LAB_share log_gdp_pc ib15.country
display e(r2)
*0.92976168

reg HS_ind_LAB_share ib15.country
display e(r2)
*0.42646979

reg HS_ind_LAB_share log_gdp_pc
display e(r2)
*0.72573318
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

*  R2 of Regressions With and Without Fixed Effects: Summary

** VA Shares Regression
** With FE and log GDP per capita the R2 is: 0.9290
** With FE only                   the R2 is: 0.5149
** With log GDP per capita only   the R2 is: 0.6636

** LAB Shares Regression
** With FE and log GDP per capita the R2 is: 0.9298
** With FE only                   the R2 is: 0.4265
** With log GDP per capita only   the R2 is: 0.7257

*-------------------------------------------------------------------------------
log close

*---------------------------------------------------------------------------------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*  These Extra Lines are Used to Produce the Figures in the Online Appendix.
** Note: the figures can be produced using the lines above, here we save these extra lines to have the footnote with the extra industries easily available.

*-------------------------------------------------------------------------------
/*
* Expanding the HS Sector to Include Real Estate and Chemicals
*Note: To obtain the results using this expanded definition for the HS Sector, comment lines 69 and 102 and 
* uncomment lines 72 and 104

*VA Shares
reg demeaned_HS_ind_VA_share demeaned_log_gdp_pc
/*
. reg demeaned_HS_ind_VA_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3732.99
       Model |  1.28683653         1  1.28683653   Prob > F        =    0.0000
    Residual |  .178909491       519   .00034472   R-squared       =    0.8779
-------------+----------------------------------   Adj R-squared   =    0.8777
       Total |  1.46574602       520  .002818742   Root MSE        =    .01857

-------------------------------------------------------------------------------------
demeaned_HS_ind_V~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   .2046749   .0033499    61.10   0.000     .1980938     .211256
              _cons |  -1.751157   .0342088   -51.19   0.000    -1.818362   -1.683953
-------------------------------------------------------------------------------------
*/
reg demeaned_LS_ind_VA_share demeaned_log_gdp_pc
/*
. reg demeaned_LS_ind_VA_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3732.99
       Model |  1.28683657         1  1.28683657   Prob > F        =    0.0000
    Residual |  .178909488       519   .00034472   R-squared       =    0.8779
-------------+----------------------------------   Adj R-squared   =    0.8777
       Total |  1.46574605       520  .002818742   Root MSE        =    .01857

-------------------------------------------------------------------------------------
demeaned_LS_ind_V~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |  -.2046749   .0033499   -61.10   0.000     -.211256   -.1980938
              _cons |   2.751157   .0342088    80.42   0.000     2.683953    2.818362
-------------------------------------------------------------------------------------
*/
 
twoway (scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(khaki) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Value Added" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Value Added" , size(medlarge)) ///
text(0.10 9.85 "High-Skill Sectors" "y = 0.205 ln(x) - 1.751",size(small)) ///
text(0.90 9.85 "Low-Skill Sectors" "y = -0.205 ln(x) + 2.751", size(small)) 

graph save Figure1/Figures/VA_shares_$set.gph, replace
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*LABOR COMPENSATION Shares
reg demeaned_HS_ind_LAB_share demeaned_log_gdp_pc
/*
. reg demeaned_HS_ind_LAB_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3681.40
       Model |  1.34002621         1  1.34002621   Prob > F        =    0.0000
    Residual |  .188915521       519  .000363999   R-squared       =    0.8764
-------------+----------------------------------   Adj R-squared   =    0.8762
       Total |  1.52894173       520  .002940273   Root MSE        =    .01908

-------------------------------------------------------------------------------------
demeaned_HS_ind_L~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   .2082789   .0034327    60.67   0.000     .2015351    .2150226
              _cons |  -1.835266   .0350484   -52.36   0.000     -1.90412   -1.766411
-------------------------------------------------------------------------------------
*/
reg demeaned_LS_ind_LAB_share demeaned_log_gdp_pc
/*
. reg demeaned_LS_ind_LAB_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3681.40
       Model |  1.34002616         1  1.34002616   Prob > F        =    0.0000
    Residual |  .188915502       519  .000363999   R-squared       =    0.8764
-------------+----------------------------------   Adj R-squared   =    0.8762
       Total |  1.52894166       520  .002940272   Root MSE        =    .01908

-------------------------------------------------------------------------------------
demeaned_LS_ind_L~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |  -.2082789   .0034327   -60.67   0.000    -.2150226   -.2015351
              _cons |   2.835266   .0350484    80.90   0.000     2.766411     2.90412
-------------------------------------------------------------------------------------
*/

twoway (scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Labor Compensation" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Labor Compensation" , size(medlarge)) ///
text(0.10  9.85 "High-Skill Sectors" "y = 0.208 ln(x) - 1.835",size(small)) ///
text(0.90 9.85 "Low-Skill Sectors" "y = -0.208 ln(x) + 2.835", size(small)) 
graph save Figure1/Figures/LAB_shares_$set.gph, replace

gr combine Figure1/Figures/LAB_shares_$set.gph Figure1/Figures/VA_shares_$set.gph, ///
note("{bf: Note:} The High-Skill sectors includes the EU KLEMS industries {it:Education}, {it:Health and Social Work}, {it:Financial Intermediation}, {it:Real Estate}," "{it:Renting of M&Eq and Other Business Activities}, and {it:Chemicals and Chemical Products}." , size(vsmall))

graph export       Figure1/Figures/figure1_$set.png, replace
graph export       Figure1/Figures/figure1_$set.pdf, replace
graph save   Graph Figure1/Figures/figure1_$set.gph, replace

*  Clean up and save figure1.dta
rm Figure1/Figures/LAB_shares_$set.gph 
rm Figure1/Figures/VA_shares_$set.gph
*/
*------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
/*
*Expanding the HS Sector to Include Real Estate, Chemicals, Electrical and optical equipment and Public Admin 
*Note: To obtain the results using this expanded definition for the HS Sector, comment lines 69 and 102 and 
* uncomment lines 75 and 107

*VA Shares

reg demeaned_HS_ind_VA_share demeaned_log_gdp_pc
/*
. reg demeaned_HS_ind_VA_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3148.07
       Model |  1.17379154         1  1.17379154   Prob > F        =    0.0000
    Residual |   .19351482       519  .000372861   R-squared       =    0.8585
-------------+----------------------------------   Adj R-squared   =    0.8582
       Total |  1.36730636       520  .002629435   Root MSE        =    .01931

-------------------------------------------------------------------------------------
demeaned_HS_ind_V~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   .1954782    .003484    56.11   0.000     .1886338    .2023227
              _cons |  -1.568623   .0355778   -44.09   0.000    -1.638517   -1.498729
-------------------------------------------------------------------------------------
*/
reg demeaned_LS_ind_VA_share demeaned_log_gdp_pc
/*
. reg demeaned_LS_ind_VA_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   3148.07
       Model |  1.17379156         1  1.17379156   Prob > F        =    0.0000
    Residual |  .193514834       519  .000372861   R-squared       =    0.8585
-------------+----------------------------------   Adj R-squared   =    0.8582
       Total |  1.36730639       520  .002629435   Root MSE        =    .01931

-------------------------------------------------------------------------------------
demeaned_LS_ind_V~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |  -.1954782    .003484   -56.11   0.000    -.2023227   -.1886338
              _cons |   2.568623   .0355778    72.20   0.000     2.498729    2.638517
-------------------------------------------------------------------------------------
*/
 
twoway (scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(ltbluishgray8) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(S) mcolor(khaki) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_VA_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_VA_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Value Added" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Value Added" , size(medlarge)) ///
text(0.15 9.85 "High-Skill Sectors" "y = 0.195 ln(x) - 1.569",size(small)) ///
text(0.80 9.85 "Low-Skill Sectors" "y = -0.195 ln(x) + 2.569", size(small)) 

graph save Figure1/Figures/VA_shares_$set.gph, replace

*LABOR COMPENSATION Shares
reg demeaned_HS_ind_LAB_share demeaned_log_gdp_pc
/*
. reg demeaned_HS_ind_LAB_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   2507.30
       Model |  1.26110931         1  1.26110931   Prob > F        =    0.0000
    Residual |  .261044076       519  .000502975   R-squared       =    0.8285
-------------+----------------------------------   Adj R-squared   =    0.8282
       Total |  1.52215338       520  .002927218   Root MSE        =    .02243

-------------------------------------------------------------------------------------
demeaned_HS_ind_L~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |   .2020528   .0040352    50.07   0.000     .1941256    .2099801
              _cons |  -1.666276   .0411995   -40.44   0.000    -1.747214   -1.585338
-------------------------------------------------------------------------------------
*/
reg demeaned_LS_ind_LAB_share demeaned_log_gdp_pc
/*
. reg demeaned_LS_ind_LAB_share demeaned_log_gdp_pc

      Source |       SS           df       MS      Number of obs   =       521
-------------+----------------------------------   F(1, 519)       =   2507.30
       Model |  1.26110927         1  1.26110927   Prob > F        =    0.0000
    Residual |  .261044087       519  .000502975   R-squared       =    0.8285
-------------+----------------------------------   Adj R-squared   =    0.8282
       Total |  1.52215336       520  .002927218   Root MSE        =    .02243

-------------------------------------------------------------------------------------
demeaned_LS_ind_L~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
demeaned_log_gdp_pc |  -.2020528   .0040352   -50.07   0.000    -.2099801   -.1941256
              _cons |   2.666276   .0411995    64.72   0.000     2.585337    2.747214
-------------------------------------------------------------------------------------
*/

twoway (scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_HS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode != "USA", msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(scatter demeaned_LS_ind_LAB_share demeaned_log_gdp_pc if countrycode == "USA", msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge)) ///
(lfit demeaned_HS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin) msize(large)) (lfit demeaned_LS_ind_LAB_share demeaned_log_gdp_pc, lcolor(black) lstyle(thin)) , ylabel(0(0.1)1) ///
leg(off) title("Labor Compensation" ) xtitle("Real GDP per capita" "(log scale)" , size(medlarge)) ytitle("Share of Total Labor Compensation" , size(medlarge)) ///
text(0.15  9.85 "High-Skill Sectors" "y = 0.202 ln(x) - 1.666",size(small)) ///
text(0.80 9.85 "Low-Skill Sectors" "y = -0.202 ln(x) + 2.666", size(small)) 

graph save Figure1/Figures/LAB_shares_$set.gph, replace

gr combine Figure1/Figures/LAB_shares_$set.gph Figure1/Figures/VA_shares_$set.gph, ///
note("{bf: Note:} The High-Skill sectors includes the EU KLEMS industries {it:Education}, {it:Health and Social Work}, {it:Financial Intermediation}, {it:Real Estate}," "{it:Renting of M&Eq and Other Business Activities}, {it:Chemicals and Chemical Products}, {it:Electrical and Optical Equipment}," "and {it:Public Administration and Defense}." , size(vsmall))

graph export       Figure1/Figures/figure1_$set.png, replace
graph export       Figure1/Figures/figure1_$set.pdf, replace
graph save   Graph Figure1/Figures/figure1_$set.gph, replace

*  Clean up and save figure1.dta
rm Figure1/Figures/LAB_shares_$set.gph 
rm Figure1/Figures/VA_shares_$set.gph
*/
