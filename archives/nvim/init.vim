set shell=/bin/zsh
set shiftwidth=4
set tabstop=4
set expandtab
set textwidth=0
set autoindent
set hlsearch
set clipboard=unnamed
syntax on

call plug#begin()
Plug 'ntk148v/vim-horizon'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

"vim-horizon
" if you don't set this option, this color might not correct
set termguicolors

colorscheme horizon
highlight Normal guibg=#2e2e2e guifg=#ffffff
set guicursor=n-v-c:block-Cursor/lCursor
highlight Cursor guifg=black guibg=white
highlight lCursor guifg=white guibg=black
highlight Visual guibg=#44475a guifg=NONE

" lightline
let g:lightline = {}
let g:lightline.colorscheme = 'horizon'

" NERDTree
" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" fzf
set rtp+=/usr/local/opt/fzf

" gitgutter
let g:gitgutter_highlight_lines = 1
" 


