/**** NITRIC ANALYSIS ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Executable file to run all NITRIC related anlalyses ****/

log using "210621_NITRIC Analysis.txt", text replace

/* Run the do file from REDCap for the screening log */
do "NITRICOXIDEOnBypassS-AllDataIdentifiableA_STATA_2021-06-21_0652.do"
rename redcap_id record_id
sort record_id
save "NITRIC_Screening", replace

/* Run the do file from REDCap */
do "NITRICOXIDEOnBypassR-AllDataIdentifiableD_STATA_2021-06-21_0653.do"

/* Run the data transformation file */
do "NITRIC Data Transformation.do"

/* Calculate outcomes */
do "NITRIC Outcome Calculations.do"

/* Run the analysis for the CONSORT */
do "NITRIC CONSORT Analysis.do"

/* Run the analysis */
do "NITRIC SAP Analysis.do"

log close
