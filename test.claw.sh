#!/bin/bash


#
# This scripts helps to test the compilation and tests execution of the
# CLAW compiler on Piz Kesch and Piz Daint at CSCS.
#


function show_help(){
  echo "$0 [-b <branch-name>] [-f] [-c gnu|pgi|cray] [-i <install-path>] [-o <offline-tar-file>]"
  echo ""
  echo "Options:"
  echo " -b <branch-name>      Specifiy the branch to be tested"
  echo " -f                    Use the forked repository for test"
  echo " -c <compiler-id>      Define the base compiler to use"
  echo " -i <install-path>     Set an install path"
  echo " -o <offline-tar-file> Use offline archive"
}

# Define local variable
CLAW_BRANCH="master"
CLAW_MAIN_REPO="git@github.com:C2SM-RCM/claw-compiler.git"
CLAW_FORK_REPO="git@github.com:clementval/claw-compiler.git"
CLAW_REPO=$CLAW_MAIN_REPO
CLAW_TEST_DIR=buildtemp-claw
CLAW_INSTALL_DIR=$PWD/$CLAW_TEST_DIR/install
CLAW_BASE_COMPILER="gnu"
CLAW_OFFLINE=false

while getopts "hfb:c:i:o:" opt; do
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
  o)
    CLAW_OFFLINE=true
    CLAW_OFFLINE_TAR=$OPTARG
    ;;
  esac
done

COMPUTER=$(hostname)

if [[ $COMPUTER == *"daint"* ]]   # CSCS supercomputer
then
  COMPUTER="daint"
  module load CMake
elif [[ $COMPUTER == *"kesch"* ]] # MeteoSwiss machine
then
  COMPUTER="kesch"
  module load cmake
elif [[ $COMPUTER == *"lxg"* ]]   # ECMWF GPU Cluster
then
  COMPUTER="lxg"
  module switch gnu gnu/4.9.1
  module load java openmpi cuda cmake
  export JAVA_HOME=/usr/local/apps/java/1.8.0_102
fi

if [[ $CLAW_OFFLINE == true ]]
then
  echo ""
  echo "=================================="
  echo "CLAW FORTRAN Compiler offline test"
  echo "=================================="
  echo "- Computer: $COMPUTER"
  echo "- Install path: $CLAW_INSTALL_DIR"
  echo "=================================="
  echo ""
  tar xvf $CLAW_OFFLINE_TAR
  cd claw-compiler
  cmake -DOFFLINE=ON -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_DIR .
  make
  make install
  make transformation test
  exit 0
fi

# Load correct PrgEnv
case  "$CLAW_BASE_COMPILER" in
  "gnu")
    module rm PrgEnv-pgi && module rm PrgEnv-cray
    module load PrgEnv-gnu
    if [[ $COMPUTER == "kesch" ]]
    then
      CLAW_FC=gfortran
      CLAW_CC=gcc
      CLAW_CXX=g++
    elif [[ $COMPUTER == "daint" ]]
    then
      CLAW_FC=ftn
      CLAW_CC=cc
      CLAW_CXX=CC
      OMNI_MPI_CC="MPI_CC=cc"
      OMNI_MPI_FC="MPI_FC=ftn"
      ADDITONAL_OPTIONS="-DOMNI_MPI_CC=$OMNI_MPI_CC -DOMNI_MPI_FC=$OMNI_MPI_FC"
    fi
  ;;
  "pgi")
    module rm PrgEnv-gnu && module rm PrgEnv-cray
    module load PrgEnv-pgi
    if [[ $COMPUTER == "kesch" ]]
    then
      CLAW_FC=mpif90
      CLAW_CC=mpicc
      CLAW_CXX=pgc++
    elif [[ $COMPUTER == "daint" ]]
    then
      module load gcc
      CLAW_FC=ftn
      CLAW_CC=cc
      CLAW_CXX=CC
      OMNI_MPI_CC="MPI_CC=cc"
      OMNI_MPI_FC="MPI_FC=ftn"
      ADDITONAL_OPTIONS="-DOMNI_MPI_CC=$OMNI_MPI_CC -DOMNI_MPI_FC=$OMNI_MPI_FC"
    fi
  ;;
  "cray")
    export CRAYPE_LINK_TYPE=dynamic
    module rm PrgEnv-pgi && module rm PrgEnv-gnu
    module load PrgEnv-cray
    module load java
    CLAW_FC=ftn
    if [[ $COMPUTER == "kesch" ]]
    then 
      module load GCC
      CLAW_CC=gcc
      CLAW_CXX=g++
    elif [[ $COMPUTER == "daint" ]]
    then
      CLAW_CC=cc
      CLAW_CXX=CC
    fi
  ;;
  *)
    echo "Error: Unknown compiler ..."
    exit 1
esac

echo ""
echo "================================"
echo "CLAW FORTRAN Compiler full tests"
echo "================================"
echo "- Computer: $COMPUTER"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo "- Base compiler: $CLAW_BASE_COMPILER"
echo "- Install path: $CLAW_INSTALL_DIR"
echo "  - FC : $CLAW_FC"
echo "  - CC : $CLAW_CC"
echo "  - CXX: $CLAW_CXX"
echo "- OMNI MPI CC: $OMNI_MPI_CC"
echo "- OMNI MPI FC: $OMNI_MPI_FC"
echo "- Dest dir: $CLAW_TEST_DIR"
echo "================================"
echo ""

# Prepare directory
rm -rf $CLAW_TEST_DIR
mkdir $CLAW_TEST_DIR
cd $CLAW_TEST_DIR

# Retrieve repository and branch
git clone -b $CLAW_BRANCH $CLAW_REPO
cd claw-compiler
git submodule init
git submodule update --remote

# Configure using cmake
FC=$CLAW_FC CC=$CLAW_CC CXX=$CLAW_CXX cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_DIR $ADDITONAL_OPTIONS .

# Compile and test
make all transformation test
make install
