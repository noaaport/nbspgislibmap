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
# -b,k,d,f,g,o,s,t,D => are passed to nbspglmap intact
#
# Example: nbspglradmap n0rjua_20110808_1948.nids
#
# Assumptions -
#
# The inputfile name has the format
#
# <awips><anything>[.nids]
#
# Then from the the <awips> the map template to use is determined as well
# as the extent (for the site).
#
# The input file(s) can be given in the command line argument or in stdin.
# When there is more than one file, all must be of the same type (e.g. n0r).
#
package require cmdline;

# Once and for all
set sharedir %PKG_SHAREDIR%;

lappend auto_path [file join $sharedir];
package require "nbsp::radstations";

proc err {s} {

    puts stderr $s;
    exit 1;
}

proc verify_inputfile_namefmt {inputfile} {

    set fbasename [file tail $inputfile];
    # set re {^[[:alnum:]]{6}.*\.nids$};
    set re {^[[:alnum:]]{6}};           # don't require nids extension

    if {[regexp $re $fbasename] == 0} {
	#return -code error "Invalid input file name: $inputfile";
	err "Invalid input file name: $inputfile";
    }
}

proc select_mapname {awips1} {

    if {[regexp {^n.(r|q|z)$} $awips1]} {
	set mapname "bref";
    } elseif {[regexp {^n.(u|v)$} $awips1]} {
	set mapname "rvel";
    } elseif {[regexp {^n(1|3|t)p} $awips1]} {
	set mapname "nxp";
    } elseif {[regexp {^n(1|2|3)s} $awips1]} {
	set mapname "srvel";
    } else {
	# return -code error "Unsupported nids type: $awips1";
	err "Unsupported nids type: $awips1";
    }

    return $mapname;
}

proc is_zlib_compressed {awips1} {

    set r 0;

    if {[regexp {^n.(r|v|z)} $awips1] || \
	    [regexp {^n(1|3|t)p} $awips1] || \
	    [regexp {^n(1|2|3)s} $awips1]} {
	set r 1;
    }

    return $r;
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

if {[llength $inputfile_list] == 0} {
    err "No files given.";
}

set sitelist [list];
foreach inputfile $inputfile_list {
    verify_inputfile_namefmt $inputfile;

    set awips [string tolower [string range [file tail $inputfile] 0 5]];
    set site [string tolower [string range $awips 3 5]];

    if {[info exists awips1] == 0} {
	set awips1 [string range $awips 0 2];
    } elseif {[string range $awips 0 2] ne $awips1} {
	err "Input files have different data type.";
    }

    lappend sitelist $site;
}

set mapname [select_mapname $awips1];

if {[is_zlib_compressed $awips1]} {
    set do_nbspunz 1;
    set shift 2;
} else {
    set do_nbspunz 0;
    set shift 4;
}

if {[llength $sitelist] == 1} {
    set extent [::nbsp::radstations::extent_bysite $site $shift];
} else {
    set extent [::nbsp::radstations::extent_bysitelist -s $shift $sitelist];
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

if {$option(b) == 1} {
    lappend cmd "-b";
}

if {$option(k) == 1} {
    lappend cmd "-k";
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
