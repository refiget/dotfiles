return {
  -- Spell check for markdown files
  {
    "kamykn/spelunker.vim",
    ft = { "markdown", "text" },
    config = function()
      vim.g.spelunker_check_type = 2
      vim.g.spelunker_highlight_type = 2
      vim.g.spelunker_enable_word_check = 1
    end,
  },

  -- Word completion for markdown files
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
    },
    config = function()
      require("plugin_config.cmp")
    end,
  },

  -- Additional markdown support
  {
    "preservim/vim-markdown",
    ft = "markdown",
    dependencies = {
      "godlygeek/tabular",
    },
  },
}
