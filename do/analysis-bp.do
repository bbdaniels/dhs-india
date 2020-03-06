// BP detection and treatment by SES

use "${directory}/constructed/individuals.dta" , clear

foreach var in bp bp_treat bp_high bp_nocontrol {
  betterbar `var' , over(hh_ses_bin) ci v
  graph save "${directory}/outputs/bp_`var'.gph" , replace
  local graphs `" `graphs' "${directory}/outputs/bp_`var'.gph"  "'
}

graph combine `graphs'


graph export "${directory}/outputs/bp_main.pdf" , replace




// End of do-file
