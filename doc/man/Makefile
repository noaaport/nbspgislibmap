#
# Copyright (c) 2015 Jose F. Nieves <nieves@ltp.uprrp.edu>
#
# See LICENSE
#
# $Id$
#
SOURCES = nbspglmap.man nbspglradmap.man nbspglsatmap.man nbspglgoesrmap.man
OBJECTS = nbspglmap.1 nbspglradmap.1 nbspglsatmap.1 nbspglgoesrmap.1
TARGET = nbspglmap.1.gz nbspglradmap.1.gz nbspglsatmap.1.gz nbspglgoesrmap.1.gz

all: ${TARGET}

nbspglmap.1.gz: nbspglmap.man
	cp nbspglmap.man nbspglmap.1
	gzip -9 -c nbspglmap.1 > nbspglmap.1.gz

nbspglradmap.1.gz: nbspglradmap.man
	cp nbspglradmap.man nbspglradmap.1
	gzip -9 -c nbspglradmap.1 > nbspglradmap.1.gz

nbspglsatmap.1.gz: nbspglsatmap.man
	cp nbspglsatmap.man nbspglsatmap.1
	gzip -9 -c nbspglsatmap.1 > nbspglsatmap.1.gz

nbspglgoesrmap.1.gz: nbspglgoesrmap.man
	cp nbspglgoesrmap.man nbspglgoesrmap.1
	gzip -9 -c nbspglgoesrmap.1 > nbspglgoesrmap.1.gz

clean:
	rm -f *~ ${OBJECTS} ${TARGET}
