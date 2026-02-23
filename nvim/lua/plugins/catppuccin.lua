-- catppuccin theme

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true

    local ok, catppuccin = pcall(require, "catppuccin")
    if ok then
      catppuccin.setup({
        flavour = "mocha",
        transparent_background = true,
        term_colors = true,
        dim_inactive = { enabled = false },
        integrations = {
          gitsigns = true,
          treesitter = true,
          telescope = true,
          trouble = true,
          native_lsp = { enabled = true },
          notify = true,
          noice = true,
          cmp = true,
          bufferline = true,
        },
      })
    end

    vim.cmd("silent! colorscheme catppuccin")

    local function apply_core_ui_hl()
      local p = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "NormalFloat", { fg = p.text, bg = p.base })
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.surface2, bg = p.base })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = p.surface0 })
      vim.api.nvim_set_hl(0, "VertSplit", { fg = p.surface0 })
    end

    apply_core_ui_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        pcall(apply_core_ui_hl)
      end,
    })

    -- Statusline: eleline
    vim.g.eleline_colorscheme = "catppuccin"
    vim.g.eleline_powerline_fonts = 0
  end,
}
