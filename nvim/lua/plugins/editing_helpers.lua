return {
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "echasnovski/mini.surround", event = "VeryLazy" },
  { "junegunn/vim-after-object", event = "VeryLazy" },
  { "lukas-reineke/indent-blankline.nvim", event = { "BufReadPost", "BufNewFile" } },
  { "Vimjas/vim-python-pep8-indent", ft = "python" },

  -- Formatter runner (simpler than routing everything through LSP/none-ls)
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.conform")
    end,
  },
}
