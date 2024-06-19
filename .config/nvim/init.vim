lua require('init')

" =============================================================================
" # PLUGINS
" =============================================================================

" Setup plugins
source $XDG_CONFIG_HOME/nvim/vim-plug/plugins.vim

" LSP configuration
lua require('lsp')

" https://github.com/rust-lang/rust.vim#installation
filetype plugin indent on

" Secure modeline config
" https://www.vim.org/scripts/script.php?script_id=1876
let g:secure_modelines_allowed_items = [
      \ "textwidth",   "tw",
      \ "softtabstop", "sts",
      \ "tabstop",     "ts",
      \ "shiftwidth",  "sw",
      \ "expandtab",   "et",   "noexpandtab", "noet",
      \ "filetype",    "ft",
      \ "foldmethod",  "fdm",
      \ "readonly",    "ro",   "noreadonly", "noro",
      \ "rightleft",   "rl",   "norightleft", "norl",
      \ "colorcolumn"
      \ ]

" Lightline
"  - https://github.com/itchyny/lightline.vim#advanced-configuration
"  - https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileencoding', 'filetype' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" Java
let java_ignore_javadoc=1

" JavaScript
let javaScript_fold=0

" Latex
let g:latex_indent_enabled = 1
let g:latex_fold_envs = 0
let g:latex_fold_sections = []

" Rust
" https://github.com/rust-lang/rust.vim#features
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'wl-copy'

" Neoformat (https://github.com/sbdchd/neoformat)
"  - Shell (shfmt): indent switch cases
"  - Hotfix: disables formatting zsh files (shfmt breaks `(( $+commands[x] ))`)
let g:shfmt_opt="-ci"
let g:neoformat_enabled_zsh = []

" Fix folding and unfolding of Markdown files
" https://github.com/plasticboy/vim-markdown/issues/414#issuecomment-519061229
let g:vim_markdown_folding_style_pythonic = 1

" =============================================================================
" # Editor settings
" =============================================================================

" Pick Base16 color scheme and access colors present in 256 colorspace
"  - https://github.com/tinted-theming/base16-shell#base16-vim-users
"  - https://github.com/tinted-theming/base16-vim#256-colorspace
"  - https://github.com/tinted-theming/base16-vim#installation
if exists('$BASE16_THEME')
    \ && (!exists('g:colors_name') 
    \ || g:colors_name != 'base16-$BASE16_THEME')
  let base16colorspace=256
  colorscheme base16-$BASE16_THEME
endif

" =============================================================================
" # Keyboard shortcuts
" =============================================================================

lua require('mappings')
