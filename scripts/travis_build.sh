#!/bin/sh 

set -xe

git clone --depth=2 https://github.com/gap-system/gap.git gapsrc
pwd
( cd gapsrc && sh autogen.sh && ./configure && make -j && make bootstrap-pkg-minimal )
pwd
( ./autogen.sh && ./configure --with-gaproot=gapsrc ${PKGOPTS} && make )
pwd
ls
ls gapsrc
ls gapsrc/pkg
echo ln -s $(pwd) gapsrc/pkg/datastructures
ln -s $(pwd) gapsrc/pkg/datastructures
