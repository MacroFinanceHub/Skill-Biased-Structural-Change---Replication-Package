## Table1 - PRELIMINARY; CODE HASN'T BEEN CHECKED OR EDITED
The exercises performed through the files in this folder constitute the analysis described in Table 1 of Section 2.4.  
    
* **Table1regressions.do:** Creates the regression results in Table 1, as well as the results without controls.

    * **Inputs:**
        - *Mapping Instruction.docx:* Instructions for mapping U.S. industrial skill intensity data to U.S. CEX consumption data through the U.S. input-output structure.
        - *CEXtoVAdocumentation.xlsx:* Contains all of the necessary matrices and cross-walks to reproduce the analysis in Section 2.2, including Table 1, as explained in the file *Mapping Instructions.docx*. The explanation of each worksheet is given in the first sheet entitled *ReadMe*.
        - *CEXdemographicdata.dta:* The demographic data by household which is merged with the value-added in the expenditure bundle data in the Stats .do file *Table1regressions.do*.
        - *CombinedVADataforRegressions.dta:* Contains value-added in the CEX consumption bundle of each household in the CEX.  Based on the CEX data from 2012.
        - *MatlabManipulations.m:* Matlab matrix manipulation codes for constructing the matrix *dataforCEXmerge* in *CEXtoVAdcoumentation.xlsx*.
    * **Output:** 
        * *Table1Results.log:* an ASCII log file containing the regression results in Table 1. It calls the data files: *CombinedVADataforRegressions.dta* and *CEXdemographicdata.dta*
