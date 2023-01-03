syntax enable
set background=dark
"colorscheme atom-dark-256
filetype plugin indent on

set number
set clipboard=unnamedplus
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
	autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

set ai
set hlsearch
set incsearch
set sidescroll=1
set tabstop=4
set autoindent
set mouse=a

nnoremap <C-k> :m .+1<CR>==
nnoremap <C-l> :m .-2<CR>==
inoremap <C-k> <Esc>:m .+1<CR>==gi
inoremap <C-l> <Esc>:m .-2<CR>==gi
vnoremap <C-k> :m '>+1<CR>gv=gv
vnoremap <C-l> :m '<-2<CR>gv=gv

noremap ; l
noremap l k
noremap k j
noremap j h

noremap ж l
noremap д k
noremap л j
noremap о h
