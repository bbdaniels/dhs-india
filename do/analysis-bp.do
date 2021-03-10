// BP Venn diagram

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
  
  // pvenn shb18 shb19 bp_high
    // Needs manual adjustments for final figure
    
  tw ///
    (histogram bp_sys if shb18 == 1 & bp_sys >= 50 ///
      , s(50) w(10) gap(10) lc(none) fc(gray) frac) ///
  , xtit("Measured Systolic Blood Pressure") xlab(60(20)240) xline(140) ///
    ytit(" ") ylab(0 "0%" .05 "5%" .1 "10%" .15 "15%" .2 "20%" .25 "25%")
    
    graph export "${directory}/outputs/bp-paper/f-warned-histo.png" , replace
    
// BP detection and treatment by Gender along Age

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
    
  tab bp_cat, gen(bp_cat)
    replace bp_cat2 = bp_cat3 + bp_cat2
    replace bp_cat1 = bp_cat1 + bp_cat2
    
  preserve
    collapse (mean) bp_cat?  , by(male age) fast
      
    tw ///
      (area bp_cat1 age , lw(none) fc("73 70 68")) ///
      (area bp_cat2 age , lw(none) fc("219 112 41")) ///
      (area bp_cat3 age , lw(none) fc("24 105 109")) ///
    , by( male , ixaxes ///
          legend(pos(3)  size(small) ) ///
          note(" ") c(1) ) ///
      xtit("    Age {&rarr}" , placement(left)) xlab(15(5)55)  ///
      ylab(0 "0%" .1 "10%" .2 "20%") ///
      legend(region(lc(none)) c(1) symxsize(small) symysize(small) ///
        order(1 "Undiagnosed:" ///
                0 "Not warned, and" 0 "Measured >140" 0 " " ////
              2 "Uncontrolled:" ///
                0 "Warned, but" 0 "Measured >140" 0 " " ///
              3 "Controlled:" ///
                0 "Warned, but" 0 "Measured <140" ))
    
      graph export "${directory}/outputs/bp-paper/f-bp-age-male.png" , replace
      restore, not

// BP detection and treatment by Age/Gender along SES

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
  
  xtile ses = hh_ses , n(100)
  egen agecat = cut(age) , at(15 35 45 50 55)
    lab def agecat 15 "Age 15-34" 35 "Age 35-44" 45 "Age 45-49" 50 "Age 50-54"
    lab val agecat agecat
    
  tab bp_cat, gen(bp_cat)
    replace bp_cat2 = bp_cat1 + bp_cat2
    replace bp_cat3 = bp_cat3 + bp_cat2
    
  preserve
    drop if bp_cat == 4
    collapse (mean) bp_cat?  , by(male agecat ses) fast
    
    tw ///
      (area bp_cat3 ses , lw(none)) ///
      (area bp_cat2 ses , lw(none)) ///
      (area bp_cat1 ses , lw(none)) ///
    , by( male agecat  , iyaxes ixaxes colfirst holes(4) c(2) ///
        legend(pos(12)  size(small) ) ///
        note(" ")) ///
      xtit(" ") xlab(0 "1st" 50 "Median SES" 100 "99th") ///
      ysize(7) ylab(0 "0%" .5 "50%" 1 "100%") ///
      legend(c(2) colfirst size(small) region(lc(none)) ///
        symxsize(small) symysize(small) ///
        order(0 "Among Individuals Warned:" ///
                1 "Measured < 140 (Controlled)" ///
                2 "Measured > 140 (Uncontrolled)" ///
              0 "Among Individuals Not Warned:" ///
                3 "Measured > 140 (Undiagnosed)"))
                
      graph export "${directory}/outputs/bp-paper/f-bp-ses-male.png" , replace
      restore, not

// All-causes in data by SES

use "${directory}/constructed/individuals.dta" , clear

  gen bp_un = (bp_cat == 1) if !missing(bp_cat)
  gen bp_di = (bp_cat == 2 | bp_cat == 3) if !missing(bp_cat)
  
  xtile ses = hh_ses , n(100)
  
  preserve
    collapse (mean) bp_un bp_di tb anemia glucose , by(male ses) fast
      lab var bp_un "BP: Undiagnosed"
      lab var bp_di "BP: Diagnosed"
      lab var glucose "Glucose"
      lab var anemia "Anemia"
      lab var tb "Tuberculosis"
    
    foreach var of varlist tb bp_un bp_di anemia glucose {
      
      local title : var lab `var'
  
      tw ///
        (area `var' ses if male == 0,  lw(none)  ) ///
        (area `var' ses if male == 1,  lw(none)  ) ///
     , by(male , iyaxes note(" ") legend(off) ) ///
       legend(off)  ///
       xtit(" ") xlab(0 "1st" 50 "Median SES" 100 "99th") ///
       ytit("`title'") yscale(r(0)) ylab(#6)
     
     graph save "${directory}/outputs/bp-paper/f-ses-`var'.gph" , replace
     
   }
   
    graph combine ///
      "${directory}/outputs/bp-paper/f-ses-bp_di.gph" ///
      "${directory}/outputs/bp-paper/f-ses-bp_un.gph" ///
      "${directory}/outputs/bp-paper/f-ses-glucose.gph" ///
      "${directory}/outputs/bp-paper/f-ses-anemia.gph" ///
      "${directory}/outputs/bp-paper/f-ses-tb.gph" ///
    , c(1) ysize(7) imargin(zero)
    
      graph export "${directory}/outputs/bp-paper/f-ses-all.png" , replace
      restore, not
   
   
// End of do-file
 
