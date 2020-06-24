* Only keep those with a randomisation group
tab rand_group, m
drop if missing(rand_group)
tab rand_group

/*** SAP Table 1: Demographics ***/

// Age at randomisation - continuous
hist rand_age_days
qnorm rand_age_days
tabstat rand_age_days, by(rand_group) stats(n mean sd min max q iqr)
tabstat rand_age_weeks, by(rand_group) stats(n mean sd min max q iqr)

// Age at randomisation - stratification group
tab rand_age rand_group, col m
tab rand_age rand_group, col 

// Weight
hist dem_weight
qnorm dem_weight
tabstat dem_weight, by(rand_group) stats(n mean sd min max q iqr)

// Gender
tab dem_gender rand_group, col m
tab dem_gender rand_group, col 

// Ethnicity
tab dem_ethnicity rand_group, col
tab dem_ethnicity_other rand_group, col
tab dem_ethnicity_gr rand_group, col m
tab dem_ethnicity_gr rand_group, col

// Cardiac physiology
tab rand_pathophys rand_group, col m
tab rand_pathophys rand_group, col

// Previous cardiac bypass
tab presurg_bypass rand_group, col m
tab presurg_bypass rand_group, col

// CHD: tetralogy of fallot
tab presurg_chdtype___1 rand_group, col m

// CHD: pulmonary stenosis
tab presurg_chdtype___10 rand_group, col m

// CHD: pulmonary atresia
tab presurg_chdtype___11 rand_group, col m

// CHD: other right-sided lesions

// CHG: total righ side lesions

// CHD: hypoplastic aortic arch
tab presurg_chdtype___5 rand_group, col m

// CHD: HLHS
tab presurg_chdtype___7 rand_group, col m

// CHD: mitral stenosis/atresia
tab presurg_chdtype___8 rand_group, col m

// CHD: aortic stenosis/atresia
tab presurg_chdtype___6 rand_group, col m

// CHD: other left-sided lesions

// CHD: total left-sided lesions

// CHD: ASD
tab presurg_chdtype___3 rand_group, col m

// CHD: VSD
tab presurg_chdtype___2 rand_group, col m

// CHD: AVSD
tab presurg_chdtype___4 rand_group, col m

// CHD: truncus

// CHD: TGA
tab presurg_chdtype___12 rand_group, col m

// CHD: other shunt lesions

// CHD: total shunt lesions

// CHD group
gen presurg_chdtype_any=0
foreach i of numlist 1/15 {
	tab presurg_chdtype___`i' rand_group, col m
	tab presurg_chdtype___`i' rand_group, col
	replace presurg_chdtype_any=presurg_chdtype_any+1 if presurg_chdtype___`i'==1
}
replace presurg_chdtype_any=presurg_chdtype_any+1 if presurg_chdtype___88==1
tab presurg_chdtype___88 rand_group, col m
tab presurg_chdtype___88 rand_group, col
tab presurg_chdtype_other rand_group, col
tab presurg_chdtype_any rand_group, col m

// PICU inpatient prior to surgery
tab presurg_picu rand_group, col m
tab presurg_picu rand_group, col

preserve
keep if presurg_picu==1

// Duration of PICU stay prior to surgery
hist adm_to_surg
qnorm adm_to_surg
tabstat adm_to_surg, by(rand_group) stats(n mean sd min max q iqr) 

// MV immediately prior to surgery
tab presurg_vent rand_group, col m
tab presurg_vent rand_group, col

// Duration of MV prior to surgery
hist mv_to_surg
qnorm mv_to_surg
tabstat mv_to_surg, by(rand_group) stats(n mean sd min max q iqr) 

// Tracheostomy
tab presurg_trache rand_group, col m
tab presurg_trache rand_group, col

// Inotropes
tab presurg_inotrope rand_group, col m
tab presurg_inotrope rand_group, col
foreach i of numlist 1/6 {
	tab presurg_inotrope_list___`i' rand_group, col m
	tab presurg_inotrope_list___`i' rand_group, col
}

// Prostaglandin
tab presurg_prosta rand_group, col m
tab presurg_prosta rand_group, col

// Diuretics
tab presurg_diuretic rand_group, col m
tab presurg_diuretic rand_group, col

// IV steroids within 48 hours prior to surgery
tab presurg_steroid___0 rand_group, col m
tab presurg_steroid___0 rand_group, col
gen presurg_steroid_any_check=0 if presurg_steroid___0==1
foreach i of numlist 1/3 {
	tab presurg_steroid___`i' rand_group, col m
	tab presurg_steroid___`i' rand_group, col
	replace presurg_steroid_any_check=1 if presurg_steroid___`i'==1
}
tab presurg_steroid_any_check presurg_steroid___0, m	// these should match
	
