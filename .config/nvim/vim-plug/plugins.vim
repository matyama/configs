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

	" Style

	" Base16 colors
	" https://github.com/chriskempson/base16-vim#installation
	Plug 'chriskempson/base16-vim'

	" VIM enhancements
	
	" Secure modeline support
	" https://www.vim.org/scripts/script.php?script_id=1876
	Plug 'ciaranm/securemodelines'

	" Jump to any location specified by two characters
	" https://github.com/justinmk/vim-sneak
	Plug 'justinmk/vim-sneak'

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
	" https://github.com/andymass/vim-matchup
	Plug 'andymass/vim-matchup'

	" Better Syntax Support
	" https://github.com/sheerun/vim-polyglot#installation
	Plug 'sheerun/vim-polyglot'

	" Search

	" Change Vim working directory to project root
	" https://github.com/airblade/vim-rooter
	Plug 'airblade/vim-rooter'
	
	" Command-line fuzzy finder
	" https://github.com/junegunn/fzf
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

	" Use RipGrep in Vim
	" https://github.com/jremmen/vim-ripgrep
	Plug 'jremmen/vim-ripgrep'

	" Syntactic language support
	Plug 'cespare/vim-toml'
	Plug 'stephpy/vim-yaml'
	Plug 'rust-lang/rust.vim'
	Plug 'plasticboy/vim-markdown'

	" A (Neo)vim plugin for formatting code
	" https://github.com/sbdchd/neoformat
	Plug 'sbdchd/neoformat'

	" Bindings for Haskell hlint code refactoring
	" https://github.com/mpickering/hlint-refactor-vim
	Plug 'mpickering/hlint-refactor-vim'

	" Semantic language support
	" https://github.com/neoclide/coc.nvim#quick-start
	"  * Rust:
	"    - https://github.com/fannheyward/coc-rust-analyzer
	"    - https://rust-analyzer.github.io/manual.html#vimneovim
	"  * Python:
	"    - https://github.com/fannheyward/coc-pyright#install
	"    - https://github.com/microsoft/pyright/blob/main/docs/configuration.md
	Plug 'neoclide/coc.nvim', {'branch': 'release'}

	" NERDTree File Explorer
	" https://github.com/preservim/nerdtree
	"  - Git status flags
	"  - Filetype-specific icons
	"  - Syntax highlighting based on filetype
	"  - Enable open, delete, move, or copy of visually-selected files
	Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \ Plug 'ryanoasis/vim-devicons' |
						\ Plug 'tiagofumo/vim-nerdtree-syntax-highlight' |
						\ Plug 'PhilRunninger/nerdtree-visual-selection'

	call plug#end()

