#!/bin/bash

#
# This scripts helps to test install ANT on CSCS system
#

function show_help(){
  echo "$0 -i <install-path>"
  echo ""
  echo "Options:"
  echo " -i <install-path> Set an install path"
}

# Define local variable
ANT_TAR="apache-ant-1.9.9-bin.tar.gz"
ANT_BINARY="http://mirror.switch.ch/mirror/apache/dist/ant/binaries/${ANT_TAR}"
ANT_INSTALL_PATH=""
ANT_EXTRACTED_DIR="apache-ant-1.9.9"

while getopts "hi:" opt; do
  case "$opt" in
  h)
    show_help
    exit 0
    ;;
  i)
    ANT_INSTALL_PATH=$OPTARG
    ;;
  esac
done

if [ "${ANT_INSTALL_PATH}" == "" ]
then
  echo "Install path must be specified"
  echo ""
  show_help
  exit 1
fi

echo ""
echo "======================="
echo "ANT install information"
echo "======================="
echo "- ANT binary path: $ANT_BINARY"
echo "- Install path: $ANT_INSTALL_PATH"
echo ""

# Download the binary
wget ${ANT_BINARY}

# Perform install task
mkdir -p "${ANT_INSTALL_PATH}"
tar -xf ${ANT_TAR} --directory "${ANT_INSTALL_PATH}"
ANT_INSTALL_PATH=${ANT_INSTALL_PATH}/${ANT_EXTRACTED_DIR}

"${ANT_INSTALL_PATH}"/bin/ant -f "${ANT_INSTALL_PATH}"/fetch.xml -Ddest=system

rm ${ANT_TAR}

echo ""
echo "INTSALLATION PROCEDURE:"
echo "Define ANT_HOME in your .bashrc file as follows:"
echo "ANT_HOME=\"${ANT_INSTALL_PATH}\""
echo "Add \${ANT_HOME}/bin to your PATH variable"
echo ""
