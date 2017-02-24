#!/bin/bash 


function show_help(){
  echo "$0 [-b <branch-name>] [-f] [-c gnu|pgi|cray]"
  echo ""
  echo "Options:"
  echo " -b <branch-name>  Specifiy the branch to be tested"
  echo " -f                Use the forked repository for test"
  echo " -c <compiler-id>  Define the base compiler to use"
}

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

COMPUTER=$(hostname)

if [[ $COMPUTER == *"daint"* ]]
then
  COMPUTER="daint"
  CMAKE_MOD="CMake"
elif [[ $COMPUTER == *"kesch"* ]]
then
  COMPUTER="kesch"
  CMAKE_MOD="cmake"
fi



# Load recent version of cmake
module load $CMAKE_MOD

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
    if [[ $COMPUTER == "kesch" ]]
    then 
      CLAW_FC=mpif90
      CLAW_CC=mpicc
      CLAW_CXX=pgc++
    else 
      module load gcc
      CLAW_FC=ftn
      CLAW_CC=cc
      CLAW_CXX=CC
      OMNI_CONF_OPTION="MPI_CC=cc MPI_FC=ftn"
    fi
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

echo ""
echo "CLAW FORTRAN Compiler full tests"
echo "================================"
echo "- Computer: $COMPUTER"
echo "- Repo: $CLAW_REPO"
echo "- Branch: $CLAW_BRANCH"
echo "- Base compiler: $CLAW_BASE_COMPILER"
echo "  - FC : $CLAW_FC"
echo "  - CC : $CLAW_CC"
echo "  - CXX: $CLAW_CXX"
echo "- OMNI Compiler option: $OMNI_CONF_OPTION"
echo "- Dest dir: $CLAW_TEST_DIR" 
echo "- Dest dir: $CLAW_INSTALL_DIR" 
echo "================================"
echo ""



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
FC=$CLAW_FC CC=$CLAW_CC CXX=$CLAW_CXX cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_DIR -DOMNI_CONF_OPTION=$OMNI_CONF_OPTION .

# Compile and test
make all transformation test

