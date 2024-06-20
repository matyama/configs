-- https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim

local cmp = require("cmp")

cmp.setup({

  snippet = {
    -- NOTE: required by nvim-cmp, get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    -- Accept currently selected item
    -- Set `select` to `false` to only confirm explicitly selected items
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),

  sources = cmp.config.sources({
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = "nvim_lsp" },
  }, {
    { name = "path" },
    { name = "buffer" },
  }),

  experimental = {
    ghost_text = true,
  },
})

-- Enable completing paths in :
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" }
  })
})

-- Lazily enable auto-completion via crates.nvim in Cargo.toml
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    callback = function()
        cmp.setup.buffer({ sources = { { name = "crates" } } })
    end,
})

-- XXX: document or deprecate
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
