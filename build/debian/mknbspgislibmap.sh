#!/bin/sh

name=nbspgislibmap

#tgzfile=${name}.tgz

#rm -rf $name
#tar -xzf $tgzfile

cd $name/build/debian
./mk.sh
