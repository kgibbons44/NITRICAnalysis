/**** NITRIC DATA TRANSFORMATION ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Transformation of NITRIC data for analysis ****/

tostring redcap_repeat_instrument, replace force
replace redcap_repeat_instrument=""
drop if record_id=="7894-1"

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
foreach v of varlist presurg_syndrome presurg_syndrome_list presurg_syndrome_group___1-presurg_chdtype___88 presurg_chdtype_group___1-presurgical_assessme_v_0 {
	replace `v'=. if ~missing(`v')
}
tab redcap_event_name randomisation_complete, m
tab redcap_event_name randomisation_complete
// Keep variables
describe record_id redcap_event_name redcap_data_access_group rand_dt-presurgical_assessme_v_0, full
keep record_id redcap_event_name redcap_data_access_group rand_dt-presurgical_assessme_v_0
gen preop_indata=1
sort record_id
save "OutputData\preop0.dta", replace
/// Keep event: acute_sdv_arm_1 - SDV randomisation data, no repeats
use "OutputData\nitric0.dta", clear
tab redcap_event_name sdv_site_complete, m
tab redcap_event_name sdv_site_complete
keep if ( redcap_event_name == "acute_sdv_arm_1" & redcap_repeat_instrument=="" )
keep if ( sdv_site_complete~=. )
tab redcap_event_name sdv_site_complete, m
tab redcap_event_name sdv_site_complete
// Keep variables
describe record_id redcap_event_name redcap_data_access_group sdv_pt_status-sdv_site_complete, full
keep record_id redcap_event_name redcap_data_access_group sdv_pt_status-sdv_site_complete
gen sdv_indata=1
sort record_id
save "OutputData\sdv0.dta", replace
/// Keep event: acute_data_arm_1 - repeat observations, but keep only the first surgery
use "OutputData\nitric0.dta", clear
tab redcap_event_name presurgical_assessme_v_0, m
tab redcap_event_name presurgical_assessme_v_0
keep if ( redcap_event_name == "acute_data_arm_1" & redcap_repeat_instance==1 )
keep if ( presurgical_assessme_v_0~=. )
tab redcap_repeat_instance presurgical_assessme_v_0, m
tab redcap_repeat_instance presurgical_assessme_v_0
// Keep variables
describe record_id redcap_event_name redcap_repeat_instance presurg_syndrome-acute_outcomes_complete perfusion_pd_dt-perfusion_pd_outcome, full
keep record_id redcap_event_name redcap_repeat_instance presurg_syndrome-acute_outcomes_complete perfusion_pd_dt-perfusion_pd_outcome
gen acute_indata=1
sort record_id
save "OutputData\acute0.dta", replace
/// Keep event: reporting_aes_arm_1 - repeating
use "OutputData\nitric0.dta", clear
tab redcap_event_name ae_sae, m
keep if ( redcap_event_name == "reporting_aes_arm_1" & redcap_repeat_instance~=. )
keep if ( ae_sae~=. )
tab redcap_event_name ae_sae, m
// Keep variables
describe record_id redcap_repeat_instance ae_sae-adverse_events_manag_v_4, full
keep record_id redcap_repeat_instance ae_sae-adverse_events_manag_v_4
// Save a version in long format
preserve
sort record_id
save "OutputData\ae_long0.dta", replace
restore
// Reshape the data
reshape wide ae_sae-adverse_events_manag_v_4, i(record_id) j(redcap_repeat_instance)
gen ae_indata=1
sort record_id	
save "OutputData\ae0.dta", replace
/// Keep event: reporting_pds_arm_1 - repeating
use "OutputData\nitric0.dta", clear
tab redcap_event_name pd_dev1, m
keep if ( redcap_event_name == "reporting_pds_arm_1" & redcap_repeat_instance~=. )
keep if ( pd_dev1~=. )
tab redcap_event_name pd_dev1, m
// Keep variables
describe record_id redcap_repeat_instance pd_dev1-protocol_deviation_m_v_3, full
keep record_id redcap_repeat_instance pd_dev1-protocol_deviation_m_v_3
// Save a version in long format
preserve
sort record_id
save "OutputData\pd_long0.dta", replace
restore
// Reshape the data
reshape wide pd_dev1-protocol_deviation_m_v_3, i(record_id) j(redcap_repeat_instance)
gen ae_indata=1
sort record_id
save "OutputData\pd0.dta", replace
/// Merge all the files together
use "OutputData\preop0.dta", clear
merge 1:1 record_id using "OutputData\sdv0.dta", update
drop _merge
merge 1:1 record_id using "OutputData\acute0.dta", update
drop _merge
merge 1:1 record_id using "OutputData\ae0.dta", update
drop _merge
merge 1:1 record_id using "OutputData\pd0.dta", update
drop _merge
save "NITRIC.dta", replace

