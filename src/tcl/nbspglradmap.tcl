#!%TCLSH%
#
# $Id$
#
# Usage:
# nbspglradmap [-b] [-k] [-e extent] [-m | -M maptemplate] [opts] <nids_file(s)>
#
# -k => keep the shapefiles created
# -e => override the default extent calculation
# -m => override the default map template determination (use as is)
# -M => same as -m but look for map in the std directories
# -b,d,f,g,o,s,t,D => are passed to nbspglmap intact
#
# Example: nbspglradmap n0rjua_20110808_1948.nids
#
# Assumptions -
#
# The inputfile name has the format
#
# <awips><anything>.nids
#
# Then from the the <awips> the map template to use is determined as well
# as the extent (for the site).
#
# The input file(s) can be given in the command line argument or in stdin.
# When there is more than one file, all must be of the same type (e.g. n0r).
#
package require cmdline;

# Once and for all (assumes a "standard" dir tree)
set basedir [file join [file dirname [info script]] ".."];
set sharedir [file join $basedir "share" "nbspgislib"];

lappend auto_path [file join $sharedir];
package require "nbsp::radstations";

proc err {s} {

    puts stderr $s;
    exit 1;
}

proc verify_inputfile_namefmt {inputfile} {

    set fbasename [file tail $inputfile];
    set re {^[[:alnum:]]{6}.+\.nids$};

    if {[regexp $re $fbasename] == 0} {
	return -code error "Invalid input file name: $inputfile";
    }
}

proc select_mapname {awips1} {

    if {[regexp {^n.(r|q|z)$} $awips1]} {
	set mapname "bref";
    } elseif {[regexp {^n.(u|v)$} $awips1]} {
	set mapname "rvel";
    } else {
	return -code error "Unsupported nids type";
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
# init
#
#
# init
#
set usage {nbspglradmap [-b] [-k] [-d outputdir] [-e extent]
    [-f mapfontsdir] [-g geodatadir] [-m | -M maptemplate] [-o outputname]
    [-s size] [-t imagetype] [-D <defs>]
    <nidsfile_1> ... <nidsfile_n>};

set optlist {b k {d.arg ""} {D.arg ""} {e.arg ""} {f.arg ""}
    {g.arg ""} {m.arg ""} {M.arg ""} {o.arg ""} {s.arg ""} {t.arg ""}};

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

set sitelist [list];
foreach inputfile $inputfile_list {
    verify_inputfile_namefmt $inputfile;

    set awips [string range [file tail $inputfile] 0 5];
    set site [string range $awips 3 5];

    if {[info exists awips1] == 0} {
	set awips1 [string range $awips 0 2];
    } elseif {[string range $awips 0 2] ne $awips1} {
	err "Input files have different data type.";
    }

    lappend sitelist $site;
}

set mapname [select_mapname $awips1];

if {[regexp {^n.(r|v|z)} $awips1]} {
    set do_nbspunz 1;
    set extent [::nbsp::radstations::extent_bysitelist $sitelist];
} else {
    set do_nbspunz 0;
    if {[llength $sitelist] == 1} {
	set extent [::nbsp::radstations::extent_bysite $site 4];
    } else {
	set extent [::nbsp::radstations::extent_bysitelist $sitelist];
    }
}

set shpname_list [list];
foreach inputfile $inputfile_list {
    set shpname [file rootname [file tail $inputfile]];
    if {$do_nbspunz == 1} {
	exec nbspunz $inputfile | nbspradgis -C -n $shpname;
    } else {
	exec nbspradgis -n $shpname $inputfile;
    }
    lappend shpname_list $shpname;
}

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
puts $F [join $shpname_list "\n"];
close $F;

if {$option(k) == 0} {
    foreach ext [list "shp" "shx" "dbf" "info"] {
	foreach shpname $shpname_list {
	    set f ${shpname}.${ext};
	    file delete $f;
	}
    }
}
