local keymap = vim.keymap.set

local M = {}

local function notify_if(enabled, msg, level)
  if enabled then
    vim.notify(msg, level or vim.log.levels.INFO)
  end
end

function M.sync_current_py(opts)
  opts = opts or {}
  local notify = opts.notify == true

  vim.cmd("w")
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not file:match("%.py$") then
    notify_if(notify, "Not a .py file", vim.log.levels.WARN)
    return
  end

  local script = vim.fn.expand("~/scripts/jtext")
  if vim.fn.filereadable(script) ~= 1 then
    notify_if(notify, "jtext script not found at ~/scripts/jtext", vim.log.levels.WARN)
    return
  end

  local rel = vim.fn.fnamemodify(file, ":.")
  vim.fn.jobstart({ script, rel }, { cwd = vim.fn.getcwd(), detach = true })
  notify_if(notify, "Jtext sync started")
end

keymap("n", "<localleader>s", function()
  M.sync_current_py({ notify = true })
end, { silent = true, desc = "Jtext: save + sync current .py" })

return M
