local map = vim.keymap.set

-------------------------------------------------------------------------------
-- Aliases
-------------------------------------------------------------------------------

map("n", ";", ":", { desc = "; as :" })

-- make Ctrl+j/k act as Esc
map({ "n", "i", "v", "s", "x", "c", "o", "l", "t" }, "<C-j>", "<Esc>")
map({ "n", "i", "v", "s", "x", "c", "o", "l", "t" }, "<C-k>", "<Esc>")

map("n", "zf", "z=", { desc = "spell check hint/correction" })

-------------------------------------------------------------------------------
-- Shortcuts
-------------------------------------------------------------------------------

-- TODO: translate to Lua (something like https://stackoverflow.com/a/72504767)
-- Reload nvim config
-- nnoremap <leader>sv :source $VIMRC<CR>

map("", "<C-p>", ":Files<CR>", { desc = "quick-open" })
map("n", "<C-q>", ":confirm qall", { desc = "quick-quit" })
map("n", "<leader>w", ":w<CR>", { desc = "quick-save" })

map("n", "<leader>e", ':e <C-R>=expand("%:p:h") . "/" <cr>', {
  desc = "open new file located in the same directory as current file",
})

-- clipboard copy/paste
-- https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity
map("v", "<leader>y", '"+y', { desc = "copy selection into clipboard" })
map("v", "<leader>d", '"+d', { desc = "move selection into clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "paste clipboard after cursor" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "paste clipboard before cursor" })

-- move line around (https://vim.fandom.com/wiki/Moving_lines_up_or_down)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "move line up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "move line down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "move line up" })

map("n", "<leader>,", ":set invlist<cr>", {
  desc = "show/hide hidden characters",
})

local function show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand("<cword>"))
  elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
    require("crates").show_popup()
  else
    vim.lsp.buf.hover()
  end
end

map("n", "K", show_documentation, {
  silent = true,
  desc = "show documentation",
})

-------------------------------------------------------------------------------
-- Buffers
-------------------------------------------------------------------------------

map("n", "<leader>;", ":Buffers<CR>", { desc = "search buffers" })

-- TODO: learn to use hjkl and drop the <leader> here
map("n", "<leader><left>", ":bp<CR>", { desc = "switch to previous buffer" })
map("n", "<leader><right>", ":bn<CR>", { desc = "switch to next buffer" })

map("n", "<leader><leader>", "<C-^>", { desc = "toggle between buffers" })

-------------------------------------------------------------------------------
-- Splits
-------------------------------------------------------------------------------

map("n", "<leader>o", "<cmd>vnew<cr>", { desc = "split vertically" })
map("n", "<leader>op", "<cmd>vsp<cr>", { desc = "duplicate vertically" })

map("n", "<leader>v", "<cmd>vnew<cr>", { desc = "split vertically" })
map("n", "<leader>vp", "<cmd>vsp<cr>", { desc = "duplicate vertically" })
map("n", "<leader>h", "<cmd>new<cr>", { desc = "split horizontally" })
map("n", "<leader>hp", "<cmd>sp<cr>", { desc = "duplicate horizontally" })

map("n", "<leader><right>", "<C-W><right>", {
  desc = "focus split to the right",
})
map("n", "<leader><left>", "<C-W><left>", { desc = "focus split to the left" })
map("n", "<leader><up>", "<C-W><up>", { desc = "focus split above" })
map("n", "<leader><down>", "<C-W><down>", { desc = "focus split below" })

-------------------------------------------------------------------------------
-- Tabs
-------------------------------------------------------------------------------

map("n", "<C-t>", "<cmd>tabnew<cr>", { desc = "open new tab" })
map("n", "<C-w>", "<cmd>tabclose<cr>", { desc = "close current tab" })

-- Use Ctrl+Left/Ctrl+Right (or j/k) to go to the next/previous tab
--  - note: cannot use <C-tab>/<C-S-tab>, <TAB> is reserved for range selection
--    with a language server, plus setting this nicely integrates with VS Code
--  - note: cannot use h/l, <c-h> is reserved for cleaning up search
map("n", "<C-left>", "<cmd>tabprevious<cr>", {
  desc = "switch to the previous tab",
})
map("n", "<C-right>", "<cmd>tabnext<cr>", {
  desc = "switch to the next tab",
})
map("n", "<C-j>", "<cmd>tabprevious<cr>", {
  desc = "switch to the previous tab",
})
map("n", "<C-k>", "<cmd>tabnext<cr>", {
  desc = "switch to the next tab",
})

-------------------------------------------------------------------------------
-- Navigation
-------------------------------------------------------------------------------

map("", "H", "^", { desc = "jump to start of the line" })
map("", "L", "$", { desc = "jump to the end of the line" })

-- move by visual line, not actual line, when text is soft-wrapped
map("n", "j", "gj", { desc = "move down by visual line" })
map("n", "k", "gk", { desc = "move up by visual line" })

-------------------------------------------------------------------------------
-- Search
-------------------------------------------------------------------------------

map({ "n", "v" }, "<C-h>", "<cmd>nohlsearch<cr>", { desc = "stop searching" })

-- always center search results
map("n", "n", "nzz", { silent = true })
map("n", "N", "Nzz", { silent = true })
map("n", "*", "*zz", { silent = true })
map("n", "#", "#zz", { silent = true })
map("n", "g*", "g*zz", { silent = true })

-- "very magic" (less escaping needed) regexes by default
map("n", "?", "?\\v")
map("n", "/", "/\\v")
map("c", "%s/", "%sm/")
