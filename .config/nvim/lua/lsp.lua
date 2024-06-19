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

-- Setup lspconfig
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- https://github.com/lvimuser/lsp-inlayhints.nvim
local inlayhints = require("lsp-inlayhints")
inlayhints.setup { inlay_hints = { only_current_line = true  } }

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)

  -- Disable semantics tokens (treesitter)
  -- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
  client.server_capabilities.semanticTokensProvider = nil

  -- Disable hover for Ruff in favor of Pyright
  if client.name == 'ruff' then
    client.server_capabilities.hoverProvider = false
  end

  -- FIXME: lsp_signatur handler RPC[Error] code_name = ContentModified
  -- message = "waiting for cargo metadata or cargo check"
  -- https://github.com/ray-x/lsp_signature.nvim/issues/168
  -- NOTE: seems to manifest only in projects with a lot of dependencies

  -- Get signatures (and _only_ signatures) when in argument lists
  require("lsp_signature").on_attach({
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  }, bufnr)

  -- Attach inlay hints
  if client.server_capabilities.inlayHintProvider then
    inlayhints.on_attach(client, bufnr)
  end
end

-- Server configurations
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- Setup bashls (https://github.com/bash-lsp/bash-language-server)
lspconfig.bashls.setup {}

-- Setup pyright (https://microsoft.github.io/pyright/#/settings)
lspconfig.pyright.setup {
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
}

-- Setup ruff (Python liner & formatter)
-- https://github.com/astral-sh/ruff/blob/main/crates/ruff_server/docs/setup/NEOVIM.md
lspconfig.ruff.setup {
  on_attach = on_attach,
}

-- TODO: consider haskell-tools.nvim instead of lspconfig
-- TODO: switch to ormolu as the default formatter
-- Setup hls (https://haskell-language-server.readthedocs.io/en/latest/configuration.html)
lspconfig.hls.setup {
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

-- Setup rust-analyzer (https://rust-analyzer.github.io/manual.html#nvim-lsp)
lspconfig.rust_analyzer.setup {

  on_attach = on_attach,

  flags = {
    debounce_text_changes = 150,
  },

  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      completion = {
        postfix = {
          enable = false,
        },
      },
    },
  },

  capabilities = capabilities,
}

-- Setup crates.nvim (https://github.com/Saecki/crates.nvim)
require("crates").setup {}

-- Enable auto-completion via crates.nvim in Cargo.toml
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    callback = function()
        cmp.setup.buffer({ sources = { { name = "crates" } } })
    end,
})

-- Display inlay hints on cursor hover
vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  callback = function()
    inlayhints.show()
  end,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

-- Setup fidget.nvim (Standalone UI for nvim-lsp progress)
-- https://github.com/j-hui/fidget.nvim/blob/main/doc/fidget.md
require("fidget").setup {
  text = {
    spinner = "dots",
  },

  -- Ignore some LSP servers: https://github.com/j-hui/fidget.nvim/issues/17
  sources = {
    ["jdtls"] = { ignore = true },
    ["elixirls"] = { ignore = true },
  }
}

