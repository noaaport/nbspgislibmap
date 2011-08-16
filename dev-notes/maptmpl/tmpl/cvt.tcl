#!/usr/bin/tclsh

package require fileutil;

lappend auto_path ".";

set map(imagetype) "png";
set map(awips1) "n0v";
set map(mapfonts) "mapfonts" 
set map(geodata) "geodata";

set name "nexrad";
set datafile datafile;

foreach mapname [list rvel rvel_1] {
    set tmpl "map_rad_${mapname}.tmpl";
    set tmap [file join ".." "tmap" "${mapname}.tmap"]; 
    source $tmpl;
    ::fileutil::writeFile $tmap [subst $nexrad];
}
