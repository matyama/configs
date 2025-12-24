return {
  -- Neovim fugitive style git blame plugin
  -- https://github.com/FabijanZulj/blame.nvim
  {
    "FabijanZulj/blame.nvim",
    lazy = true,
    keys = {
      { "<leader>b", "<cmd>BlameToggle window<cr>", desc = "BlameToggle" },
    },
    config = function()
      require("blame").setup({})
    end,
    opts = {
      -- ignore whitespace when comparing
      blame_options = { "-w" },
    },
  },
}
