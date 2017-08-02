#!/usr/bin/env bash
set -x
set -e

# build this package
./autogen.sh
./configure --with-gaproot=$GAPROOT
make

# ... and link it into GAP pkg dir
ls
ls $GAPROOT
ls $GAPROOT/pkg
ln -s $PWD $GAPROOT/pkg/
