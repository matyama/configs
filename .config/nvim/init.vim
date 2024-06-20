lua require('init')

" Setup plugins
source $XDG_CONFIG_HOME/nvim/vim-plug/plugins.vim

" LSP configuration
lua require('lsp')

" TODO: deprecate with lazy
" https://github.com/rust-lang/rust.vim#installation
filetype plugin indent on

lua require('mappings')
