#!/bin/bash

#
# This scripts helps to pack an offline version of the claw-compiler repository
# to be build on LXG cluster
#

COMPUTER=$(hostname)
CLAW_BRANCH="master"
CLAW_REPO="https://github.com/C2SM-RCM/claw-compiler.git"

# Load recent version of git
module load git

echo ""
echo "========================================="
echo "CLAW FORTRAN Compiler offline ECGATE step"
echo "========================================="
echo "- Computer: $COMPUTER"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo ""

# Set up ANT variables
export ANT_HOME="/home/ms/ec_ext/extvc/install/ant/apache-ant-1.9.9"
export PATH=$PATH:${ANT_HOME}/bin

# Needed to be able to clone repository and resolve ANT dependencies
export https_proxy=http://proxy.ecmwf.int:3333
export http_proxy=http://proxy.ecmwf.int:3333
export ANT_OPTS="-Dhttp.proxyHost=proxy.ecmwf.int -Dhttp.proxyPort=3333 -Dhttps.proxyHost=proxy.ecmwf.int -Dhttps.proxyPort=3333"

rm -rf claw-compiler*
git clone -b $CLAW_BRANCH $CLAW_REPO
cd claw-compiler
./scripts/offline.sh
cd -
tar cvf claw-compiler.tar claw-compiler/*
gzip claw-compiler.tar
rm -rf claw-compiler
