augroup filetypedetect
  " Git commit message
  autocmd Filetype gitcommit setlocal spell tw=72 colorcolumn=73
  " Shorter columns in text
  autocmd Filetype tex setlocal spell tw=80 colorcolumn=81
  autocmd Filetype text setlocal spell tw=72 colorcolumn=73
  autocmd Filetype markdown setlocal spell tw=72 colorcolumn=73
  " No autocomplete in text
  autocmd BufRead,BufNewFile /tmp/mutt* let b:coc_enabled = 0
  autocmd Filetype tex let b:coc_enabled = 0
  autocmd Filetype text let b:coc_enabled = 0
  autocmd Filetype markdown let b:coc_enabled = 0
  " Comment highlighting for jsonc
  "  - https://scalameta.org/metals/docs/editors/vim/#installing-cocnvim
  autocmd FileType json syntax match Comment +\/\/.\+$+
augroup END
