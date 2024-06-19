-- Change <leader> from '/' to '<Space>'
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })

require('options')
require('autocmds')
