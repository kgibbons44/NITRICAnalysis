/**** NITRIC DATA TRANSFORMATION ****/
/**** Prepared by: Kristen Gibbons ****/
/**** Date initialised: 12/05/2020 ****/
/**** Purpose: Transformation of NITRIC data for analysis ****/

// Number of infants screened for eligibility
count if screening_dt~=.

// Number of infants who did not meet each inclusion criteria
gen inclusion_didnt_meet=0
foreach i of numlist 1/3 {
	tab inclusion_`i', m
	replace inclusion_didnt_meet=1 if inclusion_`i'==0
}
tab inclusion_didnt_meet, m

// Number of infants who met each exclusion criteria
gen exclusion_met=0
foreach i of numlist 1/4 {
	tab exclusion_`i', m
	replace exclusion_met=1 if exclusion_`i'==1
}
tabstat exclusion_5, stats(n mean sd min max q iqr)
gen exclusion5_met=1 if exclusion_5>=15 & exclusion_5~=.
replace exclusion_met=1 if exclusion5_met==1
tab exclusion5_met, m
replace exclusion5_met=1 if exclusion5_met==1
foreach i of numlist 6/8 {
	tab exclusion_`i', m
	replace exclusion_met=1 if exclusion_`i'==1
}
tab exclusion_other, m
tab exclusion_other_comment
tab exclusion_met, m

// Number of infants who were eligible
tab eligibility_status, m
tab eligibility_status

// Number of infants who were missed
tab scn_missed_yn if eligibility_status==1 & consent_attempt==0, m
tab scn_missed_yn

// Reasons for missed
desc scn_non_consent_reason*
foreach i of numlist 0/14 {
	tab scn_non_consent_reason___`i'
}
foreach i of numlist 16/28 {
	tab scn_non_consent_reason___`i'
}
tab exclusion_other
* Collapse exclusion criteria into pre-defined categories
gen not_enrol_declined=1 if consent_outcome==1
gen not_enrol_notapproached=1 if scn_non_consent_reason___4==1 | scn_non_consent_reason___5==1 | scn_non_consent_reason___6==1 | scn_non_consent_reason___7==1 | ///
								 scn_non_consent_reason___8==1 | scn_non_consent_reason___9==1 | scn_non_consent_reason___10==1 | scn_non_consent_reason___11==1 | ///
								 scn_non_consent_reason___18==1 | scn_non_consent_reason___19==1 | scn_non_consent_reason___20==1 | scn_non_consent_reason___21==1
gen not_enrol_nocpb=1 if exclusion_other==5
gen not_enrol_resourcing=1 if scn_non_consent_reason___2==1 | scn_non_consent_reason___17==1 | scn_non_consent_reason___22==1 | scn_non_consent_reason___23==1 | ///
							  scn_non_consent_reason___24==1 | exclusion_other==2 | exclusion_other==3
gen not_enrol_covid19=1 if scn_non_consent_reason___27==1 | scn_non_consent_reason___28==1
gen not_enrol_other=1 if scn_non_consent_reason___3==1 | scn_non_consent_reason___12==1 | scn_non_consent_reason___13==1 | scn_non_consent_reason___14==1 | ///
						 scn_non_consent_reason___16==1 | scn_non_consent_reason___26==1 | scn_non_consent_reason___25==1 | scn_non_consent_reason___0==1 | exclusion_other==4 | exclusion_other==6
foreach v of varlist not_enrol_* {
	tab `v'
}
count if not_enrol_declined==1 | not_enrol_notapproached==1 | not_enrol_nocpb==1 | not_enrol_resourcing==1 | not_enrol_covid19==1 | not_enrol_other==1
count if not_enrol_declined==1 | not_enrol_notapproached==1 | not_enrol_nocpb==1 | not_enrol_resourcing==1 | not_enrol_covid19==1 | not_enrol_other==1 | inclusion_didnt_meet==1 | exclusion_met==1

// Consent outcome
tab consent_attempt, m
tab consent_outcome if consent_attempt==1, m

// Number of infants who withdrew from the study
tab withdraw_yn, m
tab withdraw_party if withdraw_yn==1, m
foreach i of numlist 1/5 {
	tab withdraw_data_use___`i' if withdraw_yn==1
}