// Afterload steroids within 48 hours prior to surgery
tab presurg_afterload___0 rand_group, col m
tab presurg_afterload___0 rand_group, col
gen presurg_afterload_any_check=0 if presurg_afterload___0==1
foreach i of numlist 1/6 {
	tab presurg_afterload___`i' rand_group, col m
	tab presurg_afterload___`i' rand_group, col
	replace presurg_afterload_any_check=1 if presurg_afterload___`i'==1
}
tab presurg_afterload_any_check presurg_afterload___0, m	// these should match
	
// iNO within 48 hours prior to surgery
tab presurg_ino rand_group, col m
tab presurg_ino rand_group, col

// Sildenafil within 48 hours prior to surgery
tab presurg_sildenafil rand_group, col m
tab presurg_sildenafil rand_group, col

restore

// Presurgical POPC
tab presurg_popc rand_group, col m
tab presurg_popc rand_group, col
hist presurg_popc
tabstat presurg_popc if presurg_popc~=7, by(rand_group) stats(n mean sd min max q iqr)

// Congenital syndrome
tab presurg_syndrome rand_group, col m
tab presurg_syndrome rand_group, col
tab presurg_syndrome_list rand_group, col chi exact m
tab presurg_syndrome_list rand_group if presurg_syndrome==1, col chi exact m
tab presurg_syndrome_other rand_group if presurg_syndrome_list==4, col

// Country of hospital
tab hosp_country rand_group, col m
tab hosp_country rand_group, col

// Surgical risk score - RACHS
hist surg_rachs
qnorm surg_rachs
count if missing(surg_rachs)
tabstat surg_rachs, by(rand_group) stats(n mean sd min max q iqr)
tab surg_rachs rand_group, col m
tab surg_rachs rand_group, col 

// Surgical procedures
foreach v of varlist surg_proc_* {
	tab `v' rand_group, col m
}

/*** SAP Table 2: Surgical and perioperative characteristics ***/

// Blood prime
tab perfusion_prime_any rand_group, col chi exact m
tab perfusion_prime_any rand_group, col chi exact
prtest perfusion_prime_any, by(rand_group)
	
// Duration of cardiopulmonary bypass
hist perfusion_cpb_total
qnorm perfusion_cpb_total
tabstat perfusion_cpb_total, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_cpb_total, by(rand_group)

// Duration of cardiopulmonary bypass - categorical
tab perfusion_cpb_total_gr rand_group, col chi exact m
tab perfusion_cpb_total_gr rand_group, col chi exact
xi: prtest i.perfusion_cpb_total_gr, by(rand_group)

// Use of cross-clamp
tab perfusion_xclamp_ny rand_group, col chi exact m
tab perfusion_xclamp_ny rand_group, col chi exact
prtest perfusion_xclamp_ny, by(rand_group)

// Duration of cross-clamp
preserve
keep if perfusion_xclamp_ny==0
hist perfusion_xclamp_total
qnorm perfusion_xclamp_total
tabstat perfusion_xclamp_total, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_xclamp_total, by(rand_group)
restore

// Number of CPB runs
tab perfusion_cpb_runs rand_group, col chi exact m
tab perfusion_cpb_runs rand_group, col chi exact
xi i.perfusion_cpb_runs
gen _Iperfusion_1=1 if perfusion_cpb_runs==1
replace _Iperfusion_1=0 if perfusion_cpb_runs>1 & ~missing(perfusion_cpb_runs)
prtest _Iperfusion_1, by(rand_group)
prtest _Iperfusion_2, by(rand_group)
prtest _Iperfusion_3, by(rand_group)
prtest _Iperfusion_4, by(rand_group)

