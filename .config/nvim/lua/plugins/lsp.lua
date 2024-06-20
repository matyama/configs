return {

	-- Quickstart configs for Nvim LSP
	-- https://github.com/neovim/nvim-lspconfig
	{
		'neovim/nvim-lspconfig',

		dependencies = {
			'lvimuser/lsp-inlayhints.nvim',
		},

		config = function()
			local lspconfig = require('lspconfig')

			-- Rust: https://rust-analyzer.github.io/manual.html#nvim-lsp
			lspconfig.rust_analyzer.setup {
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
			}

			-- TODO: consider haskell-tools.nvim instead of lspconfig
			-- TODO: switch to ormolu as the default formatter
			-- Haskell: https://haskell-language-server.readthedocs.io/en/latest/configuration.html
			lspconfig.hls.setup {
				filetypes = { 'haskell', 'lhaskell', 'cabal' },
			}

			-- Setup pyright (https://microsoft.github.io/pyright/#/settings)
			lspconfig.pyright.setup {
				settings = {
					pyright = {
						-- Using Ruff's import organizer
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- Ignore all files for analysis to exclusively lint with Ruff
							ignore = { '*' },
						},
					},
				},
			}

			-- Setup ruff (Python liner & formatter)
			-- https://github.com/astral-sh/ruff/blob/main/crates/ruff_server/docs/setup/NEOVIM.md
			lspconfig.ruff.setup {}

			-- Bash LSP
			local configs = require('lspconfig.configs')

			if not configs.bash_lsp and vim.fn.executable('bash-language-server') == 1 then
				configs.bash_lsp = {
					default_config = {
						cmd = { 'bash-language-server', 'start' },
						filetypes = { 'sh' },
						root_dir = require('lspconfig').util.find_git_ancestor,
						init_options = {
							settings = {
								args = {}
							}
						}
					}
				}
			end

			if configs.bash_lsp then
				lspconfig.bash_lsp.setup {}
			end

			-- Global mappings
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
			vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					-- Buffer local mappings
					local buf = vim.lsp.buf
					local map = vim.keymap.set
					local opts = { buffer = ev.buf }

					map('n', 'gD', buf.declaration, opts)
					map('n', 'gd', buf.definition, opts)
					map('n', 'K', buf.hover, opts)
					map('n', 'gi', buf.implementation, opts)
					map('n', '<C-k>', buf.signature_help, opts)
					map('n', '<leader>wa', buf.add_workspace_folder, opts)
					map('n', '<leader>wr', buf.remove_workspace_folder, opts)
					map('n', '<leader>wl', function()
						print(vim.inspect(buf.list_workspace_folders()))
					end, opts)

					--map('n', '<space>D', buf.type_definition, opts)
					map('n', '<leader>r', buf.rename, opts)
					map({ 'n', 'v' }, '<leader>a', buf.code_action, opts)
					map('n', 'gr', buf.references, opts)
					map('n', '<leader>f', function()
						buf.format { async = true }
					end, opts)

					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- Attach inlay hints
					if client.server_capabilities.inlayHintProvider then
						require("lsp-inlayhints").on_attach(client, ev.buf)
					end

					-- Disable semantics tokens (treesitter)
					-- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely
					client.server_capabilities.semanticTokensProvider = nil

					-- Disable hover for Ruff in favor of Pyright
					if client.name == 'ruff' then
						client.server_capabilities.hoverProvider = false
					end

				end,
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
		'ray-x/lsp_signature.nvim',
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- Get signatures (and _only_ signatures) when in argument lists
			require('lsp_signature').setup({
				doc_lines = 0,
				handler_opts = {
					border = 'none'
				},
			})
		end,
	},

	-- Inlay hints for the built-in LSP
	-- https://github.com/lvimuser/lsp-inlayhints.nvim
	{
		'lvimuser/lsp-inlayhints.nvim',
		config = function()
			-- Setup inlay hints
			require("lsp-inlayhints").setup {
				inlay_hints = { only_current_line = true  },
			}

			-- Display inlay hints on cursor hover
			vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
				callback = function()
					require('lsp-inlayhints').show()
				end,
			})
		end,
	},

	-- TODO: upgrade to some recent version
	-- Standalone UI for nvim-lsp progress
	{
		'j-hui/fidget.nvim',
		tag = 'legacy',
		config = function()
			require('fidget').setup {
				text = {
					spinner = 'dots',
				},
				-- Ignore some LSP servers
				-- https://github.com/j-hui/fidget.nvim/issues/17
				sources = {
					['jdtls'] = { ignore = true },
					['elixirls'] = { ignore = true },
				}
			}
		end,
	},

}
