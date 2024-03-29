/**** NITRIC DATA ANALYSIS ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Analysis of NITRIC data as per SAP ****/

* Only keep those with a randomisation group
tab rand_group, m
drop if missing(rand_group)
tab rand_group, m

* Only keep those who underwent CPB
tab rand_group if perfusion_cpb_runs==. | perfusion_cpb_runs==0
drop if perfusion_cpb_runs==. | perfusion_cpb_runs==0
sort rand_dt
tab rand_group, m

* Remove the withdrawn patients
drop if withdraw_data_use___1==1 | withdraw_data_use___2==1

/*** SAP Table 1: Demographics ***/

// Age at randomisation - continuous
hist rand_age_days
qnorm rand_age_days
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

// Congenital heart disease group
foreach v of varlist presurg_chdtype_group__* presurg_chdgroup_rightside presurg_chdgroup_leftside presurg_chdgroup_shunt presurg_chdgroup_various {
	tab `v' rand_group, col m
	tab `v' rand_group, col
}

// PICU inpatient prior to surgery
tab presurg_picu rand_group, col m
tab presurg_picu rand_group, col

preserve
keep if presurg_picu==1

// Duration of PICU stay prior to surgery
hist adm_to_surg
qnorm adm_to_surg
tabstat adm_to_surg, by(rand_group) stats(n mean sd min max q iqr) 

restore

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
list record_id site presurg_steroid* if presurg_steroid_any_check==1 & presurg_steroid___0 ==1
	
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
list record_id site presurg_afterload* if presurg_afterload_any_check==1 & presurg_afterload___0==1
	
// iNO within 48 hours prior to surgery
tab presurg_ino rand_group, col m
tab presurg_ino rand_group, col

// Sildenafil within 48 hours prior to surgery
tab presurg_sildenafil rand_group, col m
tab presurg_sildenafil rand_group, col

// Presurgical POPC
tab presurg_popc rand_group, col m
tab presurg_popc rand_group, col
hist presurg_popc
tabstat presurg_popc if presurg_popc~=7, by(rand_group) stats(n mean sd min max q iqr)

// Congenital syndrome
tab presurg_syndrome rand_group, col m
tab presurg_syndrome rand_group, col
foreach v of varlist presurg_syndrome_group___2 presurg_syndrome_group___1 presurg_syndrome_group___6 presurg_syndrome_group___5 presurg_syndrome_group___7 presurg_syndrome_group___3 presurg_syndrome_other_gr {
	tab `v' rand_group, col m
	tab `v' rand_group, col
}

// Country of hospital
tab hosp_country rand_group, col m
tab hosp_country rand_group, col

// Surgical risk score - RACHS
hist surg_rachs
qnorm surg_rachs
tabstat surg_rachs, by(rand_group) stats(n mean sd min max q iqr)
tab surg_rachs rand_group, col m
tab surg_rachs rand_group, col 

// Surgical procedures
gen surg_proc_any=0
foreach v of varlist surg_proc_* {
	tab `v' rand_group, col m
	replace surg_proc_any=1 if `v'==1
}

/*** SAP Table 2: Surgical and perioperative characteristics ***/

// Blood prime
tab perfusion_prime_any rand_group, col m
tab perfusion_prime_any rand_group, col
prtest perfusion_prime_any, by(rand_group)
	
// Duration of cardiopulmonary bypass
hist perfusion_cpb_total
qnorm perfusion_cpb_total
tabstat perfusion_cpb_total, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_cpb_total b(1).rand_group

// Duration of cardiopulmonary bypass - categorical
tab perfusion_cpb_total_gr rand_group, col m
tab perfusion_cpb_total_gr rand_group, col
xi: prtest i.perfusion_cpb_total_gr, by(rand_group)

// Use of cross-clamp
tab perfusion_xclamp_yn rand_group, col m
tab perfusion_xclamp_yn rand_group, col
prtest perfusion_xclamp_yn, by(rand_group)

