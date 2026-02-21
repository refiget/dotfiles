-- folke/trouble.nvim

return {
  "folke/trouble.nvim",
  event = "LspAttach",

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  -- keys are intentionally minimal for now (Bob: not using Trouble keymaps yet)
  keys = {},

  config = function()
    local ok, trouble = pcall(require, "trouble")
    if not ok then
      return
    end
    trouble.setup({})
  end,
}
