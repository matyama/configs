" Original formatter settings with additional sqlfluff as the default formatter
function! neoformat#formatters#sql#enabled() abort
    return ['sqlfluff', 'sqlformat', 'pg_format', 'sqlfmt']
endfunction

function! neoformat#formatters#sql#sqlfluff() abort
    return {
        \ 'exe': 'sqlfluff',
        \ 'args': ['fix', '--force', '--disable_progress_bar', '-'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#sql#sqlformat() abort
    return {
        \ 'exe': 'sqlformat',
        \ 'args': ['--reindent', '-'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#sql#pg_format() abort
    return {
        \ 'exe': 'pg_format',
        \ 'args': ['-'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#sql#sqlfmt() abort
    return {
        \ 'exe': 'sqlfmt',
        \ 'args': [],
        \ 'stdin': 1,
        \ }
endfunction