// Duration of cross-clamp
preserve
keep if perfusion_xclamp_yn==1
hist perfusion_xclamp_total
qnorm perfusion_xclamp_total
tabstat perfusion_xclamp_total, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_xclamp_total b(1).rand_group
restore

// Number of CPB runs
tab perfusion_cpb_runs rand_group, col m
tab perfusion_cpb_runs rand_group, col
xi i.perfusion_cpb_runs
gen _Iperfusion_1=1 if perfusion_cpb_runs==1
replace _Iperfusion_1=0 if perfusion_cpb_runs>1 & ~missing(perfusion_cpb_runs)
prtest _Iperfusion_1, by(rand_group)
prtest _Iperfusion_2, by(rand_group)
prtest _Iperfusion_3, by(rand_group)
prtest _Iperfusion_4, by(rand_group)

// Deep hypothermic arrest
tab perfusion_cool rand_group, col m
tab perfusion_cool rand_group, col
prtest perfusion_cool, by(rand_group)

// Duration of deep hypothermic arrest
preserve
keep if perfusion_cool==1
hist perfusion_cool_time
qnorm perfusion_cool_time
tabstat perfusion_cool_time, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_cool_time b(1).rand_group
restore

// Antegrade cerebal perfusion
tab perfusion_cerebralperf rand_group, col m
tab perfusion_cerebralperf rand_group, col
prtest perfusion_cerebralperf, by(rand_group)

// Modified ultrafiltration
tab perfusion_muf_scuf___1 rand_group, col m
tab perfusion_muf_scuf___1 rand_group, col
prtest perfusion_muf_scuf___1, by(rand_group)

// Slow continuous ultrafiltration
tab perfusion_muf_scuf___2 rand_group, col m
tab perfusion_muf_scuf___2 rand_group, col
prtest perfusion_muf_scuf___2, by(rand_group)

// Red blood cells
tab perfusion_rbc_yn rand_group, m col
tab perfusion_rbc_yn rand_group, col
prtest perfusion_rbc_yn, by(rand_group)
hist perfusion_rbc_kg if perfusion_rbc_yn==1
qnorm perfusion_rbc_kg if perfusion_rbc_yn==1
tabstat perfusion_rbc_kg if perfusion_rbc_yn==1, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_rbc_kg b(1).rand_group if perfusion_rbc_yn==1

// Whole blood
tab perfusion_wb_yn rand_group, m col
tab perfusion_wb_yn rand_group, col
prtest perfusion_wb_yn, by(rand_group)
hist perfusion_wb_kg if perfusion_wb_yn==1
qnorm perfusion_wb_kg if perfusion_wb_yn==1
tabstat perfusion_wb_kg if perfusion_wb_yn==1, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_wb_kg b(1).rand_group if perfusion_wb_yn==1

// Platelets
tab perfusion_plt_yn rand_group, m col
tab perfusion_plt_yn rand_group, col
prtest perfusion_plt_yn, by(rand_group)
hist perfusion_plt_kg if perfusion_plt_yn==1
qnorm perfusion_plt_kg if perfusion_plt_yn==1
tabstat perfusion_plt_kg if perfusion_plt_yn==1, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_plt_kg b(1).rand_group if perfusion_plt_yn==1

// Fresh frozen plasma
tab perfusion_ffp_yn rand_group, m col
tab perfusion_ffp_yn rand_group, col
prtest perfusion_ffp_yn, by(rand_group)
hist perfusion_ffp_kg if perfusion_ffp_yn==1
qnorm perfusion_ffp_kg if perfusion_ffp_yn==1
tabstat perfusion_ffp_kg if perfusion_ffp_yn==1, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_ffp_kg b(1).rand_group if perfusion_ffp_yn==1

// Cryoprecipitate
tab perfusion_cryo_yn rand_group, m col
tab perfusion_cryo_yn rand_group, col
prtest perfusion_cryo_yn, by(rand_group)
hist perfusion_cryo_kg if perfusion_cryo_yn==1
qnorm perfusion_cryo_kg if perfusion_cryo_yn==1
tabstat perfusion_cryo_kg if perfusion_cryo_yn==1, by(rand_group) stats(n mean sd min max q iqr)
qreg perfusion_cryo_kg b(1).rand_group if perfusion_cryo_yn==1

