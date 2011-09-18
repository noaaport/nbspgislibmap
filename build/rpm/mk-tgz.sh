#!/bin/sh

. ../../VERSION

cd ../../..

cp -r ${name} ${name}-${version}
tar -czf ${name}-${version}.tgz ${name}-${version}

rm -rf ${name}-${version}
mv ${name}-${version}.tgz ~/rpmbuild/SOURCES
