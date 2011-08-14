#!/bin/sh
#
# $Id: mkplist.sh 769 2010-11-21 12:47:44Z nieves $
#
# Use to generate the deb and rpm plist file when the bsd pkg-plist
# is updated.
#

awk '!/^@/ {printf("/usr/local/%s\n", $0)}' pkg-plist > ../debian/plist
cp ../debian/plist ../rpm
