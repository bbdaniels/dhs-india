// Construct GPS linking

ssc install shp2dta, replace

shp2dta using "/Users/bbdaniels/Box/India DHS/GPS/IAGE71FL/IAGE71FL.shp" ///
  , data("${directory}/constructed/gps-db.dta") ///
    coord("${directory}/constructed/gps.dta") ///
    genid(ID) replace



// End of dofile
