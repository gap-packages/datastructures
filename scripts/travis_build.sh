#!/bin/sh -e

git clone --depth=2 https://github.com/gap-system/gap.git gapsrc
pwd
( cd gapsrc && ./configure --with-gmp=system && make configure && make -j && make bootstrap-pkg-minimal)
( cd gapsrc/pkg && git clone --depth=2 https://github.com/gap-packages/io && cd io && ./autogen.sh && ./configure ${PKGOPTS} && make )
pwd
( ./autogen.sh && ./configure --with-gaproot=gapsrc ${PKGOPTS} && make )
pwd
ls
ls gapsrc
ls gapsrc/pkg
echo ln -s $(pwd) gapsrc/pkg/datastructures
ln -s $(pwd) gapsrc/pkg/datastructures
