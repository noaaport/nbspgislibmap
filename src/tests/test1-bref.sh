#!/bin/sh
#
# $Id$
#
PATH="$PATH:`pwd`/../bin"

usage="Usage example: test-bref.sh jua n0r"

# config
server="www.opennoaaport.net:8015"
listurl="http://$server/_export/query_dir?dir=digatmos/nexrad/nids"
geturl="http://$server/_export_get/digatmos/nexrad/nids"

#
# main
#
[ $# -ne 2 ] && { echo "Needs a site and type. E.g., $usage"; exit 1; }
site=$1
type=$2

nidsfile="${type}${site}_latest.nids"

mkdir -p ${type}${site}
cd ${type}${site}

echo "Downloading $nidsfile ..."
wget -q -O $nidsfile $geturl/$site/$type/latest
[ $? -ne 0 ] && { echo "Error from wget"; rm -f $nidsfile; exit 1; }

echo "Generating shapefile and png ..."
nbspglradmap -k $nidsfile
