#!/bin/sh

. ../../VERSION

./mk-tgz.sh
./mk-spec.sh

rpmbuild -bb rpm-spec
