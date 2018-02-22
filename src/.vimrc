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
set cursorcolumn
set cursorline
set noswapfile
set backspace=indent,eol,start
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
" vim-airline now maps the new base16 airline themes:
"   cf. https://github.com/vim-airline/vim-airline/pull/948#issuecomment-193491975
let g:airline_theme='base16'
let g:airline_powerline_fonts=1
let g:airline#extensions#whitespace#enabled=0
let g:airline_section_z='per:%p%% col:%c'
