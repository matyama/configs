-- https://neovim.io/doc/user/options.html
local opt = vim.opt
local o = vim.o
local g = vim.g
-- NOTE: o/g has simple API while opt has more extensive OOP API

-------------------------------------------------------------------------------
-- Global
-------------------------------------------------------------------------------

g.mapleader = " "

-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------

-- TODO
-- Never ever folding
-- o.foldenable = false
-- o.foldmethod = "manual"
-- o.foldlevelstart = 99

-- Better display for messages
o.cmdheight = 2

-- Better completion
opt.completeopt = {
  "menuone", -- popup even when there's only one match
  "noinsert", -- do not insert text until a selection is made
  "noselect", -- do not select, force user to select one from the menu
}

-- You will have bad experience for diagnostic messages when it's default 4000
-- NOTE: This also affects CursorHold event, and as such the inlay hints.
o.updatetime = 300

-- http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
o.timeoutlen = 300

-- Show some lines after cursor
o.scrolloff = 2

-- Disable Nvim intro
opt.shortmess:append("sI")

-- Don't pass messages to |ins-completion-menu|
--opt.shortmess:append("c")

-- Stop line breaking (i.e., never show line breaks if they're not there)
o.wrap = false

-- Always draw sign column. Prevent buffer moving when adding/deleting sign.
-- Recently vim can merge signcolumn and number column into one
o.signcolumn = "number"

-- Enable line relative and absolute numbers by default
o.relativenumber = true
o.number = true

-- Sane splits (keep current content top + left when splitting)
o.splitright = true
o.splitbelow = true

-- Enable infinite undo (stored in `~/.local/state/nvim/undo/`)
o.undofile = true

-- Decent wildmenu
--  - In completion: When there is more than one match, list all matches, and
--                   only complete to longest common match
--  - When opening a file with a command (like :e), ignore some files
opt.wildmode = { "list:longest" }
opt.wildignore = {
  ".hg",
  ".svn",
  "*~",
  "*.png",
  "*.jpg",
  "*.gif",
  "*.min.js",
  "*.swp",
  "*.o",
  "vendor",
  "dist,_site",
}

-- Wrapping options (https://neovim.io/doc/user/change.html#fo-table)
opt.formatoptions = {
  t = true, -- wrap text using 'textwidth'
  c = true, -- wrap comments using 'textwidth'
  r = true, -- continue comments when pressing ENTER in I mode
  q = true, -- enable formatting of comments with "gq"
  n = true, -- detect lists for formatting
  b = true, -- auto-wrap in insert mode, and do not wrap old long lines
  -- disable rest of the defaults
  o = false,
  l = false,
  j = false,
}

-- tabs: go big or go home
--o.shiftwidth = 8
--o.softtabstop = 8
--o.tabstop = 8
--o.expandtab = false

-- Make ripgrep the default grep program
if vim.fn.executable("rg") == 1 then
  o.grepprg = "rg --no-heading --vimgrep"
  o.grepformat = "%f:%l:%c:%m"
end

-- Show results while searching search
o.incsearch = true
-- Do case-insensitive search/replace
o.ignorecase = true
-- Unless there's an uppercase in search term
o.smartcase = true

-- Prevent the terminal from ever beep
o.vb = true

-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
opt.diffopt:append("iwhite")
opt.diffopt:append("algorithm:histogram")
opt.diffopt:append("indent-heuristic")

-- Show red vertical bar at column 80
o.colorcolumn = "80"

-- Show more hidden characters (and nicer tabs)
opt.listchars = {
  tab = "^ ",
  nbsp = "¬",
  extends = "»",
  precedes = "«",
  trail = "•",
}

-- Show (partial) command in status line.
o.showcmd = true

-- Enable spell check (stored in `~/.config/nvim/spell/`)
--  - https://linuxhint.com/vim_spell_check
--  - ']s' or '[s' - navigate, 'z=' - correct, 'zg' - add word to 'spellfile'
o.spell = true
o.spelllang = "en_us"

-- TODO: re-visit this when upgrading to v0.10
-- Color setup (inspired by https://github.com/jonhoo/configs)

opt.guicursor = {
  "n-v-c:block-Cursor/lCursor-blinkon0",
  "i-ci:ver25-Cursor/lCursor",
  "r-cr:hor20-Cursor/lCursor",
}

o.inccommand = "nosplit"

if not vim.fn.has("gui_running") then
  o.t_Co = 256
end

-- TODO: deprecate with v0.10 (checked for support and enabled by default)
if vim.env.TERM:match("-256color") and vim.env.TERM ~= "screen-256color" then
  -- screen does not (yet) support truecolor
  o.termguicolors = true
end