// Deep hypothermic arrest
tab perfusion_cool rand_group, col chi exact m
tab perfusion_cool rand_group, col chi exact
prtest perfusion_cool, by(rand_group)

// Duration of deep hypothermic arrest
preserve
keep if perfusion_cool==1
hist perfusion_cool_time
qnorm perfusion_cool_time
tabstat perfusion_cool_time, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_cool_time, by(rand_group)
restore

// Antegrade cerebal perfusion
tab perfusion_cerebralperf rand_group, col chi exact m
tab perfusion_cerebralperf rand_group, col chi exact
prtest perfusion_cerebralperf, by(rand_group)

// Modified ultrafiltration
tab perfusion_muf_scuf___1 rand_group, col chi exact m
tab perfusion_muf_scuf___1 rand_group, col chi exact
prtest perfusion_muf_scuf___1, by(rand_group)

// Slow continuous ultrafiltration
tab perfusion_muf_scuf___2 rand_group, col chi exact m
tab perfusion_muf_scuf___2 rand_group, col chi exact
prtest perfusion_muf_scuf___2, by(rand_group)

// Red blood cells
count if perfusion_rbc==0
gen perfusion_rbc_kg=perfusion_rbc/dem_weight if perfusion_rbc>0
hist perfusion_rbc_kg
qnorm perfusion_rbc_kg
count if missing(perfusion_rbc_kg)
tabstat perfusion_rbc_kg, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_rbc_kg, by(rand_group)

// Whole blood
hist perfusion_wb_kg
qnorm perfusion_wb_kg
tabstat perfusion_wb_kg, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_wb_kg, by(rand_group)

// Platelets
hist perfusion_plt_kg
qnorm perfusion_plt_kg
tabstat perfusion_plt_kg, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_plt_kg, by(rand_group)

// Fresh frozen plasma
hist perfusion_ffp_kg
qnorm perfusion_ffp_kg
tabstat perfusion_ffp_kg, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_ffp_kg, by(rand_group)

// Cryoprecipitate
hist perfusion_cryo_kg
qnorm perfusion_cryo_kg
tabstat perfusion_cryo_kg, by(rand_group) stats(n mean sd min max q iqr)
cendif perfusion_cryo_kg, by(rand_group)

// IV steroids during surgery
tab surg_steroids rand_group, col chi exact m
tab surg_steroids rand_group, col chi exact
prtest surg_steroids, by(rand_group)

// iNO during surgery
tab surg_ino rand_group, col chi exact m
tab surg_ino rand_group, col chi exact
prtest surg_steroids, by(rand_group)

preserve
keep if rand_group==1

// Time from randomisation to the start of NO
hist rand_to_no
qnorm rand_to_no
tabstat rand_to_no, stats(n mean sd min max q iqr) 

// Dose of NO on CPB (ppm)

// Time from start of CPB to start of NO
hist cpb_to_no
qnorm cpb_to_no
tabstat cpb_to_no, stats(n mean sd min max q iqr) 

// Duration of NO on CPB
hist perfusion_runs_total
qnorm perfusion_runs_total
tabstat perfusion_runs_total, stats(n mean sd min max q iqr) 
 
// Proportion of time spent on CPB with NO
hist prop_cpb_no
qnorm prop_cpb_no
tabstat prop_cpb_no if prop_cpb_no<1, stats(n mean sd min max q iqr) 

// Change in methaemoglobin level before and after CPB
tabstat perfusion_methb_pre, stats(n mean sd min max q iqr)
tabstat perfusion_methb_post, stats(n mean sd min max q iqr)
hist meth_change
qnorm meth_change
tabstat meth_change, stats(n mean sd min max q iqr) 

restore

/*** SAP Table 3: Comparison of primary and secondary outcomes per intention-to-treat analysis ***/

// Primary outcome: ventilator-free days
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)

