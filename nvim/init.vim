" ==============================================
" Basic Neovim config for VSCode Neovim extension
" Source of truth: ~/dotfiles/nvim/init.vim
" (plugins intentionally omitted)
" ==============================================

" Leaders
let mapleader = " "
let maplocalleader = ","

" UI / editing basics
set termguicolors
set number
set relativenumber
set signcolumn=yes
set cursorline

set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent

set list
set listchars=tab:\|\ ,trail:·
set fillchars=eob:\ 

set scrolloff=5
set splitbelow
set splitright

set ignorecase
set smartcase
set completeopt=menuone,noselect

set updatetime=100
set virtualedit=block
set inccommand=split
set noshowmode

" Basic keymaps
nnoremap ; :
nnoremap Q :q<CR>
noremap <silent> <leader><CR> :nohlsearch<CR>

nnoremap J 5j
nnoremap K 5k
xnoremap J 5j
xnoremap K 5k

nnoremap <silent> <C-g> :echo line('.') col('.')<CR>

" Surround current word
nnoremap <leader>( bi(<Esc>ea)<Esc>
nnoremap <leader>[ bi[<Esc>ea]<Esc>
nnoremap <leader>{ bi{<Esc>ea}<Esc>

nnoremap s <Nop>

" Window navigation
nnoremap <leader>l <C-w>l
nnoremap <leader>k <C-w>k
nnoremap <leader>j <C-w>j
nnoremap <leader>h <C-w>h

" Terminal mode back to Normal mode
" (kept from your original config)
tnoremap <C-N> <C-\\><C-N>
