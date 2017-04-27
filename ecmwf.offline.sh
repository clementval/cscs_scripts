#!/bin/bash


#
# This scripts helps to pack an offline version of the claw-compiler repository
# to be build on LXG cluster
#


function show_help(){
  echo "$0 [-b <branch-name>] [-f] [-c gnu|pgi|cray] [-i <install-path>]"
  echo ""
  echo "Options:"
  echo " -b <branch-name>  Specifiy the branch to be tested"
  echo " -f                Use the forked repository for test"
  echo " -c <compiler-id>  Define the base compiler to use"
  echo " -i <install-path> Set an install path"
}

# Define local variable
CLAW_BRANCH="master"
CLAW_MAIN_REPO="git@github.com:C2SM-RCM/claw-compiler.git"
CLAW_FORK_REPO="git@github.com:clementval/claw-compiler.git"
CLAW_REPO=$CLAW_MAIN_REPO
CLAW_TEST_DIR=buildtemp-claw
CLAW_INSTALL_DIR=$PWD/$CLAW_TEST_DIR/install
CLAW_BASE_COMPILER="gnu"

while getopts "hfb:c:i:" opt; do
  case "$opt" in
  h)
    show_help
    exit 0
    ;;
  f)
    CLAW_REPO=$CLAW_FORK_REPO
    ;;
  b)
    CLAW_BRANCH=$OPTARG
    ;;
  c)
    CLAW_BASE_COMPILER=$OPTARG
    ;;
  i)
    CLAW_INSTALL_DIR=$OPTARG
    ;;
  esac
done

COMPUTER=$(hostname)

# Load recent version of git
module load git

echo ""
echo "================================"
echo "CLAW FORTRAN Compiler offline   "
echo "================================"
echo "- Computer: $COMPUTER"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo ""


export ANT_HOME="/home/ms/ec_ext/extvc/install/ant/apache-ant-1.9.9"

#
export PATH=$PATH:${ANT_HOME}/bin

# Needed to be able to clone repository and resolve ANT dependencies
export https_proxy=http://proxy.ecmwf.int:3333
export http_proxy=http://proxy.ecmwf.int:3333
export ANT_OPTS="-Dhttp.proxyHost=proxy.ecmwf.int -Dhttp.proxyPort=3333 -Dhttps.proxyHost=proxy.ecmwf.int -Dhttps.proxyPort=3333"

git clone -b $CLAW_BRANCH $CLAW_REPO
cd claw-compiler
./scripts/offline.sh
cd -
tar cvf claw-compiler.tar claw-compiler/*
gzip claw-compiler.tar
