#!%TCLSH%
#
# $Id$
#
# Usage:
# nbspglsatmap [-b] [-k] [-e extent] [-m | -M maptemplate] [opts] <gini_file(s)>
#
# -k => keep the shapefiles created
# -e => override the default extent calculation
# -m => override the default map template determination (use as is)
# -M => same as -m but look for map in the std directories
# -b,d,f,g,o,s,t,D => are passed to nbspglmap intact
# -r, -q => are passed to nbspsatgis intact 
#
# Example: nbspglsatmap tige01_20110818_1715.gini
#
# Assumptions -
#
# The inputfile name has the format
#
# <tigxxx><anything>.gini
#
# Then from the the <wmoid> the map template to use.
#
# The input file(s) can be given in the command line argument or in stdin.
#
package require cmdline;

# Once and for all (assumes a "standard" dir tree)
set basedir [file join [file dirname [info script]] ".."];
set sharedir [file join $basedir "share" "nbspgislib"];

lappend auto_path [file join $sharedir];
package require "nbsp::radstations";

set nbspglsatmap(ascfext) ".asc";

proc err {s} {

    puts stderr $s;
    exit 1;
}

proc verify_inputfile_namefmt {inputfile} {

    set fbasename [file tail $inputfile];
    set re {^[[:alnum:]]{6}.+\.gini$};

    if {[regexp $re $fbasename] == 0} {
	return -code error "Invalid input file name: $inputfile";
    }
}

proc select_mapname {wmoid} {

    if {[regexp {^tig} $wmoid]} {
	set mapname "tig";
    } else {
	return -code error "Unsupported type";
    }

    return $mapname;
}

proc check_conflicts {usage} {

    global option;

    set conflict_mM 0;
    
    if {$option(m) ne ""} {
	incr conflict_mM;
    }

    if {$option(M) ne ""} {
	incr conflict_mM;
    }

    if {$conflict_mM > 1} {
	err $usage;
    }
}

#
# Functions to support the determination of the default extent from
# the asc files themselves.
#
proc get_extent_from_ascfile_list {file_list} {
#
# This is the main function of the combo. The other two, next,
# are used in this one.
#
    set extent [list];

    foreach f $file_list {
	set new_extent [get_extent_from_ascfile $f];
	set extent [update_extent $extent $new_extent];
    }

    return $extent;
}

proc get_extent_from_ascfile {file} {

    set data [split [string trim [exec head -n 6 $file]] "\n"];
    foreach line $data {
	set key [lindex [split $line] 0];
	set val [lindex [split $line] 1];
	set a($key) $val;
    }

    set lon1 $a(xllcorner);
    set lat1 $a(yllcorner);
    set lon2 [expr $lon1 + $a(ncols) * $a(cellsize)];
    set lat2 [expr $lat1 + $a(nrows) * $a(cellsize)];

    return [list $lon1 $lat1 $lon2 $lat2];
}

proc update_extent {old_extent new_extent} {

    if {[llength $old_extent] == 0} {
	return $new_extent;
    }
    
    set lon1 [lindex $old_extent 0];
    set new [lindex $new_extent 0];
    if {$new < $lon1} {
	set lon1 $new;
    }

    set lat1 [lindex $old_extent 1];
    set new [lindex $new_extent 1];
    if {$new < $lat1} {
	set lat1 $new;
    }
    
    set lon2 [lindex $old_extent 2];
    set new [lindex $new_extent 2];
    if {$new > $lon2} {
	set lon2 $new;
    }

    set lat2 [lindex $old_extent 3];
    set new [lindex $new_extent 3];
    if {$new > $lat2} {
	set lat2 $new;
    }
    
    return [list $lon1 $lat1 $lon2 $lat2];
}

#
# init
#
#
# init
#
set usage {nbspglsatmap [-b] [-k] [-d outputdir] [-e extent]
    [-f mapfontsdir] [-g geodatadir] [-m | -M maptemplate] [-o outputname]
    [-q] [-r lon1,lat1,lon2,lat2] [-s size] [-t imagetype] [-D <defs>]
    <nidsfile_1> ... <nidsfile_n>};

set optlist {b k q {d.arg ""} {D.arg ""} {e.arg ""} {f.arg ""}
    {g.arg ""} {m.arg ""} {M.arg ""} {o.arg ""} {r.arg ""}
    {s.arg ""} {t.arg ""}};

array set option [::cmdline::getoptions argv $optlist $usage];
set argc [llength $argv];

check_conflicts $usage;

#
# main
#
if {$argc != 0} {
    set inputfile_list $argv;
} else {
    set inputfile_list [split [string trim [read stdin]]];
}

set regionlist [list];
foreach inputfile $inputfile_list {
    verify_inputfile_namefmt $inputfile;

    set wmoid [string range [file tail $inputfile] 0 5];
    set region [string range $wmoid 0 3];

    if {[info exists type] == 0} {
	set type [string range $wmoid 4 5];
    } elseif {[string range $wmoid 4 5] ne $type} {
	err "Input files have different data type.";
    }

    lappend regionlist $region;
}

set mapname [select_mapname $wmoid];

if {$option(r) ne ""} {
    set optr_list [split $option(r) ";"];
} else {
    set optr_list [list];
}

set ascfile_list [list];
foreach inputfile $inputfile_list {
    set ascname [file rootname [file tail $inputfile]];
    set cmd [list exec nbspunz $inputfile | nbspsatgis -A -n $ascname];

    if {[llength $optr_list] != 0} {
	set opts [list "-r" [lindex $optr_list 0]];
	set optr_list [lreplace $optr_list 0 0];
	if {$option(q) == 1} {
	    lappend opts "-q";
	}
	set cmd [concat $cmd $opts];
    }

    eval $cmd;

    lappend ascfile_list ${ascname}$nbspglsatmap(ascfext);
}

# Get the default extent from the asc files
set extent [get_extent_from_ascfile_list $ascfile_list];

set cmd [list "|nbspglmap"];

# The overrides
if {$option(e) ne ""} {
    lappend cmd "-e" $option(e);
} else {
    lappend cmd "-e" [join $extent ";"];
}

if {$option(M) ne ""} {
    lappend cmd "-M" $option(M);
} elseif {$option(m) ne ""} {
    lappend cmd "-m" $option(m);
} else {
    lappend cmd "-M" $mapname;
}

foreach k [list d D f g o s t] {
    if {$option($k) ne ""} {
	lappend cmd "-${k}" $option($k);
    }
}

set F [open [join $cmd] "w"];
puts $F [join $ascfile_list "\n"];
close $F;

if {$option(k) == 0} {
    foreach f $ascfile_list {
	file delete $f;
    }
}
