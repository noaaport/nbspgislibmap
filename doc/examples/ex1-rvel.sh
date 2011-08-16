#!/bin/sh
#
# $Id$
#

usage="rvel.sh <site>"

# config
server="www.opennoaaport.net:8015"
listurl="http://$server/_export/query_dir?dir=digatmos/nexrad/nids"
geturl="http://$server/_export_get/digatmos/nexrad/nids"

#
# main
#
[ $# -ne 1 ] && { echo "Needs a site and type. E.g., $usage"; exit 1; }
site=$1

mkdir $site
cd $site

for type in n0v n0u n1u n2u n3u
do
    nidsfile="${type}${site}_latest.nids"

    echo "Downloading $nidsfile ..."
    wget -q -O $nidsfile $geturl/$site/$type/latest
    [ $? -ne 0 ] && { echo "Error from wget"; rm -f $nidsfile; exit 1; }

    echo "Generating shapefile and png for ${site}${type} ..."
    nbspglradmap -k $nidsfile
done
