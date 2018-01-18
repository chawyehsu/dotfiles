#!/bin/bash
if [[ ! -d ~/.vim/bundle ]]; then
  echo "Installing Vim Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
