#!/bin/bash
if [[ ! -d $HOME/miniconda3 ]]; then
  echo "Installing Miniconda3..."
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh
  bash /tmp/miniconda3.sh -b -p $HOME/miniconda3
  export PATH="$HOME/miniconda3/bin:$PATH"
fi
