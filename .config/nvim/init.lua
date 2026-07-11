-- Change <leader> from '/' to '<Space>'
vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })

require("options")
require("mappings")

-------------------------------------------------------------------------------
-- Configuring diagnostics
-------------------------------------------------------------------------------
local diagnostic_jump_ns = vim.api.nvim_create_namespace("on_diagnostic_jump")

vim.diagnostic.config({
  jump = {
    -- Show the diagnostic in as a floating text window
    -- float = true,

    -- Setup implicit callback for vim.diagnostic.jump() calls
    on_jump = function(diagnostic, bufnr)
      if not diagnostic then
        return
      end

      vim.diagnostic.show(diagnostic_jump_ns, bufnr, { diagnostic }, {
        -- Allow virtual text
        virtual_text = true,
        -- Disable virtual lines
        virtual_lines = false,
      })
    end,
  },
})

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
