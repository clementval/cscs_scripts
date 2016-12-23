# clementval (clementv) bashrc file for CSCS machines

test -s ~/.alias && . ~/.alias || true

# Define host 
if [[ $(hostname -s) = kesch* ]]
then
  HOST="kesch"
elif [[ $(hostname -s) = daint* ]]
then
  HOST="daint"
else
  HOST=""
fi

# Load modules and export variables corresponding to the host
# Do not load any module when connected on ela
if [[ "$HOST" != "" ]]
then
  if [[ "$HOST" = "kesch" ]] 
  then
    source /etc/bashrc
    module load cmake
  elif [[ "$HOST" = "daint" ]] 
  then 
    module load daint-gpu
    module load CMake
  fi

  module load git
 
  export SVN_EDITOR=vi
  export PYTHONPATH=$PYTHONPATH:/project/c01/install/$HOST/serialbox/gnu/python
  export PATH=~/.local/bin/:$PATH
  #export PATH=$PATH:/project/c01/install/$HOST/claw/bin/
  export PATH=$PATH:/scratch/clementv/install/claw/bin/

  alias gitst='git status -sb'
fi
