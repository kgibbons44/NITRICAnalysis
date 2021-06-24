/**** NITRIC OUTCOME CALCULATIONS ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Calculation of NITRIC outcomes ****/

/* Calculate variables used in outcome calculations */

// Define the 48 hour post-CPB start date and time
gen post48hrsurg_dt=perfusion_cpb1_start+48*60*60*1000
format post48hrsurg_dt %tc
	
// Define the 28 day post-CPB start date and time
gen post28daysurg_dt=perfusion_cpb1_start+28*24*60*60*1000
format post28daysurg_dt %tc

// Define the 24 hour post-PICU admission date and time
gen post24hrpicu_dt=picu_adm+24*60*60*1000
format post24hrpicu_dt %tc

// Define the 48 hour post-PICU admission date and time
gen post48hrpicu_dt=picu_adm+48*60*60*1000
format post48hrpicu_dt %tc

// Define the 24 hour post-PICU admission date and time
gen post28daypicu_dt=picu_adm+28*24*60*60*1000
format post28daypicu_dt %tc

/* Calculate the primary outcome variable: ventilator-free days from start of CPB */

tab mment_vent, m
tab mment_vent_events, m

// Initial ventilation period between start of bypass and first extubation
gen mment_vent_dur_initial=hours(mment_extub-perfusion_cpb1_start)/24 if mment_vent==1
replace mment_vent_dur_initial=0 if mment_vent==0 // not ventilated on arrival to PICU

* If ventilation lasts longer than the 28 days post-CPB start then set to 28 days
replace mment_vent_dur_initial=28 if mment_extub>post28daysurg_dt & ~missing(mment_extub)

// Set as the initial value
gen mment_vent_dur=mment_vent_dur_initial if ~missing(mment_vent_dur_initial)

// Add on each of the subsequent ventilator episodes
foreach i of numlist 1/5 {
	
	// Calculate difference between start and stop times of ventilator episode
	gen mment_vent_dur`i'=hours(mment_vent_stop`i'-mment_vent_start`i')/24 if ~missing(mment_vent_stop`i') & ~missing(mment_vent_start`i')
	count if ( (rand_dt>mment_vent_start`i') | (rand_dt>mment_vent_stop`i') )& ~missing(mment_vent_dur`i')
	
	// Calculate the duration of ventilation (hours) if less than 28 days post-randomisation and add to current total
	replace mment_vent_dur`i'=0 if mment_vent_start`i'>post28daysurg_dt & ~missing(mment_vent_start`i') & ~missing(post28daysurg_dt)
	replace mment_vent_dur`i'=hours(post28daysurg_dt-mment_vent_start`i')/24 if mment_vent_start`i'<post28daysurg_dt & mment_vent_stop`i'>=post28daysurg_dt & ~missing(post28daysurg_dt) & ~missing(mment_vent_stop`i') & ~missing(mment_vent_start`i')
	replace mment_vent_dur=mment_vent_dur+mment_vent_dur`i' if ~missing(mment_vent_dur`i')
	
}

// Assign the total amount of ventilation to the secondary outcome variable
gen vent_dur=mment_vent_dur

// If the patient dies within the 28 days post-CPB start set the duration of invasive respiratory support to maximum
gen death_28day=1 if outcome_death<post28daysurg_dt & outcome_death>=perfusion_cpb1_start & ~missing(outcome_death) & ~missing(post28daysurg_dt)
replace death_28day=0 if ( outcome_death>=post28daysurg_dt & ~missing(outcome_death) & ~missing(post28daysurg_dt) ) | outcome_status30==1
replace mment_vent_dur=28 if death_28day==1

// If no ventilator time recorded, use the extubation time in surgery
replace mment_vent_dur=hours(surg_extub_dt-perfusion_cpb1_start) if ~missing(surg_extub_dt) & mment_vent_dur==0

// If no ventilator time recorded and no extubation time in surgery, use the total time on bypass
replace mment_vent_dur=perfusion_cpb_total/60/24 if ~missing(perfusion_cpb_total) & mment_vent_dur==0

// Translate to ventilator free days
gen vfd=28-mment_vent_dur if ~missing(mment_vent_dur)

/* Calculate the secondary outcomes */

// Extracorporeal life support (ECLS)
* Definition: ECLS started within the first 48 hours post-CPB start
gen ecls_48hr=1 if ( ~missing(mment_ecls_start1) & mment_ecls_start1<post48hrsurg_dt & mment_ecls_start1>=perfusion_cpb1_start ) | ///
				   ( ~missing(mment_ecls_start2) & mment_ecls_start2<post48hrsurg_dt & mment_ecls_start2>=perfusion_cpb1_start ) | ///
				   ( ~missing(mment_ecls_start3) & mment_ecls_start3<post48hrsurg_dt & mment_ecls_start3>=perfusion_cpb1_start ) | ///
				   ~missing(post48hrsurg_dt)
