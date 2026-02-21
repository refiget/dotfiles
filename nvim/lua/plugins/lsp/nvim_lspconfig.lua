-- neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    require("plugins.lib.lsp")
  end,
}
