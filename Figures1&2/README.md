## Figures1&2
This folder contains the files needed to produce Figure 1 in section 2.3 and Figure 2 in section 2.4 of the paper. Each subfolder contains the corresponding *.do* file needed to produce the figure. They take as inputs files contained in the folders called *excel_files* and/or *dta_files*.

### Subfolder: Figure 1

* **Figure1.do:** produces Figure 1 in Section 2.3. It also produces the two alternative versions of Figure 1 in the Online Appendix under two broader definitions of the high-skill sector. Additionally, this routine computes the regressions in the figure and their corresponding $R^{2}$s with and without country-specific fixed effects.

    * **Inputs:** 
        * *excel excel_files/basic_files_09/'i'_output_09I.xls* -> one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
        * *dta_files/pwt90.dta* -> the Penn World Table, version 9.0.
    * **Output:**
        * *Figure1/figure1.dta:* a file containing the data in Figure 1.
        * *Figure1/Figures/figure1_benchmark.pdf:* Figure 1 in the paper.  


### Subfolder: Figure 2

* **chain_price_indice.do:**  produces the Chain Price Indices for the High- and Low-Skill Sector and a Relative Price Index for the 15 countries in Figure 2.
    * **Inputs:** 
        * *excel excel_files/basic_files_09/'i'_output_09I.xls* one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
    * **Output:**
        * *dta_files/Prices/HS_Sector_Benchmark/P_indices_combined.dta:* a *.dta* file containing time series of the chain-weighted price indices for the countries in Figure 2.

* **Figure2.do:** produces Figure 2 in Section 2.4. It also produces the two alternative versions of Figure 2 in the Online Appendix under two broader definitions of the high-skill sector. Additionally, this routine computes the regressions in the figure and their corresponding $R^{2}$s with and without country-specific fixed effects.

    * **Inputs:**
        * *dta_files/Prices/HS_Sector_Benchmark/P_indices_combined.dta:* a *.dta* file containing time series of the chain-weighted price indices for the countries in Figure 2. 

        * *excel_files/basic_files_09/'i'_output_09I.xls* -> one excel spredsheet per country *'i'* containing the basic files in the EUKlems database, November 2009 release, revised in June 2010.
        * *dta_files/pwt90.dta* -> the Penn World Table, version 9.0.
    * **Output:**
        * *dta_files/figure2.dta:* a file containing the data in Figure 2.
        * *Figure2/Figures/figure2_benchmark.pdf:* Figure 2 in the paper.  
