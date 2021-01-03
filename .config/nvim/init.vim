" Change <leader> from '/' to ','
let mapleader = ","

" =============================================================================
" # PLUGINS
" =============================================================================

" Setup plugins
source ~/.config/nvim/vim-plug/plugins.vim

" =============================================================================
" # Editor settings
" =============================================================================

" Enable line numbers by default
set number

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Show commands
set showcmd

" Enable automatic file reload
" See: https://vi.stackexchange.com/questions/444/how-do-i-reload-the-current-file
set autoread

" Trigger autoread when changing buffers inside while inside vim
au FocusGained,BufEnter * :checktime

" =============================================================================
" # Keyboard shortcuts
" =============================================================================

" Reload nvim config
" nnoremap <leader>sv :source $VIMRC<CR>

" ; as :
nnoremap ; :

" Ctrl+h to stop searching
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" Jump to start and end of line using the home row keys
map H ^
map L $

" Mappings to move line up with Alt+k and down with Alt+j
" https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
