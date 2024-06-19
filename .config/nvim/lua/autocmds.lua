-- https://neovim.io/doc/user/api.html
local api = vim.api

-------------------------------------------------------------------------------
-- Mode events
-------------------------------------------------------------------------------

-- Highlight yanked text
api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    command = 'silent! lua vim.highlight.on_yank({ timeout = 500 })',
})

-- Leave paste mode when leaving insert mode
api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    command = 'set nopaste',
})

-------------------------------------------------------------------------------
-- Buffer events
-------------------------------------------------------------------------------

-- Trigger autoread when changing buffers while inside vim
api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
    pattern = '*',
    command = 'checktime',
})

-- Jump to last edit position on opening file
api.nvim_create_autocmd('BufReadPost', {
    pattern = '*',
    callback = function(ev)
        local fn = vim.fn
        if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
            -- except for in git commit messages
            -- https://stackoverflow.com/a/31451511
            if not fn.expand('%:p'):find('.git', 1, true) then
                vim.cmd('exe "normal! g\'\\""')
            end
        end
    end
})

-- Prevent accidental writes to buffers that shouldn't be edited
api.nvim_create_autocmd('BufRead', {
    pattern = '*.orig',
    command = 'set readonly',
})

-- TODO: deprecate in favor of `conform.nvim` (use `format_on_save`)
-- Run a formatter on save (https://github.com/sbdchd/neoformat#basic-usage)
local fmt = api.nvim_create_augroup('fmt', { clear = true })

api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    group = fmt,
    command = 'undojoin | Neoformat',
})

-------------------------------------------------------------------------------
-- Filetype: text
-------------------------------------------------------------------------------

local text = api.nvim_create_augroup('text', { clear = true })

-- Shorter columns in text because it reads better that way
for _, pat in ipairs({'text', 'markdown', 'mail', 'gitcommit'}) do
    api.nvim_create_autocmd('Filetype', {
        pattern = pat,
        group = text,
        command = 'setlocal spell tw=72 colorcolumn=73',
    })
end

--- tex has so much syntax that a little wider is ok
api.nvim_create_autocmd('Filetype', {
    pattern = 'tex',
    group = text,
    command = 'setlocal spell tw=80 colorcolumn=81',
})

-------------------------------------------------------------------------------
-- Filetype: rust
-------------------------------------------------------------------------------

-- XXX: deprecate completely (or keep just colorcolumn)
api.nvim_create_autocmd('Filetype', {
    pattern = 'rust',
    command =
    'setlocal colorcolumn=100 shiftwidth=4 softtabstop=4 tabstop=4 expandtab'
})

-------------------------------------------------------------------------------
-- Filetype: scala
-------------------------------------------------------------------------------

local scala = api.nvim_create_augroup('scala', { clear = true })

-- Shorter columns in text because it reads better that way
for _, pat in ipairs({'*.sbt', '*.sc'}) do
    api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
        pattern = pat,
        group = scala,
        command = 'set filetype=scala',
    })
end

-------------------------------------------------------------------------------
-- Colors
-------------------------------------------------------------------------------

-- TODO: move to base16 plugin config
api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function(ev)
        -- Make the background terminal color transparent for the Normal group
        -- https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
        normal.ctermbg = nil
        api.nvim_set_hl(0, 'Normal', normal)

        -- Make comments more prominent
        local bools = vim.api.nvim_get_hl(0, { name = 'Boolean' })
        api.nvim_set_hl(0, 'Comment', bools)

        -- Highlight current arguments
        local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
        api.nvim_set_hl(0, 'LspSignatureActiveParameter', {
            fg = marked.fg,
            bg = marked.bg,
            ctermfg = marked.ctermfg,
            ctermbg = marked.ctermbg,
            bold = true
        })
    end
})