// IV steroids during surgery
tab surg_steroids rand_group, col m
tab surg_steroids rand_group, col
prtest surg_steroids, by(rand_group)

// iNO during surgery
tab surg_ino rand_group, col m
tab surg_ino rand_group, col
prtest surg_ino, by(rand_group)

preserve
keep if rand_group==2

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
tabstat prop_cpb_no, stats(n mean sd min max q iqr) 

// Change in methaemoglobin level before and after CPB
tabstat perfusion_methb_pre, stats(n mean sd min max q iqr)
tabstat perfusion_methb_post, stats(n mean sd min max q iqr)
hist meth_change
qnorm meth_change
tabstat meth_change, stats(n mean sd min max q iqr) 

// Change in methaemoglobin level before and after CPB
tab meth_change_3, m

restore

/*** SAP Table 3: Comparison of primary and secondary outcomes per intention-to-treat analysis ***/

// Randomly shuffle the two groups so that it is not known for the first pass of the analysis
* Remove this portion of code for the final analysis
/*rename rand_group rand_group_o
scalar ran=runiform()
quietly gen rand_group=rand_group_o if ran<0.5
quietly replace rand_group=2 if rand_group==. & rand_group_o==1
quietly replace rand_group=1 if rand_group==. & rand_group_o==2
scalar drop ran*/

// Primary outcome: ventilator-free days
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
xi: qreg vfd b(1).rand_group

// Primary analysis
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
* Generate the graph
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
		 ytitle("Probability of extubation") lpattern(dash) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ylabel(, grid format(%4.1f))
* Sensitivity analysis
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(2).site b(1).dem_gender

// Subgroup analysis
* Age group - <6 weeks
preserve
keep if rand_age==1
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
xi: qreg vfd b(1).rand_group b(2).rand_pathophys b(2).site
restore

* Age group - >=6 weeks
preserve
keep if rand_age==2
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
xi: qreg vfd b(1).rand_group b(2).rand_pathophys b(2).site
restore

* Age group - interaction
xi: qreg vfd b(1).rand_group##b(2).rand_age b(2).rand_pathophys b(2).site
xi: stcrreg b(1).rand_group##b(2).rand_age b(2).rand_pathophys, compete(outcome_cc=2) // needed for the graph
preserve
keep if rand_age==1
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
xi: stcrreg b(1).rand_group b(2).rand_pathophys, compete(outcome_cc=2) // needed for the graph
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_age1,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ylabel(, grid format(%4.1f))
restore
preserve
keep if rand_age==2
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
xi: stcrreg b(1).rand_group b(2).rand_pathophys, compete(outcome_cc=2) // needed for the graph
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_age2,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ylabel(, grid format(%4.1f))
restore

* Physiology - univentricular
preserve
keep if rand_pathophys==1
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).site
restore

* Physiology - biventricular
preserve
keep if rand_pathophys==2
hist vfd
qnorm vfd
tabstat vfd, by(rand_group) stats(n mean sd min max q iqr)
ranksum vfd, by(rand_group)
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).site
restore

* Physiology - interaction
xi: qreg vfd b(1).rand_group##b(2).rand_pathophys b(2).rand_age b(2).site
xi: stcrreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age, compete(outcome_cc=2) // needed for the graph
preserve
keep if rand_pathophys==1
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
xi: stcrreg b(1).rand_group b(2).rand_age, compete(outcome_cc=2) // needed for the graph
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_phys1,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ylabel(, grid format(%4.1f))
restore
preserve
keep if rand_pathophys==2
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
xi: stcrreg b(1).rand_group b(2).rand_age, compete(outcome_cc=2) // needed for the graph
stcurve, cif at1(rand_group=1) at2(rand_group=2) saving(Figures\\vfd_phys2,replace) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ylabel(, grid format(%4.1f))
restore

/* Secondary outcomes */

