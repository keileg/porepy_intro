#!/bin/bash

# Description: This script installs PorePy on a linux system, with all dependencies
# The installation will be in a virtual environment porepy_env

# To uninstall porepy again, delete the directories $POREPY_DIR, $GMSH_DIR and $HOME/porepy-env


# Before runing this script:
# 1)  run sudo apt install python3-tk
#    I could not get that install to work with pip or otherwise
# 2) Make sure the directory specified by variable $DIR_IN_PYTHONPATH 
#    is indeed in the pythonpath (in .bashrc)
# 3) sudo apt install python3-dev


# Base directory for the install
BASE_DIR="/home/eke001"

# Whether to download porepy or not. If true, any directory 
# with the name $POREPY_DIR (below) will be deleted
DO_DOWNLOAD_POREPY=$true

# Install directory for porepy
POREPY_DIR="$BASE_DIR/porepy"

## Gmsh should be available in version >=4.0
# If true, gmsh is installed in directory specified below
DO_INSTALL_GMSH=$false

# Directory for gmsh install, if $DO_INSTALL_GMSH
GMSH_DIR="$BASE_DIR/gmsh"

# Path to the gmsh binary. 
GMSH_RUN="$GMSH_DIR/bin/gmsh"

# Give a directory in $PYTHONPATH 
# if the directory does not exist, it will be made
DIR_IN_PYTHONPATH="$BASE_DIR/python"

# Make a virtual env porepy-env
if ! test -d $HOME/porepy-env ; then
  python3.6 -m venv $HOME/porepy-env
  source $HOME/porepy-env/bin/activate

  pip install --upgrade pip
else
  source $HOME/porepy-env/bin/activate
fi

# Delete porepy directory if it exists (not sure if this is good practice)
if $DO_DOWNLOAD_POREPY ; then
  if ! test -d "$POREPY_DIR" ; then 
    rm -Rf $POREPY_DIR; 
  fi
  # Clone PorePy from github
  git clone https://github.com/pmgbergen/porepy.git $POREPY_DIR
fi


# Install porepy requirements
pip install -r "$POREPY_DIR/requirements-dev.txt"

# install additional packages
pip install numba vtk jupyter ipython

# install porepy
pip install $POREPY_DIR

if $DO_INSTALL_GMSH ; then
  wget 'http://gmsh.info/bin/Linux/gmsh-4.3.0-Linux64.tgz' 
  tar xf gmsh-4.3.0-Linux64.tgz
  mv gmsh-4.3.0-Linux64 $GMSH_DIR
  rm gmsh-4.3.0-Linux64.tgz
fi

if ! test -d $DIR_IN_PYTHONPATH ; then
  mkdir ${DIR_IN_PYTHONPATH}
fi

# Write the path to the gmsh binary to a file porepy_config.py
echo "config = {\"gmsh_path\": \"$GMSH_RUN\" } " > $DIR_IN_PYTHONPATH/porepy_config.py

# Install a file from GitHub which is not available through pip or other sources
wget 'https://raw.githubusercontent.com/keileg/polyhedron/master/polyhedron.py'
mv polyhedron.py $DIR_IN_PYTHONPATH/robust_point_in_polyhedron.py

# Finally, run tests
cd $POREPY_DIR
pytest test/unit test/integration

cd $BASE_DIR

