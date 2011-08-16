#!/bin/sh

for name in rvel_1 rvel
do
    sed -e "/@classitem@/ {
r ${name}.classitem
d}" main.tmap > ${name}.tmap
done
