" Change <leader> from '/' to '<Space>'
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
let mapleader = "\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================

" Necessary for lots of cool vim things
set nocompatible

" Setup plugins
source $XDG_CONFIG_HOME/nvim/vim-plug/plugins.vim

" LSP configuration
lua require('lsp')

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

" from http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif

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
let g:rust_clip_command = 'xclip -selection clipboard'

" Neoformat (https://github.com/sbdchd/neoformat)
"  - Shell (shfmt): indent switch cases
"  - Hotfix: disables formatting zsh files (shfmt breaks `(( $+commands[x] ))`)
let g:shfmt_opt="-ci"
let g:neoformat_enabled_zsh = []

" Better completion
"  - menuone: popup even when there's only one match
"  - noinsert: do not insert text until a selection is made
"  - noselect: do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000
set updatetime=300

" Fix folding and unfolding of Markdown files
" https://github.com/plasticboy/vim-markdown/issues/414#issuecomment-519061229
let g:vim_markdown_folding_style_pythonic = 1

" =============================================================================
" # Editor settings
" =============================================================================

" Color setup
" https://github.com/jonhoo/configs/

if has('nvim')
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
    set inccommand=nosplit
    noremap <C-q> :confirm qall<CR>
end

if !has('gui_running')
  set t_Co=256
endif
if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

set background=dark

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

" Enable spell check
"  - https://linuxhint.com/vim_spell_check
"  - ']s' or '[s' - navigate, 'z=' - correct, 'zg' - add word to 'spellfile'
set spell
set spelllang=en_us
set spellfile=$XDG_STATE_HOME/nvim/spell/en-utf-8.add

" Enable syntax highlight
"  - alternatively change to `syntax on`
syntax enable

" When using a color terminal, set the background terminal color to `NONE` for
" the `Normal` group.
"
" https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax/
hi Normal ctermbg=NONE

" Brighter comments
call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")

" Highlight current arguments
call Base16hi("LspSignatureActiveParameter",
      \ g:base16_gui05,
      \ g:base16_gui03,
      \ g:base16_cterm05,
      \ g:base16_cterm03,
      \ "bold",
      \ "")

" https://github.com/rust-lang/rust.vim#installation
filetype plugin indent on
set autoindent

" http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set timeoutlen=300

" Default encoding
set encoding=utf-8

" Show some lines after cursor
set scrolloff=2

" Hide status
set noshowmode

" TextEdit might fail if hidden is not set.
set hidden

" Stop line breaking
set nowrap

" Join lines without an extra space
set nojoinspaces

" Always draw sign column. Prevent buffer moving when adding/deleting sign.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Sane splits
set splitright
set splitbelow

" Permanent undo
set undodir=$XDG_STATE_HOME/vimdid
set undofile

" Decent wildmenu
set wildmenu
set wildmode=list:longest,full
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,*.o,*.hi

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Show commands
set showcmd

" Enable automatic file reload
" https://vi.stackexchange.com/questions/444/how-do-i-reload-the-current-file
set autoread

" Trigger autoread when changing buffers inside while inside vim
au FocusGained,BufEnter * :checktime

" =============================================================================
" # GUI settings
" =============================================================================

" Remove toolbar
set guioptions-=T

" No more beeps
set vb t_vb= "

" Backspace over newlines
set backspace=2 

" TODO
" set nofoldenable

" Scroll fast
set ttyfast

" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500

" Always display status line
set laststatus=2

" Enable line relative and absolute numbers by default
set relativenumber
set number

" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=iwhite
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic

" Show red vertical bar at column 80
set colorcolumn=80

" Show (partial) command in status line.
set showcmd

" Enable mouse usage (all modes) in terminals
set mouse=a

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Show those damn hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set listchars=nbsp:¬,extends:»,precedes:«,trail:•

" =============================================================================
" # Keyboard shortcuts
" =============================================================================