// Primary analysis
gen days=vent_dur
replace days=hours(outcome_death-perfusion_cpb1_start)/24 if ~missing(outcome_death) & ~missing(perfusion_cpb1_start) & outcome_death<=post28daysurg_dt
gen outcome_cc=0 if vent_dur==28 & death_28day==0 // not extubated and didn't die
replace outcome_cc=1 if vent_dur<28 & death_28day==0 // extubated and didn't die
replace outcome_cc=2 if death_28day==1 // died within 28 days
stset days, failure(outcome_cc=1)
xi: stcrreg b(1).rand_group b(2).rand_age b(2).rand_pathophys, compete(outcome_cc=2)
matrix coeff=e(b)
mata : st_matrix("coeff_shr", exp(st_matrix("coeff")))
stcurve, cif at1(rand_group=1) at2(rand_group=2) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)

// Subgroup analysis
* Age group - <6 weeks
preserve
keep if rand_age==1
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
restore

* Age group - >=6 weeks
preserve
keep if rand_age==2
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
restore

* Age group - interaction
xi: stcrreg b(1).rand_group##b(2).rand_age b(2).rand_pathophys, compete(outcome_cc=2)
preserve
keep if rand_age==1
xi: stcrreg b(1).rand_group b(2).rand_pathophys, compete(outcome_cc=2)
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_age1,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)
restore
preserve
keep if rand_age==2
xi: stcrreg b(1).rand_group b(2).rand_pathophys, compete(outcome_cc=2)
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_age2,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)
restore

* Physiology - univentricular
preserve
keep if rand_pathophys==1
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
restore

* Physiology - biventricular
preserve
keep if rand_pathophys==2
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
restore

* Physiology - interaction
xi: stcrreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age, compete(outcome_cc=2)
preserve
keep if rand_pathophys==1
xi: stcrreg b(1).rand_group b(2).rand_age, compete(outcome_cc=2)
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_phys1,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)
restore
preserve
keep if rand_pathophys==2
xi: stcrreg b(1).rand_group b(2).rand_age, compete(outcome_cc=2)
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_phys2,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)
restore

/* Secondary outcomes */

// Create variable lists for remaining outcome variables
local outcomes_cont "mment_vent_dur dur_chestopen mment_vent_nohrs mment_vent_rrthrs picu_pelod2_* picu_troponin* picu_creatinine*"
local outcomes_binary "picu_lcos_any ecls_48hr death_28day comp_outcome mment_vent_no mment_rrt_pd_crrt"
local outcomes_surv "los_picu los_hosp"

// Analyse continuous outcomes
foreach v of varlist `outcomes_cont' {

	* Descriptive statistics
	hist `v'
	qnorm `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	
	* Unadjusted p-value
	ttest `v', by(rand_group)
	ranksum `v', by(rand_group)
	
	* Primary analysis and sensitivity analyses
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys surg_rachs || site:
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore
	
	* Subgroup analysis: age group - interaction
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys surg_rachs || site:
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Physiology - interaction
	xi: meglm picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:
	xi: meglm picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:
	xi: meglm picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age surg_rachs || site:

}

// Analyse binary outcomes
foreach v of varlist `outcomes_binary' {

	* Descriptive statistics and unadjusted p-value
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact
	
	* Primary analysis and sensitivity analyses
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys surg_rachs || site:, or
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact
	restore
	
	* Subgroup analysis: age group - interaction
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys surg_rachs || site:, or
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact
	restore

	* Physiology - interaction
	xi: melogit picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, or
	xi: melogit picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:, or
	xi: melogit picu_lcos_any b(1).rand_group##b(2).rand_pathophys b(2).rand_age surg_rachs || site:, or

}

