#
# $Id$
#

SOURCES = nbspglgoesrmap.sh
TARGET = nbspglgoesrmap

all: ${TARGET}

nbspglgoesrmap: nbspglgoesrmap.sh
	sed -e "/%SHELL%/s||${SHELL}|" \
	-e "/%PKG_SHAREDIR%/s||${PKG_SHAREDIR}|" \
	nbspglgoesrmap.sh > nbspglgoesrmap

clean:
	rm -f *~ ${TARGET}
