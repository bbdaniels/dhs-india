// BP Venn diagram

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
  
  preserve
    keep if male == 1
    pvenn shb18 shb19 bp_high , xscale(noline) yscale(noline)
    graph save "${directory}/outputs/bp-paper/f-bp-venn-m.gph" , replace
  restore
  preserve
    keep if male == 0
    pvenn shb18 shb19 bp_high , xscale(noline) yscale(noline)
    graph save "${directory}/outputs/bp-paper/f-bp-venn-f.gph" , replace
    
    // Needs manual adjustments for final figure
    graph combine ///
      "${directory}/outputs/bp-paper/f-bp-venn-f.gph" ///
      "${directory}/outputs/bp-paper/f-bp-venn-m.gph" ///
    , r(1)
     
     graph save "${directory}/outputs/bp-paper/f-bp-venn.gph" , replace
    // graph export "${directory}/outputs/bp-paper/f-bp-venn.png" , replace
    
// BP Definition

  use "${directory}/constructed/individuals.dta" ///
    if !missing(shb18) , clear
    
  histogram bp_sys ///
  , s(53) w(1) gap(10) lc(none) fc(gray) xline(140) frac  ///
    xtit(" ") ytit(" xx ", color(white)) xscale(off range(50 260)) ///
    ylabel(0 .01 .02 .03 "100",labcolor(white)) fysize(20)
  
    graph save "${directory}/outputs/bp-paper/f-bp-sys.gph" , replace
  
  tw histogram bp_dia ///
  , s(53) w(1) gap(10) lc(none) fc(gray) yline(90) frac hor ///
    xtit(" ") ytit(" ") ylab(30 60 90 120 150) yscale(off range(30 180)) ///
    xlabel(0 .01 .02 .03 ,labcolor(white)) fxsize(20)
    
    graph save "${directory}/outputs/bp-paper/f-bp-dia.gph" , replace
  
  tw ///
    (bar bp_dia bp_sys in 1 if bp_dia > 200 , fc(gray) lc(none)) ///
    (bar bp_dia bp_sys in 1 if bp_dia > 200 , fc(black) lc(none)) ///
    (bar bp_dia bp_sys in 1 if bp_dia > 200 , fc(red) lc(none)) ///
    (scatter bp_dia bp_sys  ///
      if (bp_sys < 140 & bp_dia >= 90) ///
       | (bp_sys >= 140 & bp_dia < 90) ///
      , m(.) msize(tiny) mc(gray%1) lc(none)) ///
    (scatter bp_dia bp_sys   ///
      if bp_sys < 140 & bp_dia < 90 ///
      , m(.) msize(tiny) mc(black%1) lc(none)) ///
    (scatter bp_dia bp_sys  ///
      if bp_sys >= 140 & bp_dia >= 90 ///
      , m(.) msize(tiny) mc(red%1) lc(none)) ///
  , xlab(60 100 140 180 220) ylab(30 60 90 120 150) ///
    xline(140) yline(90) xscale(range(50 260)) yscale(range(30 180)) ///
    xtit("Systolic Blood Pressure") ytit("Diastolic Blood Pressure") ///
    legend(on region(lc(none)) pos(11) ring(0) c(1) size(small) ///
      order(2 "Not Considered Hypertensive" ///
            3 "Hypertensive by Either Measure" ///
            1 "Hypertensive by Only One Measure"))
  
  graph save "${directory}/outputs/bp-paper/f-bp-scatter.gph" , replace
  
  graph combine ///
    "${directory}/outputs/bp-paper/f-bp-sys.gph" ///
    "${directory}/outputs/bp-paper/f-bp-scatter.gph" ///
    "${directory}/outputs/bp-paper/f-bp-dia.gph" ///
  , holes(2) imargin(zero) 
  
  graph export "${directory}/outputs/bp-paper/f-bp-scatter.png" , replace


