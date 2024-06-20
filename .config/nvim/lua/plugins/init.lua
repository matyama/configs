return {
  -- Auto pairs for '(' '[' '{'
  'jiangmiao/auto-pairs',

  -- Visually select increasingly larger regions of text
  -- https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity
  'terryma/vim-expand-region',

  -- Navigate and highlight matching words (i.e., better %)
  {
      'andymass/vim-matchup',
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
      end,
  },

  -- Change Vim working directory to project root
  {
      'notjedi/nvim-rooter.lua',
      config = function()
        require('nvim-rooter').setup()
      end,
  },

  -- Use RipGrep in Vim via <leader>s
  {
      'jremmen/vim-ripgrep',
      config = function()
          vim.keymap.set('', '<leader>s', ':Rg<space>', {
            remap = false,
            desc = "RipGrep search",
          })
      end,
  },

  -- Better syntax support
  'sheerun/vim-polyglot',

  -- Rust: https://github.com/rust-lang/rust.vim#features
  {
      'rust-lang/rust.vim',
      ft = { 'rust' },
      config = function()
          local g = vim.g
          g.rustfmt_autosave = 1
          g.rustfmt_emit_files = 1
          g.rustfmt_fail_silently = 0
          g.rust_clip_command = 'wl-copy'
      end,
  },

  -- Cargo: https://github.com/Saecki/crates.nvim
  {
    'saecki/crates.nvim',
    tag = 'stable',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    event = { 'BufRead Cargo.toml' },
    config = function()
      require('crates').setup()
    end,
  },

  -- Bindings for Haskell hlint code refactoring
  -- https://github.com/mpickering/hlint-refactor-vim
  {
      'mpickering/hlint-refactor-vim',
      ft = { 'haskell' },
  },

  {
      'cespare/vim-toml',
      ft = { 'toml' },
  },

  {
      'cuducos/yaml.nvim',
      ft = { 'yaml' },
      dependencies = {
          'nvim-treesitter/nvim-treesitter',
      },
  },

  {
      'plasticboy/vim-markdown',
      ft = { 'markdown' },
      dependencies = {
          'godlygeek/tabular',
      },
      config = function()
          local g = vim.g
          -- never fold
          g.vim_markdown_folding_disabled = 1
          -- support front-matter in .md files
          g.vim_markdown_frontmatter = 1
          -- 'o' on a list item should insert at same level
          g.vim_markdown_new_list_item_indent = 0
          -- don't add bullets when wrapping:
          -- https://github.com/preservim/vim-markdown/issues/232
          g.vim_markdown_auto_insert_bullets = 0
        end,
  },

  -- TODO: Debugging
  -- Debug Adapter Protocol client implementation
  -- https://github.com/mfussenegger/nvim-dap
}
