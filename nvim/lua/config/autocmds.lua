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

-- Override eleline file-size function to avoid errors on non-file buffers/UI prompts
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd([[
      function! ElelineFsize(f) abort
        let l:target = a:f
        if empty(l:target)
          return ''
        endif
        if l:target =~# '^\[.*\]$' || l:target =~# '^term://'
          return ''
        endif
        if filereadable(l:target) == 0
          return ''
        endif
        let l:size = getfsize(l:target)
        if l:size <= 0
          return ''
        endif
        if l:size < 1024
          let size = l:size.' bytes'
        elseif l:size < 1024*1024
          let size = printf('%.1f', l:size/1024.0).'k'
        elseif l:size < 1024*1024*1024
          let size = printf('%.1f', l:size/1024.0/1024.0) . 'm'
        else
          let size = printf('%.1f', l:size/1024.0/1024.0/1024.0) . 'g'
        endif
        return '  '.size.' '
      endfunction
    ]])
  end,
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
