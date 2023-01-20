call plug#begin(stdpath('data') . '/plugged')

Plug 'joshdick/onedark.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'

call plug#end()

let g:coc_global_extensions = ['coc-tsserver', 'coc-json']

set tabstop=2
set shiftwidth=2
set expandtab
set termguicolors

colorscheme onedark
