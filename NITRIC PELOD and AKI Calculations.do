/**** NITRIC STUDY ****/
/**** PELOD-2 Syntax and AKI (KDIGO) Criteria ****/
/**** Calculate at baseline, 24 hours, 48 hours ****/

// Set values of 4444, 5555, 9999 to missing for relevant variables 
mvdecode *_lactate* picu_lact24 picu_lactatemax48 *_creatinine* picu_wccmax48 picu_wccmin48 picu_plateletmin48 mment_platelets48 rand_age_days, mv(9999=.\ 4444=.\ 5555=.) 

// Determine how far prior to the PICU admission randomisation occurred
gen rand_to_post_picuadm=hours(picu_adm-rand_dt)
hist rand_to_post_picuadm
tabstat rand_to_post_picuadm, stats(n mean sd min max q iqr)

// Define the 48 hour post-randomisation date and time
gen post48hrrand_dt=rand_dt+48*60*60*1000
format post48hrrand_dt %tc

// Define the 48 hour post-surgery start date and time
gen post48hrsurg_dt=perfusion_cpb1_start+48*60*60*1000
format post48hrsurg_dt %tc

// Define the 28 day post-randomisation date and time
gen post28dayrand_dt=rand_dt+28*24*60*60*1000
format post28dayrand_dt %tc
	
// Define the 28 day post-surgery start date and time
gen post28daysurg_dt=perfusion_cpb1_start+28*24*60*60*1000
format post28daysurg_dt %tc

// Define the 12 month post-randomisation date and time
gen post12mrand_dt=rand_dt+365*24*60*60*1000
format post12mrand_dt %tc
	
// Define the 12 month post-surgery start date and time
gen post12msurg_dt=perfusion_cpb1_start+365*24*60*60*1000
format post12msurg_dt %tc

// Calculate if the start/stop time of any of the mechanical ventilation episodes are at 24 hours and 48 hours
// Define the 24 hour post-PICU admission date and time
gen post24hrpicu_dt=picu_adm+24*60*60*1000
format post24hrpicu_dt %tc
// Define the 48 hour post-PICU admission date and time
gen post48hrpicu_dt=picu_adm+48*60*60*1000
format post48hrpicu_dt %tc

