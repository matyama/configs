-- Change <leader> from '/' to '<Space>'
vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })

require("options")
require("mappings")

-- Setup plugin manager (https://github.com/folke/lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Auto-discover and setup plugins
-- https://github.com/folke/lazy.nvim/#-structuring-your-plugins
require("lazy").setup("plugins")

require("autocmds")
