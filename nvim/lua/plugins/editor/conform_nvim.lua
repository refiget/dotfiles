-- stevearc/conform.nvim (plugin spec)

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("plugins.lib.conform")
  end,
}