// Analyse survival outcomes
foreach v of varlist `outcomes_surv' {

	* Descriptive statistics
	hist `v'
	qnorm `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	
	* Unadjusted p-value
	ranksum `v', by(rand_group)
	
	* Primary analysis and sensitivity analyses
	stset `v', `v'_event
	xi: mestreg b(1).rand_group b(2).rand_pathophys b(2).rand_age || site:, distribution(weibull)
	xi: mestreg b(1).rand_group b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:, distribution(weibull)
	xi: mestreg b(1).rand_group b(2).rand_pathophys b(2).rand_age surg_rachs || site:, distribution(weibull)
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore
	
	* Subgroup analysis: age group - interaction
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, distribution(weibull)
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:, distribution(weibull)
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age surg_rachs || site:, distribution(weibull)
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	ranksum `v', by(rand_group)
	restore

	* Physiology - interaction
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, distribution(weibull)
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:, distribution(weibull)
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age surg_rachs || site:, distribution(weibull)

}

// Analyse AKI timepoints
local aki_timepoints "picu_aki0 picu_aki24 picu_aki48"
foreach v of varlist `aki_timepoints' {

	* Descriptive statistics and unadjusted p-value
	tab `v' rand_group, m col exact
	tab `v' rand_group, col exact

	** Primary analysis
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:, or
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys surg_rachs || site:, or

	** Subgroup analysis
	* Age group - <6 weeks
	preserve
	keep if rand_age==1
	tab `v' rand_group, m col chi exact
	tab `v' rand_group, col chi exact
	restore

	* Age group - >=6 weeks
	preserve
	keep if rand_age==2
	tab `v' rand_group, m col chi exact
	tab `v' rand_group, col chi exact
	restore

	* Age group - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys || site:, or
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total || site:, or
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys surg_rachs || site:, or

	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	tab `v' rand_group, m col chi exact
	tab `v' rand_group, col chi exact
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	tab `v' rand_group, m col chi exact
	tab `v' rand_group, col chi exact
	restore

	* Physiology - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, or
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total || site:, or
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age surg_rachs || site:, or
	
}

/*** SAP: Figure 3 ***/
* Composite figure of: a) proportion of patients with LCOS, 
* 					   b) SaO2-ScvO2 difference, 
*					   c) lactate, 
*					   d) VIS score, over time points
* 0, 6, 12, 24, 48 hours after PICU admission, separated by treatment group

// Figure 3a
preserve
keep picu_lcos* rand_group record_id
drop picu_lcos_any
rename picu_lcos0_value picu_lcos_0
rename picu_lcos6_value picu_lcos_6
rename picu_lcos12_value picu_lcos_12
rename picu_lcos24_value picu_lcos_24
rename picu_lcos48_value picu_lcos_48
reshape long picu_lcos_, i(record_id) j(timepoint)
collapse (mean) picu_lcos_, by(timepoint rand_group)
reshape wide picu_lcos_, i(timepoint) j(rand_group)
label define timepoint 0 "PICU Admission" 6 "6hr" 12 "12hr" 24 "24hr" 48 "48hr"
label values timepoint timepoint
rename picu_lcos_1 picu_lcos_std
rename picu_lcos_2 picu_lcos_tmt
replace picu_lcos_std=picu_lcos_std*100
replace picu_lcos_tmt=picu_lcos_tmt*100

graph bar picu_lcos_std picu_lcos_tmt, ///
		  over(timepoint) xsize(4.8) ytitle("% of patients") ///
		  legend(label(1 "Standard Care") label(2 "Nitric Oxide")) ///
		  scheme(s1mono) saving("Figures\\fig3a", replace)
restore

