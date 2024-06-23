-- Improved fzf.vim written in lua (https://github.com/ibhagwan/fzf-lua)
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    -- Command-line fuzzy finder (https://github.com/junegunn/fzf)
    {
      "junegunn/fzf",
      dir = vim.env.FZF_BASE or "~/.local/share/fzf",
      build = "./install --bin --no-update-rc",
    },
  },
  config = function()
    require("fzf-lua").setup({
      -- TODO: use skim as the default fuzzy finder (remove fzf)
      -- { "max-perf", "skim" },
      -- use native binary, globally disable icons
      { "max-perf" },
      winopts = {
        height = 0.2, -- start small, use Alt-f to toggle fullscreen
        width = 1, -- full width
        row = 1, -- show at the very bottom
        col = 0, -- show at the very left
        preview = {
          hidden = "hidden",
        },
      },
      keymap = {
        builtin = {
          ["<A-f>"] = "toggle-fullscreen",
          ["<A-p>"] = "toggle-preview",
          ["<A-j>"] = "preview-page-down",
          ["<A-k>"] = "preview-page-up",
          ["<A-h>"] = "preview-page-reset",
        },
      },
      fzf_colors = true,
      previewers = {
        builtin = {
          treesitter = { enable = false },
        },
      },
    })

    --    -- When using :Files, pass the file list through
    --    --
    --    --   https://github.com/jonhoo/proximity-sort
    --    --
    --    -- to prefer files closer to the current file.
    --    local function list_cmd()
    --      local fn = vim.fn
    --      local base = fn.fnamemodify(fn.expand("%"), ":h:.:S")
    --      if base == "." then
    --        -- proximity-sort won't work if there's no current file
    --        return "fd --type file --follow --hidden"
    --      else
    --        return fn.printf("fd --type file --follow --hidden | proximity-sort %s", fn.shellescape(fn.expand("%")))
    --      end
    --    end
    --
    --    local function files(arg)
    --      vim.fn["fzf#vim#files"](arg.qargs, { source = list_cmd(), options = "--tiebreak=index" }, arg.bang)
    --    end

    -- TODO: https://github.com/jonhoo/proximity-sort
    -- see: https://github.com/ibhagwan/fzf-lua/wiki/Advanced
    local function files(arg)
      return require("fzf-lua").files()
    end

    vim.api.nvim_create_user_command("Files", files, {
      bang = true,
      nargs = "?",
      complete = "dir",
    })

    -- Enable insert-mode completion with <leader><leader>
    vim.keymap.set({ "n", "v", "i" }, "<leader><leader>", function()
      require("fzf-lua").complete_path()
    end, { silent = true, desc = "Fuzzy complete path" })
  end,
}
