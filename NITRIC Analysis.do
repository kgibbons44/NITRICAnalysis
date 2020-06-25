/**** NITRIC ANALYSIS ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Executable file to run all NITRIC related anlalyses ****/

log using "200625_NITRIC Analysis.txt", text replace

/* Run the do file from REDCap for the screening log */
do "NITRICOXIDEOnBypassS_STATA_2020-06-15_1316.do"

/* Run the analysis for the CONSORT */
do "NITRIC CONSORT Analysis.do"

/* Run the do file from REDCap */
do "NITRICOXIDEOnBypassR-AllDataIdentifiableD_STATA_2020-06-15_1312_KG.do"

/* Run the data transformation file */
do "NITRIC Data Transformation.do"

/* Calculate PELOD scores */
do "NITRIC Outcome Calculations.do"

/* Run the analysis */
do "NITRIC SAP Analysis.do"

log close