// BP detection and treatment by Gender along Age

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
    
  tab bp_cat, gen(bp_cat)
    replace bp_cat2 = bp_cat1 + bp_cat2
    replace bp_cat3 = bp_cat3 + bp_cat2
    
  preserve
    collapse (mean) bp_cat? [iweight=wgt] , by(male age) fast
      
    tw ///
      (area bp_cat3 age , lw(none) fc(navy%50)) ///
      (area bp_cat2 age , lw(none) fc(navy)) ///
      (area bp_cat1 age , lw(none) fc(black)) ///
    , by( male , ixaxes ///
          legend(pos(12)  size(small) ) ///
          note(" ") c(1) ) ///
      ysize(5) ///
      xtit("    Age {&rarr}" , placement(left)) xlab(15(5)55)  ///
      ylab(0 "0%" .1 "10%" .2 "20%".3 "30%" .4 "40%") ///
      legend(region(lc(none)) r(1) symxsize(small) symysize(small) ///
        order(1 "Controlled" 2 "Uncontrolled" 3 "Undiagnosed"))
    
      graph export "${directory}/outputs/bp-paper/f-bp-male.png" , replace
      restore, not
      
// BP detection and treatment by Gender along SES

use "${directory}/constructed/individuals.dta" ///
  if !missing(shb18) , clear
    
  xtile ses = hh_ses , n(100)
  
  tab bp_cat, gen(bp_cat)
    replace bp_cat2 = bp_cat1 + bp_cat2
    replace bp_cat3 = bp_cat3 + bp_cat2
    
  preserve
    collapse (mean) bp_cat? [iweight=wgt] , by(male ses) fast
      
    tw ///
      (area bp_cat3 ses , lw(none) fc(navy%50)) ///
      (area bp_cat2 ses , lw(none) fc(navy)) ///
      (area bp_cat1 ses , lw(none) fc(black)) ///
    , by( male , ixaxes ///
          legend(pos(12)  size(small) ) ///
          note(" ") c(1) ) ///
      ysize(5) ///
      xtit("    Socioeconomic Status Percentile {&rarr}" , placement(left)) xlab(0 "1st" 50 "Median SES" 100 "99th")  ///
      ylab(0 "0%" .1 "10%" .2 "20%") ///
      legend(region(lc(none)) r(1) symxsize(small) symysize(small) ///
        order(1 "Controlled" 2 "Uncontrolled" 3 "Undiagnosed"))
    
      graph export "${directory}/outputs/bp-paper/f-bp-ses.png" , replace
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
    collapse (mean) bp_cat? [iweight=wgt] , by(male agecat ses) fast
    
    tw ///
      (area bp_cat3 ses , lw(none) fc(navy%50)) ///
      (area bp_cat2 ses , lw(none) fc(navy)) ///
      (area bp_cat1 ses , lw(none) fc(black)) ///
    , by( male agecat  , iyaxes ixaxes colfirst holes(4) c(2) ///
        legend(pos(12)  size(small) ) ///
        note(" ")) ///
      xtit(" ") xlab(0 "1st" 50 "Median SES" 100 "99th") ///
      ysize(7) ylab(0 "0%" .5 "50%" 1 "100%") ///
      legend(region(lc(none)) r(1) symxsize(small) symysize(small) ///
        order(1 "Controlled" 2 "Uncontrolled" 3 "Undiagnosed"))
                
      graph export "${directory}/outputs/bp-paper/f-bp-ses-male.png" , replace
      restore, not

// All-causes in data by SES

use "${directory}/constructed/individuals.dta" , clear

  gen bp_un = (bp_cat == 1) if !missing(bp_cat)
  gen bp_di = (bp_cat == 2 | bp_cat == 3) if !missing(bp_cat)
  
  xtile ses = hh_ses , n(100)
  
  preserve
    collapse (mean) bp_un bp_di tb anemia glucose [iweight=wgt], by(male ses) fast
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
 
