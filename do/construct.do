// Construct individual-level records

// Get HIV results -------------------------------------------------------------

use "${directory}/data/AR72.dta" , clear
  duplicates drop hiv01, force // 5 duplicates pairs, all negative results
  clonevar hv001 = hivclust // Create matching variable for PR dataset
  clonevar hv002 = hivnumb // Create matching variable for PR dataset
  clonevar hvidx = hivline // Create matching variable for PR dataset
  tempfile hiv
  save `hiv'

// Open individual records -----------------------------------------------------
use "${directory}/data/PR74.dta" , clear
  merge m:1 hv001 hv002 hvidx using `hiv' , nogen

// Generate new SES variable ---------------------------------------------------
pca hv206 hv207 hv208 hv209 hv210 hv211 hv212 hv221 hv243a hv243b hv243c hv247
  predict hh_ses

  xtile hh_ses_bin = hh_ses , n(5)
    lab var hh_ses_bin "SES Quintile"

// Clean existing raw variables ------------------------------------------------
  lab var sh24 "TB (Self-Reported)"
  lab var shb18 "High BP (Told by Doctor)"
  lab var shb19 "Taking BP Meds"
  lab var shb70 "Glucose Level"

  // Survey codes
  foreach var of varlist ha53 hb53 hc53 shb??s shb2?d shb70 {
    replace `var' = . if `var' > 990
  }

// Construct variables
  recode hv104 (1 = 1 "Male")(2 = 0 "Female") , gen(male)
    lab var male "Male"

  clonevar bp = shb18
  clonevar bp_med = shb19
  clonevar tb = sh24

// Check BP --------------------------------------------------------------------
  // https://www.nice.org.uk/guidance/ng136/chapter/Recommendations#diagnosing-hypertension
  egen bp_sys = rowmin(shb??s)
  egen bp_dia = rowmin(shb2?d)

  gen bp_high = (bp_sys > 140) if !missing(bp_sys)
    lab var bp_high "High BP (Measured)"

  gen bp_treat = (bp_med == 1) if (bp == 1) & (!missing(bp) & !missing(bp_med))
    lab var bp_treat "On Meds if Told"
  gen bp_control = (bp_high == 0) if (bp == 1) & (!missing(bp) & !missing(bp_high))
    lab var bp_control "Low BP if Told"
  gen bp_nocontrol = (bp_high == 1) if (bp == 1) & (!missing(bp) & !missing(bp_high))
    lab var bp_nocontrol "High BP if Told"

// Generate derived conditions -------------------------------------------------
  gen hiv = (hiv03 == 1) if !missing(hiv03)
    lab var hiv "HIV"
  gen anemia_raw = min(ha57,hb57,hc57) ///
    if !(missing(ha57) & missing(hb57) & missing(hc57))
    lab var anemia_raw "Anemia Level (Lowest = Worst)"
  gen anemia = (anemia_raw < 3) if !missing(anemia_raw)
    lab var anemia "Moderate or Severe Anemia"
  gen glucose = shb70 > 125 if !missing(shb70)
    lab var glucose "Glucose > 125"

// Gen missingness indicators
  gen miss_tb = missing(sh24)
    lab var miss_tb "Missing TB Self-Report"
  gen miss_bp1 = missing(shb18)
    lab var miss_bp1 "Missing BP Self-Report"
  gen miss_bp2 = missing(bp_high)
    lab var miss_bp2 "Missing BP Measurement"
  gen miss_bp3 = missing(shb19)
    lab var miss_bp3 "Missing BP Meds Report"
  gen miss_glu = missing(shb70)
    lab var miss_glu "Missing Glucose Measure"
  gen miss_hiv = missing(hiv)
    lab var miss_hiv "Missing HIV Testing"

// Save ------------------------------------------------------------------------

save "${directory}/constructed/individuals.dta" , replace

// End of dofile
