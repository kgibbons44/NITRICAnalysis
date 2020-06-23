/**** NITRIC DATA TRANSFORMATION ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Transformation of NITRIC data for analysis ****/

tostring redcap_repeat_instrument, replace force
replace redcap_repeat_instrument=""

/** Transform the data so it's all on one row **/
describe, fullnames
sort record_id redcap_event_name redcap_repeat_instance
save "OutputData\nitric0.dta", replace
/// Keep event: preoperative_data_arm_1 - initial observations, no repeats
use "OutputData\nitric0.dta", clear
tab redcap_event_name randomisation_complete, m
tab redcap_event_name randomisation_complete
keep if ( redcap_event_name == "preoperative_data_arm_1" & redcap_repeat_instrument=="" )
keep if ( randomisation_complete~=. )
tab redcap_event_name randomisation_complete, m
tab redcap_event_name randomisation_complete
// Keep variables
describe record_id redcap_event_name redcap_data_access_group rand_dt-ages_and_stages_complete, full
keep record_id redcap_event_name redcap_data_access_group rand_dt-ages_and_stages_complete
gen preop_indata=1
sort record_id
save "OutputData\preop0.dta", replace
/// Keep event: acute_data_arm_1 - repeat observations, but keep only the first surgery
use "OutputData\nitric0.dta", clear
tab redcap_event_name presurgical_assessme_v_0, m
tab redcap_event_name presurgical_assessme_v_0
keep if ( redcap_event_name == "acute_data_arm_1" & redcap_repeat_instance==1 )  // EDIT THIS TO "" IF ALL SURGERIES ARE NEEDED
keep if ( presurgical_assessme_v_0~=. )
tab redcap_repeat_instance presurgical_assessme_v_0, m
tab redcap_repeat_instance presurgical_assessme_v_0
// Keep variables
describe record_id redcap_event_name redcap_repeat_instance presurg_syndrome-acute_outcomes_complete, full
keep record_id redcap_event_name redcap_repeat_instance presurg_syndrome-acute_outcomes_complete
// Reshape the data
// COMMENTED OUT FOR NOW AS ONLY KEEPING FIRST SURGERY
/*rename presurg_chdtype___* presurg_chdtype___*_
rename surg_arrythmias___* surg_arrythmias___*_
rename picu_arrythmias___* picu_arrythmias___*_
reshape wide presurg_syndrome-acute_outcomes_complete, i(record_id) j(redcap_repeat_instance)*/
gen acute_indata=1
sort record_id
save "OutputData\acute0.dta", replace
/// Keep event: delirium_for_arm_1 - repeat observations
/*use "OutputData\nitric0.dta", clear
tab redcap_event_name if delirium_complete~=., m
keep if ( redcap_event_name == "delirium_arm_1" & redcap_repeat_instrument~="" )
keep if ( delirium_complete~=. )
tab redcap_repeat_instance if delirium_complete~=., m
// Keep variables
describe record_id redcap_event_name redcap_repeat_instance delirium_day-delirium_complete, full
keep record_id redcap_event_name redcap_repeat_instance delirium_day-delirium_complete
// Reshape the data
reshape wide delirium_day-delirium_complete, i(record_id) j(redcap_repeat_instance)
gen delirum_indata=1
sort record_id
save "OutputData\delirium0.dta", replace*/
/// Keep event: biobanking_arm_1 - initial observations
use "OutputData\nitric0.dta", clear
tab redcap_event_name biobanking_complete, m
tab redcap_event_name biobanking_complete
keep if ( redcap_event_name == "biobanking_arm_1" & redcap_repeat_instrument=="" )
keep if ( biobanking_complete~=. )
tab redcap_event_name biobanking_complete, m
tab redcap_event_name biobanking_complete
// Keep variables
describe record_id redcap_event_name biobank_no_samples_covid19-biobanking_complete, full
keep record_id redcap_event_name biobank_no_samples_covid19-biobanking_complete
gen biobanking_indata=1
sort record_id
save "OutputData\biobanking0.dta", replace
/// Keep event: 12_months_follow_u_arm_1 - 12m follow-up data, no repeats
/*use "OutputData\nitric0.dta", clear
tab redcap_event_name pediatric_cerebral_p_v_2, m
tab redcap_event_name pediatric_cerebral_p_v_2
keep if ( redcap_event_name == "12_months_follow_u_arm_1" & redcap_repeat_instance==. )
keep if ( pediatric_cerebral_p_v_2~=. )
tab redcap_event_name pediatric_cerebral_p_v_2, m
tab redcap_event_name pediatric_cerebral_p_v_2
// Keep variables
describe record_id redcap_event_name redcap_data_access_group popc-followup_12_months_complete, full
keep record_id redcap_event_name redcap_data_access_group popc-followup_12_months_complete
gen fup_indata=1
sort record_id
save "OutputData\fup0.dta", replace*/
/// Keep event: reporting_aes_arm_1 - repeating
use "OutputData\nitric0.dta", clear
tab redcap_event_name ae_sae, m
keep if ( redcap_event_name == "reporting_aes_arm_1" & redcap_repeat_instance~=. )
keep if ( ae_sae~=. )
tab redcap_event_name ae_sae, m
// Keep variables
describe record_id redcap_repeat_instance ae_sae-adverse_events_manag_v_4, full
keep record_id redcap_repeat_instance ae_sae-adverse_events_manag_v_4
// Reshape the data
reshape wide ae_sae-adverse_events_manag_v_4, i(record_id) j(redcap_repeat_instance)
gen ae_indata=1
sort record_id	
save "OutputData\ae0.dta", replace
/// Keep event: reporting_pds_arm_1 - repeating
/*use "OutputData\nitric0.dta", clear
tab redcap_event_name pd_dev1, m
keep if ( redcap_event_name == "reporting_pds_arm_1" & redcap_repeat_instance~=. )
keep if ( pd_dev1~=. )
tab redcap_event_name pd_dev1, m
// Keep variables
describe record_id redcap_repeat_instance pd_dev1-protocol_deviation_m_v_3, full
keep record_id redcap_repeat_instance pd_dev1-protocol_deviation_m_v_3
// Reshape the data
reshape wide pd_dev1-protocol_deviation_m_v_3, i(record_id) j(redcap_repeat_instance)
gen ae_indata=1
sort record_id
save "OutputData\pd0.dta", replace*/
/// Merge all the files together
use "OutputData\preop0.dta", clear
merge 1:1 record_id using "OutputData\acute0.dta"
drop _merge
*merge 1:1 record_id using "OutputData\delirium0.dta"
*drop _merge
merge 1:1 record_id using "OutputData\biobanking0.dta"
drop _merge
*merge 1:1 record_id using "OutputData\fup0.dta"
*drop _merge
merge 1:1 record_id using "OutputData\ae0.dta"
drop _merge
merge 1:1 record_id using "OutputData\pd0.dta"
drop _merge
save "NITRIC.dta", replace

