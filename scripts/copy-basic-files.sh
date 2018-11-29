#!/bin/bash

. ./include/color.sh

# setup basic usage
if [[ -d $HOME/.dotfiles ]]; then
  cp $HOME/.dotfiles/src/.{bash_logout,bash_profile,bashrc,dircolorsdb,gitconfig,gitignore_global,inputrc,npmrc,vimrc} $HOME
  echo "${CSUCCESS}Done.${CEND}"
fi
