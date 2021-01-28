## Cross-Country

This folder contains the files needed to produce the results in Section 8 of the paper and Section 5 of the Online Appendix.

### Subfolder: Cross_Country_Calibration_Targets

* *CC_cali_targets.do:* This .do file produces the times series used to perform the calibration of the technology parameters for the ten OECD countries in the Cross-Country Analysis presented in Section 8 of the paper and Section 5 of the Online Appendix. The series computed are the same as those in section **Data for Calibration**. The countries used in Figure 1/Figure 2 that have labor input files in the EUKlems database (Austria, Australia, Belgium, Denmark, Spain, Germany, Italy, Japan, The Netherlands, United Kingdom, and the United States).

    * **Inputs:**
        * *excel_files/LI_files/'i'_labour_input_08I.xls:* a series of Excel spreadsheets containing the the EUKLEMS labor input file for each country *i* in the analysis.
        * *excel_files/basic_files_09/'i'_output_09I.xls:* a series of Excel spreadsheets containing the the EUKLEMS basic files for each country *i* in the analysis.
        * *excel_files/benchmark_1997.xls:* an excel spreadsheet containing Internationally comparable PPP for value-added (double deflated) for each country for 1997.
    * **Outputs:**
        * *dta_files:* *'i'.dta* a series of *.dta* files containing the time series above mentioned for each country *'i'* in the analysis.
        * *csv_files:* *data_'i'.csv* a series of *.csv* files containing the time series above mentioned for each country *'i'* in the analysis.

### Subfolder: Cross-Country_Model_Fit

* *cross_country_figures.do:* Produces Figures 7 and 8 in Section 5 the Online Appendix. These figures measure the ability of the model to fit the actual series for the skill premium and the share of the high-skill intensive sector in the ten countries mentioned above.

    * **Inputs:**
        * *excel_files/model_fit_crosscountry.xlsx:* and excel spreadsheet containing series of model-simulated and actual data for the countries in the cross-country analysis.

    * **Outputs:**
        * *dta_files/cross_country_model_fit.dta:* a *.dta* file containing the data in Figures 7 and 8 in Section 5 of the Online Appendix.
        * *Figures/figure7.pdf:* & *Figures/figure8.pdf:* Figures 7 and 8 in Section 5 of the Online Appendix.
