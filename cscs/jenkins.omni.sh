#!/bin/bash -e

#
# Jenkins script for the OMNI Compiler build test
#

# Filter:
# (slave=="kesch" && compiler=="gnu") || (slave=="kesch" && compiler=="pgi") ||
# (slave=="daint" && compiler=="cray") || (slave=="daint" && compiler=="pgi") ||
# (slave=="daint" && compiler=="gnu")

JAVA_MODULE="Java"

# shellcheck disable=SC2154
if [ "$slave" == "daint" ]
then
  JAVA_MODULE="java"
fi

module load git
module load "${JAVA_MODULE}"


# Install path by computer and compiler
# shellcheck disable=SC2154
OMNI_INSTALL_PATH=/project/c01/install/"$slave"/omni/"$compiler"

if [ "$compiler" == "gnu" ]
then
  module rm PrgEnv-pgi && module rm PrgEnv-cray
  module load PrgEnv-gnu
  if [ "$slave" == "kesch" ]
  then
    FC=gfortran CC=gcc CXX=g++ ./configure --prefix="$OMNI_INSTALL_PATH"
  elif [ "$slave" == "daint" ]
  then
    module load cudatoolkit
    # On Daint the cray wrapper must be used regardless the compiling env.
    FC=ftn CC=cc CXX=CC ./configure --prefix="$OMNI_INSTALL_PATH" MPI_CC=cc MPI_FC=ftn
  fi
elif [ "$compiler" == "pgi" ]
then
  module rm PrgEnv-gnu && module rm PrgEnv-cray
  module load PrgEnv-pgi
  if [ "$slave" == "kesch" ]
  then
    module load GCC
    ./configure --prefix="$OMNI_INSTALL_PATH"
  elif [ "$slave" == "daint" ]
  then
    module load cudatoolkit
    # On Daint the cray wrapper must be used regardless the compiling env.
    FC=ftn CC=cc CXX=CC ./configure --prefix="$OMNI_INSTALL_PATH" MPI_CC=cc MPI_FC=ftn
  fi
elif [ "$compiler" == "cray" ]
then
  if [ "$slave" == "kesch" ]
  then
    module load PrgEnv-cray
    module load GCC
    FC=ftn CC=cc CXX=CC ./configure --prefix="$OMNI_INSTALL_PATH"
  elif [ "$slave" == "daint" ]
  then
    export CRAYPE_LINK_TYPE=dynamic
    module load daint-gpu
    module load PrgEnv-cray
    FC=ftn CC=cc CXX=CC ./configure --prefix="$OMNI_INSTALL_PATH" --target=Cray-linux-gnu MPI_CC=cc MPI_FC=ftn
  fi
fi

# Compile and run unit tests
make
make install

# Remove installation after success
rm -rf "$OMNI_INSTALL_PATH"
