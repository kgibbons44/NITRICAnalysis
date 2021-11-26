/**** NITRIC ANALYSIS ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Executable file to run all NITRIC related anlalyses ****/

log using "211117_NITRIC Analysis.txt", text replace

/* Run the do file from REDCap for the screening log */
do "NITRICOXIDEOnBypassS_STATA_2021-11-01_1531.do"
rename redcap_id record_id
replace record_id="" if record_id=="4444" | record_id=="5555" | record_id=="9999"
drop if record_id=="7894-1"
sort record_id
save "NITRIC_Screening", replace

/* Run the do file from REDCap */
do "NITRICOXIDEOnBypassR-AllDataIdentifiableD_STATA_2021-11-01_1707.do"

/* Run the data transformation file */
do "NITRIC Data Transformation.do"

/* Calculate outcomes */
do "NITRIC Outcome Calculations.do"

/* Run the analysis for the CONSORT */
do "NITRIC CONSORT Analysis.do"

/* Run the analysis */
do "NITRIC SAP Analysis.do"

log close
