#!/bin/bash 


# Define local variable
CLAW_BRANCH="master"
CLAW_MAIN_REPO="git@github.com:C2SM-RCM/claw-compiler.git"
CLAW_FORK_REPO="git@github.com:clementval/claw-compiler.git"
CLAW_REPO=$CLAW_MAIN_REPO
CLAW_TEST_DIR=buildtemp-claw
CLAW_INSTALL_DIR=$PWD/$TEST_DIR/install

while getopts "hfb:" opt; do
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
  esac
done

echo "CLAW FORTRAN Compiler full tests"
echo "================================"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo "- Dest dir: $CLAW_TEST_DIR" 
echo "- Dest dir: $CLAW_INSTALL_DIR" 

# Load recent version of cmake
module load cmake

# Prepare directory
rm -rf $CLAW_TEST_DIR
mkdir $CLAW_TEST_DIR
cd $CLAW_TEST_DIR

# Retrive repository and branch
git clone -b $CLAW_BRANCH $CLAW_REPO
cd claw-compiler
git submodule init
git submodule update --remote

# Configure using cmake
#FC=gfortran CC=gcc CXX=g++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
#FC=pgf90 CC=pgcc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR .
FC=mpif90 CC=mpicc CXX=pgc++ cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_DIR .
#FC=ftn cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DOMNI_CONF_OPTION=--target=Cray-linux-gnu .

# Compile and test
make all transformation test

