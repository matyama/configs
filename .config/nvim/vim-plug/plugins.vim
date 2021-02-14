" Plugin configuration
" See: https://www.chrisatmachine.com/Neovim/01-vim-plug/

" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source ~/.config/nvim/init.vim
endif

call plug#begin('~/.config/nvim/autoload/plugged')

	" Capture some events in terminal and tmux vim
	Plug 'tmux-plugins/vim-tmux-focus-events'

	" Auto pairs for '(' '[' '{'
	Plug 'jiangmiao/auto-pairs'

	" Better Syntax Support
	" https://github.com/sheerun/vim-polyglot#installation
	Plug 'sheerun/vim-polyglot'

	" Syntactic language support
	Plug 'cespare/vim-toml'
	Plug 'stephpy/vim-yaml'
	Plug 'rust-lang/rust.vim'
	Plug 'plasticboy/vim-markdown'

	" Semantic language support
	" https://github.com/neoclide/coc.nvim#quick-start
	"  - https://github.com/fannheyward/coc-rust-analyzer
	"  - https://rust-analyzer.github.io/manual.html#vimneovim
	Plug 'neoclide/coc.nvim', {'branch': 'release'}

	" TODO: Experiment with 
	
	" File Explorer
	" Plug 'scrooloose/NERDTree'
	
call plug#end()

