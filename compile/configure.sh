#!/bin/sh

os=`uname`
for c in $os nbspgislib
do
    . ./configure.d/configure.${c}
done

sed -e "/%TCLSH%/s||$TCLSH|" Makefile.in > Makefile

rm -rf src
cp -R ../src .

tar -xzf ../ext/nbspgislib-${nbspgislibversion}.tgz -C src
mv src/nbspgislib-${nbspgislibversion} src/nbspgislib
cd src/nbspgislib/compile
./configure.sh
