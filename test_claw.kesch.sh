#!/bin/bash -x


CLAW_BRANCH="master"

while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
    -b|--branch)
    CLAW_BRANCH="$2"
    shift
    ;;
  esac
done

echo "CLAW FORTRAN Compiler full tests"
echo "================================"
echo "Branch: $CLAW_BRANCH"

TEST_DIR=buildtemp-claw
INSTALL_DIR=$PWD/$TEST_DIR/install
rm -rf $TEST_DIR
mkdir $TEST_DIR
cd $TEST_DIR
git clone -b $CLAW_BRANCH git@github.com:C2SM-RCM/claw-compiler.git
cd claw-compiler
git submodule init
git submodule update --remote
#FC=gfortran CC=gcc CXX=g++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
#FC=pgf90 CC=pgcc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
FC=mpif90 CC=mpicc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
#FC=ftn cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DOMNI_CONF_OPTION=--target=Cray-linux-gnu .
make all transformation test

