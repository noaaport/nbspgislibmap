

all:
	cd ../../compile; ./configure.sh; ${MAKE}

install:
	PKGBUILDDIR=`pwd`/pkg;\
	cd ../../compile; ${MAKE} PKGBUILDDIR=$${PKGBUILDDIR} install

clean:
	cd ../../compile; ${MAKE} clean
	rm -rf *~ pkg
