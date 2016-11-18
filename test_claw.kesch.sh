#!/bin/bash -x

TEST_DIR=buildtemp-claw
INSTALL_DIR=$PWD/$TEST_DIR/install
rm -rf $TEST_DIR
mkdir $TEST_DIR
cd $TEST_DIR
git clone git@github.com:C2SM-RCM/claw-compiler.git
cd claw-compiler
git submodule init
git submodule update --remote
#FC=gfortran CC=gcc CXX=g++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
#FC=pgf90 CC=pgcc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
FC=mpif90 CC=mpicc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
#FC=ftn cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DOMNI_CONF_OPTION=--target=Cray-linux-gnu .
make all transformation test
