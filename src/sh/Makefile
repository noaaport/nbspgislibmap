#
# $Id$
#

SOURCES = nbspglgoesrmap.sh
TARGET = nbspglgoesrmap

all: ${TARGET}

nbspglgoesrmap: nbspglgoesrmap.sh
	sed -e "/%SHELL%/s||${SHELL}|" nbspglgoesrmap.sh > nbspglgoesrmap

clean:
	rm -f *~ ${TARGET}
