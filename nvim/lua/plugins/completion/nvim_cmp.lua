-- nvim-cmp (completion)

return {
  "hrsh7th/nvim-cmp",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lua",
    "f3fora/cmp-spell",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local function apply_cmp_hl()
      -- Completion menu contrast (plugin-owned UX)
      local ok, p = pcall(function()
        return require("catppuccin.palettes").get_palette("mocha")
      end)
      local base = (ok and p and p.base) or "#1e1e2e"
      local mantle = (ok and p and p.mantle) or "#181825"
      local surface0 = (ok and p and p.surface0) or "#313244"
      local surface1 = (ok and p and p.surface1) or "#45475a"
      local text = (ok and p and p.text) or "#cdd6f4"

      vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = base })
      vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = surface0 })
      vim.api.nvim_set_hl(0, "PmenuSbar", { bg = mantle })
      vim.api.nvim_set_hl(0, "PmenuThumb", { bg = surface1 })
    end

    apply_cmp_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        pcall(apply_cmp_hl)
      end,
    })

    require("plugins.lib.cmp")
  end,
}
