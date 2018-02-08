#!/bin/bash

. ./include/color.sh

if [[ ! -x "$(command -v pipsi)" ]]; then
  echo "Installing Pipsi..."
  curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py | python
  echo "${CSUCCESS}Pipsi installed in '$HOME/.local/bin'.${CEND}"
  echo "You should add '$HOME/.local/bin' into your PATH to use pipsi."
else
  echo "${CWARNING}Pipsi has installed in '$HOME/.local/bin'.${CEND}"
fi
