-- ===================== autocmds.lua =====================
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
})

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  command = "startinsert",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  command = "setlocal spell",
})

-- Disable eleline statusline in DAP UI buffers to avoid errors
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_repl",
    "dapui_console",
    "dap-repl",
  },
  callback = function()
    vim.opt_local.statusline = " "
  end,
})

-- Focus neo-tree window when opened
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "neo-tree filesystem [1-9]*",
  callback = function()
    local winid = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_current_win(winid)
    end
  end,
})
