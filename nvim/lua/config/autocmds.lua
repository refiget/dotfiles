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
local dapui_fts = {
  ["dapui_scopes"] = true,
  ["dapui_stacks"] = true,
  ["dapui_breakpoints"] = true,
  ["dapui_watches"] = true,
  ["dapui_console"] = true,
  ["dap-repl"] = true,
}

local function clean_dapui_chrome(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local ft = vim.bo[bufnr].filetype
  if not dapui_fts[ft] then
    return
  end

  -- For dapui_console, keep a thin separator line (winbar) instead of a chunky statusline.
  local want_sepbar = (ft == "dapui_console")
  local winbar_value = want_sepbar and "%{%v:lua.require('config.ui').sepbar()%}" or ""

  -- Clear statusline for *any* window showing this buffer.
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    pcall(vim.api.nvim_win_set_option, win, "statusline", "")
    pcall(vim.api.nvim_win_set_option, win, "winbar", winbar_value)
  end
  pcall(vim.api.nvim_buf_set_option, bufnr, "statusline", "")
  pcall(vim.api.nvim_buf_set_option, bufnr, "winbar", winbar_value)
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = dapui_group,
  pattern = "*",
  callback = function(ev)
    clean_dapui_chrome(ev.buf)
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
