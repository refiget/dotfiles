-- ===================== ime.lua =====================
-- macOS: 自动在插入/普通模式切换时切换输入法
-- 支持：im-select（优先，可查询当前输入法）、macism（无 toggle，仅切回英文 + 恢复上次记录）

local M = {}

local function detect_switcher()
  if vim.fn.executable("im-select") == 1 then
    return { cmd = "im-select", toggle = false }
  end
  if vim.fn.executable("macism") == 1 then
    return { cmd = "macism", toggle = false }
  end
end

-- 默认英文输入法 ID，可根据本机调整，例如 com.apple.keylayout.ABC
local default_english = vim.env.NVIM_IME_DEFAULT_ENG or "com.apple.keylayout.ABC"

function M.setup()
  if vim.loop.os_uname().sysname ~= "Darwin" then
    return
  end

  local switcher = detect_switcher()
  if not switcher then
    return
  end

  local last_ime = nil

  local function current_ime()
    if switcher.cmd == "im-select" then
      local out = vim.fn.systemlist({ switcher.cmd })
      return out[1] or ""
    end
    if switcher.cmd == "macism" then
      local out = vim.fn.systemlist({ switcher.cmd })
      return out[1] or ""
    end
    return ""
  end

  local function switch_im(mode)
    if mode == "insert" then
      if last_ime and last_ime ~= "" and last_ime ~= default_english then
        vim.fn.jobstart({ switcher.cmd, last_ime }, { detach = true })
      end
      return
    end
    -- normal: 记录当前输入法并切回英文
    local current = current_ime()
    if current ~= "" and current ~= default_english then
      last_ime = current
    end
    vim.fn.jobstart({ switcher.cmd, default_english }, { detach = true })
  end

  -- 启动时切到英文，避免初始颜色/模式不同步
  switch_im("normal")

  local group = vim.api.nvim_create_augroup("IMEAutoSwitch", { clear = true })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      switch_im("insert")
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      switch_im("normal")
    end,
  })
end

return M
