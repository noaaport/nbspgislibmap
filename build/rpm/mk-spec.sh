#!/bin/sh

. ../../VERSION
rpmrelease=`cat rpm-release`

sed -e "/@name@/s//$name/" \
    -e "/@version@/s//$version/" \
    -e "/@rpmrelease@/s//$rpmrelease/" \
    -e "/@plist@/r rpm-plist" -e "/@plist@/d" \
    rpm-spec.in > rpm-spec
