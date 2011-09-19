#!/bin/sh

. ../../VERSION

cd ../..

cp -r build/debian .
dpkg-buildpackage
fakeroot debian/rules distclean

build/debian/ckplist.sh build/debian/plist ../${name}_${version}*.deb
