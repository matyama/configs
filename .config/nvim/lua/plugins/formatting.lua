-- Lightweight yet powerful formatter plugin for Neovim
-- https://github.com/stevearc/conform.nvim
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },

  opts = {
    -- Define formatters (use a sub-list to run only the first available)
    formatters_by_ft = {
      bash = { "shfmt" },
      lua = { "stylua" },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
      sql = { "sqlfluff" },
      sh = { "shfmt" },
      zsh = { "shfmt" },
    },

    -- Set up format-on-save
    format_on_save = function(bufnr)
      -- sqlfluff takes too long, so increase the timeout
      if require("conform").get_formatter_info("sqlfluff", bufnr).available then
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,

    -- Customize formatters
    formatters = {
      shfmt = {
        -- Google style (https://google.github.io/styleguide/shellguide.html)
        prepend_args = { "-i", "2", "-ci" },
      },
    },
  },

  init = function()
    vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
  end,
}