egen ecls_minstart=rowmin(mment_ecls_start1 mment_ecls_start2 mment_ecls_start3)
format ecls_minstart %tc
replace ecls_48hr=0 if mment_ecls==0 | ecls_minstart>=post48hrsurg_dt

// Composite outcome
* Definition: any of LCOS within 48 hours, ECLS within 48 hours, death within 28 days post-CPB start
gen comp_outcome=1 if picu_lcos_any==1 | ecls_48hr==1 | death_28day==1
replace comp_outcome=0 if picu_lcos_any==0 & ecls_48hr==0 & death_28day==0

// Duration of time (hours) with chest open post-operatively
* Definition: duration of time with chest open from PICU admission post-surgery, censored at 28 days
* Including time spent with open chest in cases of emergency secondary reopening
gen dur_chestopen=0 if mment_chestclose==0 & mment_chestopen==0
replace dur_chestopen=hours(mment_chestclosure_dt-picu_adm) if ~missing(mment_chestclosure_dt) & ~missing(picu_adm)
replace dur_chestopen=dur_chestopen+hours(mment_chestopen_dt_close-mment_chestopen_dt) if mment_chestopen==1 & mment_chestopen_dt_close<post28daysurg_dt & ~missing(mment_chestopen_dt_close) & ~missing(mment_chestopen_dt)
replace dur_chestopen=dur_chestopen+hours(post28daysurg_dt-mment_chestopen_dt) if mment_chestopen==1 & mment_chestopen_dt_close>=post28daysurg_dt & ~missing(mment_chestopen_dt_close) & ~missing(mment_chestopen_dt)