/* Merge on the data from the screening file */
sort record_id
merge m:m record_id using "NITRIC_Screening"
// Clean the data
duplicates report record_id
duplicates tag record_id, gen(dupls)
sort record_id screening_dt
bysort record_id: gen x=_n
drop if x==2
duplicates report record_id

/* Prepare the variables */

// Set values of 4444, 5555, 9999 to missing for relevant variables 
mvdecode *_lactate* picu_mbp_* picu_gcs_* *_creatinine* picu_pao2_* picu_bga_fio2_* picu_paco2_* ///
		 picu_wcc_* picu_platelets_* rand_age_days dem_weight surg_rachs ///
		 perfusion_cpb_total perfusion_xclamp_total perfusion_cool_time perfusion_rbc ///
		 perfusion_wb perfusion_plt perfusion_ffp perfusion_cryo picu_avsatdiff* ///
		 picu_vis* picu_troponin*, mv(9999=.\ 4444=.\ 5555=.)

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
tab rand_group rand_group
label define rand_group 1 "Standard Care" 2 "Nitric Oxide"
label values rand_group rand_group
// Add in the manual allocations
replace rand_group=1 if rand_manual_allocation==2
replace rand_group=2 if rand_manual_allocation==1

// Convert age (days) to age (weeks)
gen rand_age_weeks=rand_age_days/7

// Collapse ethnicity variable
gen dem_ethnicity_gr=dem_ethnicity
replace dem_ethnicity_gr=7 if dem_ethnicity==3 | dem_ethnicity==6
label values dem_ethnicity_gr dem_ethnicity_

