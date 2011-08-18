#
# $Id$
#

SOURCES = nbspglmap.tcl nbspglradmap.tcl nbspglsatmap.tcl
TARGET = nbspglmap nbspglradmap nbspglsatmap

TCLSH = /usr/bin/tclsh

all: ${TARGET}


nbspglmap: nbspglmap.tcl
	sed -e "/%TCLSH%/s||${TCLSH}|" nbspglmap.tcl > nbspglmap

nbspglradmap: nbspglradmap.tcl
	sed -e "/%TCLSH%/s||${TCLSH}|" nbspglradmap.tcl > nbspglradmap

nbspglsatmap: nbspglsatmap.tcl
	sed -e "/%TCLSH%/s||${TCLSH}|" nbspglsatmap.tcl > nbspglsatmap


clean:
	rm -f *~ ${TARGET}
