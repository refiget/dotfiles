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
    local ok, lspsaga = pcall(require, "lspsaga")
    if not ok then
      return
    end
    lspsaga.setup({
      lightbulb = {
        enable = false,
        sign = false,
        virtual_text = false,
      },
      symbol_in_winbar = {
        enable = false,
      },
      ui = {
        border = "rounded",
      },
    })
  end,
}
