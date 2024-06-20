" Plugin configuration
" See: https://www.chrisatmachine.com/Neovim/01-vim-plug/

" auto-install vim-plug
if empty(glob("$XDG_CONFIG_HOME/nvim/autoload/plug.vim"))
  silent !curl -fLo $XDG_CONFIG_HOME/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $XDG_CONFIG_HOME/nvim/init.vim
endif

call plug#begin("$XDG_CONFIG_HOME/nvim/autoload/plugged")

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

	call plug#end()
