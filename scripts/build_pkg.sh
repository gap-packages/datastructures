#!/usr/bin/env bash
set -ex

# build this package
./autogen.sh
./configure --with-gaproot=$GAPROOT
make -j4 V=1

# ... and link it into GAP pkg dir
ls
ls $GAPROOT
ls $GAPROOT/pkg
ln -s $PWD $GAPROOT/pkg/
