-- Autocommands go here.

local autosave_group = vim.api.nvim_create_augroup("AutosaveMarkdownOnModeChange", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    if vim.bo.filetype ~= "markdown" then
      return
    end
    if vim.g.markdown_autosave_enabled == false then
      return
    end
    if not vim.bo.modified then
      return
    end
    if not vim.bo.modifiable or vim.bo.readonly then
      return
    end

    vim.cmd("silent! update")
  end,
})

-- UI hygiene: keep DAP UI panels clean (no winbar/statusline)
local dapui_group = vim.api.nvim_create_augroup("DapUiMinimalChrome", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = dapui_group,
  pattern = {
    "dapui_scopes",
    "dapui_stacks",
    "dapui_breakpoints",
    "dapui_watches",
    "dapui_console",
    "dap-repl",
  },
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()
    -- Window-local: remove the cheap thick bars inside dap-ui splits.
    pcall(vim.api.nvim_win_set_option, win, "winbar", "")
    pcall(vim.api.nvim_win_set_option, win, "statusline", "")
    -- Buffer-local: also ensure they don't come back.
    pcall(vim.api.nvim_buf_set_option, ev.buf, "winbar", "")
    pcall(vim.api.nvim_buf_set_option, ev.buf, "statusline", "")
  end,
})

-- Re-assert minimal chrome after plugins load (some statusline plugins override these)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
  end,
})
