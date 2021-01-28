cls
clear all
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Table1

use 	     CEXmicrodata/intrvw12/fmli131.dta
append using CEXmicrodata/intrvw12/fmli121x.dta
append using CEXmicrodata/intrvw12/fmli122.dta
append using CEXmicrodata/intrvw12/fmli123.dta
append using CEXmicrodata/intrvw12/fmli124.dta

keep newid finlwt21 inc_rank popsize age_ref educ_ref ref_race sex_ref as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 fam_size fam_type bls_urbn region state high_edu inc_hrs1 inc_hrs2 fincbtax fincatax 
sort newid

save CEXdemographicdata.dta, replace

use          CEXmicrodata/intrvw12/mtbi131.dta
append using CEXmicrodata/intrvw12/mtbi121x.dta
append using CEXmicrodata/intrvw12/mtbi122.dta
append using CEXmicrodata/intrvw12/mtbi123.dta
append using CEXmicrodata/intrvw12/mtbi124.dta
destring ucc, replace
sort ucc

merge m:m ucc using VAdataforCEXmerge.dta
tab _merge, summarize(cost) obs mean
keep if _merge==3
save CombinedVADataforRegressions, replace
 
use CombinedVADataforRegressions, clear
drop if cost<0
collapse (sum) cost [aweight=weight], by (PCEline newid ref_mo ref_yr Hsect)
g Hsectc=cost*Hsect
collapse (sum) cost Hsectc, by (newid ref_mo ref_yr)
rename cost totalexp
g Hsect=Hsectc/totalexp
log using basicresults.log, replace
summ
summ totalexp, detail
log close 
destring ref_mo, replace
sort newid
merge newid using CEXdemographicdata.dta
drop if inc_rank==.
keep if _merge==3
drop _merge
g age2=age_ref^2
destring state, replace
destring region, replace
destring high_edu, replace
destring ref_race, replace
destring sex_ref, replace
destring bls, replace
destring ref_mo, replace
destring popsize, replace
keep if age_ref>=25 & age_ref<55
g lincome=log(fincatax)
g lexpenditures=log(totalexp)
g highskill1=1 if high_edu>=16
replace highskill1=0 if high_edu<16
g highskill2=1 if high_edu==16
replace highskill2=0 if high_edu==12

log using monthlyresults.log, replace 
*VA results monthly

reg Hsect lincome [aw=finlwt21]
reg Hsect lexpenditures [aw=finlwt21]
reg Hsect highskill2 [aw=finlwt21]

reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race lincome [aw=finlwt21]
reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race lexpenditures [aw=finlwt21]

xi: ivreg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize (lincome=high_edu)  [aw=finlwt21]
xi: ivreg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize (lexpenditures=high_edu) [aw=finlwt21]

reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race highskill2 [aw=finlwt21]
reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race highskill1 [aw=finlwt21]


log close

g count=1

collapse (sum) totalexp Hsectc count (mean) finlwt21 inc_rank popsize ref_mo age_ref as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 bls_urbn fam_size fincatax fincbtax inc_hrs1 inc_hrs2 ref_race region sex_ref high_edu state, by (newid)
g Hsect=Hsectc/totalexp
g lincome=log(fincatax)
g lexpenditures=log(totalexp)
g age2=age_ref^2
g ref_months=int(ref_mo)
drop ref_mo
g highskill1=1 if high_edu>=16
replace highskill1=0 if high_edu<16
g highskill2=1 if high_edu==16
replace highskill2=0 if high_edu==12
*adjust for number of months
g totalexpa=totalexp/count 
g lexpendituresa=log(totalexpa)


log using Table1results.log, append

*VA results quarterly


reg Hsect lincome [aw=finlwt21]
reg Hsect lexpendituresa [aw=finlwt21]
reg Hsect highskill2 [aw=finlwt21]

reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize  lincome [aw=finlwt21]
reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize  lexpendituresa [aw=finlwt21]

xi: ivreg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize (lincome=high_edu)  [aw=finlwt21]
xi: ivreg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize (lexpendituresa=high_edu) [aw=finlwt21] 


reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race i.popsize  highskill2 [aw=finlwt21]
reg Hsect i.ref_mo age_ref age2 bls_urbn as_comp1 as_comp2 as_comp3 as_comp4 as_comp5 i.state sex_ref i.ref_race highskill1 [aw=finlwt21]

summ totalexpa, detail
summ lexpendituresa, detail

log close


