set nocompatible
filetype off
" Plugins begin
call plug#begin('~/.vim/plugged')
" Plugins follow
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'base16-community/base16-vim'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
" Plugins end
call plug#end()
filetype plugin indent on

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
colorscheme base16-snazzy

" vim-airline: (cf. https://github.com/vim-airline/vim-airline)
" vim-airline now maps the new base16 airline themes:
"   cf. https://github.com/vim-airline/vim-airline/pull/948#issuecomment-193491975
let g:airline_theme='base16'
let g:airline_powerline_fonts=1
let g:airline#extensions#whitespace#enabled=0
let g:airline_section_z='per:%p%% col:%c'
