#!/bin/bash -e

#
# Jenkins script for the OMNI Compiler parsing test
#

module load git
module rm PrgEnv-pgi && module rm PrgEnv-cray
module load PrgEnv-gnu

# shellcheck disable=SC2154
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
  module load cudatoolkit
fi

# First parse test fetch, compile and install CLAW FORTRAN Compiler
./cosmo/parse.cosmo.sh

# Second parse test reiles on the first installation
#./icon/parse.icon.sh -s
