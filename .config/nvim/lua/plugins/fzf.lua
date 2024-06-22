-- TODO: replace with https://github.com/ibhagwan/fzf-lua
-- Command-line fuzzy finder (https://github.com/junegunn/fzf)
return {
  "junegunn/fzf.vim",
  dependencies = {
    {
      "junegunn/fzf",
      dir = vim.env.FZF_BASE or "~/.local/share/fzf",
      build = "./install --bin --no-update-rc",
    },
  },
  config = function()
    -- Stop putting a giant window over the editor
    vim.g.fzf_layout = { down = "~20%" }

    -- Customize keybindings
    vim.g.fzf_action = {
      ["ctrl-t"] = "tab split",
      ["ctrl-h"] = "split",
      ["ctrl-v"] = "vsplit",
    }

    -- When using :Files, pass the file list through
    --
    --   https://github.com/jonhoo/proximity-sort
    --
    -- to prefer files closer to the current file.
    local function list_cmd()
      local fn = vim.fn
      local base = fn.fnamemodify(fn.expand("%"), ":h:.:S")
      if base == "." then
        -- proximity-sort won't work if there's no current file
        return "fd --type file --follow --hidden"
      else
        return fn.printf("fd --type file --follow --hidden | proximity-sort %s", fn.shellescape(fn.expand("%")))
      end
    end

    local function files(arg)
      vim.fn["fzf#vim#files"](arg.qargs, { source = list_cmd(), options = "--tiebreak=index" }, arg.bang)
    end

    vim.api.nvim_create_user_command("Files", files, {
      bang = true,
      nargs = "?",
      complete = "dir",
    })
  end,
}
