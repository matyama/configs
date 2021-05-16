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

	" VIM enhancements
	
	" Auto pairs for '(' '[' '{'
	Plug 'jiangmiao/auto-pairs'

	" Visually select increasingly larger regions of text
	"  - https://github.com/terryma/vim-expand-region
	"  - https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
	Plug 'terryma/vim-expand-region'

	" GUI enhancements
	
	" A light and configurable statusline
	Plug 'itchyny/lightline.vim'

	" Make the yanked region apparent
	Plug 'machakann/vim-highlightedyank'

	" Navigate and highlight matching words
	" Plug 'andymass/vim-matchup'

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

	" NERDTree File Explorer
	" https://github.com/preservim/nerdtree
	"  - Git status flags
	"  - Filetype-specific icons
	Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \ Plug 'ryanoasis/vim-devicons'

	call plug#end()

