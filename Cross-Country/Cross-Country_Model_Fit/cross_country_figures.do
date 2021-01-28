cd /home/nacho/Dropbox/BKR/Nacho/Data_Appendix_2/Cross-Country_Model_Fit

use "cross_country_model_fit.dta"

*First Figure
twoway (scatter skill_premium_model skill_premium_data, msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge) xscale(range(1.00 2.25)) xlabel(1.00(0.25)2.25) yscale(range(1.00 2.25)) ylabel(1.00(0.25)2.25)) ///
(line skill_premium_data skill_premium_data, lcolor(black) lstyle(thin) msize(large)), ///
leg(off) xtitle("Actual Skill Premium" , size(medlarge)) ytitle("Predicted Skill Premium" , size(medlarge))

graph save skill_prem.gph, replace

twoway (scatter service_share_model service_share_data, msymbol(O) mlcolor(black) mlwidth(vvthin) msize(medlarge) xscale(range(0.10 0.40)) xlabel(0.10(0.05)0.40) yscale(range(0.10 0.40)) ylabel(0.10(0.05)0.40)) ///
(line service_share_data service_share_data, lcolor(black) lstyle(thin) msize(large)), ///
leg(off) xtitle("Actual Skill-Intensive Sector Share" , size(medlarge)) ytitle("Predicted Skill-Intensive Sector Share" , size(medlarge))

graph save serv_share.gph, replace
gr combine serv_share.gph skill_prem.gph
graph save figure3.gph, replace

*Second Figure
gen log_serv_prod   = log(service_productivity)
gen log_goods_prod  = log(goods_productivity)
gen log_gdp_pc      = log(gdp_pc)

             egen         avg_log_serv_prod  =  mean(log_serv_prod)
bys country: egen country_avg_log_serv_prod  =  mean(log_serv_prod)
gen demeaned_log_serv_prod                   = log_serv_prod + avg_log_serv_prod - country_avg_log_serv_prod

             egen         avg_log_goods_prod =  mean(log_goods_prod)
bys country: egen country_avg_log_goods_prod =  mean(log_goods_prod)
gen demeaned_log_goods_prod                  = log_goods_prod + avg_log_goods_prod - country_avg_log_goods_prod

             egen         avg_log_gdp_pc   =  mean(log_gdp_pc)
bys country: egen country_avg_log_gdp_pc   =  mean(log_gdp_pc)
gen demeaned_log_gdp_pc         = log_gdp_pc + avg_log_gdp_pc - country_avg_log_gdp_pc

twoway (scatter demeaned_log_serv_prod demeaned_log_gdp_pc, msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge) xlabel(9.5(0.50)11.0) ylabel(-1.50(0.20)0.30) ) ///
(scatter demeaned_log_goods_prod demeaned_log_gdp_pc, msymbol(S) mlcolor(black) mlwidth(vvthin) msize(medlarge) ), ///
leg(off) /// 
text(-0.20 10.0 "A{subscript:S}",place(c) ) ///
text(-0.50 10.5 "A{subscript:G}" ,place(c)) ///
xtitle("log Real GDP per Capita" , size(medlarge)) ytitle("log Sector-Biased Productivity" , size(medlarge))

graph save Aj.gph, replace

             egen         avg_low_skill_weight_serv  =  mean(low_skill_weight_services)
bys country: egen         c_avg_low_skill_weight_serv  =  mean(low_skill_weight_services)
gen demeaned_low_skill_weight_serv         = low_skill_weight_serv + avg_low_skill_weight - c_avg_low_skill_weight

             egen         avg_low_skill_weight_goods    =  mean(low_skill_weight_goods)
bys country: egen         c_avg_low_skill_weight_goods  =  mean(low_skill_weight_goods)
gen demeaned_low_skill_weight_goods         = low_skill_weight_goods + avg_low_skill_weight_goods - c_avg_low_skill_weight_goods

gen demeaned_high_skill_weight_goods = 1-demeaned_low_skill_weight_goods
gen demeaned_high_skill_weight_serv  = 1-demeaned_low_skill_weight_serv

twoway (scatter demeaned_high_skill_weight_serv demeaned_log_gdp_pc, msymbol(D) mlcolor(black) mlwidth(vvthin) msize(medlarge) xlabel(9.5(0.50)11.0) ylabel(0.00(0.10)0.60) ) ///
(scatter demeaned_high_skill_weight_goods demeaned_log_gdp_pc, msymbol(S) mlcolor(black) mlwidth(vvthin) msize(medlarge) ), ///
leg(off) xtitle("log Real GDP per Capita" , size(medlarge)) ytitle("Skill-Biased Technology Parameter" , size(medlarge)) ///
text(0.43 10.00 "{&alpha}{subscript:S}" ,place(c) ) ///
text(0.20 10.50 "{&alpha}{subscript:G}" ,place(c) ) 

graph save hs_weights.gph, replace
 
gr combine hs_weights.gph Aj.gph
graph save figure4.gph, replace