// Analyse non-normally distributed outcomes
local outcomes_cont "mment_vent_dur dur_chestopen mment_vent_nohrs mment_vent_rrthrs picu_troponin*"
foreach v of varlist `outcomes_cont' {

	* Descriptive statistics
	hist `v'
	qnorm `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
		
	* Primary analysis and sensitivity analysis
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(2).site b(1).dem_gender
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_pathophys b(2).site
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_pathophys b(2).site
	restore
	
	* Subgroup analysis: age group - interaction
	capture noisily xi: qreg `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys b(2).site
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	capture noisily xi: qreg `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(2).site b(1).dem_gender
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_age b(2).site
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	capture noisily xi: qreg `v' b(1).rand_group b(2).rand_age b(2).site
	restore

	* Physiology - interaction
	xi: meglm `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	capture noisily xi: qreg `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(2).site b(1).dem_gender
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r

}

// Analyse normally-distributed continuous outcomes
local outcomes_cont "picu_pelod2_* picu_creatinine*"
foreach v of varlist `outcomes_cont' {

	* Descriptive statistics
	hist `v'
	qnorm `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
		
	* Primary analysis and sensitivity analysis
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	xi: meglm `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: meglm `v' b(1).rand_group b(2).rand_pathophys || site:
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: meglm `v' b(1).rand_group b(2).rand_pathophys || site:
	restore
	
	* Subgroup analysis: age group - interaction
	xi: meglm `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	xi: meglm `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: meglm `v' b(1).rand_group b(2).rand_age || site:
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: meglm `v' b(1).rand_group b(2).rand_age || site:
	restore

	* Physiology - interaction
	xi: meglm `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r
	xi: meglm `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:
	* Test assumptions
	predict pr, xb
	predict r, residuals
	scatter r pr
	drop pr r

}

// Analyse binary outcomes
local outcomes_binary "picu_lcos_any ecls_48hr death_28day comp_outcome mment_vent_no mment_rrt_pd_crrt picu_aki0_yn picu_aki24_yn picu_aki48_yn ae_any ae_related_any"
foreach v of varlist `outcomes_binary' {

	* Descriptive statistics
	tab `v' rand_group, m col
	tab `v' rand_group, col
	
	* Primary analysis and sensitivity analyses
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	tab `v' rand_group, m col
	tab `v' rand_group, col
	xi: melogit `v' b(1).rand_group b(2).rand_pathophys || site:, or
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	tab `v' rand_group, m col
	tab `v' rand_group, col
	xi: melogit `v' b(1).rand_group b(2).rand_pathophys || site:, or
	restore
	
	* Subgroup analysis: age group - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	tab `v' rand_group, m col
	tab `v' rand_group, col
	xi: melogit `v' b(1).rand_group b(2).rand_age || site:, or
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	tab `v' rand_group, m col
	tab `v' rand_group, col
	xi: melogit `v' b(1).rand_group b(2).rand_age || site:, or
	restore

	* Physiology - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	
}

// Analyse survival outcomes
local outcomes_surv "los_picu los_hosp"
foreach v of varlist `outcomes_surv' {

	* Descriptive statistics
	hist `v'
	qnorm `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
		
	* Primary analysis and sensitivity analyses
	stset `v', failure(`v'_event)
	xi: mestreg b(1).rand_group b(2).rand_pathophys b(2).rand_age || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'
	xi: mestreg b(1).rand_group b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'
	
	* Subgroup analysis: age group <6 weeks
	preserve
	keep if rand_age==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: mestreg b(2).rand_group b(2).rand_pathophys || site:, distribution(weibull)
	restore

	* Subgroup analysis: age group >=6 weeks
	preserve
	keep if rand_age==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: mestreg b(2).rand_group b(2).rand_pathophys || site:, distribution(weibull)
	restore
	
	* Subgroup analysis: age group - interaction
	xi: mestreg b(1).rand_group##b(2).rand_age b(2).rand_pathophys || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'
	xi: mestreg b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'
	
	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: mestreg b(1).rand_group b(2).rand_age || site:, distribution(weibull)
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	hist `v'
	tabstat `v', by(rand_group) stats(n mean sd min max q iqr)
	xi: mestreg b(1).rand_group b(2).rand_age || site:, distribution(weibull)
	restore

	* Physiology - interaction
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'
	xi: mestreg b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, distribution(weibull)
	* Test assumptions
	predict s, surv
	gen lnls=log(-1*log(s))
	gen log_`v'=log(`v')
	scatter lnls log_`v'
	drop s lnls log_`v'

}

