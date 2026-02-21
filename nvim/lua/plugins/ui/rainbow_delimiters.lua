-- HiPhish/rainbow-delimiters.nvim

return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    vim.g.rainbow_delimiters = {
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }

    pcall(function()
      local p = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = p.red })
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = p.yellow })
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = p.blue })
      vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = p.peach })
      vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = p.green })
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = p.mauve })
      vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = p.sapphire })
    end)
  end,
}
