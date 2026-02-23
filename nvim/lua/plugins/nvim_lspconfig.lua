-- neovim/nvim-lspconfig

return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    require("core.lsp_config")
  end,
}
