#!/bin/sh
#
# $Id$
#

#
# config
#
deb_plist_file="deb_plist"

#
# main
#
[ $# -ne 2 ] && { echo "ckplist <plist-file> <pkg_file>"; exit 1; }
plist_file=$1
pkgfile=$2

# Get the list of packaged files
dpkg -c $pkgfile | awk '{print substr($6,2)}' > $deb_plist_file

# Run through every file in the plist and check for each if it is installed
echo ""
echo "Checking plist ..."
echo ""
#
for f in `cat $plist_file`
do
  grep -q "^$f\$" $deb_plist_file || echo "Not found: $f"
done

rm $deb_plist_file