" Reload nvim config
nnoremap <leader>sv :source $VIMRC<CR>

" ; as :
nnoremap ; :

" FZF key bindings
"  - open file with FZF using Ctrl+p
"  - this file can be opened in new tab (Ctrl+t) or horizontal/vertical split
"    (Ctrl+h/Ctrl+v)
nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-h': 'split',
  \ 'ctrl-v': 'vsplit' }

" Open hotkeys
" FIXME: Files have similar issue with fzf as Rg search does
"map <C-p> :Files<CR>
nmap <leader>; :buffers<CR>

" Switch buffers with <leader>+<Right>/<Left>
nnoremap <leader><Left> :bp<CR>
nnoremap <leader><Right> :bn<CR>

" Toggle between buffers with <leader><leader>
nnoremap <leader><leader> <c-^>

" Move by line
nnoremap j gj
nnoremap k gk

" Make Ctrl+j/k act as Esc
nnoremap <C-j> <Esc>
inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>
snoremap <C-j> <Esc>
xnoremap <C-j> <Esc>
cnoremap <C-j> <C-c>
onoremap <C-j> <Esc>
lnoremap <C-j> <Esc>
tnoremap <C-j> <Esc>

nnoremap <C-k> <Esc>
inoremap <C-k> <Esc>
vnoremap <C-k> <Esc>
snoremap <C-k> <Esc>
xnoremap <C-k> <Esc>
cnoremap <C-k> <C-c>
onoremap <C-k> <Esc>
lnoremap <C-k> <Esc>
tnoremap <C-k> <Esc>

" Open a new file with <leader>+o and replicate with <leader>+op
nnoremap <leader>o :vnew<CR>
nnoremap <leader>op :vsp<CR>

" Open a new split with <leader>+v and replicate with <leader>+vp and
" similarly for horizontal split with h/hp (vsplit is equivalent to <leader>o)
nnoremap <leader>v :vnew<CR>
nnoremap <leader>vp :vsp<CR>
nnoremap <leader>h :new<CR>
nnoremap <leader>hp :sp<CR>

" Use <leader>+x to close a split
nnoremap <leader>x <c-w>c

" Use <leader>+<Right/Left/Up/Down> to switch between splits
nnoremap <leader><Right> <C-W><Right>
nnoremap <leader><Left> <C-W><Left>
nnoremap <leader><Up> <C-W><Up>
nnoremap <leader><Down> <C-W><Down>

" Use Ctrl+t to open new tab and Ctrl+w to close it
nnoremap <C-t> :tabnew<CR>
nnoremap <C-w> :tabclose<CR>

" Use Ctrl+Left/Ctrl+Right (or j/k) to go to the next/previous tab
"  - note: cannot use <C-tab>/<C-S-tab>, <TAB> is reserved for range selection
"    with a language server, plus setting this nicely integrates with VS Code
"  - note: cannot use h/l, <c-h> is reserved for cleaning up search
nnoremap <C-Left> :tabprevious<CR>                                                                            
nnoremap <C-Right> :tabnext<CR>
nnoremap <C-j> :tabprevious<CR>                                                                            
nnoremap <C-k> :tabnext<CR>

" Save file with <leader>+w
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
nnoremap <leader>w :w<CR>

" Enter visual mode with <leader><leader>
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
"  - Note: currently disable in favor of switching between buffers
" nmap <leader><leader> V

" Press 'v' to expand the visual selection and C-v to shrink it.
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" Ctrl+h to stop searching
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" Spell check hint/correction with z+f
nmap zf z=

" Jump to start and end of line using the home row keys
map H ^
map L $

" Neat X clipboard integration
" <leader>p will paste clipboard into buffer
" <leader>c will copy entire buffer into clipboard
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
vnoremap <leader>y "+y
vnoremap <leader>d "+d
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P
"noremap <leader>p :read !xsel --clipboard --output<cr>
"noremap <leader>c :w !xsel -ib<cr><cr>

