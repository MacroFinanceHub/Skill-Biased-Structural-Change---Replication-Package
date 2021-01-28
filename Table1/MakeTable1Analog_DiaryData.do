cls
clear all
cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix/REStud/Table1

use          CEXmicrodata/diary12/fmld121.dta
append using CEXmicrodata/diary12/fmld122.dta
append using CEXmicrodata/diary12/fmld123.dta
append using CEXmicrodata/diary12/fmld124.dta
keep newid finlwt21 inc_rank popsize age_ref educ_ref ref_race sex_ref perslt18 persot64 fam_size fam_type bls_urbn region state high_edu fincbefx fincaftx 
sort newid
save CEXdemographicdataDiary.dta, replace

use 	     CEXmicrodata/diary12/expd121.dta
append using CEXmicrodata/diary12/expd122.dta
append using CEXmicrodata/diary12/expd123.dta
append using CEXmicrodata/diary12/expd124.dta
destring ucc, replace
sort ucc
merge ucc using VAdataforCEXmerge.dta
tab _merge, summarize(cost) obs mean
keep if _merge==3
save CombinedVADataforRegressions_Diary.dta, replace

 
use CombinedVADataforRegressions_Diary.dta, clear
drop if cost<0
collapse (sum) cost (mean) Hsect, by (PCEline newid expnmo expnyr)
g Hsectc=cost*Hsect
collapse (sum) cost Hsectc, by (newid expnmo expnyr)
rename cost totalexp
g Hsect=Hsectc/totalexp
destring expnmo, replace
sort newid
merge newid using CEXdemographicdataDiary.dta
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
destring expnmo, replace
destring popsize, replace
keep if age_ref>=25 & age_ref<55 & bls_urbn==1
g lincome=log(fincaftx)
g lexpenditures=log(totalexp)
g highskill1=1 if high_edu>=16
replace highskill1=0 if high_edu<16
g highskill2=1 if high_edu==16
replace highskill2=0 if high_edu==12

log using MonthlyResultsDiary.log, replace 
*VA results monthly

reg Hsect lincome [aw=finlwt21]
reg Hsect lexpenditures [aw=finlwt21]
reg Hsect highskill2 [aw=finlwt21]

reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize lincome [aw=finlwt21]
reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize lexpenditures [aw=finlwt21]

xi: ivreg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref i.ref_race i.popsize (lincome=high_edu)  [aw=finlwt21]
xi: ivreg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize (lexpenditures=high_edu) [aw=finlwt21]

reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize highskill2 [aw=finlwt21]


log close

g count=1

collapse (sum) totalexp Hsectc count (mean) finlwt21 inc_rank popsize expnmo age_ref fam_size perslt18 persot64 bls_urbn fincaftx fincbefx ref_race region sex_ref high_edu state, by (newid)
g Hsect=Hsectc/totalexp
g lincome=log(fincaftx)
g lexpenditures=log(totalexp)
g age2=age_ref^2
g expnmonths=int(expnmo)
drop expnmo
g highskill1=1 if high_edu>=16
replace highskill1=0 if high_edu<16
g highskill2=1 if high_edu==16
replace highskill2=0 if high_edu==12
*adjust for number of months
g totalexpa=totalexp/count  
g lexpendituresa=log(totalexpa)


log using QuarterlyResultsDiary.log, append

*VA results quarterly

reg Hsect lincome [aw=finlwt21]
reg Hsect lexpendituresa [aw=finlwt21]
reg Hsect highskill2 [aw=finlwt21]

reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize lincome [aw=finlwt21]
reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize lexpendituresa [aw=finlwt21]

xi: ivreg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize (lincome=high_edu) [aw=finlwt21]
xi: ivreg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize (lexpendituresa=high_edu) [aw=finlwt21]

reg Hsect i.expnmo age_ref age2 bls_urbn fam_size perslt18 persot64 i.state sex_ref  i.ref_race i.popsize highskill2 [aw=finlwt21]

summ totalexpa, detail
summ lexpendituresa, detail
log close




