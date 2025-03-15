return {

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "lvimuser/lsp-inlayhints.nvim",
    },

    config = function()
      local lspconfig = require("lspconfig")

      -- Rust: https://rust-analyzer.github.io/manual.html#nvim-lsp
      lspconfig.rust_analyzer.setup({
        flags = {
          debounce_text_changes = 150,
        },
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            imports = {
              group = {
                enable = false,
              },
            },
            completion = {
              postfix = {
                enable = false,
              },
            },
          },
        },
      })

      -- TODO: consider haskell-tools.nvim instead of lspconfig
      -- Haskell: https://haskell-language-server.readthedocs.io/en/latest/configuration.html
      -- fourmolu: https://github.com/fourmolu/fourmolu
      lspconfig.hls.setup({
        filetypes = { "haskell", "lhaskell", "cabal" },
        settings = {
          haskell = {
            formattingProvider = "fourmolu",
          },
        },
      })

      -- Setup pylsp
      -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
      -- https://github.com/python-lsp/pylsp-mypy#configuration
      -- https://github.com/python-lsp/python-lsp-ruff#configuration
      lspconfig.pylsp.setup({
        settings = {
          pylsp = {
            plugins = {
              pylint = {
                -- Let Ruff handle linting
                enabled = false,
              },
              ruff = {
                enabled = true,
              },
            },
          },
        },
      })

      -- Lua LSP (https://luals.github.io)
      lspconfig.lua_ls.setup({
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
            return
          end

          local settings = client.config.settings

          settings.Lua = vim.tbl_deep_extend("force", settings.Lua, {
            -- Tell the language server which version of Lua we're using
            runtime = {
              version = "LuaJIT",
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
          })
        end,

        settings = {
          Lua = {},
        },
      })

      -- Bash LSP (https://github.com/bash-lsp/bash-language-server)
      -- FIXME: https://github.com/neovim/nvim-lspconfig/issues/3453
      local configs = require("lspconfig.configs")

      if not configs.bash_lsp and vim.fn.executable("bash-language-server") == 1 then
        configs.bash_lsp = {
          default_config = {
            cmd = { "bash-language-server", "start" },
            filetypes = { "sh" },
            root_dir = require("lspconfig").util.find_git_ancestor,
            init_options = {
              settings = {
                args = {},
              },
            },
          },
        }
      end

      if configs.bash_lsp then
        lspconfig.bash_lsp.setup({})
      end

      -- TOML LSP (https://taplo.tamasfe.dev)
      lspconfig.taplo.setup({})

      -- Global mappings
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings
          local buf = vim.lsp.buf
          local map = vim.keymap.set
          local opts = { buffer = ev.buf }

          map("n", "gD", buf.declaration, opts)
          map("n", "gd", buf.definition, opts)
          map("n", "K", buf.hover, opts)
          map("n", "gi", buf.implementation, opts)
          map("n", "<C-k>", buf.signature_help, opts)
          map("n", "<leader>wa", buf.add_workspace_folder, opts)
          map("n", "<leader>wr", buf.remove_workspace_folder, opts)
          map("n", "<leader>wl", function()
            print(vim.inspect(buf.list_workspace_folders()))
          end, opts)

          --map('n', '<space>D', buf.type_definition, opts)
          map("n", "<leader>r", buf.rename, opts)
          map({ "n", "v" }, "<leader>a", buf.code_action, opts)
          map("n", "gr", buf.references, opts)
          map("n", "<leader>f", function()
            buf.format({ async = true })
          end, opts)

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client == nil then
            return
          end

          -- Attach inlay hints
          if client.server_capabilities.inlayHintProvider then
            require("lsp-inlayhints").on_attach(client, ev.buf)
          end

          -- Disable semantics tokens (treesitter)
          -- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely
          client.server_capabilities.semanticTokensProvider = nil

          -- Disable hover for Ruff in favor of Pyright
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

      -- XXX: document or deprecate
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
      })
    end,
  },

  -- Crates LSP: https://github.com/Saecki/crates.nvim
  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup({
        popup = {
          autofocus = true,
          hide_on_select = true,
        },
        completion = {
          cmp = {
            enabled = true,
          },
        },
        lsp = {
          enabled = true,
          actions = true,
          -- use cmp for completions
          completion = false,
          hover = true,
        },
      })
    end,
  },

  -- FIXME: lsp_signatur handler RPC[Error] code_name = ContentModified
  -- message = "waiting for cargo metadata or cargo check"
  -- https://github.com/ray-x/lsp_signature.nvim/issues/168
  -- NOTE: seems to manifest only in projects with a lot of dependencies
  --
  -- LSP-based inline function signatures
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      -- Get signatures (and _only_ signatures) when in argument lists
      require("lsp_signature").setup({
        doc_lines = 0,
        handler_opts = {
          border = "none",
        },
      })
    end,
  },

  -- Inlay hints for the built-in LSP
  -- https://github.com/lvimuser/lsp-inlayhints.nvim
  {
    "lvimuser/lsp-inlayhints.nvim",
    config = function()
      -- Setup inlay hints
      require("lsp-inlayhints").setup({
        inlay_hints = { only_current_line = true },
      })

      -- Display inlay hints on cursor hover
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function()
          require("lsp-inlayhints").show()
        end,
      })
    end,
  },

  -- Completion plugin coded in Lua, LSP client buffer, and path integration
  -- https://github.com/hrsh7th/nvim-cmp
  {
    "hrsh7th/nvim-cmp",

    event = "InsertEnter",

    -- NOTE: dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- TODO: check out https://github.com/saadparwaiz1/cmp_luasnip
      -- NOTE: `*-vsip` inluded only because nvim-cmp requires snippets
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      -- Enable parenthesis auto-pairing on confirmation
      "windwp/nvim-autopairs",
    },

    config = function()
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
          -- Set select to false to only confirm explicitly selected items
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),

        sources = cmp.config.sources({
          -- stop prioritization of snippets from LSP
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
          { name = "path" },
        }),
      })

      -- Insert `(` after select function or method item
      local autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", autopairs.on_confirm_done())

      local api = vim.api

      -- Lazily enable auto-completion via crates.nvim in Cargo.toml
      api.nvim_create_autocmd("BufRead", {
        group = api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
        pattern = "Cargo.toml",
        callback = function()
          cmp.setup.buffer({ sources = { { name = "crates" } } })
        end,
      })
    end,
  },

  -- TODO: upgrade to some recent version
  -- Standalone UI for nvim-lsp progress
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require("fidget").setup({
        text = {
          spinner = "dots",
        },
        -- Ignore some LSP servers
        -- https://github.com/j-hui/fidget.nvim/issues/17
        sources = {
          ["jdtls"] = { ignore = true },
          ["elixirls"] = { ignore = true },
        },
      })
    end,
  },
}