* Generate Kaplan-Meier curves
stset los_picu, failure(los_picu_event)
sts graph, by(rand_group) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) title("") scheme(s1mono) ///
		legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of remaining in ICU") xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ytick(0(0.2)1) ylabel(0(0.2)1, format(%4.1f))
stset los_hosp, failure(los_hosp_event)
sts graph, by(rand_group) xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) title("") scheme(s1mono) ///
		legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of remaining in hospital") xtick(0(4)28) xlabel(0(4)28) xscale(range (0 28)) ytick(0(0.2)1) ylabel(0(0.2)1, format(%4.1f))

// Analyse AKI timepoints
local aki_timepoints "picu_aki0 picu_aki24 picu_aki48"
foreach v of varlist `aki_timepoints' {

	* Descriptive statistics and unadjusted p-value
	tab `v' rand_group, m col
	tab `v' rand_group, col

	** Primary analysis
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr

	** Subgroup analysis
	* Age group - <6 weeks
	preserve
	keep if rand_age==1
	tab `v' rand_group, m col
	tab `v' rand_group, col
	restore

	* Age group - >=6 weeks
	preserve
	keep if rand_age==2
	tab `v' rand_group, m col
	tab `v' rand_group, col
	restore

	* Age group - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group##b(2).rand_age b(2).rand_pathophys perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr

	* Physiology - univentricular
	preserve
	keep if rand_pathophys==1
	tab `v' rand_group, m col
	tab `v' rand_group, col
	restore

	* Physiology - biventricular
	preserve
	keep if rand_pathophys==2
	tab `v' rand_group, m col
	tab `v' rand_group, col
	restore

	* Physiology - interaction
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
	xi: melogit `v' b(1).rand_group##b(2).rand_pathophys b(2).rand_age perfusion_cpb_total surg_rachs perfusion_prime_any b(1).dem_gender || site:, or
	* Test assumptions
	linktest, nolog
	predict p
	predict devr, dev
	scatter devr p, yline(0) mlabel(record_id)
	drop p devr
}

// Sensitivity analysis using multiple imputation for the primary outcome
mi register imputed vfd
mi impute chained (regress) vfd = rand_group site rand_pathophys rand_age, add(10) rseed(54321) savetrace(trace1,replace)

* Re-run the primary analysis
xi: qreg vfd b(1).rand_group b(2).rand_age b(2).rand_pathophys b(2).site
stset days, failure(outcome_cc=1)
xi: stcrreg b(1).rand_group b(2).rand_age b(2).rand_pathophys, compete(outcome_cc=2) // needed for the graph
matrix coeff_mi=e(b)
mata : st_matrix("coeff_shr_mi", exp(st_matrix("coeff_mi")))
stcurve, cif at1(rand_group=1) at2(rand_group=2) title("") scheme(s1mono) ///
		 legend(lab(1 "Standard Care") lab(2 "Nitric Oxide")) xtitle("Days since start of cardiopulmonary bypass") ///
		 ytitle("Probability of extubation") lpattern(dash)
		 
/*** Supplementary Material: Adverse Events ***/
preserve
use "OutputData\ae_long0.dta", clear
tab ae_term_gr rand_group, m col
tab ae_term_gr rand_group, col
tab ae_druga rand_group, m col
tab ae_druga rand_group, col
restore

// Any AE/SAE
tab ae_any rand_group, m col
tab ae_any rand_group, col

/*** Supplementary Material: Protocol Deviations ***/
tab 
preserve
use "OutputData\pd_long0.dta", clear
tab pd_d1_details rand_group, m col
tab pd_d1_algorith rand_group if pd_d1_details==2, m col
restore

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



