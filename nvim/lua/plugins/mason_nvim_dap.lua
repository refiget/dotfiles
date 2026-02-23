-- jay-babu/mason-nvim-dap.nvim

return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
  config = function()
    local ok, mdap = pcall(require, "mason-nvim-dap")
    if not ok then
      return
    end
    mdap.setup({
      ensure_installed = { "python" },
      automatic_installation = true,
      handlers = {},
    })
  end,
}
