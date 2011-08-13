#
# $Id$
#

SOURCES = nbspglmap.tcl  nbspglradmap.tcl
TARGET = nbspglmap nbspglradmap

TCLSH = /usr/bin/tclsh

all: ${TARGET}


nbspglmap: nbspglmap.tcl
	sed -e "/%TCLSH%/s||${TCLSH}|" nbspglmap.tcl > nbspglmap

nbspglradmap: nbspglradmap.tcl
	sed -e "/%TCLSH%/s||${TCLSH}|" nbspglradmap.tcl > nbspglradmap


clean:
	rm -f *~ ${TARGET}
