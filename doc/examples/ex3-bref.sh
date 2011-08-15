#!/bin/sh
#
# $Id$
#

usage="Usage example: ex3-bref.sh n0r"

# config
server="www.opennoaaport.net:8015"
listurl="http://$server/_export/query_dir?dir=digatmos/nexrad/nids"
geturl="http://$server/_export_get/digatmos/nexrad/nids"

#
# main
#
[ $# -eq 0 ] && { echo $usage; exit 1; }
type=$1

mkdir -p ${type}
cd ${type}

# tx: ama bro crp dfx dyx ewx fws grk hgx lbb maf sjt
# ok: fdr inx tlx vnx

for site in ama bro crp dfx dyx ewx fws grk hgx lbb maf sjt \
    fdr inx tlx vnx
do 
    nidsfile="${type}${site}_latest.nids"
    echo "Downloading $nidsfile ..."
    wget -q -O $nidsfile $geturl/$site/$type/latest
    [ $? -ne 0 ] && { echo "Error from wget"; rm -f $nidsfile; exit 1; }
done

echo "Generating shapefile and png ..."
# nbspglradmap -k *.nids
nbspglradmap *.nids
