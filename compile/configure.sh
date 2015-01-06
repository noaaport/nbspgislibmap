#!/bin/sh

os=`uname`
for c in $os nbspgislib
do
    . ./configure.d/configure.${c}
done

sed -e "/%TCLSH%/s||$TCLSH|" Makefile.in > Makefile

for d in doc src
do
    rm -rf $d
    cp -R ../$d .
done

tar -xzf ../ext/nbspgislib-${nbspgislibversion}.tgz -C src
mv src/nbspgislib-${nbspgislibversion} src/nbspgislib

cd src/nbspgislib/compile
./configure.sh
cp Makefile Makefile.orig
sed -e "/^PKGBUILDDIR =.*\$/s||PKGBUILDDIR = ../../../pkg|" \
    Makefile.orig > Makefile