// Collapse syndromes
replace presurg_syndrome_group___1=1 if presurg_syndrome_list==1
replace presurg_syndrome_group___2=1 if presurg_syndrome_list==2
replace presurg_syndrome_group___3=1 if presurg_syndrome_list==3
gen presurg_syndrome_other_gr=0
foreach v of varlist presurg_syndrome_group___4 presurg_syndrome_group___8 presurg_syndrome_group___9 presurg_syndrome_group___10 presurg_syndrome_group___11 presurg_syndrome_group___12 presurg_syndrome_group___13 presurg_syndrome_group___14 presurg_syndrome_group___15 presurg_syndrome_group___16 presurg_syndrome_group___17 presurg_syndrome_group___18 presurg_syndrome_group___19 presurg_syndrome_group___20 presurg_syndrome_group___88 {
	replace presurg_syndrome_other_gr=1 if `v'==1
}

// Determine how far prior to the PICU admission randomisation occurred
gen rand_to_post_picuadm=hours(picu_adm-rand_dt)
hist rand_to_post_picuadm
tabstat rand_to_post_picuadm, stats(n mean sd min max q iqr)

// Collapse CHD type
replace presurg_chdtype_group___16=1 if presurg_chdtype___1
replace presurg_chdtype_group___20=1 if presurg_chdtype___2
replace presurg_chdtype_group___1=1 if presurg_chdtype___3
replace presurg_chdtype_group___2=1 if presurg_chdtype___4
replace presurg_chdtype_group___7=1 if presurg_chdtype___5
replace presurg_chdtype_group___9=1 if presurg_chdtype___6 | presurg_chdtype_group___29 | presurg_chdtype_group___23 | presurg_chdtype_group___25 | presurg_chdtype_group___27
replace presurg_chdtype_group___6=1 if presurg_chdtype___7 | presurg_chdtype_group___31
replace presurg_chdtype_group___9=1 if presurg_chdtype___8
replace presurg_chdtype_group___18=1 if presurg_chdtype___9
replace presurg_chdtype_group___12=1 if presurg_chdtype___10
replace presurg_chdtype_group___12=1 if presurg_chdtype___11
replace presurg_chdtype_group___17=1 if presurg_chdtype___12 | presurg_chdtype_group___26
replace presurg_chdtype_group___14=1 if presurg_chdtype___13 | presurg_chdtype_group___29 | presurg_chdtype_group___21 | presurg_chdtype_group___30
replace presurg_chdtype_group___13=1 if presurg_chdtype___14 | presurg_chdtype_group___22 | presurg_chdtype_group___28
replace presurg_chdtype_group___15=1 if presurg_chdtype___15
replace presurg_chdtype_group___3=1 if presurg_chdtype_group___24

* Right-sided obstructive lesions
gen presurg_chdgroup_rightside=1 if presurg_chdtype_group___16==1 | presurg_chdtype_group___5==1 | presurg_chdtype_group___12 | ///
									presurg_chdtype_group___18 | presurg_chdtype_group___13
* Left-sided obstructive lesions
gen presurg_chdgroup_leftside=1 if  presurg_chdtype_group___3==1 | presurg_chdtype_group___8==1 | presurg_chdtype_group___7==1 | ///
									presurg_chdtype_group___6==1 | presurg_chdtype_group___9==1
* Shunt lesions
gen presurg_chdgroup_shunt=1 if		presurg_chdtype_group___1==1 | presurg_chdtype_group___20==1 | presurg_chdtype_group___2==1 | ///
									presurg_chdtype_group___19==1 | presurg_chdtype_group___17==1 | presurg_chdtype_group___11 | ///
									presurg_chdtype_group___14==1
* Various lesions
gen presurg_chdgroup_various=1 if 	presurg_chdtype_group___4==1 | presurg_chdtype_group___15==1 | presurg_chdtype_group___10==1
									

// Collapse surgical procedures
* Tetralogy repair 
gen surg_proc_tetralogy=1 if surg_procedure___1919==1 | surg_procedure___1945==1 | surg_procedure___1949==1 | ///
							 surg_procedure___1973==1

* Norwood procedure 
gen surg_proc_norwood=1 if surg_procedure___1977==1 | surg_procedure___1978==1 | surg_procedure___1979==1

* Bicavopulmonary shunt 
gen surg_proc_bicav_shunt=1 if surg_procedure___1921==1 | surg_procedure___1951==1

* Right ventricular to pulmonary artery shunt/conduit 
gen surg_proc_right_pulm_shunt=1 if surg_procedure___1943==1

* Fontan completion  
gen surg_proc_fontan=1 if surg_procedure___1946==1 | surg_procedure___1986==1 | surg_procedure___1987==1

* Arterial switch operation 
gen surg_proc_art_switch=1 if surg_procedure___1952==1 | surg_procedure___1953==1 | surg_procedure___1963==1 | ///
							  surg_procedure___1964==1 | surg_procedure___1965==1 | surg_procedure___1966==1 | ///
							  surg_procedure___1967==1 | surg_procedure___1968==1 | surg_procedure___1974==1 

* ASD repair 
gen surg_proc_asd_repair=1  if surg_procedure___1901==1 | surg_procedure___1914==1 | surg_procedure___1927==1 | ///
							   surg_procedure___1928==1
							   
* VSD repair 
gen surg_proc_vsd_repair=1  if surg_procedure___1913==1 | surg_procedure___1915==1 | surg_procedure___1916==1 | ///
							   surg_procedure___1917==1 | surg_procedure___1918==1
							   
* AVSD repair 
gen surg_proc_asvd_repair=1 if surg_procedure___1947==1

* Aortic arch repair 
gen surg_proc_aortic_arch_repair=1 if surg_procedure___1933==1 | surg_procedure___1970==1 | surg_procedure___1971==1 | ///
									  surg_procedure___1972==1

* Coarctation repair 
gen surg_proc_coarc_repair=1 if surg_procedure___1904==1 | surg_procedure___1924==1 | surg_procedure___1956==1

* Truncus repair 
gen surg_proc_truncus=1 if surg_procedure___1969==1 | surg_procedure___1976==1

* Pulmonary artery band
gen surg_proc_pulm_art_band=1 if surg_procedure___1948==1

* Ross procedure 
gen surg_proc_pulm_ross=1 if surg_procedure___1930==1

* Left ventricular outflow tract surgery 
gen surg_proc_left_vent_outflow=1 if surg_procedure___1907==1 | surg_procedure___1931==1 | surg_procedure___1932==1 | ///
									 surg_procedure___1959==1
									  
* Right ventricular outflow tract surgery 
gen surg_proc_right_vent_outflow=1 if surg_procedure___1910==1 | surg_procedure___1911==1 | surg_procedure___1925==1

* Valve surgery 
gen surg_proc_valve=1 if surg_procedure___1906==1 | surg_procedure___1909==1 | surg_procedure___1935==1 | ///
						 surg_procedure___1936==1 | surg_procedure___1937==1 | surg_procedure___1938==1 | ///
						 surg_procedure___1939==1 | surg_procedure___1942==1 | surg_procedure___1955==1 | ///
						 surg_procedure___1958==1 | surg_procedure___1975==1

* Valve repair
gen surg_proc_valve_repair=1 if surg_procedure___1929==1 | surg_procedure___1934==1
						 
* Anomalous pulmonary vein repair 
gen surg_proc_anom_pulm_vein=1 if surg_procedure___1905==1 | surg_procedure___1920==1 | surg_procedure___1961==1 | ///
								  surg_procedure___1991==1

* Heart Transplant 
gen surg_proc_heart_trans=1 if surg_procedure___1994==1 | surg_procedure___1995==1

* Other 
gen surg_proc_other=1 if surg_procedure___1902==1 | surg_procedure___1908==1 | surg_procedure___1912==1 | ///
						 surg_procedure___1923==1 | surg_procedure___1926==1 | surg_procedure___1940==1 | ///
						 surg_procedure___1941==1 | surg_procedure___1944==1 | surg_procedure___1950==1 | ///
						 surg_procedure___1954==1 | surg_procedure___1957==1 | surg_procedure___1960==1 | ///
						 surg_procedure___1997==1 | surg_procedure___1999==1

// Replace missing RACHS score
replace surg_rachs=2 if record_id=="5982-143"
						 
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
gen perfusion_xclamp_yn=0 if perfusion_xclamp_runs==0
replace perfusion_xclamp_yn=1 if perfusion_xclamp_runs>0 & ~missing(perfusion_xclamp_runs)

// Calculate yes/no variables for the blood products used in theatre and convert from mL to mL/kg
foreach v of varlist perfusion_rbc perfusion_wb perfusion_plt perfusion_ffp perfusion_cryo {
	gen `v'_yn=1 if `v'>0 & ~missing(`v')
	replace `v'_yn=0 if `v'==0
	gen `v'_kg=`v'/dem_weight
}

// Calculate time from randomisation to the start of NO
gen rand_to_no=hours(perfusion_run1_start-rand_dt)

// Calculate time from start of CPB to start of NO
gen cpb_to_no=hours(perfusion_cpb1_start-perfusion_run1_start)*60

// Calculate duration of NO on CPB
gen perfusion_runs_total=0
foreach i of numlist 1/4 {
	replace perfusion_runs_total=perfusion_runs_total+hours(perfusion_run`i'_stop-perfusion_run`i'_start) if ~missing(perfusion_run`i'_stop) & ~missing(perfusion_run`i'_start)
}
replace perfusion_runs_total=. if perfusion_runs==0
replace perfusion_runs_total=perfusion_runs_total*60 // convert to minutes
replace perfusion_runs_total=perfusion_cpb_total if perfusion_runs_total==. & rand_group==2

// Calculate proportion of time spent on CPB with NO
gen cpb_nitric_mins=0
foreach i of numlist 1/4 {
	
	* Replace NO times with CPB times if missing as incorrect data entry
	replace perfusion_run`i'_start=perfusion_cpb`i'_start if missing(perfusion_run`i'_start)
	replace perfusion_run`i'_stop=perfusion_cpb`i'_stop if missing(perfusion_run`i'_stop)
	
	* Duration of CPB
	gen cpb_mins`i'=hours(perfusion_cpb`i'_stop-perfusion_cpb`i'_start)*60 if ~missing(perfusion_cpb`i'_stop) & ~missing(perfusion_cpb`i'_start)
	
	* NO started before CPB and ended after CPB
	gen cpb_mins_nitric`i'=cpb_mins`i' if perfusion_run`i'_start<=perfusion_cpb`i'_start & perfusion_run`i'_stop>=perfusion_cpb`i'_stop & ~missing(perfusion_cpb`i'_stop) & ~missing(perfusion_cpb`i'_start) & ~missing(perfusion_run`i'_stop) & ~missing(perfusion_run`i'_start)
	
	* NO started after CPB, NO finished after CPB
	replace cpb_mins_nitric`i'=hours(perfusion_cpb`i'_stop-perfusion_run`i'_start)*60 if perfusion_run`i'_start>perfusion_cpb`i'_start & perfusion_run`i'_stop>=perfusion_cpb`i'_stop & ~missing(perfusion_cpb`i'_stop) & ~missing(perfusion_run`i'_start) & missing(cpb_mins_nitric`i')
	
	* NO stopped before end of CPB, NO started before CPB
	replace cpb_mins_nitric`i'=hours(perfusion_run`i'_stop-perfusion_cpb`i'_start)*60 if perfusion_run`i'_stop<perfusion_cpb`i'_stop & perfusion_run`i'_start<=perfusion_cpb`i'_start & ~missing(perfusion_cpb`i'_stop) & ~missing(perfusion_run`i'_start) & missing(cpb_mins_nitric`i')
	
	* NO started after CPB and ended before CPB
	replace cpb_mins_nitric`i'=hours(perfusion_run`i'_stop-perfusion_run`i'_start)*60 if perfusion_run`i'_stop<perfusion_cpb`i'_stop & perfusion_run`i'_start>perfusion_cpb`i'_start & ~missing(perfusion_cpb`i'_stop) & ~missing(perfusion_run`i'_start) & missing(cpb_mins_nitric`i')
	
	* Update the total
	replace cpb_nitric_mins=cpb_nitric_mins+cpb_mins_nitric`i' if ~missing(cpb_mins_nitric`i')
	
}
gen prop_cpb_no=cpb_nitric_mins/perfusion_cpb_total
replace prop_cpb_no=217/219 if record_id=="5980-362" // manually calculated given anomalies in surgery

// Calculate change in methaemoglobin level before and after CPB
gen meth_change=perfusion_methb_post-perfusion_methb_pre
gen meth_change_3=1 if meth_change>3 & ~missing(meth_change)
replace meth_change_3=0 if meth_change<=3 & ~missing(meth_change)

// Determine if any AEs occurred for a patient
gen ae_any=0
foreach v of varlist ae_sae* {
	replace ae_any=1 if `v'==1
}

// Determine if any AE that was possibly, probably or definitively related occurred for a patient
gen ae_related_any=0
foreach v of varlist ae_druga* {
	replace ae_any=1 if `v'==3 | `v'==4 | `v'==5 
}

save "NITRIC.dta", replace

// Prepare adverse event data for listing
keep record_id rand_group
sort record_id
save "NITRIC_Rand", replace
use "OutputData\ae_long0.dta", clear
merge m:m record_id using "NITRIC_Rand"
tab _merge
keep if _merge==3
drop _merge
gen ae_term_gr=floor(ae_term/100)
replace ae_term_gr=7 if ae_term_gr==70
label define ae_term_gr 1 "Blood/lymphatic system" 2 "Cardiac" 3 "Congenital/familial/genetic" 4 "Ear/labryinth" 5 "Endocrine" 6 "Eye" 7 "GI" 8 "General/administration site" 9 "Hepatobiliary" 10 "Immune system" 11 "Infection/infestation" 12 "Injury/poison" 13 "Investigations" 14 "Metabolism/nutrition" 15 "Musculoskeletal/connective" 16 "Neoplasms" 17 "Nervous system" 18 "Pregnancy" 19 "Psychiatric" 20 "Renal/urinary" 21 "Reproductive system/breast" 22 "Respiratory/thoracic/mediastinal" 23 "Skin/subcutaneous tissue" 24 "Social circumstances" 25 "Surgical/medical procedures" 26 "Vascular"
label values ae_term_gr ae_term_gr
save "OutputData\ae_long0.dta", replace

// Prepare protocol deviations data for listing
keep record_id rand_group
sort record_id
save "NITRIC_Rand", replace
use "OutputData\pd_long0.dta", clear
merge m:m record_id using "NITRIC_Rand"
tab _merge
keep if pd_dev1==1
save "OutputData\pd_long0.dta", replace

use "NITRIC", clear