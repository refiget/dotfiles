-- ===================== clipboard.lua =====================
-- 保持默认寄存器逻辑；剪贴板由 provider 提供。
vim.opt.clipboard = ""

-- 纯 Lua base64，避免额外依赖
local function base64_encode(data)
  local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  return ((data:gsub(".", function(x)
    local r, byte = "", x:byte()
    for i = 8, 1, -1 do
      r = r .. (byte % 2 ^ 1)
      byte = math.floor(byte / 2)
    end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then
      return ""
    end
    local c = 0
    for i = 1, 6 do
      c = c * 2 + x:sub(i, i)
    end
    return b:sub(c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function osc52_copy(lines, _)
  local data = table.concat(lines, "\n")
  local max = tonumber(vim.env.OSC52_MAX_BYTES or "100000") or 100000
  if max > 0 and #data > max then
    return
  end
  local esc = base64_encode(data)
  local osc = string.format("\x1b]52;c;%s\x07", esc)
  if vim.env.TMUX then
    osc = string.format("\x1bPtmux;\x1b%s\x1b\\", osc)
  end
  local tty = vim.env.TTY or "/dev/tty"
  local ok, fd = pcall(vim.loop.fs_open, tty, "w", 0)
  if ok and fd then
    vim.loop.fs_write(fd, osc, -1)
    vim.loop.fs_close(fd)
  else
    io.write(osc)
  end
end

local function osc52_paste()
  -- 无法从远端终端读取系统剪贴板，这里退回默认寄存器
  return vim.fn.split(vim.fn.getreg('"'), "\n")
end

local has_builtin_osc52 = vim.ui and vim.ui.clipboard and vim.ui.clipboard.osc52

-- Auto-enable OSC52 on SSH (server -> local clipboard) unless explicitly disabled.
if (vim.env.SSH_CONNECTION and vim.env.SSH_CONNECTION ~= "") and vim.env.NVIM_CLIPBOARD_OSC52 == nil then
  vim.env.NVIM_CLIPBOARD_OSC52 = "1"
end

-- Optional: force OSC52 (terminal must support it)
-- Usage: NVIM_CLIPBOARD_OSC52=1 nvim
if vim.env.NVIM_CLIPBOARD_OSC52 == "1" then
  if has_builtin_osc52 then
    -- SSH: 用内置 OSC52（0.10+）
    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = vim.ui.clipboard.osc52.copy("+"),
        ["*"] = vim.ui.clipboard.osc52.copy("*"),
      },
      paste = {
        ["+"] = vim.ui.clipboard.osc52.paste("+"),
        ["*"] = vim.ui.clipboard.osc52.paste("*"),
      },
      cache_enabled = 0,
    }
  else
    -- SSH: 退回纯 OSC52（终端需支持）
    vim.g.clipboard = {
      name = "osc52",
      copy = { ["+"] = osc52_copy, ["*"] = osc52_copy },
      paste = { ["+"] = osc52_paste, ["*"] = osc52_paste },
      cache_enabled = 0,
    }
  end
end
