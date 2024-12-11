-- Base16 colors (https://github.com/tinted-theming/base16-vim)
return {
  "tinted-theming/base16-vim",
  lazy = false, -- load at start
  priority = 1000, -- load first
  config = function()
    -- Pick Base16 color scheme and access colors present in 256 colorspace
    vim.g.tinted_colorspace = 256

    local theme = vim.env.BASE16_THEME or "gruvbox-dark-hard"
    vim.cmd.colorscheme("base16-" .. theme)

    local api = vim.api

    -- Make the background terminal color transparent for the Normal group
    -- https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    normal.ctermbg = nil
    api.nvim_set_hl(0, "Normal", normal)

    -- Make comments more prominent
    local bools = vim.api.nvim_get_hl(0, { name = "Boolean" })
    api.nvim_set_hl(0, "Comment", bools)

    -- Highlight current arguments
    local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
    api.nvim_set_hl(0, "LspSignatureActiveParameter", {
      fg = marked.fg,
      bg = marked.bg,
      ctermfg = marked.ctermfg,
      ctermbg = marked.ctermbg,
      bold = true,
    })
  end,
}
