-- ===================== highlights.lua =====================
-- Unified highlight policy (Catppuccin Mocha)
-- Goal: make all popups/panels feel consistent and premium.

local M = {}

local function palette()
  local ok, p = pcall(function()
    return require("catppuccin.palettes").get_palette("mocha")
  end)
  if ok and p then
    return p
  end
  -- Fallback palette (mocha-ish)
  return {
    text = "#cdd6f4",
    base = "#1e1e2e",
    mantle = "#181825",
    crust = "#11111b",
    surface0 = "#313244",
    surface1 = "#45475a",
    surface2 = "#585b70",
    overlay0 = "#6c7086",
    red = "#f38ba8",
    yellow = "#f9e2af",
    blue = "#89b4fa",
    green = "#a6e3a1",
    mauve = "#cba6f7",
    sapphire = "#74c7ec",
    teal = "#94e2d5",
    peach = "#fab387",
  }
end

function M.apply()
  local p = palette()

  -- Floating windows (Noice/cmp/telescope/dap-ui/notify) should have a real background
  -- even when the main editor uses transparent background.
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = p.text, bg = p.base })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.surface2, bg = p.base })

  -- Completion menu contrast
  vim.api.nvim_set_hl(0, "Pmenu", { fg = p.text, bg = p.base })
  vim.api.nvim_set_hl(0, "PmenuSel", { fg = p.text, bg = p.surface0 })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = p.mantle })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = p.surface1 })

  -- Notify background
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = p.base })

  -- Statusline background should match the buffer (transparent)
  vim.api.nvim_set_hl(0, "StatusLine", { fg = p.text, bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = p.overlay0, bg = "NONE" })

  -- Subtle separators (used across UI)
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = p.surface0 })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = p.surface0 })

  -- DAP UI: keep separators/borders consistent and avoid loud title colors
  vim.api.nvim_set_hl(0, "DapUIBorder", { link = "WinSeparator" })
  vim.api.nvim_set_hl(0, "DapUIFloatBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "DapUISeparator", { link = "WinSeparator" })
  vim.api.nvim_set_hl(0, "DapUISeparatorActive", { link = "WinSeparator" })

  -- Keep telescope borders consistent
  vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
end

function M.setup()
  -- Apply once now (if colorscheme already loaded)
  pcall(M.apply)
  -- Re-apply on colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      pcall(M.apply)
    end,
  })
end

return M
