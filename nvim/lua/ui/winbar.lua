local M = {}

local WINBAR_DENY_FT = {
  ["TelescopePrompt"] = true,
  ["TelescopeResults"] = true,
  ["NvimTree"] = true,
  ["Trouble"] = true,
  ["help"] = true,
  ["lazy"] = true,
  ["dapui_scopes"] = true,
  ["dapui_stacks"] = true,
  ["dapui_breakpoints"] = true,
  ["dapui_watches"] = true,
  ["dapui_console"] = true,
  ["dap-repl"] = true,
}

local function is_normal_file_buf(bufnr)
  bufnr = bufnr or 0
  local bo = vim.bo[bufnr]
  return bo.buftype == "" and bo.filetype ~= "" and not WINBAR_DENY_FT[bo.filetype]
end

function _G.Crab_winbar()
  if not is_normal_file_buf(0) then
    return ""
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end

  local rel = vim.fn.fnamemodify(name, ":~")
  local tail = vim.fn.fnamemodify(rel, ":t")
  local head = rel:sub(1, #rel - #tail)

  local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local diag_hl = "WinBarDiagNone"
  if e > 0 then
    diag_hl = "WinBarDiagErr"
  elseif w > 0 then
    diag_hl = "WinBarDiagWarn"
  end

  local modified = vim.bo.modified
  local diag_slot = (diag_hl == "WinBarDiagNone") and " ·" or " ●"
  local mod_slot = modified and " ●" or "  "

  local is_cur = (vim.api.nvim_get_current_win() == vim.g.statusline_winid)
  local hl_path = is_cur and "WinBarPath" or "WinBarPathNC"
  local hl_file = is_cur and "WinBarFile" or "WinBarFileNC"

  local left = string.format("%%#%s#%s%%#%s#%s", hl_path, head, hl_file, tail)
  local right = string.format("%%#WinBarMeta#│%%#%s#%s%%#WinBarMod#%s", diag_hl, diag_slot, mod_slot)

  return string.format(" %%<%s%%=%s %%#WinBar#", left, right)
end

function M.apply_highlights()
  local accent = "#b294bb"
  local p = {
    text = "#cdd6f4",
    overlay0 = "#6c7086",
  }

  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })

  vim.api.nvim_set_hl(0, "WinBar", { fg = p.text })
  vim.api.nvim_set_hl(0, "WinBarNC", { fg = p.overlay0 })
  vim.api.nvim_set_hl(0, "WinBarMeta", { fg = p.overlay0 })
  vim.api.nvim_set_hl(0, "WinBarPath", { fg = p.overlay0 })
  vim.api.nvim_set_hl(0, "WinBarPathNC", { fg = p.overlay0 })
  vim.api.nvim_set_hl(0, "WinBarFile", { fg = p.text, bold = true })
  vim.api.nvim_set_hl(0, "WinBarFileNC", { fg = p.text, bold = true })
  vim.api.nvim_set_hl(0, "WinBarDiagNone", { fg = p.overlay0 })
  vim.api.nvim_set_hl(0, "WinBarDiagWarn", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "WinBarDiagErr", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "WinBarMod", { fg = accent, bold = true })

  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent, bold = true })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

  vim.api.nvim_set_hl(0, "NonText", { fg = "#181825" })
  vim.api.nvim_set_hl(0, "Whitespace", { fg = "#181825" })
end

function M.setup()
  vim.opt.fillchars:append({
    vert = "│",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
  })

  vim.opt.laststatus = 0
  vim.opt.showtabline = 0
  vim.o.winbar = "%{%v:lua.Crab_winbar()%}"

  M.apply_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      pcall(M.apply_highlights)
    end,
  })
end

return M