/* Prepare the variables */
// Recode data access group to site
tab redcap_data_access_group, m
rename redcap_data_access_group site
replace site="1" if site=="qch"
replace site="2" if site=="rchm"
replace site="3" if site=="tchw"
replace site="4" if site=="pch"
replace site="5" if site=="star"
replace site="6" if site=="wkz"
replace site="7" if site=="xother"
destring site, replace
label define site 1 "QCH" 2 "RCHM" 3 "Westmead" 4 "Perth" 5 "Starship" 6 "Utrecht" 7 "Other"
label values site site
tab site, m
drop if site==7
tab site, m

// Create country of hospital variable
gen hosp_country=1 if site==1 | site==2 | site==3 | site==4
replace hosp_country=2 if site==5
replace hosp_country=3 if site==6
label define hosp_country 1 "Australia" 2 "New Zealand" 3 "The Netherlands"
label values hosp_country hosp_country

// Reverse the randomisation groups so that standard care is the reference group
gen rand_group=1 if rand_random==2
replace rand_group=2 if rand_random==1
label define rand_group 1 "Standard Care" 2 "Nitric Oxide"
label values rand_group rand_group
tab rand_group rand_group

// Convert age (days) to age (weeks)
gen rand_age_weeks=rand_age_days/7

// Collapse ethnicity variable
gen dem_ethnicity_gr=dem_ethnicity
replace dem_ethnicity_gr=7 if dem_ethnicity==3 | dem_ethnicity==6
label values dem_ethnicity_gr dem_ethnicity_

// Calculate duration of PICU stay prior to surgery
gen adm_to_surg=hours(perfusion_cpb1_start-presurg_picu_dt)/24

// Calculate duration of mechanical ventliation prior to surgery
gen mv_to_surg=hours(perfusion_cpb1_start-presurg_vent_dt) if presurg_vent==1

// Determine if any blood prime was used
gen perfusion_prime_any=0
foreach i of numlist 1/5 {
	replace perfusion_prime_any=1 if perfusion_prime___`i'==1
}

// Categorise duration of CPB
gen perfusion_cpb_total_gr=1 if perfusion_cpb_total<60 & ~missing(perfusion_cpb_total)
replace perfusion_cpb_total_gr=2 if perfusion_cpb_total>=60 & ~missing(perfusion_cpb_total)
label define perfusion_cpb_total_gr 1 "CPB<60min" 2 "CPB>=60min"
label values perfusion_cpb_total_gr perfusion_cpb_total_gr

// Use of cross-clamp
gen perfusion_xclamp_ny=1 if perfusion_xclamp_runs==0
replace perfusion_xclamp_ny=0 if perfusion_xclamp_runs>0 & ~missing(perfusion_xclamp_runs)

// Convert blood products used in theatre from mL to mL/kg
gen perfusion_wb_kg=perfusion_wb/dem_weight if perfusion_wb>0  // red blood cells
gen perfusion_plt_kg=perfusion_plt/dem_weight if perfusion_plt>0  // platelets
gen perfusion_ffp_kg=perfusion_ffp/dem_weight if perfusion_ffp>0  // fresh frozen plasma
gen perfusion_cryo_kg=perfusion_cryo/dem_weight if perfusion_cryo>0  // cryoprecipitate

// Calculate time from randomisation to the start of NO
gen rand_to_no=hours(perfusion_run1_start-rand_dt)

// Calculate time from start of CPB to start of NO
gen cpb_to_no=hours(perfusion_run1_start-perfusion_cpb1_start)

// Calculate duration of NO on CPB
gen perfusion_runs_total=0
foreach i of numlist 1/4 {
	replace perfusion_runs_total=perfusion_runs_total+hours(perfusion_run`i'_stop-perfusion_run`i'_start) if ~missing(perfusion_run`i'_stop) & ~missing(perfusion_run`i'_start)
}
replace perfusion_runs_total=. if perfusion_runs==0
replace perfusion_runs_total=perfusion_runs_total*60 // convert to minutes

// Calculate proportion of time spent on CPB with NO
gen prop_cpb_no=perfusion_runs_total/perfusion_cpb_total

// Calculate change in methaemoglobin level before and after CPB
gen meth_change=perfusion_methb_post-perfusion_methb_pre
