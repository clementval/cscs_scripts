#!/bin/bash -e

module load git

if [ "$slave" == "kesch" ]
then  
	module load cmake
    module load Java
elif [ "$slave" == "daint" ]
then
	# For Daint
    export ANT_HOME="/scratch/snx3000/clementv/apache-ant-1.10.1"
    export PATH=$PATH:$ANT_HOME/bin
	module load CMake
    module load java
fi

# Get OMNI Compiler as submodule
git submodule init 
git submodule update --remote 

# Install path by computer and compiler
CLAW_INSTALL_PATH=/project/c01/install/$slave/$compiler/claw


if [ "$compiler" == "gnu" ]
then
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
  module load PrgEnv-cray
  if [ "$slave" == "kesch" ]
  then  
	module load GCC
  fi
  FC=ftn cmake -DCMAKE_INSTALL_PREFIX=$CLAW_INSTALL_PATH .
fi

# Compile and run unit tests
make all transformation test && make install
