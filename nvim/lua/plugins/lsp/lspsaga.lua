-- glepnir/lspsaga.nvim

return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  -- keys are intentionally minimal for now (Bob: not using LSP keymaps yet)
  keys = {},

  config = function()
    require("lspsaga").setup(require("plugins.lib.lsp_ui").lspsaga)
  end,
}
