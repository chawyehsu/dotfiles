" Vundle START
set nocompatible              " required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" Plugins follow
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'chriskempson/base16-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugins end
call vundle#end()            " required
filetype plugin indent on    " required
" Vundle END

syntax on
set hlsearch
set number
set encoding=utf-8
set cursorline
set noswapfile
" 不设定在插入状态无法用退格键和 Delete 键删除回车符
set backspace=indent,eol,start 
" 把当前行的对齐格式应用到下一行
set autoindent
set smartindent
set shiftwidth=4
set expandtab
set tabstop=4
set t_Co=256
set laststatus=2
set background=dark
" base16 colorscheme (cf. https://github.com/chriskempson/base16-vim)
colorscheme base16-tomorrow-night

" vim-airline: (cf. https://github.com/vim-airline/vim-airline)
let g:airline_theme='solarized'
let g:airline_powerline_fonts=1
"let g:airline#extensions#tabline#enabled=1
"let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline#extensions#whitespace#enabled=0

