-- Improved fzf.vim written in lua (https://github.com/ibhagwan/fzf-lua)
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    -- Command-line fuzzy finder (https://github.com/junegunn/fzf)
    {
      "junegunn/fzf",
      dir = vim.env.FZF_BASE or "~/.local/share/fzf",
      build = "./install --bin --no-update-rc",
      cond = function()
        return (vim.env.FZF or "fzf") == "fzf"
      end,
    },
    -- Vim support for skim (https://github.com/lotabout/skim.vim)
    {
      "lotabout/skim",
      tag = "v0.10.4",
      dir = vim.env.SKIM_BASE or "~/.local/share/skim",
      build = "./install",
      cond = function()
        return (vim.env.FZF or "fzf") == "sk"
      end,
    },
  },
  config = function()
    -- use native binary (fzf/sk), globally disable icons
    local profile = { "max-perf" }

    if (vim.env.FZF or "fzf") == "sk" then
      profile[#profile + 1] = "skim"
    end

    require("fzf-lua").setup({
      profile,
      winopts = {
        height = 0.2, -- start small, use Alt-f to toggle fullscreen
        width = 1, -- full width
        row = 1, -- show at the very bottom
        col = 0, -- show at the very left
        preview = {
          hidden = "hidden", -- hide preview by default, use Alt-p to toggle
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
        -- sk/fzf
        fzf = {
          ["ctrl-z"] = "abort",
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-f"] = "half-page-down",
          ["ctrl-b"] = "half-page-up",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
          -- NOTE: only valid with sk/fzf previewers (bat/cat/git/etc)
          ["alt-p"] = "toggle-preview",
          ["alt-j"] = "preview-page-down",
          ["alt-k"] = "preview-page-up",
        },
      },
      -- FIXME: base16 colors for sk
      fzf_colors = true,
      previewers = {
        builtin = {
          treesitter = { enable = false },
        },
        bat = {
          theme = vim.env.BAT_THEME or "base16-256",
        },
      },
      files = {
        previewer = "bat",
      },
    })

    -- When using :Files, pass the file list through
    --
    --   https://github.com/jonhoo/proximity-sort
    --
    -- to prefer files closer to the current file.
    local function list_cmd()
      local fn = vim.fn
      local file = fn.expand("%")
      if fn.fnamemodify(file, ":h:.:S") == "." then
        -- proximity-sort won't work if there's no current file
        return "fd --type file --follow --hidden"
      else
        return fn.printf("fd --type file --follow --hidden | proximity-sort %s", fn.shellescape(file))
      end
    end

    vim.api.nvim_create_user_command("Files", function()
      return require("fzf-lua").files({ cmd = list_cmd() })
    end, {
      bang = true,
      nargs = "?",
      complete = "dir",
    })

    vim.api.nvim_create_user_command("Buffers", function()
      return require("fzf-lua").buffers()
    end, {
      bang = true,
      nargs = "?",
      complete = "dir",
    })

    -- Enable insert-mode completion
    --vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function()
    --  require("fzf-lua").complete_path()
    --end, { silent = true, desc = "Fuzzy complete path" })
  end,
}
