-- ===================== ui.lua =====================
-- UI alignment with tmux: minimal chrome, soft separators, and tmux theme color cohesion.

local M = {}

local function is_normal_file_buf(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  local ft = vim.bo[bufnr].filetype
  if ft == "" then
    -- unnamed scratch buffers: keep quiet
    return false
  end
  local deny = {
    ["TelescopePrompt"] = true,
    ["TelescopeResults"] = true,
    ["NvimTree"] = true,
    ["Trouble"] = true,
    ["help"] = true,
    ["lazy"] = true,
  }
  if deny[ft] then
    return false
  end
  return true
end

local function tmux_theme_color()
  local c = vim.env.TMUX_THEME_COLOR
  if type(c) == "string" and c:match("^#%x%x%x%x%x%x$") then
    return c
  end
  -- Fallback: a muted purple that matches your tmux aesthetic.
  return "#b294bb"
end

-- Cache diagnostics counts (avoid recomputing on every redraw)
local function diag_counts(bufnr)
  bufnr = bufnr or 0
  local c = vim.b[bufnr]._ui_diag_counts
  if c then
    return c
  end
  return { e = 0, w = 0 }
end

local function update_diag_cache(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local diags = vim.diagnostic.get(bufnr)
  local e, w = 0, 0
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      e = e + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      w = w + 1
    end
  end
  vim.b[bufnr]._ui_diag_counts = { e = e, w = w }
end

-- Public: used by winbar statusline expression
function M.winbar()
  if not is_normal_file_buf(0) then
    return ""
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end

  local rel = vim.fn.fnamemodify(name, ":~:.")

  -- Split into path + tail for nicer styling
  local tail = vim.fn.fnamemodify(rel, ":t")
  local head = rel:sub(1, #rel - #tail)

  -- Diagnostics indicator (fixed-width): a single dot for WARN/ERROR.
  -- Uses cached counts to avoid redraw jitter.
  local c = diag_counts(0)
  local diag_hl = "WinBarDiagNone"
  if (c.e or 0) > 0 then
    diag_hl = "WinBarDiagErr"
  elseif (c.w or 0) > 0 then
    diag_hl = "WinBarDiagWarn"
  end

  -- Fixed slots (2 chars each including leading space):
  --   diag_slot: " ●" or "  "
  --   mod_slot:  " ●" or "  "
  -- Always show the diagnostics slot (use a faint dot when clean) to avoid any perceived shifting.
  local diag_slot = (diag_hl == "WinBarDiagNone") and " ·" or " ●"
  local mod_slot = modified and " ●" or "  "

  -- Styling: dim path, title filename; make non-current windows quieter.
  -- statusline_winid is set by nvim when evaluating statusline/winbar.
  local is_cur = (vim.api.nvim_get_current_win() == vim.g.statusline_winid)
  local hl_path = is_cur and "WinBarPath" or "WinBarPathNC"
  local hl_file = is_cur and "WinBarFile" or "WinBarFileNC"
  local left = string.format("%%#%s#%s%%#%s#%s", hl_path, head, hl_file, tail)
  local right = string.format(
    "%%#WinBarMeta#│%%#%s#%s%%#WinBarMod#%s",
    diag_hl,
    diag_slot,
    mod_slot
  )

  return string.format(" %%<%s%%=%s %%#WinBar#", left, right)
end

function M.apply_highlights()
  local accent = tmux_theme_color()

  -- Reduce boxiness: soften separators.
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "grey20" })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = "grey20" })

  -- Floats: unify borders with separators (tmux-like, low contrast).
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "grey20" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  -- Plugin-specific borders: link to FloatBorder for consistency
  vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

  -- Transparent background cohesion (tmux-style)
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })

  -- Winbar base
  vim.api.nvim_set_hl(0, "WinBar", { fg = "grey85" })
  vim.api.nvim_set_hl(0, "WinBarNC", { fg = "grey55" })

  -- Right-side separator/meta should be subtle
  vim.api.nvim_set_hl(0, "WinBarMeta", { fg = "grey40" })

  -- Winbar segments
  vim.api.nvim_set_hl(0, "WinBarPath", { fg = "grey55" })
  vim.api.nvim_set_hl(0, "WinBarPathNC", { fg = "grey35" })
  -- Match tmux window title vibe: crisp white for active, grey for inactive
  vim.api.nvim_set_hl(0, "WinBarFile", { fg = "grey95", bold = true })
  vim.api.nvim_set_hl(0, "WinBarFileNC", { fg = "grey60", bold = true })

  -- Fixed-width right indicators
  -- Prefer linking to Diagnostic groups so the colorscheme controls exact hues.
  vim.api.nvim_set_hl(0, "WinBarDiagNone", { fg = "grey30" })
  vim.api.nvim_set_hl(0, "WinBarDiagWarn", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "WinBarDiagErr", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "WinBarMod", { fg = accent, bold = true })

  -- Focus cue: accent line number
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent, bold = true })

  -- Cursorline: keep it ultra-minimal (we rely on CursorLineNr as the focus cue)
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

  -- Whitespace/non-text: keep very quiet
  vim.api.nvim_set_hl(0, "NonText", { fg = "grey10" })
  vim.api.nvim_set_hl(0, "Whitespace", { fg = "grey10" })
end

function M.setup()
  -- Minimal chrome: let tmux own the persistent bottom UI.
  vim.opt.laststatus = 0
  vim.opt.showtabline = 0

  -- Use lua-powered winbar.
  vim.o.winbar = "%{%v:lua.require('config.ui').winbar()%}"

  -- Diagnostics cache
  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter" }, {
    callback = function(args)
      -- args.buf can be nil for some events
      local bufnr = (args and args.buf) or 0
      pcall(update_diag_cache, bufnr)
    end,
  })

  -- Keep tmux accent in sync (lightweight polling; only reapplies when changed)
  local last = vim.env.TMUX_THEME_COLOR or ""
  vim.fn.timer_start(2000, function()
    local cur = vim.env.TMUX_THEME_COLOR or ""
    if cur ~= last then
      last = cur
      pcall(M.apply_highlights)
    end
  end, { ["repeat"] = -1 })

  M.apply_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      pcall(M.apply_highlights)
    end,
  })
end

return M