" Use <leader>b to display git blame info for current line
nnoremap <leader>b :<C-u>call gitblame#echo()<CR>

" FIXME: rg/fzf does not seem to work after reloading vim config
" Use <leader>s for Rg search
noremap <leader>s :Rg<Space>
let g:fzf_layout = { 'down': '~20%' }
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --hidden --smart-case --color=always -- '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
  \   <bang>0)

function! s:list_cmd()
  let base = fnamemodify(expand('%'), ':h:.:S')
  return base == '.' ? 
                    \ 'fd --type file --follow --hidden' : 
                    \ printf('fd --type file --follow --hidden | proximity-sort %s', shellescape(expand('%')))
endfunction

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source': s:list_cmd(),
  \                               'options': '--tiebreak=index'}, <bang>0)

" Open new file located in the same directory as current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Mappings to move line up with Alt+k and down with Alt+j
" https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Show stats with <leader>+q
nnoremap <leader>q g<c-g>

" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" Crates (Cargo.toml)
" https://github.com/Saecki/crates.nvim

nnoremap <silent> <leader>ct :lua require('crates').toggle()<cr>
nnoremap <silent> <leader>cr :lua require('crates').reload()<cr>

nnoremap <silent> <leader>cv :lua require('crates').show_versions_popup()<cr>
nnoremap <silent> <leader>cf :lua require('crates').show_features_popup()<cr>
nnoremap <silent> <leader>cd :lua require('crates').show_dependencies_popup()<cr>

nnoremap <silent> <leader>cu :lua require('crates').update_crate()<cr>
vnoremap <silent> <leader>cu :lua require('crates').update_crates()<cr>
nnoremap <silent> <leader>ca :lua require('crates').update_all_crates()<cr>
nnoremap <silent> <leader>cU :lua require('crates').upgrade_crate()<cr>
vnoremap <silent> <leader>cU :lua require('crates').upgrade_crates()<cr>
nnoremap <silent> <leader>cA :lua require('crates').upgrade_all_crates()<cr>

nnoremap <silent> <leader>ce :lua require('crates').expand_plain_crate_to_inline_table()<cr>
nnoremap <silent> <leader>cE :lua require('crates').extract_crate_into_table()<cr>

nnoremap <silent> <leader>cH :lua require('crates').open_homepage()<cr>
nnoremap <silent> <leader>cR :lua require('crates').open_repository()<cr>
nnoremap <silent> <leader>cD :lua require('crates').open_documentation()<cr>
nnoremap <silent> <leader>cC :lua require('crates').open_crates_io()<cr>

" Show appropriate documentation in Cargo.toml
nnoremap <silent> K :call <SID>show_documentation()<cr>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (index(['man'], &filetype) >= 0)
        execute 'Man '.expand('<cword>')
    elseif (expand('%:t') == 'Cargo.toml' && luaeval('require("crates").popup_available()'))
        lua require('crates').show_popup()
    else
        lua vim.lsp.buf.hover()
    endif
endfunction

" =============================================================================
" # Autocommands
" =============================================================================

" Prevent accidental writes to buffers that shouldn't be edited
autocmd BufRead *.orig set readonly

" Leave paste mode when leaving insert mode
autocmd InsertLeave * set nopaste

" Jump to last edit position on opening file
" https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
if has("autocmd")
  au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Run a formatter on save
" https://github.com/sbdchd/neoformat#basic-usage
augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END

" Follow Rust code style rules
au Filetype rust source $XDG_CONFIG_HOME/nvim/scripts/spacetab.vim
au Filetype rust set colorcolumn=100

" Help filetype detection
autocmd BufRead *.plot set filetype=gnuplot
autocmd BufRead *.md set filetype=markdown
autocmd BufRead *.tex set filetype=tex
autocmd BufRead,BufNewFile *.sbt,*.sc set filetype=scala

