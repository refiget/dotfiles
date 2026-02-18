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

-- Statusline policy:
-- - Default buffers: hide the statusline entirely (no extra row).
-- - DAP UI windows: show the statusline (for context like "DAP Scopes 1,0-1 All").
local dapui_fts = {
  ["dapui_scopes"] = true,
  ["dapui_stacks"] = true,
  ["dapui_breakpoints"] = true,
  ["dapui_watches"] = true,
  ["dapui_console"] = true,
  ["dap-repl"] = true,
}

local function is_dapui_win(win)
  win = win or 0
  local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
  if not ok or not buf then
    return false
  end
  local ft = vim.bo[buf].filetype
  return dapui_fts[ft] == true
end

local function apply_laststatus_for_current_win()
  if is_dapui_win(0) then
    vim.opt.laststatus = 2
  else
    vim.opt.laststatus = 0
  end
end

local chrome_group = vim.api.nvim_create_augroup("ChromePolicy", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "WinEnter", "BufEnter", "FileType" }, {
  group = chrome_group,
  callback = function()
    pcall(apply_laststatus_for_current_win)
  end,
})
