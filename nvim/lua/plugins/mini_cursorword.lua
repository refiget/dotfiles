-- mini.cursorword

return {
  "echasnovski/mini.cursorword",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local ok, cw = pcall(require, "mini.cursorword")
    if not ok then
      return
    end
    cw.setup({ delay = 600 })

    pcall(function()
      local p = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "MiniCursorword", { bg = p.surface0 })
      vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { bg = p.surface1 })
    end)

    vim.cmd("silent! MiniCursorwordEnable")
  end,
}
