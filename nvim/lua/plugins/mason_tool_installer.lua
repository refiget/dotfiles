-- WhoIsSethDaniel/mason-tool-installer.nvim
-- Auto-install LSP servers/formatters on fresh machines.

return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "VeryLazy" },
  config = function()
    local ok, mti = pcall(require, "mason-tool-installer")
    if not ok then
      return
    end

    mti.setup({
      ensure_installed = {
        -- LSP servers
        "pyright",
        "lua-language-server",
        "json-lsp",
        "yaml-language-server",
        "typescript-language-server",
        "bash-language-server",

        -- Formatters
        "black",
        "stylua",
        "shfmt",
        "prettier",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 12,
      integrations = {
        ["mason-lspconfig"] = true,
      },
    })
  end,
}
