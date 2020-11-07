" Setup plugins
source ~/.config/nvim/vim-plug/plugins.vim

" Enable line numbers by default
set number

" Enable automatic file reload
" See: https://vi.stackexchange.com/questions/444/how-do-i-reload-the-current-file
set autoread

" Trigger autoread when changing buffers inside while inside vim
au FocusGained,BufEnter * :checktime

" TOOD: Add more configs

