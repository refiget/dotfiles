return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      require("lsp.java").setup(opts.servers)
    end,
  },
}