gen mment_vent24=0
gen mment_vent48=0
foreach i of numlist 1/5 {
	
	replace mment_vent24=1 if ( (mment_vent_start`i'<post24hrpicu_dt) & (mment_vent_stop`i'>post24hrpicu_dt) )& ~missing(mment_vent_start`i') & ~missing(mment_vent_stop`i')	
	replace mment_vent48=1 if ( (mment_vent_start`i'<post48hrpicu_dt) & (mment_vent_stop`i'>post48hrpicu_dt) )& ~missing(mment_vent_start`i') & ~missing(mment_vent_stop`i')
			
}


/****** PELOD-2 ******/

foreach i in numlist 0(24)48 {

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
	replace picu_bl_pao2_fio2_p`i'=2 if (picu_pao2_`i'/picu_bga_fio2_`i')<=60 & picu_pao2_`i'~=. & picu_bga_fio2_`i'~=.

	// Generate points for PaCO2 - assign a value of 0 where no value
	gen picu_bl_paco2_p`i'=0
	replace picu_bl_paco2_p`i'=1 if picu_paco2_`i'>=59 & picu_paco2_`i'<95 & picu_paco2_`i'~=.
	replace picu_bl_paco2_p`i'=3 if picu_paco2_`i'>=95 & picu_paco2_`i'~=.

	// Generate points for invasive ventilation - assign a value of 0 where no value
	gen picu_iv_p`i'=0
	replace picu_iv_p`i'=3 if mment_vent==1

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


/****** AKI ******/

/* Stage 1: x1.5-<2.0 increase from baseline
   Stage 2: x2.0-<3.0 increase from baseline
   Stage 3: x>=3.0 increase from baseline
   Baseline assumed as 'normal' criteria from PELOD-2 syntax */
   
/// Baseline in PICU
// Stage 1
gen icu_aki0=0
replace icu_aki0=1 if picu_creatinine0>=(70*1.5) & picu_creatinine0<(70*2) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki0=1 if picu_creatinine0>=(23*1.5) & picu_creatinine0<(23*2) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki0=1 if picu_creatinine0>=(35*1.5) & picu_creatinine0<(35*2) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki0=1 if picu_creatinine0>=(51*1.5) & picu_creatinine0<(51*2) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki0=1 if picu_creatinine0>=(59*1.5) & picu_creatinine0<(59*2) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki0=1 if picu_creatinine0>=(93*1.5) & picu_creatinine0<(93*2) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 2
replace icu_aki0=2 if picu_creatinine0>=(70*2) & picu_creatinine0<(70*3) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki0=2 if picu_creatinine0>=(23*2) & picu_creatinine0<(23*3) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki0=2 if picu_creatinine0>=(35*2) & picu_creatinine0<(35*3) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki0=2 if picu_creatinine0>=(51*2) & picu_creatinine0<(51*3) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki0=2 if picu_creatinine0>=(59*2) & picu_creatinine0<(59*3) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki0=2 if picu_creatinine0>=(93*2) & picu_creatinine0<(93*3) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 3
replace icu_aki0=3 if picu_creatinine0>=(70*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki0=3 if picu_creatinine0>=(23*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki0=3 if picu_creatinine0>=(35*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki0=3 if picu_creatinine0>=(51*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki0=3 if picu_creatinine0>=(59*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki0=3 if picu_creatinine0>=(93*3) & picu_creatinine0~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

/// 24 hours post-PICU admission
// Stage 1
gen icu_aki24=0
replace icu_aki24=1 if picu_creatinine24>=(70*1.5) & picu_creatinine24<(70*2) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki24=1 if picu_creatinine24>=(23*1.5) & picu_creatinine24<(23*2) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki24=1 if picu_creatinine24>=(35*1.5) & picu_creatinine24<(35*2) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki24=1 if picu_creatinine24>=(51*1.5) & picu_creatinine24<(51*2) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki24=1 if picu_creatinine24>=(59*1.5) & picu_creatinine24<(59*2) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki24=1 if picu_creatinine24>=(93*1.5) & picu_creatinine24<(93*2) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 2
replace icu_aki24=2 if picu_creatinine24>=(70*2) & picu_creatinine24<(70*3) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki24=2 if picu_creatinine24>=(23*2) & picu_creatinine24<(23*3) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki24=2 if picu_creatinine24>=(35*2) & picu_creatinine24<(35*3) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki24=2 if picu_creatinine24>=(51*2) & picu_creatinine24<(51*3) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki24=2 if picu_creatinine24>=(59*2) & picu_creatinine24<(59*3) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki24=2 if picu_creatinine24>=(93*2) & picu_creatinine24<(93*3) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 3
replace icu_aki24=3 if picu_creatinine24>=(70*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki24=3 if picu_creatinine24>=(23*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki24=3 if picu_creatinine24>=(35*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki24=3 if picu_creatinine24>=(51*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki24=3 if picu_creatinine24>=(59*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki24=3 if picu_creatinine24>=(93*3) & picu_creatinine24~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

/// 48 hours post-PICU admission
// Stage 1
gen icu_aki48=0
replace icu_aki48=1 if picu_creatinine48>=(70*1.5) & picu_creatinine48<(70*2) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki48=1 if picu_creatinine48>=(23*1.5) & picu_creatinine48<(23*2) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki48=1 if picu_creatinine48>=(35*1.5) & picu_creatinine48<(35*2) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki48=1 if picu_creatinine48>=(51*1.5) & picu_creatinine48<(51*2) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki48=1 if picu_creatinine48>=(59*1.5) & picu_creatinine48<(59*2) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki48=1 if picu_creatinine48>=(93*1.5) & picu_creatinine48<(93*2) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 2
replace icu_aki48=2 if picu_creatinine48>=(70*2) & picu_creatinine48<(70*3) & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki48=2 if picu_creatinine48>=(23*2) & picu_creatinine48<(23*3) & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki48=2 if picu_creatinine48>=(35*2) & picu_creatinine48<(35*3) & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki48=2 if picu_creatinine48>=(51*2) & picu_creatinine48<(51*3) & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki48=2 if picu_creatinine48>=(59*2) & picu_creatinine48<(59*3) & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki48=2 if picu_creatinine48>=(93*2) & picu_creatinine48<(93*3) & rand_age_days/(365.25/12)>=144 & rand_age_days~=.
// Stage 3
replace icu_aki48=3 if picu_creatinine48>=(70*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)<1 & rand_age_days~=.
replace icu_aki48=3 if picu_creatinine48>=(23*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)>=1 & rand_age_days/(365.25/12)<12 & rand_age_days~=.
replace icu_aki48=3 if picu_creatinine48>=(35*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)>=12 & rand_age_days/(365.25/12)<24 & rand_age_days~=.
replace icu_aki48=3 if picu_creatinine48>=(51*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)>=24 & rand_age_days/(365.25/12)<60 & rand_age_days~=.
replace icu_aki48=3 if picu_creatinine48>=(59*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)>=60 & rand_age_days/(365.25/12)<144 & rand_age_days~=.
replace icu_aki48=3 if picu_creatinine48>=(93*3) & picu_creatinine48~=. & rand_age_days/(365.25/12)>=144 & rand_age_days~=.

/* Calculate the primary outcome variables */

tab mment_vent
tab mment_vent_events

// Initial ventilation period
gen mment_vent_durhr_initial=hours(mment_extub-perfusion_cpb1_start) if mment_vent==1
hist mment_vent_durhr_initial
tabstat mment_vent_durhr_initial, stats(n mean sd min max q iqr)
replace mment_vent_durhr_initial=. if mment_vent_durhr_initial<0 & ~missing(mment_vent_durhr_initial)  // ERRORS
tabstat mment_vent_durhr_initial, stats(n mean sd min max q iqr)
replace mment_vent_durhr_initial=0 if mment_vent==0
tabstat mment_vent_durhr_initial, stats(n mean sd min max q iqr)
* If ventilation lasts longer than the 28 days then cut it off
replace mment_vent_durhr_initial=672 if mment_extub>post28daysurg_dt & ~missing(mment_extub)
tabstat mment_vent_durhr_initial, stats(n mean sd min max q iqr)
gen mment_vent_durday_initial=mment_vent_durhr_initial/24
tabstat mment_vent_durday_initial, stats(n mean sd min max q iqr)

// Set the initial values
gen mment_vent_durhr=mment_vent_durhr_initial if ~missing(mment_vent_durhr_initial)
gen mment_vent_durday=mment_vent_durday_initial if ~missing(mment_vent_durday_initial)
tabstat mment_vent_durhr, stats(n mean sd min max q iqr)
tabstat mment_vent_durday, stats(n mean sd min max q iqr)

foreach i of numlist 1/5 {
	
	// Difference between start and stop times
	gen mment_vent_durhr`i'=hours(mment_vent_stop`i'-mment_vent_start`i') if ~missing(mment_vent_stop`i') & ~missing(mment_vent_start`i')
	tabstat mment_vent_durhr`i', stats(n mean sd min max q iqr)
	*replace mment_vent_durhr`i'=. if (mment_vent_durhr`i'<0 | mment_vent_durhr`i'>2500) & ~missing(mment_vent_durhr`i')  // ERRORS
	tabstat mment_vent_durhr`i', stats(n mean sd min max q iqr)
	replace mment_vent_durhr`i'=. if ( (rand_dt>mment_vent_start`i') | (rand_dt>mment_vent_stop`i') )& ~missing(mment_vent_durhr`i')  // ERRORS - ventilation start and/or stop times before randomisation
	tabstat mment_vent_durhr`i', stats(n mean sd min max q iqr)
	
	// Calculate the duration of ventilation (hours) if less than 28 days post-randomisation and add to current total
	replace mment_vent_durhr`i'=0 if mment_vent_start`i'>post28daysurg_dt & ~missing(mment_vent_start`i') & ~missing(post28daysurg_dt)  // vent start time after post-28 day randomisation time
	tabstat mment_vent_durhr`i', stats(n mean sd min max q iqr)
	replace mment_vent_durhr`i'=hours(post28daysurg_dt-mment_vent_start`i') if mment_vent_start`i'<post28daysurg_dt & mment_vent_stop`i'>=post28daysurg_dt & ~missing(post28daysurg_dt) & ~missing(mment_vent_stop`i') & ~missing(mment_vent_start`i') // num vent hours if 28 day timepoint was in between vent start and stop times
	tabstat mment_vent_durhr`i', stats(n mean sd min max q iqr)
	replace mment_vent_durhr=mment_vent_durhr+mment_vent_durhr`i' if ~missing(mment_vent_durhr`i')
	tabstat mment_vent_durhr, stats(n mean sd min max q iqr)
	
	// Calculate the duration of ventilation (days) if less than 28 days post-randomisation and add to current total
	gen mment_vent_durday`i'=mment_vent_durhr`i'/24
	replace mment_vent_durday=mment_vent_durday+mment_vent_durday`i' if ~missing(mment_vent_durday`i')
	tabstat mment_vent_durday, stats(n mean sd min max q iqr)
	
}

gen vent_durday=mment_vent_durday

// If the patients die set the duration of invasive respiratory support to maximum
replace mment_vent_durday=28 if outcome_death<post28daysurg_dt & ~missing(outcome_death)
replace mment_vent_durhr=672 if outcome_death<post28daysurg_dt & ~missing(outcome_death)

// If no ventilator time recorded, use the extubation time in surgery
replace mment_vent_durday=hours(surg_extub_dt-perfusion_cpb1_start) if ~missing(surg_extub_dt) & mment_vent_durday==0
replace mment_vent_durhr=mment_vent_durday/24 if mment_vent_durhr==0

// If no ventilator time recorded and no extubation time in surgery, use the total time on bypass
replace mment_vent_durday=perfusion_cpb_total/60/24 if ~missing(perfusion_cpb_total) & mment_vent_durday==0
replace mment_vent_durhr=mment_vent_durday/24 if mment_vent_durhr==0

// Translate to ventilator free days
gen vfd=28-mment_vent_durday if ~missing(mment_vent_durday)

// Death within 28 days post-surgery
gen death_28day=1 if outcome_death<post28daysurg_dt & outcome_death>=perfusion_cpb1_start & ~missing(outcome_death) & ~missing(post28daysurg_dt)
replace death_28day=0 if ( outcome_death>=post28daysurg_dt & ~missing(outcome_death) & ~missing(post28daysurg_dt) ) | outcome_status30==1
tab death_28day rand_group, m col chi exact
tab death_28day rand_group, col chi exact

// Extracorporeal life support (ECLS)
* Defined as starting ECLS within the first 48 hours
gen ecls_48hr=1 if ( ~missing(mment_ecls_start1) & mment_ecls_start1<post48hrsurg_dt & mment_ecls_start1>rand_dt ) | ///
				   ( ~missing(mment_ecls_start2) & mment_ecls_start2<post48hrsurg_dt & mment_ecls_start2>rand_dt ) | ///
				   ( ~missing(mment_ecls_start3) & mment_ecls_start3<post48hrsurg_dt & mment_ecls_start3>rand_dt ) | ///
				   ~missing(post48hrsurg_dt)
egen ecls_minstart=rowmin(mment_ecls_start1 mment_ecls_start2 mment_ecls_start3)
format ecls_minstart %tc
replace ecls_48hr=0 if mment_ecls==0 | ecls_minstart>=post48hrsurg_dt

// Composite outcome
gen comp_outcome=1 if picu_lcos_any==1 | ecls_48hr==1 | death_28day==1
replace comp_outcome=0 if picu_lcos_any==0 & ecls_48hr==0 & death_28day==0

// Length of stay - PICU
* Definition: from PICU admission post-surgery to PICU discharge
gen los_picu=hours(outcome_picu_dc-picu_adm)/24 if ~missing(outcome_picu_dc) & ~missing(picu_adm)
replace los_picu=. if outcome_picu_dc<picu_adm & ~missing(outcome_picu_dc) & ~missing(picu_adm)

// Length of stay - hospital
* Definition: from PICU admission post-surgery to hospital discharge
gen los_hosp=hours(outcome_hospdc_date-picu_adm)/24 if ~missing(outcome_hospdc_date) & ~missing(picu_adm)
replace los_hosp=. if outcome_hospdc_date<picu_adm & ~missing(outcome_hospdc_date) & ~missing(picu_adm)

// Duration of treatment with renal replacement therapy
* Definition: from PICU admission post-surgery to 28 days post-PICU admission
gen mment_vent_rrthrs=0 if mment_rrt_pd_crrt==1
replace mment_vent_rrthrs=mment_vent_rrthrs+hours(mment_rrt_pd_stop-mment_rrt_pd_start) if ~missing(mment_rrt_pd_stop) & ~missing(mment_rrt_pd_start)
replace mment_vent_rrthrs=mment_vent_rrthrs+hours(mment_rrt_cvvh_stop-mment_rrt_cvvh_start) if ~missing(mment_rrt_cvvh_stop) & ~missing(mment_rrt_cvvh_start)

// Death within 28 days post-randomisation
gen death_28day=1 if outcome_death<post28daysurg_dt & outcome_death>=perfusion_cpb1_start & ~missing(outcome_death) & ~missing(post28daysurg_dt)
replace death_28day=0 if ( outcome_death>=post28daysurg_dt & ~missing(outcome_death) & ~missing(post28daysurg_dt) ) | outcome_status30==1

// Renal replacement therapy
gen mment_rrt_any=0 if mment_rrt___4==1
foreach i of numlist 1/3 {
	tab mment_rrt___`i' rand_group, m col chi exact
	tab mment_rrt___`i' rand_group, col chi exact
	replace mment_rrt_any=1 if mment_rrt___`i'==1
}
tab mment_rrt_any rand_group, m col chi exact
gen mment_rrt_pd_crrt=1 if mment_rrt___1==1 | mment_rrt___2==1
replace mment_rrt_pd_crrt=0 if mment_rrt___3==1 | mment_rrt___4==1
