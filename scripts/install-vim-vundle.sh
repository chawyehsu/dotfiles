#!/bin/bash
if [[ ! -d $HOME/.vim/bundle ]]; then
  echo "Installing Vim Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
else
  echo "Vundle has installed in '$HOME/.vim/bundle'."
fi
