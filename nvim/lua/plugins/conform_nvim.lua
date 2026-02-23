-- stevearc/conform.nvim (plugin spec)

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("core.conform_config")
  end,
}
