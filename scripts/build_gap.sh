#!/usr/bin/env bash
set -x
set -e

# build GAP in a subdirectory
git clone --depth=2 https://github.com/gap-system/gap.git $GAPROOT
pushd $GAPROOT
./autogen.sh
./configure
make -j4
make bootstrap-pkg-minimal
popd
