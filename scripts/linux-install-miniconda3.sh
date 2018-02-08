#!/bin/bash

. ./include/color.sh

ORIGIN=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

if [[ -d /usr/local/miniconda3 ]]; then
  echo "${CWARNING}Miniconda3 has installed in '/usr/local/miniconda3'.${CEND}"
  exit 1
elif [[ -d $HOME/miniconda3 ]]; then
  echo "${CWARNING}Miniconda3 has installed in '$HOME/miniconda3'.${CEND}"
  exit 1
else
  echo "Installing Miniconda3..."
  if [ $1 == '-m' ]; then
    wget $MIRROR -O /tmp/miniconda3.sh
  else
    wget $ORIGIN -O /tmp/miniconda3.sh
  fi
  if [ $2 == '--all-user' ]; then
    bash /tmp/miniconda3.sh -b -p /usr/local/miniconda3
    export PATH="/usr/local/miniconda3/bin:$PATH"
    echo "${CSUCCESS}Miniconda3 installed in '/usr/local/miniconda3'.${CEND}"
    echo "You should add '/usr/local/miniconda3' into your PATH to use conda."
  else
    bash /tmp/miniconda3.sh -b -p $HOME/miniconda3
    export PATH="$HOME/miniconda3/bin:$PATH"
    echo "${CSUCCESS}Miniconda3 installed in '$HOME/miniconda3'.${CEND}"
    echo "You should add '$HOME/miniconda3' into your PATH to use conda."
  fi
fi
