#!/bin/bash -e

module load git

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
fi


module rm PrgEnv-pgi && module rm PrgEnv-cray
module load PrgEnv-gnu
if [ "$slave" == "daint" ]
then
  module load cudatoolkit
fi

./cosmo/parse.cosmo.sh

./icon/parse.icon.sh
