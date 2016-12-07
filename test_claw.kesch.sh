#!/bin/bash 


# Define local variable
CLAW_BRANCH="master"
CLAW_MAIN_REPO="git@github.com:C2SM-RCM/claw-compiler.git"
CLAW_FORK_REPO="git@github.com:clementval/claw-compiler.git"
CLAW_REPO=$CLAW_MAIN_REPO
CLAW_TEST_DIR=buildtemp-claw
CLAW_INSTALL_DIR=$PWD/$TEST_DIR/install
CLAW_BASE_COMPILER="gnu"

while getopts "hfb:c:" opt; do
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
  esac
done

echo ""
echo "CLAW FORTRAN Compiler full tests"
echo "================================"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo "- Base compiler: $CLAW_BASE_COMPILER"
echo "- Dest dir: $CLAW_TEST_DIR" 
echo "- Dest dir: $CLAW_INSTALL_DIR" 
echo "================================"
echo ""


# Load recent version of cmake
module load cmake

# Load correct PrgEnv
case  "$CLAW_BASE_COMPILER" in
  "gnu")
    module rm PrgEnv-pgi && module rm PrgEnv-cray
    module load PrgEnv-gnu
    CLAW_FC=gfortran
    CLAW_CC=gcc
    CLAW_CXX=g++
  ;;
  "pgi")
    module rm PrgEnv-gnu && module rm PrgEnv-cray
    module load PrgEnv-pgi
    CLAW_FC=mpif90
    CLAW_CC=mpicc
    CLAW_CXX=pgc++
  ;;
  "cray")
    module rm PrgEnv-pgi && module rm PrgEnv-gnu
    module load PrgEnv-cray
    CLAW_FC=ftn
    CLAW_CC=cc
    CLAW_CXX=CC
  ;;
  *)
    echo "Error: Unknown compiler ..."
    exit 1
esac

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
FC=$CLAW_FC CC=$CLAW_CC CXX=$CLAW_CXX cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_DIR .

# Compile and test
make all transformation test

