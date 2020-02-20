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
pca hv206 hv207 hv208 hv209 hv210 hv211 hv212 hv221 hv242 hv243a hv243b hv243c hv247
  predict hh_ses

// Check BP --------------------------------------------------------------------
  // https://www.nice.org.uk/guidance/ng136/chapter/Recommendations#diagnosing-hypertension
  egen bp_sys = rowmin(shb??s)
  egen bp_dia = rowmin(shb2?d)

  gen bp_high = (bp_sys > 140) if !missing(bp_sys)
    lab var bp_high "High BP (Measured)"

// Generate derived conditions -------------------------------------------------
  gen hiv = (hiv03 == 1)
    lab var hiv "HIV"
  gen anemia_raw = min(ha57,hb57,hc57)
    lab var anemia_raw "Anemia Level (Lowest = Worst)"
  gen anemia = (anemia_raw < 3)
    lab var anemia "Moderate or Severe Anemia"
  gen glucose = shb70 > 125
    lab var glucose "Glucose > 125"

  gen bp_control = (shb19 == 1) & (bp_high == 1 | shb18 == 1) ///
    if !(missing(bp_high) & missing(shb18))
    lab var bp_control "BP Diagnosed & Controlled"

// Label existing raw variables ------------------------------------------------
  lab var sh24 "TB (Self-Reported)"
  lab var shb18 "High BP (Told by Doctor)"
  lab var shb19 "Taking BP Meds"
  lab var shb70 "Glucose Level"

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