// Figure 3b
foreach v of varlist picu_avsatdiff* {
	hist `v'
}
preserve
keep picu_avsatdiff* rand_group record_id
drop picu_avsatdiffmax48
reshape long picu_avsatdiff, i(record_id) j(timepoint)
label define timepoint 0 "PICU Admission" 6 "6hr" 12 "12hr" 24 "24hr" 48 "48hr"
label values timepoint timepoint

local varname picu_avsatdiff
local group timepoint rand_group
collapse (mean) y = `varname' (semean) se_y = `varname', by(`group')

sort `group'
gen x = _n
replace x = x[_n-2]+3 if _n>=3

gen yu = y + 1.96*se_y
gen yl = y - 1.96*se_y

label define x 1  "PICU Adm" 4 "6hr" 7 "12hr" 10 "24hr" 13 "48hr" 
label value x x

twoway (scatter y x if rand_group==1, msymbol(S) ) ///
       (rcap yu  yl x if rand_group==1) (line y x if rand_group==1, lpattern(dash)) ///
       (scatter y x if rand_group==2, msymbol(S) ) ///
       (rcap yu  yl x if rand_group==2) (line y x if rand_group==2), ///
  	   xlabel(1 4 7 10 13, valuelabel) xtitle(" ") ///
	   ytitle("Mean (95% CI) SaO{subscript:2}-ScvO{subscript:2}") yline(50) ///
	   legend(order(3 6) lab(3 "Standard Care") lab(6 "Nitric Oxide")) scheme(s1mono) ///
	   saving("Figures\\fig3b", replace)

restore

// Figure 3c
foreach v of varlist picu_lactate* {
	hist `v'
}
preserve
keep picu_lactate* rand_group record_id
drop picu_lactatemax48 picu_lactate_p0 picu_lactate_p24 picu_lactate_p48
reshape long picu_lactate, i(record_id) j(timepoint)
label define timepoint 0 "PICU Admission" 6 "6hr" 12 "12hr" 24 "24hr" 48 "48hr"
label values timepoint timepoint

graph box picu_lactate, over(rand_group) over(timepoint) asyvars scheme(s1mono) ///
					ytitle("Lactate (mmol/L)") saving("Figures\\fig3c", replace)

restore

// Figure 3d
foreach v of varlist picu_vis* {
	hist `v'
}
preserve
keep picu_vis* rand_group record_id
reshape long picu_vis, i(record_id) j(timepoint)
label define timepoint 0 "PICU Admission" 6 "6hr" 12 "12hr" 24 "24hr" 48 "48hr"
label values timepoint timepoint

graph box picu_vis, over(rand_group) over(timepoint) asyvars scheme(s1mono) ///
					ytitle("Vasoactive-Inotrope Score") saving("Figures\\fig3d", replace)

restore

// Figure 3e
foreach v of varlist picu_creatinine* {
	hist `v'
}
preserve
keep picu_creatinine* rand_group record_id
drop picu_creatinine_p0 picu_creatinine_p24 picu_creatinine_p48
reshape long picu_creatinine, i(record_id) j(timepoint)
label define timepoint 0 "PICU Admission" 6 "6hr" 12 "12hr" 24 "24hr" 48 "48hr"
label values timepoint timepoint

local varname picu_creatinine
local group timepoint rand_group
collapse (mean) y = `varname' (semean) se_y = `varname', by(`group')

sort `group'
gen x = _n
replace x = x[_n-2]+3 if _n>=3

gen yu = y + 1.96*se_y
gen yl = y - 1.96*se_y

label define x 1  "PICU Adm" 4 "6hr" 7 "12hr" 10 "24hr" 13 "48hr" 
label value x x

twoway (scatter y x if rand_group==1, msymbol(S) ) ///
       (rcap yu  yl x if rand_group==1) (line y x if rand_group==1, lpattern(dash)) ///
       (scatter y x if rand_group==2, msymbol(S) ) ///
       (rcap yu  yl x if rand_group==2) (line y x if rand_group==2), ///
  	   xlabel(1 4 7 10 13, valuelabel) xtitle(" ") ///
	   ytitle("Mean (95% CI) Creatinine (umol/L)") yline(50) ///
	   legend(order(3 6) lab(3 "Standard Care") lab(6 "Nitric Oxide")) scheme(s1mono) ///
	   saving("Figures\\fig3e", replace)

restore

// Figure 3f
foreach v of varlist picu_pelod2_* {
	hist `v'
}
preserve
keep picu_pelod2_* rand_group record_id
reshape long picu_pelod2_, i(record_id) j(timepoint)
label define timepoint 0 "PICU Admission" 24 "24hr" 48 "48hr"
label values timepoint timepoint

graph box picu_pelod2_, over(rand_group) over(timepoint) asyvars scheme(s1mono) ///
					ytitle("PELOD-2 Score") saving("Figures\\fig3f", replace)

restore

// Combine the graphs
graph combine "Figures\\fig3a" "Figures\\fig3b" "Figures\\fig3c"  ///
			  "Figures\\fig3d" "Figures\\fig3e" "Figures\\fig3f", ///
			   scheme(s1mono) saving("Figures\\fig3", replace)



