return {
  -- Spell check for markdown files
  {
    "kamykn/spelunker.vim",
    ft = { "markdown", "text" },
    config = function()
      vim.g.spelunker_check_type = 2
      vim.g.spelunker_highlight_type = 2
      vim.g.spelunker_enable_word_check = 1
      -- Ignore code blocks and inline code
      vim.g.spelunker_ignore_patterns = {
        [[`[^`]+`]],  -- Inline code
        [[```.*```]], -- Code blocks
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text" },
        callback = function()
          vim.opt_local.spell = true
        end,
      })
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
      require("plugins.config.cmp")
    end,
  },

  -- Additional markdown support
  {
    "preservim/vim-markdown",
    ft = "markdown",
    dependencies = {
      "godlygeek/tabular",
    },
    config = function()
      -- Markdown writing conventions
      vim.g.vim_markdown_auto_insert_bullets = 1
      vim.g.vim_markdown_conceal = 1
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_folding = 1
      vim.g.vim_markdown_heading_anchors = 1
      vim.g.vim_markdown_toc_autofit = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_url_inline = 1
    end,
  },
}
