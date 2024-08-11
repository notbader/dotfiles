" General Settings
set nocompatible                " Disable compatibility with vi
set encoding=utf-8              " Use UTF-8 encoding
set clipboard=unnamedplus       " Use system clipboard
set hidden                      " Allow hidden buffers
set nobackup                    " Disable backup files
set nowritebackup               " Disable backup before overwriting
set cmdheight=2                 " More space for displaying messages
set updatetime=300              " Faster completion
set shortmess+=c                " Avoid showing extra messages when using completion
set termguicolors               " Enable true color support
set splitbelow                  " Open new horizontal splits below
set splitright                  " Open new vertical splits to the right
syntax on                       " Enable syntax highlighting
filetype plugin indent on       " Enable filetype detection, plugins, and indentation
set foldmethod=indent           " Fold based on indentation
set foldlevel=99                " Start with all folds open
set number                      " Show line numbers
set relativenumber              " show line number on the current line relative to other lines
let python_highlight_all=1      " Highlight all Python syntax

" Tab and Indentation Settings
set tabstop=4                   " Number of spaces in a tab
set shiftwidth=4                " Number of spaces to use for autoindent
set expandtab                   " Use spaces instead of tabs
set smarttab                    " sets `tabstop` number of spaces when the tab is pressed
set softtabstop=4               " sets 4 spaces when tab or backspace is pressed

" Mouse Settings
set mouse=a                     " enables the mouse for scrolling and resize

" Leader Key
let mapleader = " "

" Clipboard Mappings
vnoremap <C-S-X> "+x           " Ctrl-Shift-X to cut
vnoremap <C-S-C> "+y           " Ctrl-Shift-C to copy
map <C-S-V> "+gP               " Ctrl-Shift-V to paste
imap <C-S-V> <C-R>+
cmap <C-S-V> <C-R>+

" Ensure visual selections with vG extend to the end of the line, and vgg to the beginning
vnoremap G G$
vnoremap gg gg^

" Ensure G in normal mode goes to the end of the line, and gg to the beginning
nnoremap G G$
nnoremap gg gg^

" Leader Key Mappings
nnoremap <leader>a ggVG        " Select all
nnoremap <leader>] >>          " Indent line or selection
vnoremap <leader>] >gv
nnoremap <leader>[ <<          " De-indent line or selection
vnoremap <leader>[ <gv

" Undo and Redo Mappings
nnoremap <C-z> u               " Ctrl-Z to undo
inoremap <C-z> <C-o>u
nnoremap <C-r> <C-r>           " Ctrl-R to redo
inoremap <C-r> <C-o><C-r>

" NERDTree Key Mappings
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>t :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" Window Navigation Mappings
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Folding with the Spacebar
nnoremap <leader> fo

" Plugin Management
call plug#begin('~/.config/nvim/plugged')

" Core Plugins
Plug 'tpope/vim-fugitive'                   " Git integration
Plug 'scrooloose/nerdtree'                  " File explorer
Plug 'kien/ctrlp.vim'                       " Fuzzy file finder
Plug 'vim-airline/vim-airline'              " Status/tabline
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " Fuzzy finder
Plug 'junegunn/fzf.vim'                     " Fzf integration for Vim
Plug 'akinsho/toggleterm.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

" Color Scheme
Plug 'AlexvZyl/nordic.nvim', { 'branch': 'main' }

" Python-specific Plugins
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install', 'for': 'python' } " Python docstring generator
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Conquer of Completion (CoC)

call plug#end()

" Auto Commands
autocmd VimEnter * if argc() == 0 | execute "NERDTree" | endif  " Start NERDTree unless a file is specified
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif  " Exit Neovim if NERDTree is the only window remaining

" Filetype-specific indentation
autocmd FileType html,css,yaml,javascript setlocal shiftwidth=2 tabstop=2 expandtab
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

" Python-specific settings
let g:pydocstring_formatter = 'google'           " Use Google style docstrings
let g:vimspector_install_gadgets = [ 'debugpy' ] " Debugpy for debugging Python in Vimspector

" Define terminal settings
set shell=powershell.exe
set shellxquote=
let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
let &shellquote   = ''
let &shellpipe    = '| Out-File -Encoding UTF8 %s'
let &shellredir   = '| Out-File -Encoding UTF8 %s'


" Configure ToggleTerm
lua << EOF
require("toggleterm").setup{
  size = 20,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  direction = "horizontal",  -- Default direction can be overridden with mappings
  close_on_exit = true,
  shell = shell,  -- Use the default shell, like PowerShell
}
EOF

" Map <C-t>h to open a terminal in a horizontal split
nnoremap <C-t>h :ToggleTerm direction=horizontal<CR>

" Map <C-t>v to open a terminal in a vertical split
nnoremap <C-t>v :ToggleTerm direction=vertical<CR>
