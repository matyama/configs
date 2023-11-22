" Plugin configuration
" See: https://www.chrisatmachine.com/Neovim/01-vim-plug/

" auto-install vim-plug
if empty(glob("$XDG_CONFIG_HOME/nvim/autoload/plug.vim"))
  silent !curl -fLo $XDG_CONFIG_HOME/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $XDG_CONFIG_HOME/nvim/init.vim
endif

call plug#begin("$XDG_CONFIG_HOME/nvim/autoload/plugged")

	" Capture some events in terminal and tmux vim
	Plug 'tmux-plugins/vim-tmux-focus-events'

	" Style

	" Base16 colors
	" https://github.com/tinted-theming/base16-vim
	Plug 'tinted-theming/base16-vim'

	" VIM enhancements
	
	" Secure modeline support
	" https://www.vim.org/scripts/script.php?script_id=1876
	Plug 'ciaranm/securemodelines'

	" Auto pairs for '(' '[' '{'
	Plug 'jiangmiao/auto-pairs'

	" Visually select increasingly larger regions of text
	"  - https://github.com/terryma/vim-expand-region
	"  - https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
	Plug 'terryma/vim-expand-region'

	" NeoVim enhancements

	" Library of utility functions in Lua
	" https://github.com/nvim-lua/plenary.nvim
	Plug 'nvim-lua/plenary.nvim'

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

	" Git blame
	" https://github.com/zivyangll/git-blame.vim
	Plug 'zivyangll/git-blame.vim'

	" Search

	" Change Vim working directory to project root
	" https://github.com/airblade/vim-rooter
	Plug 'airblade/vim-rooter'
	
	" Command-line fuzzy finder
	" https://github.com/junegunn/fzf
	Plug 'junegunn/fzf', { 'dir': $FZF_BASE, 'do': './install --bin --no-update-rc' }

	" Use RipGrep in Vim
	" https://github.com/jremmen/vim-ripgrep
	Plug 'jremmen/vim-ripgrep'

	" Use zoxide in Vim
	" https://github.com/nanotee/zoxide.vim
	Plug 'nanotee/zoxide.vim'

	" Syntactic language support
	Plug 'cespare/vim-toml', { 'branch': 'main' }
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

	" Quickstart configs for Nvim LSP
	" https://github.com/neovim/nvim-lspconfig
	Plug 'neovim/nvim-lspconfig'

	" Completion plugin coded in Lua, LSP client buffer, and path integration
	" https://github.com/hrsh7th/nvim-cmp
	"
	" NOTE: `*-vsip` inluded only because nvim-cmp requires snippets
	Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
	Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
	Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
	Plug 'hrsh7th/cmp-path', {'branch': 'main'}
	Plug 'hrsh7th/cmp-vsnip', {'branch': 'main'}
	Plug 'hrsh7th/vim-vsnip'

	" LSP signature hint as you type
	" https://github.com/ray-x/lsp_signature.nvim
	Plug 'ray-x/lsp_signature.nvim'

	" Inlay hints for the built-in LSP
	" https://github.com/lvimuser/lsp-inlayhints.nvim
	Plug 'lvimuser/lsp-inlayhints.nvim'

	" Standalone UI for nvim-lsp progress
	" https://github.com/j-hui/fidget.nvim
	Plug 'j-hui/fidget.nvim', { 'tag': 'legacy' }

	" TODO: Debugging

	" Debug Adapter Protocol client implementation
	" https://github.com/mfussenegger/nvim-dap
	"Plug 'mfussenegger/nvim-dap'

	" Dependency management
	"  - Rust: https://github.com/Saecki/crates.nvim
	Plug 'saecki/crates.nvim'

	call plug#end()

