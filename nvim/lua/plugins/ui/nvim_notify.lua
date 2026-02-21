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

    notify.setup({
      stages = "fade",
      timeout = 2500,
      background_colour = bg,
      render = "minimal",
      max_width = function()
        return math.floor(vim.o.columns * 0.4)
      end,
    })

    vim.notify = notify
  end,
}
