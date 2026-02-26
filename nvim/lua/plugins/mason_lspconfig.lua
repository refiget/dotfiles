-- williamboman/mason-lspconfig.nvim

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    local ok, mlsp = pcall(require, "mason-lspconfig")
    if not ok then
      return
    end
    mlsp.setup({
      ensure_installed = {
        "pyright",
        "lua_ls",
        "jsonls",
        "yamlls",
        "ts_ls",
        "bashls",
      },
      automatic_installation = true,
    })
  end,
}
