" 开启语法高亮
syntax on

" 高亮search命中的文本
set hlsearch

" 显示行号
set number

" 突出显示当前行
set cursorline

" 关闭交换文件
set noswapfile

" 关闭vi兼容
set nocompatible

" 不设定在插入状态无法用退格键和Delete键删除回车符
set backspace=indent,eol,start 

" 把当前行的对齐格式应用到下一行
set autoindent

" 智能的选择对齐方式
set smartindent

" 设置缩进宽度
set shiftwidth=4

" 将Tab键转化成空格
set expandtab

" 改Tab键长度为4空格
set tabstop=4

" vim开启256色
set t_Co=256
let g:rehash256 = 1

" 高亮配色
colorscheme solarized
