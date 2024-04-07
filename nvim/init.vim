set background=dark
set hidden
set nocompatible            " disable compatibility to old-time vi
set relativenumber
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " enable mouse click 
set mouse=a                 " middle-click paste with
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=120                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set clipboard=unnamed       " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.


call plug#begin()
Plug 'lervag/vimtex'
Plug 'sirver/ultisnips'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' } " On-demand loading
Plug 'vim-airline/vim-airline'
Plug 'preservim/tagbar'
Plug 'folke/tokyonight.nvim'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'tpope/vim-commentary'
Plug 'machakann/vim-highlightedyank'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

colorscheme gruvbox

" Set Python path
let g:python3_host_prog = '/Users/nsc/.pyenv/versions/neovim/bin/python'

" vimtex
let g:vimtex_view_method = 'zathura'
" let g:vimtex_view_general_viewer = 'preview'
" let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:tex_flavor='latex'
let g:vimtex_quickfix_mode=0
" set conceallevel=1
let g:tex_conceal='abdmg'

" ultisnips
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']

" set yank hightlight
let g:highlightedyank_highlight_duration = 1000