// Length of stay: PICU
* Definition: length of stay from PICU admission post-surgery to PICU discharge, censored at 28 days
gen los_picu=hours(outcome_picu_dc-picu_adm)/24 if ~missing(outcome_picu_dc) & ~missing(picu_adm)
foreach i of numlist 1/3 {
	replace los_picu=los_picu+hours(outcome_picu_readmit_dc`i'-outcome_picu_readmit_adm`i')/24 ///
					 if ~missing(outcome_picu_readmit_dc`i') & ~missing(outcome_picu_readmit_adm`i') & ///
					 outcome_picu_readmit_dc`i'<post28daypicu_dt
	replace los_picu=los_picu+hours(post28daypicu_dt-outcome_picu_readmit_adm`i')/24 ///
					 if ~missing(outcome_picu_readmit_dc`i') & ~missing(outcome_picu_readmit_adm`i') & ///
					 outcome_picu_readmit_dc`i'>=post28daypicu_dt
}
replace los_picu=28 if los_picu>28 & ~missing(outcome_picu_dc) & ~missing(picu_adm)
gen los_picu_event=1 if los_picu<28 // censoring variable
replace los_picu_event=0 if los_picu==28

// Length of stay: hospital
* Definition: from PICU admission post-surgery to hospital discharge, censored at 28 days
gen los_hosp=hours(outcome_hospdc_date-picu_adm)/24 if ~missing(outcome_hospdc_date) & ~missing(picu_adm)
replace los_hosp=28 if los_hosp>28 & ~missing(outcome_hospdc_date) & ~missing(picu_adm)
gen los_hosp_event=1 if los_hosp<28 // censoring variable
replace los_hosp_event=0 if los_hosp==28

// Duration of inhaled nitric oxide
destring mment_vent_nohrs, replace force
replace mment_vent_nohrs=. if mment_vent_no==0

// Renal replacement therapy
* Definition: any use of peritoneal dialysis or continuous renal replacement therapy from PICU admission post-surgery, censored at 28 days
foreach i of numlist 1/3 {
	tab mment_rrt___`i' rand_group, m col chi exact
	tab mment_rrt___`i' rand_group, col chi exact
}
gen mment_rrt_pd_crrt=1 if mment_rrt___1==1 | mment_rrt___2==1
replace mment_rrt_pd_crrt=0 if mment_rrt___3==1 | mment_rrt___4==1

// Duration of treatment with renal replacement therapy
* Definition: from PICU admission post-surgery to 28 days post-PICU admission
gen mment_vent_rrthrs=0 if mment_rrt_pd_crrt==1
replace mment_vent_rrthrs=mment_vent_rrthrs+hours(mment_rrt_pd_stop-mment_rrt_pd_start) if ~missing(mment_rrt_pd_stop) & ~missing(mment_rrt_pd_start)
replace mment_vent_rrthrs=mment_vent_rrthrs+hours(mment_rrt_cvvh_stop-mment_rrt_cvvh_start) if ~missing(mment_rrt_cvvh_stop) & ~missing(mment_rrt_cvvh_start)
replace mment_vent_rrthrs=. if mment_rrt_pd_crrt==0

// PELOD-2
* Definition: PELOD-2 score calculated at PICU admission, 24 hours and 48 hours post-PICU admission
 
* Calculate if the start/stop time of any of the mechanical ventilation episodes are at 24 hours and 48 hours
gen mment_vent24=0
gen mment_vent48=0
foreach i of numlist 1/5 {
	
	replace mment_vent24=1 if ( (mment_vent_start`i'<post24hrpicu_dt) & (mment_vent_stop`i'>post24hrpicu_dt) )& ~missing(mment_vent_start`i') & ~missing(mment_vent_stop`i')	
	replace mment_vent48=1 if ( (mment_vent_start`i'<post48hrpicu_dt) & (mment_vent_stop`i'>post48hrpicu_dt) )& ~missing(mment_vent_start`i') & ~missing(mment_vent_stop`i')
			
}
rename mment_vent mment_vent0

* Calculate the PELOD-2 score at each timepoint
foreach i of numlist 0(24)48 {

	// Generate points for glasgow coma scale - assign a value of 0 where no value
	gen picu_gcs_p`i'=0
	replace picu_gcs_p`i'=1 if (picu_gcs_`i'>=5 & picu_gcs_`i'<11 & picu_gcs_`i'~=.)
	replace picu_gcs_p`i'=4 if picu_gcs_`i'>=3 & picu_gcs_`i'<5 & picu_gcs_`i'~=.

	// Generate points for pupils - assign a value of 0 where no value
	gen picu_pupil_p`i'=0
	replace picu_pupil_p`i'=5 if picu_pupil_fix_`i'==1

	// Generate points for lactate - assign a value of 0 where no value
	gen picu_lactate_p`i'=0
	replace picu_lactate_p`i'=1 if picu_lactate`i'>=5 & picu_lactate`i'<11 & picu_lactate`i'~=.
	replace picu_lactate_p`i'=4 if picu_lactate`i'>=11 & picu_lactate`i'~=.

	// Generate points for mean arterial pressure - Assign a value of 0 where no value
	gen picu_bl_map_p`i'=0
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=31 & picu_mbp_`i'<46 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=39 & picu_mbp_`i'<55 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=44 & picu_mbp_`i'<60 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=46 & picu_mbp_`i'<62 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=49 & picu_mbp_`i'<65 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_bl_map_p`i'=2 if picu_mbp_`i'>=52 & picu_mbp_`i'<67 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=17 & picu_mbp_`i'<31 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=25 & picu_mbp_`i'<39 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=31 & picu_mbp_`i'<44 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=32 & picu_mbp_`i'<46 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=. // appears to be a no score for mbp 45 in this age range. score as 3
	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=36 & picu_mbp_`i'<49 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_bl_map_p`i'=3 if picu_mbp_`i'>=38 & picu_mbp_`i'<52 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=16 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=24 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=30 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=31 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=35 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_bl_map_p`i'=6 if picu_mbp_`i'<=37 & picu_mbp_`i'~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

	// Generate points for creatinine - assign a value of 0 where no value
	gen picu_creatinine_p`i'=0
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=70 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=23 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=35 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=51 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=59 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_creatinine_p`i'=2 if picu_creatinine`i'>=93 & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

	// Generate points for PaO2/FiO2 ratio - assign a value of 0 where no value
	gen picu_bl_pao2_fio2_p`i'=0
	replace picu_bl_pao2_fio2_p`i'=2 if (picu_pao2_`i'/picu_bga_fio2_`i')<=60 & picu_pao2_paco2_unit==1 & picu_pao2_`i'~=. & picu_bga_fio2_`i'~=.
    replace picu_bl_pao2_fio2_p`i'=2 if ((picu_pao2_`i'*7.50062)/picu_bga_fio2_`i')<=60 & picu_pao2_paco2_unit==2 & picu_pao2_`i'~=. & picu_bga_fio2_`i'~=.

	// Generate points for PaCO2 - assign a value of 0 where no value
	gen picu_bl_paco2_p`i'=0
	replace picu_bl_paco2_p`i'=1 if picu_paco2_`i'>=59 & picu_paco2_`i'<95 & picu_pao2_paco2_unit==1 & picu_paco2_`i'~=.
    replace picu_bl_paco2_p`i'=3 if picu_paco2_`i'>=95 & picu_pao2_paco2_unit==1 & picu_paco2_`i'~=.
    replace picu_bl_paco2_p`i'=1 if picu_paco2_`i'*7.50062>=59 & picu_paco2_`i'*7.50062<95 & picu_pao2_paco2_unit==2 & picu_paco2_`i'~=.
    replace picu_bl_paco2_p`i'=3 if picu_paco2_`i'*7.50062>=95 & picu_pao2_paco2_unit==2 & picu_paco2_`i'~=.

	// Generate points for invasive ventilation - assign a value of 0 where no value
	gen picu_iv_p`i'=0
	replace picu_iv_p`i'=3 if mment_vent`i'==1

	// Generate points for white cell count - assign a value of 0 where no value
	gen picu_bl_wcc_p`i'=0
	replace picu_bl_wcc_p`i'=2 if picu_wcc_`i'<=2 & picu_wcc_`i'~=.

	// Generate points for platelets - Assign a value of 0 where no value
	gen picu_bl_plat_p`i'=0
	replace picu_bl_plat_p`i'=1 if picu_platelets_`i'>=77 & picu_platelets_`i'<142 & picu_platelets_`i'~=.
	replace picu_bl_plat_p`i'=2 if picu_platelets_`i'<=76 & picu_platelets_`i'~=.

	/* Generate the PELOD-2 score by summing points for all components */
	egen picu_pelod2_`i'=rowtotal(picu_gcs_p`i' picu_pupil_p`i' picu_lactate_p`i' picu_bl_map_p`i' picu_creatinine_p`i' picu_bl_pao2_fio2_p`i' picu_bl_paco2_p`i' picu_iv_p`i' picu_bl_wcc_p`i' picu_bl_plat_p`i')

}

// Acute kidney injury
* Definition: AKI stage according to KDIGO criteria calculated at PICU admission, 24 hours and 48 hours post-PICU admission
* Stage 1: x1.5-<2.0 increase from baseline; Stage 2: x2.0-<3.0 increase from baseline; Stage 3: x>=3.0 increase from baseline
* Baseline assumed as 'normal' PELOD-2 criteria
   
* Calculate the PELOD-2 score at each timepoint   
foreach i of numlist 0(24)48 {

	// Stage 1
	gen picu_aki`i'=0
	replace picu_aki`i'=1 if picu_creatinine`i'>=(70*1.5) & picu_creatinine`i'<(70*2) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_aki`i'=1 if picu_creatinine`i'>=(23*1.5) & picu_creatinine`i'<(23*2) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_aki`i'=1 if picu_creatinine`i'>=(35*1.5) & picu_creatinine`i'<(35*2) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_aki`i'=1 if picu_creatinine`i'>=(51*1.5) & picu_creatinine`i'<(51*2) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_aki`i'=1 if picu_creatinine`i'>=(59*1.5) & picu_creatinine`i'<(59*2) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_aki`i'=1 if picu_creatinine`i'>=(93*1.5) & picu_creatinine`i'<(93*2) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
	// Stage 2
	replace picu_aki`i'=2 if picu_creatinine`i'>=(70*2) & picu_creatinine`i'<(70*3) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_aki`i'=2 if picu_creatinine`i'>=(23*2) & picu_creatinine`i'<(23*3) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_aki`i'=2 if picu_creatinine`i'>=(35*2) & picu_creatinine`i'<(35*3) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_aki`i'=2 if picu_creatinine`i'>=(51*2) & picu_creatinine`i'<(51*3) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_aki`i'=2 if picu_creatinine`i'>=(59*2) & picu_creatinine`i'<(59*3) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_aki`i'=2 if picu_creatinine`i'>=(93*2) & picu_creatinine`i'<(93*3) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
	// Stage 3
	replace picu_aki`i'=3 if picu_creatinine`i'>=(70*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
	replace picu_aki`i'=3 if picu_creatinine`i'>=(23*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
	replace picu_aki`i'=3 if picu_creatinine`i'>=(35*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
	replace picu_aki`i'=3 if picu_creatinine`i'>=(51*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
	replace picu_aki`i'=3 if picu_creatinine`i'>=(59*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
	replace picu_aki`i'=3 if picu_creatinine`i'>=(93*3) & picu_creatinine`i'~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

}

save "NITRIC.dta", replace
