-- williamboman/mason.nvim

return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Mason", mode = "n" },
  },

  config = function()
    local ok, mason = pcall(require, "mason")
    if not ok then
      return
    end
    mason.setup({
      ui = {
        border = "rounded",
      },
    })
  end,
}
