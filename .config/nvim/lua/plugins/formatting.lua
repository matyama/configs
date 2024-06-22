-- TODO: deprecate in favor of `conform.nvim` (use `format_on_save`)
-- A (Neo)Vim plugin for formatting code (https://github.com/sbdchd/neoformat)
return {
  "sbdchd/neoformat",
  config = function()
    local g = vim.g
    local api = vim.api

    -- Shell (shfmt): indent switch cases
    g.shfmt_opt = "-ci"

    -- Hotfix: disables formatting zsh files, because shfmt breaks:
    -- `(( $+commands[x] ))`
    g.neoformat_enabled_zsh = {}

    -- Run a formatter on save
    local fmt = api.nvim_create_augroup("fmt", { clear = true })
    api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      group = fmt,
      command = "undojoin | Neoformat",
    })
  end,
}
