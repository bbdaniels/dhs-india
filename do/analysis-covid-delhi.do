// Get smoking from adults data
use "${directory}/data/IR74.dta" if v024 == 25, clear
  clonevar DHSCLUST = v001
  clonevar hv002 = v002

  gen smokes = 1-v463z
  keep smokes DHSCLUST hv002
  gen male = 0

  tempfile gis
  save `gis'

// Get smoking from adults data
use "${directory}/data/MR74.dta" if mv024 == 25, clear
  clonevar DHSCLUST = mv001
  gen smokes = 1-mv463z
  clonevar hv002 = mv002
  keep smokes DHSCLUST hv002
  gen male = 1

  append using `gis'
    tempfile indivs
    save `indivs'

  collapse (mean) smokes , by(DHSCLUST)
  save `gis' , replace

// Cheat for household risks
use "${directory}/constructed/individuals.dta" if hv024 == 25, clear
  clonevar DHSCLUST = hv001

  gen age = (hml16 >= 65)
  gen bp2 = (bp == 1 | bp_high == 1) if (!missing(bp) | !missing(bp_high))

  append using `indivs' , gen(fake)
    replace male = . if fake == 1

  collapse (sum) age bp2 male smokes (firstnm) hh_ses (count) n = male, by(DHSCLUST hv002)

  gen risk = 2*age + bp2 + smokes + male
-
// Get biomarker and age data from all-persons
use "${directory}/constructed/individuals.dta" if hv024 == 25, clear
  clonevar DHSCLUST = hv001

  gen age = (hml16 >= 65)
  gen bp2 = (bp == 1 | bp_high == 1) if (!missing(bp) | !missing(bp_high))

  collapse (mean) age bp2 male (count) n = male, by(DHSCLUST)
  merge 1:1 DHSCLUST using `gis' , keep(3) nogen

  save `gis' , replace

use "${directory}/constructed/gps-db.dta" , clear

  merge 1:m DHSCLUST using `gis' , keep(3)

  gen risk = 2*age + bp2 + smokes + male

  replace risk = 1.33 if risk > 1.5
  xtile r = risk , nq(4)
    replace r = 4
    replace r = 3 if risk < 1
    replace r = 2 if risk < 0.85
    replace r = 1 if risk < 0.65

  local o percent lc(black) la(center) start(0.5) w(.05)

  tw (histogram risk if r==1 , `o' fc("145 250 145")) ///
     (histogram risk if r==2 , `o' fc("250 250 115")) ///
     (histogram risk if r==3 , `o' fc("250 200 115")) ///
     (histogram risk if r==4 , `o' fc("250 115 145")) ///
     (kdensity risk , yaxis(2) lw(thick) lc(black)) ///
     , yscale(off axis(2)) ylab(0 "0%" 20 "5%" 40 "10%" 60 "15%") ///
       xscale(noline) yscale(noline) ytit("Share of clusters") ///
       xtit("Cluster-wide average risk score")

       graph export "/users/bbdaniels/desktop/delhi-risk.png" , width(2000) replace
-
  // KML

  gen icon = ""
    replace icon = "http://maps.google.com/mapfiles/kml/paddle/grn-blank.png" if r == 1
    replace icon = "http://maps.google.com/mapfiles/kml/paddle/ylw-blank.png" if r == 2
    replace icon = "http://maps.google.com/mapfiles/kml/paddle/orange-blank.png" if r == 3
    replace icon = "http://maps.google.com/mapfiles/kml/paddle/pink-blank.png" if r == 4

  dta2kml using "/users/bbdaniels/desktop/delhi-risk.kml" ///
  ,  lat(LATNUM) lon(LONGNUM) icons(icon) replace
// End of dofile
