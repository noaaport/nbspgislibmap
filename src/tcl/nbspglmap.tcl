#!%TCLSH%
#
# $Id$
#
# Usage:
#	nbspglmap [-b] [-k] [-d outputdir] [-e extent]
#                 [-f mapfontsdir] [-g geodatadir] [-m | -M maptemplate]
#                 [-o outputname] [-s size] [-t imagetype]
#                 [-D <defs>] <inputfile_1> ... <inputfile_n>};
#
# -k => keep the map script
# -m => use the tmap template as is (do not search in std directories)
# -M => add the ".tmap" ext, and search it in the std directories
# -e => extent in the form "lon1 lat1 lon2 lat2"  (or with ; separator)
# -s => size as "width height" or "width;height"
#
# The input file(s) is a gis file (i.e., a shapefile for radar and
# asc file for sat). They can be given as arguments or in stdin.
#
package require fileutil;
package require cmdline;

append env(PATH) ":[file join [pwd] [file dirname [info script]]]";

# Once and for all (assumes a "standard" dir tree)
set basedir [file join [file dirname [info script]] ".."];
set sharedir [file join $basedir "share" "nbspgislib"];
set mapdir [file join $sharedir "maps"];

#
# Default configuration
#
set map(mapfonts) [file join $sharedir "mapfonts"];
set map(geodata) [file join $sharedir "geodata"];
#
set map(imagetype) "png";

# Map variables (set in the cmd line arguments)
#
# set map(inputfile,1) "";
# set map(extent) "";
# set map(size) "";

# parameters
set g(mapfext) ".map";
set g(tmapfext) ".tmap";

# variables
## set g(output_img)
## set g(output_map)
## set g(map_template)

proc err {s} {
    
    global argv0;

    set name [file tail $argv0];
    puts stderr "$name: $s";

    exit 1;
}

proc build_map_script {template} {

    global map;

    source $template;
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
set usage {nbspglmap [-b] [-k] [-d outputdir] [-e extent]
    [-f mapfontsdir] [-g geodatadir] [-m | -M maptemplate] [-o outputname]
    [-s size] [-t imagetype] [-D <defs>] <inputfile(s)>};

set optlist {b k {d.arg ""} {D.arg ""} {e.arg ""} {f.arg ""}
    {g.arg ""} {m.arg ""} {M.arg ""} {o.arg ""} {s.arg ""} {t.arg ""}};

array set option [::cmdline::getoptions argv $optlist $usage];
set argc [llength $argv];

check_conflicts $usage;

if {$argc != 0} {
    set inputfile_list $argv;
} else {
    set inputfile_list [split [string trim [read stdin]]];
}

set i 1;
foreach f $inputfile_list {
    set map(inputfile,$i) $f;
    incr i;
}

if {$option(e) ne ""} {
    set map(extent) $option(e);
}

if {$option(m) ne ""} {
    set g(map_template) $option(m);
} elseif {$option(M) ne ""} {
    set g(map_template) $option(M);
    if {[file extension $g(map_template)] ne $g(tmapfext)} {
	append g(map_template) $g(tmapfext);
    }
    set g(map_template) [file join $mapdir $g(map_template)];
} else {
    err "No map template specfied".
}

if {$option(f) ne ""} {
    set map(mapfonts) $option(f);
}

if {$option(g) ne ""} {
    set map(geodata) $option(g);
}

if {$option(s) ne ""} {
    set map(size) $option(size);
}

# Image type (option t)
if {$option(t) ne ""} {
    set map(imagetype) $option(t);
}

#
# Map parameters (option D)
#
# To set
#
## set map(extent) {-68 16 -64 20};
## set map(size) {800 600};
#
# use
#       -D "extent=-68;16;-64;20,size=800;600"
#
if {$option(D) ne ""} {
    set Dlist [split $option(D) ","];
    foreach pair $Dlist {
        set p [split $pair "="];
        set var [lindex $p 0];
        set val [lindex $p 1];
        set map($var) $val;
    }
}

if {[info exists map(extent)] == 0} {
    err "No extent specified.";
}

#
# main
#
if {[llength $inputfile_list] == 1} {
    set rootname [file rootname [file tail $map(inputfile,1)]];
} else {
    set rootname [file rootname [file tail $g(map_template)]];
}

if {$option(o) ne ""} {
    set g(output_img) $option(o);
} else {
    set g(output_img) ${rootname}.$map(imagetype);
}

if {$option(d) ne ""} {
    set g(output_img) [file join [pwd] $option(d) $g(output_img)];
}

set g(output_map) [file rootname $g(output_img)];
append g(output_map) $g(mapfext); 

if {[file dirname $g(output_img)] ne "."} {
    file mkdir [file dirname $g(output_img)];
    # Use full paths for everything that shp2img uses
    set g(output_img) [file join [pwd] $g(output_img)];
    # set g(map_template) [file join [pwd] $g(map_template)];
    set g(output_map) [file join [pwd] $g(output_map)];
    set map(mapfonts) [file join [pwd] $map(mapfonts)];
    set map(geodata) [file join [pwd] $map(geodata)];
    set i 1;
    foreach f $inputfile_list {
	set map(inputfile,$i) [file join [pwd] $f];
	incr i;
    }
}

build_map_script $g(map_template);
::fileutil::writeFile $g(output_map) $map(scriptstr);

exec shp2img -m $g(output_map) -o $g(output_img);

if {$option(k) == 0} {
    file delete $g(output_map);
}
