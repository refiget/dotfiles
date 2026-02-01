-- ===================== tmux.lua =====================
local M = {}

local function set_tmux_mode(mode)  -- Decide the action how to run
  if not vim.env.TMUX then
    return
  end
  local cmd = string.format(
    "tmux set-environment -g TMUX_MODE %s 2>/dev/null && tmux run-shell ~/.config/tmux/scripts/update_theme_color.sh",
    mode
  )
  vim.fn.jobstart({ "bash", "-lc", cmd }, { detach = true })
end

function M.setup_mode_sync()  -- Decide the action when to run
  local group = vim.api.nvim_create_augroup("TmuxModeSync", { clear = true })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      set_tmux_mode("insert")
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      set_tmux_mode("normal")
    end,
  })
end

return M
