return {
  -- TODO: add gitui as an alternative (https://github.com/brneor/gitui.nvim)
  -- https://github.com/kdheepak/lazygit.nvim
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cond = function()
      return vim.fn.executable("lazygit")
    end,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      -- optional for floating window border decoration
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    config = function()
      local g = vim.g
      g.lazygit_floating_window_scaling_factor = 1.0
      g.lazygit_floating_window_use_plenary = 0
    end,
  },
}
