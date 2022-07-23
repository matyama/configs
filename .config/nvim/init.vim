" Change <leader> from '/' to '<Space>'
" https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
let mapleader = "\<Space>"

" Change <leader> from '/' to ','
" let mapleader = ","

" =============================================================================
" # PLUGINS
" =============================================================================

" Necesary for lots of cool vim things
set nocompatible

" Setup plugins
source $XDG_CONFIG_HOME/nvim/vim-plug/plugins.vim

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
      \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'cocstatus': 'coc#status'
      \ },
      \ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" from http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif

" NERDTree
" https://github.com/preservim/nerdtree#frequently-asked-questions
"  - https://github.com/Xuyuanp/nerdtree-git-plugin#faq

" Start NERDTree, unless a file or session is specified, eg. vim -S session_file.vim.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') && v:this_session == '' | NERDTree | endif

" Show hidden files in NERDTree by default
let g:NERDTreeShowHidden = 1

" Enable NerdFonts for NERDTree
let g:NERDTreeGitStatusUseNerdFonts = 1

" Show git ignored status for files in NERDTree
let g:NERDTreeGitStatusShowIgnored = 1

" Rust
" https://github.com/rust-lang/rust.vim#features
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" Completion
" https://github.com/neoclide/coc.nvim#example-vim-configuration

" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
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
"  - https://github.com/base16-project/base16-shell#base16-vim-users
"  - https://github.com/base16-project/base16-vim#256-colorspace
"  - https://github.com/base16-project/base16-vim#installation
if exists('$BASE16_THEME')
    \ && (!exists('g:colors_name') 
    \ || g:colors_name != 'base16-$BASE16_THEME')
  let base16colorspace=256
  colorscheme base16-$BASE16_THEME
endif

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
" https://github.com/neoclide/coc.nvim#example-vim-configuration
set hidden

" Stop line breaking
set nowrap

" Join lines without an extra space
set nojoinspaces

" Go to next search match with another 's'
" https://github.com/justinmk/vim-sneak#usage
let g:sneak#s_next = 1

" Print config
set printfont=:h10
set printencoding=utf-8
set printoptions=paper:letter

" Always draw sign column. Prevent buffer moving when adding/deleting sign.
" https://github.com/neoclide/coc.nvim#example-vim-configuration 
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

" Show red vertical bar at coloumn 80
set colorcolumn=80

" Show (partial) command in status line.
set showcmd

" Enable mouse usage (all modes) in terminals
set mouse=a

" Don't pass messages to |ins-completion-menu|.
" https://github.com/neoclide/coc.nvim#example-vim-configuration
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

" NERDTree shortcuts
"  - source: https://stackoverflow.com/a/58627426/15112035
"  - improved: https://bit.ly/3nKuCHb

function NerdTreeToggleFind()
    if &filetype == 'nerdtree' || exists("g:NERDTree") && g:NERDTree.IsOpen()
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction

" NOTE: This breaks 'New Text File...' in VS Code, use <C-t> there insted
nnoremap <C-n> :call NerdTreeToggleFind()<CR>
nnoremap <leader>n :NERDTreeFocus<CR>

" Metals (Scala language server) shortcuts
" https://scalameta.org/metals/docs/editors/vim/#recommended-cocnvim-mappings
"  - Expand decorations in worksheets
"  - Toggle panel with Tree Views
"  - Toggle Tree View 'metalsPackages'
"  - Toggle Tree View 'metalsCompile'
"  - Toggle Tree View 'metalsBuild'
"  - Reveal current current class (trait or object) in Tree View 'metalsPackages'
nmap <Leader>ws <Plug>(coc-metals-expand-decoration)
nnoremap <silent> <space>t :<C-u>CocCommand metals.tvp<CR>
nnoremap <silent> <space>tp :<C-u>CocCommand metals.tvp metalsPackages<CR>
nnoremap <silent> <space>tc :<C-u>CocCommand metals.tvp metalsCompile<CR>
nnoremap <silent> <space>tb :<C-u>CocCommand metals.tvp metalsBuild<CR>
nnoremap <silent> <space>tf :<C-u>CocCommand metals.revealInTreeView metalsPackages<CR>

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

" Open new file located in the same direactory as current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Mappings to move line up with Alt+k and down with Alt+j
" https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" 'Smart' nevigation
" - https://github.com/neoclide/coc.nvim#example-vim-configuration
" - https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Show stats with <leader>+q
nnoremap <leader>q g<c-g>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" Introduce function and class text objects 
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
"  - https://github.com/neoclide/coc.nvim#example-vim-configuration
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

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

