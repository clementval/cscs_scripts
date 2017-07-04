#!/bin/bash

#
# This scripts helps to pack an offline version of the claw-compiler repository
# to be build on LXG cluster. This script needs to be executed on the LXG.
#

COMPUTER=$(hostname)

# Load recent version of git
module load git

archive="claw-compiler.tar.gz"

echo ""
echo "======================================"
echo "CLAW FORTRAN Compiler offline LXG step"
echo "======================================"
echo "- Computer: $COMPUTER"
echo "- Archive: $archive"
echo ""

rm -f claw-compiler
module switch gnu gnu/4.9.1
module load java openmpi cuda cmake
tar xvf ${archive}
cd claw-compiler || exit 1
export JAVA_HOME=/usr/local/apps/java/1.8.0_102
cmake -DOFFLINE=ON -DCMAKE_INSTALL_PREFIX=/home/ms/ec_ext/extvc/install/claw .
make
make install
