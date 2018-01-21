#!/bin/bash
ORIGIN=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

if [[ ! -d $HOME/miniconda3 ]]; then
  if [ $1 == '-m' ]; then
    wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh
  else
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh
  fi
  bash /tmp/miniconda3.sh -b -p $HOME/miniconda3
  export PATH="$HOME/miniconda3/bin:$PATH"
else
  echo "Miniconda3 has installed in '$HOME/miniconda3'."
fi
