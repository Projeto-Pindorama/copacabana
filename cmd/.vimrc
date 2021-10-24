" Caio's vimrc

" Basic options
set nocompatible
syntax on
set number
filetype plugin indent on

" Indent without hard tabs
set expandtab
set shiftwidth=2
set softtabstop=2

" Limit lines to be at most 80 characters long
set textwidth=80

" Enable True Colors
set termguicolors

" Automatically remove all trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

" ~/ Clean-up
let g:netrw_dirhistmax=0
set viminfo=""
