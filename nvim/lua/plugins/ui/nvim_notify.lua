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

    local PERSIST_TIMEOUT = 500000 -- 500s

    notify.setup({
      stages = "fade",
      -- nvim-notify timers require a number; use a very large timeout to mimic persistence.
      timeout = PERSIST_TIMEOUT,
      background_colour = bg,
      render = "minimal",
      max_width = function()
        return math.floor(vim.o.columns * 0.4)
      end,
    })

    -- Normalize timeout=false/nil to a large numeric timeout to avoid timer errors.
    local base_notify = notify
    vim.notify = function(msg, level, opts)
      opts = opts or {}
      if opts.timeout == nil or opts.timeout == false then
        opts.timeout = PERSIST_TIMEOUT
      end
      return base_notify(msg, level, opts)
    end
  end,
}
