// Master dofile for DHS India analysis


// Set global directory locations
global rawdata "/Users/bbdaniels/Box/India DHS/"
global directory "/Users/bbdaniels/GitHub/dhs-india/"

// Install packages ------------------------------------------------------------------------------
sysdir set PLUS "${directory}/ado/"

// Globals -------------------------------------------------------------------------------------

  // title
  global title justification(left) color(black) span pos(11)

  // Options for -twoway- graphs
  global tw_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
  	yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

  // Options for -graph- graphs
  global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))

  // Options for histograms
  global hist_opts ///
  	ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
  	ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

  // Useful stuff

  global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
  global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
  global bar lc(white) lw(thin) la(center) fi(100) // ← Remove la(center) for Stata < 15


// Part 1: Load datafiles into Git location ----------------------------------------------------

  foreach type in HR74 PR74 AR72 IR74 MR74 {
    copy "${rawdata}/DATA/IA`type'DT/IA`type'FL.dta" "${directory}/data/`type'.dta" , replace
  }







// End of dofile
