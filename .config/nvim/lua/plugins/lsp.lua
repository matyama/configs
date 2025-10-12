return {

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "chrisgrieser/nvim-lsp-endhints",
    },

    config = function()
      -- Rust: https://rust-analyzer.github.io/manual.html#nvim-lsp
      vim.lsp.config.rust_analyzer = {
        settings = {
          -- https://rust-analyzer.github.io/book/configuration.html
          ["rust-analyzer"] = {
            cargo = {
              -- Pass --all-features to cargo
              features = "all",
            },
            check = {
              command = "clippy",
              -- Pass --all-features to cargo
              features = "all",
            },
            imports = {
              granularity = {
                -- Merge imports from the same module into a single use stmt
                group = "module",
              },
              group = {
                -- Group inserted imports in order: std, external, crate
                enable = true,
              },
            },
            completion = {
              postfix = {
                -- Don't show postfix snippets like dbg, if, not, etc.
                enable = false,
              },
            },
          },
        },
      }

      vim.lsp.enable("rust_analyzer")

      -- TODO: consider haskell-tools.nvim instead of lspconfig
      -- Haskell: https://haskell-language-server.readthedocs.io/en/latest/configuration.html
      -- fourmolu: https://github.com/fourmolu/fourmolu
      vim.lsp.config.hls = {
        filetypes = { "haskell", "lhaskell", "cabal" },
        settings = {
          haskell = {
            formattingProvider = "fourmolu",
          },
        },
      }

      vim.lsp.enable("hls")

      -- Setup pylsp
      -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
      -- https://github.com/python-lsp/pylsp-mypy#configuration
      -- https://github.com/python-lsp/python-lsp-ruff#configuration
      vim.lsp.config.pylsp = {
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
      }

      vim.lsp.enable("pylsp")

      -- Lua LSP (https://luals.github.io)
      vim.lsp.config.lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
              return
            end
          end

          local settings = client.config.settings

          settings.Lua = vim.tbl_deep_extend("force", settings.Lua, {
            -- Tell the language server which version of Lua we're using
            runtime = {
              version = "LuaJIT",
              path = {
                "lua/?.lua",
                "lua/?/init.lua",
              },
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
          Lua = {
            hint = { enable = true },
          },
        },
      }

      vim.lsp.enable("lua_ls")

      -- Bash LSP (https://github.com/bash-lsp/bash-language-server)
      if vim.fn.executable("bash-language-server") == 1 then
        vim.lsp.enable("bashls")
      end

      -- TOML LSP (https://taplo.tamasfe.dev)
      vim.lsp.enable("taplo")

      -- YAML LSP (https://github.com/redhat-developer/yaml-language-server)
      vim.lsp.enable("yamlls")

      -- TypeScript LSP (https://github.com/typescript-language-server/typescript-language-server)
      vim.lsp.enable("ts_ls")

      -- Docker LSP (https://github.com/rcjsuen/dockerfile-language-server)
      vim.lsp.enable("dockerls")

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
    -- FIXME: tag = "stable",
    tag = "v0.7.1",
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
  -- https://github.com/chrisgrieser/nvim-lsp-endhints
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    -- required, even if empty
    opts = {},
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

  -- Standalone UI for nvim-lsp progress
  -- https://github.com/j-hui/fidget.nvim/wiki/Known-compatible-LSP-servers
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        progress = {
          -- List of LSP servers to ignore
          ignore = {
            "elixirls",
          },
        },
      })
    end,
  },
}
