#!/bin/bash -e

module load git

if [ "$slave" == "kesch" ]
then
  module load cmake
  module load Java
elif [ "$slave" == "daint" ]
then
  # For Daint
  export ANT_HOME="/project/c01/install/daint/ant/apache-ant-1.10.1/"
  export PATH=$PATH:$ANT_HOME/bin
  module load CMake
  module load java
fi

# Get OMNI Compiler as submodule
git submodule init
git submodule update --remote

# Install path by computer and compiler
CLAW_INSTALL_PATH=/project/c01/install/$slave/claw/$compiler

if [ "$compiler" == "gnu" ]
then
  module rm PrgEnv-pgi && module rm PrgEnv-cray
  module load PrgEnv-gnu
  if [ "$slave" == "kesch" ]
  then
    FC=gfortran cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH .
  elif [ "$slave" == "daint" ]
  then
    module load cudatoolkit
    # On Daint the cray wrapper must be used regardless the compiling env.
    FC=ftn CC=cc CXX=CC cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH -DOMNI_MPI_CC="MPI_CC=cc" -DOMNI_MPI_FC="MPI_FC=ftn" .
  fi
elif [ "$compiler" == "pgi" ]
then
  module rm PrgEnv-gnu && module rm PrgEnv-cray
  module load PrgEnv-pgi
  if [ "$slave" == "kesch" ]
  then
    module load GCC
    cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH .
  elif [ "$slave" == "daint" ]
  then
    module load cudatoolkit
    # On Daint the cray wrapper must be used regardless the compiling env.
    FC=ftn CC=cc CXX=CC cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH -DOMNI_MPI_CC="MPI_CC=cc" -DOMNI_MPI_FC="MPI_FC=ftn" .
  fi
elif [ "$compiler" == "cray" ]
then
  module rm PrgEnv-pgi && module rm PrgEnv-gnu
  module load PrgEnv-cray
  if [ "$slave" == "kesch" ]
  then
    module load GCC
    FC=ftn cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH .
  elif [ "$slave" == "daint" ]
  then
    module load daint-gpu
    #module load libxml2/.2.9.4-CrayGNU-2016.11-Python-2.7.12 # Hidden module for workaround
    FC=ftn CC=cc CXX=CC cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH -DOMNI_MPI_CC="MPI_CC=cc" -DOMNI_MPI_FC="MPI_FC=ftn" .
  fi
fi

# Compile and run unit tests
make all transformation test && make install
