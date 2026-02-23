-- rcarriga/nvim-notify

return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local ok, notify = pcall(require, "notify")
    if not ok then
      return
    end
    local bg = "#1e1e2e"
    pcall(function()
      bg = require("catppuccin.palettes").get_palette("mocha").base
    end)

    local function apply_notify_hl()
      vim.api.nvim_set_hl(0, "NotifyBackground", { bg = bg })
    end

    apply_notify_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        pcall(apply_notify_hl)
      end,
    })

    local DEFAULT_TIMEOUT = 3000

    notify.setup({
      stages = "fade",
      timeout = DEFAULT_TIMEOUT,
      background_colour = bg,
      -- "minimal" 容易把长内容压缩成省略号，改用可换行渲染。
      render = "wrapped-compact",
      max_width = function()
        return math.floor(vim.o.columns * 0.68)
      end,
      max_height = function()
        return math.floor(vim.o.lines * 0.55)
      end,
    })

    local log_file = vim.fn.stdpath("state") .. "/notify.log"

    local function level_name(level)
      local map = {
        [vim.log.levels.TRACE] = "TRACE",
        [vim.log.levels.DEBUG] = "DEBUG",
        [vim.log.levels.INFO] = "INFO",
        [vim.log.levels.WARN] = "WARN",
        [vim.log.levels.ERROR] = "ERROR",
      }
      return map[level] or tostring(level or "INFO")
    end

    local function append_notify_log(msg, level, opts)
      local title = (opts and opts.title) and ("[" .. opts.title .. "] ") or ""
      local text = type(msg) == "table" and table.concat(msg, "\n") or tostring(msg)
      local line = string.format("%s [%s] %s%s", os.date("%Y-%m-%d %H:%M:%S"), level_name(level), title, text)
      pcall(vim.fn.writefile, vim.split(line, "\n"), log_file, "a")
    end

    local LEVEL_TIMEOUT = {
      [vim.log.levels.ERROR] = 10000,
      [vim.log.levels.WARN] = 6000,
      [vim.log.levels.INFO] = 3000,
      [vim.log.levels.DEBUG] = 2000,
      [vim.log.levels.TRACE] = 2000,
    }

    local base_notify = notify
    vim.notify = function(msg, level, opts)
      opts = opts or {}
      local lv = level or vim.log.levels.INFO

      -- 按级别分配默认淡出时间；显式传 timeout 时尊重调用方。
      if opts.timeout == nil then
        opts.timeout = LEVEL_TIMEOUT[lv] or DEFAULT_TIMEOUT
      elseif opts.timeout == false then
        -- 兼容 false：转成较长数值，避免底层 timer 报错。
        opts.timeout = 600000
      end

      append_notify_log(msg, lv, opts)
      return base_notify(msg, lv, opts)
    end

    vim.api.nvim_create_user_command("NotifyLog", function(cmd)
      if vim.fn.filereadable(log_file) == 0 then
        vim.notify("notify.log 还不存在", vim.log.levels.INFO, { title = "NotifyLog" })
        return
      end
      local tail = tonumber(cmd.args) or 300
      vim.cmd("botright split " .. vim.fn.fnameescape(log_file))
      vim.cmd("normal! G")
      if tail > 0 then
        vim.cmd("normal! " .. tostring(tail) .. "k")
      end
      vim.bo.buflisted = false
      vim.bo.modifiable = false
      vim.bo.readonly = true
    end, {
      nargs = "?",
      desc = "Open notify log (optional: tail lines)",
    })

    vim.api.nvim_create_user_command("NotifyLogClear", function()
      pcall(vim.fn.delete, log_file)
      vim.notify("已清空 notify.log", vim.log.levels.INFO, { title = "NotifyLog" })
    end, {
      desc = "Clear notify log",
    })
  end,
}
