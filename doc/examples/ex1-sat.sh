#!/bin/sh
#
# $Id$
#

usage="Usage example: ex2-sat.sh 02"

# config
server="www.opennoaaport.net:8015"
listurl="http://$server/_export/query_dir?dir=digatmos/sat/gini/tig"
geturl="http://$server/_export_get/digatmos/sat/gini/tig"

#
# main
#
[ $# -eq 0 ] && { echo $usage; exit 1; }
type=$1

mkdir -p $type
cd $type

for region in tigw tige
do 
    ginifile="${region}${type}_latest.gini"
    echo "Downloading $ginifile ..."
    wget -q -O $ginifile $geturl/${region}${type}/latest
    [ $? -ne 0 ] && { echo "Error from wget"; rm -f $ginifile; exit 1; }
done

echo "Generating asc and png ..."

#
# nbspglsatmap -k tigw${type}_latest.gini tige${type}_latest.gini
#

nbspglsatmap -k -q -r "0,0,5,0;5,0,0,0" \
    tigw${type}_latest.gini tige${type}_latest.gini
