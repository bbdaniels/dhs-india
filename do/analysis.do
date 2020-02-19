// Graph relationship between SES and conditions

use "${directory}/constructed/individuals.dta" ///
  if hh_ses < 4.5 , clear // if hh_ses < 4.5

// Glucose & Diabetes
tw ///
  (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
  (lpoly glucose hh_ses , lw(thick)) ///
  (lpoly shb70 hh_ses , lw(thick) yaxis(3)) ///
, ${hist_opts} ytit(" " , ax(1)) ytit(" " , ax(3)) xtit("HH SES") ///
  title("Glucose and Diabetes") ///
  legend(on order(2 "Glucose > 125" 3 "Glucose Level")) ///
  yscale(alt ax(1))

  graph export "${directory}/outputs/ses_glucose.eps" , replace

// Blood Pressure and Management
tw ///
  (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
  (lpoly shb18 hh_ses , lw(thick)) ///
  (lpoly bp_high hh_ses , lw(thick)) ///
  (lpoly bp_control hh_ses , lw(thick) ) ///
, ${hist_opts} ytit(" ") xtit("HH SES") ///
  title("High Blood Pressure and Treatment") ///
  legend(on c(1) pos(11) ring(0) order(2 "High BP (Told by Doctor)" 3 "High BP (Measured)" ///
    4 "Diagnosed (Either) & Controlled"))

  graph export "${directory}/outputs/ses_bp.eps" , replace

// Anemia
tw ///
  (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
  (lpoly anemia hh_ses if ha57 != ., lw(thick)) ///
  (lpoly anemia hh_ses if hb57 != ., lw(thick)) ///
  (lpoly anemia hh_ses if hc57 != ., lw(thick) ) ///
, ${hist_opts} ytit(" ") xtit("HH SES") ///
  title("Moderate or Severe Anemia") ///
  legend(on order(2 "Women" 3 "Men" 4 "Children"))

  graph export "${directory}/outputs/ses_anemia.eps" , replace

// HIV
tw ///
  (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
  (lpoly hiv hh_ses if ha62 != "", lw(thick)) ///
  (lpoly hiv hh_ses if hb62 != "", lw(thick)) ///
, ${hist_opts} ytit(" ") xtit("HH SES") ///
  title("HIV") ///
  legend(on order(2 "Women" 3 "Men"))

  graph export "${directory}/outputs/ses_hiv.eps" , replace

// TB
tw ///
  (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
  (lpoly sh24 hh_ses if hv104 == 2, lw(thick)) ///
  (lpoly sh24 hh_ses if hv104 == 1, lw(thick)) ///
, ${hist_opts} ytit(" ") xtit("HH SES") ///
  title("Tuberculosis") ///
  legend(on order(2 "Women" 3 "Men"))

  graph export "${directory}/outputs/ses_tb.eps" , replace

-
foreach var in sh24 hiv anemia_raw anemia shb18 bp_high glucose shb70 shb19 {

  local title : var lab `var'

  tw ///
    (histogram hh_ses , yaxis(2) lw(none) fc(gs12) ) ///
    (lpoly `var' hh_ses , lw(thick)) ///
  , ${hist_opts} ytit("Prevalence") xtit("HH SES") ///
    title("`title'")

    graph export "${directory}/outputs/ses_`var'.eps" , replace

}




// End of dofile