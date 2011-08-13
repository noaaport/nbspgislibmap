#!/bin/sh

for name in bref_1 bref_3 bref_5 bref
do
    sed -e "/@classitem@/ {
r ${name}.classitem
d}" main.tmap > ${name}.tmap
done
