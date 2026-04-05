-- Autocmds are automatically loaded on the VeryLazy event
-- Add any additional autocmds here

-- CS61B helper: warm-index all Java files in src/tests
local function cs61b_warm_index_once()
  local root = vim.fn.getcwd()
  vim.g._cs61b_indexed_roots = vim.g._cs61b_indexed_roots or {}
  if vim.g._cs61b_indexed_roots[root] then
    return
  end

  local roots = { "src", "tests" }
  local files = {}
  for _, r in ipairs(roots) do
    local found = vim.fn.glob(r .. "/**/*.java", false, true)
    if type(found) == "table" then
      vim.list_extend(files, found)
    end
  end

  if #files == 0 then
    return
  end

  vim.g._cs61b_indexed_roots[root] = true

  -- single status message (no notify spam)
  vim.api.nvim_echo({ { "Index established", "ModeMsg" } }, false, {})

  -- warm buffers without changing current window
  for _, f in ipairs(files) do
    local b = vim.fn.bufadd(f)
    pcall(vim.fn.bufload, b)
  end

  -- ask jdtls to refresh project model/diagnostics
  for _, c in ipairs(vim.lsp.get_clients()) do
    if c.name == "jdtls" then
      pcall(c.request_sync, c, "workspace/executeCommand", { command = "java.project.import" }, 3000, 0)
      pcall(c.request_sync, c, "workspace/executeCommand", { command = "java.project.refreshDiagnostics" }, 3000, 0)
    end
  end

end

-- Manual command (still available)
vim.api.nvim_create_user_command("Cs61bIndex", function()
  -- clear current-root mark, then run once now
  local root = vim.fn.getcwd()
  vim.g._cs61b_indexed_roots = vim.g._cs61b_indexed_roots or {}
  vim.g._cs61b_indexed_roots[root] = nil
  cs61b_warm_index_once()
end, { desc = "Warm-index all Java files in src/tests" })

-- Auto-run once when jdtls attaches in a CS61B-style project
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end

    local has_src = vim.fn.isdirectory("src") == 1
    local has_tests = vim.fn.isdirectory("tests") == 1
    local has_marker = vim.fn.filereadable(".cs61b-root") == 1
    if not ((has_src and has_tests) or has_marker) then
      return
    end

    -- Defer slightly to let initial project import settle
    vim.defer_fn(function()
      pcall(cs61b_warm_index_once)
    end, 1200)
  end,
})

-- Markdown: disable conceal so md shows raw syntax (no "natural rendering")
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "md", "rmd", "quarto" },
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
  end,
})

-- Force statusline background to match Normal background
local function sync_statusline_bg_to_normal()
  local n = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local s = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local snc = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
  if not n or not n.bg then
    return
  end
  vim.api.nvim_set_hl(0, "StatusLine", { fg = s and s.fg or nil, bg = n.bg, bold = s and s.bold or false })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = snc and snc.fg or nil, bg = n.bg })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = function()
    vim.schedule(sync_statusline_bg_to_normal)
  end,
})

-- Re-apply after lualine/theme finalizes
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "VeryLazy",
  callback = function()
    vim.defer_fn(function()
      local n = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local s = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
      local snc = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
      if n and n.bg then
        vim.api.nvim_set_hl(0, "StatusLine", { fg = s and s.fg or nil, bg = n.bg, bold = s and s.bold or false })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = snc and snc.fg or nil, bg = n.bg })
      end
    end, 120)
  end,
})


-- Clean jdtls index/cache for current project and restart LSP
vim.api.nvim_create_user_command("JavaIndexClean", function()
  local data = vim.fn.stdpath("data")
  local root = vim.fn.getcwd()
  local ws = data .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")

  -- stop jdtls clients first (release files)
  for _, c in ipairs(vim.lsp.get_clients()) do
    if c.name == "jdtls" then
      pcall(vim.lsp.stop_client, c.id, true)
    end
  end

  -- clear warm-index memo for this root
  vim.g._cs61b_indexed_roots = vim.g._cs61b_indexed_roots or {}
  vim.g._cs61b_indexed_roots[root] = nil

  if vim.fn.isdirectory(ws) == 1 then
    vim.fn.delete(ws, "rf")
    vim.notify("Java index cache cleaned: " .. ws, vim.log.levels.INFO)
  else
    vim.notify("No Java index cache dir: " .. ws, vim.log.levels.INFO)
  end

  -- restart lsp so jdtls re-imports project
  vim.defer_fn(function()
    pcall(vim.cmd, "LspStart jdtls")
    vim.defer_fn(function()
      pcall(vim.cmd, "Cs61bIndex")
    end, 1200)
  end, 300)
end, { desc = "Clean jdtls workspace cache for current project and re-index" })


-- Java tests without opening DAP UI (REPL/UI stays closed)
vim.api.nvim_create_user_command("JavaTestClassNoUI", function()
  local ok, jdtls_dap = pcall(require, "jdtls.dap")
  if not ok then
    vim.notify("jdtls.dap not available", vim.log.levels.WARN)
    return
  end
  vim.g._dapui_suppress_next_open = true
  jdtls_dap.test_class()
end, { desc = "Run Java test class without opening dap-ui" })

vim.api.nvim_create_user_command("JavaTestNearestNoUI", function()
  local ok, jdtls_dap = pcall(require, "jdtls.dap")
  if not ok then
    vim.notify("jdtls.dap not available", vim.log.levels.WARN)
    return
  end
  vim.g._dapui_suppress_next_open = true
  jdtls_dap.test_nearest_method()
end, { desc = "Run nearest Java test without opening dap-ui" })

-- Auto-show diagnostics float on hover, normal mode only
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "n" then
      return
    end
    vim.diagnostic.open_float(nil, {
      focus = false,
      scope = "cursor",
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter", "WinLeave" },
    })
  end,
})

-- Java tests: run class and show bottom 12-line split panel (left summary, right details)
vim.api.nvim_create_user_command("JavaTestClassPanel", function()
  local ok, jdtls_dap = pcall(require, "jdtls.dap")
  if not ok then
    vim.notify("jdtls.dap not available", vim.log.levels.WARN)
    return
  end

  local state = {
    left_buf = nil,
    right_buf = nil,
    left_win = nil,
    right_win = nil,
    tests_by_line = {},
  }

  local function set_scratch(buf)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "java-test-panel"
  end

  local function render_right(test)
    if not (state.right_buf and vim.api.nvim_buf_is_valid(state.right_buf)) then
      return
    end
    vim.bo[state.right_buf].modifiable = true
    local lines = {}
    if not test then
      lines = { "No test selected." }
    else
      table.insert(lines, string.format("Test: %s", test.method or "<unknown>"))
      table.insert(lines, string.format("Class: %s", test.fq_class or "<unknown>"))
      table.insert(lines, string.format("Status: %s", test.failed and "FAILED" or "PASSED"))
      table.insert(lines, "")
      if test.failed and test.traces and #test.traces > 0 then
        vim.list_extend(lines, test.traces)
      elseif test.failed then
        table.insert(lines, "(No trace available)")
      else
        table.insert(lines, "No error. Test passed.")
      end
    end
    vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, lines)
    vim.bo[state.right_buf].modifiable = false
  end

  local function open_panel(tests)
    vim.cmd("botright 12split")
    state.left_win = vim.api.nvim_get_current_win()

    state.left_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.left_win, state.left_buf)
    set_scratch(state.left_buf)

    vim.cmd("vsplit")
    state.right_win = vim.api.nvim_get_current_win()
    state.right_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.right_win, state.right_buf)
    set_scratch(state.right_buf)

    if vim.api.nvim_win_is_valid(state.left_win) then
      local target = math.max(32, math.floor(vim.o.columns * 0.30))
      pcall(vim.api.nvim_win_set_width, state.left_win, target)
    end

    local passed, failed = 0, 0
    for _, t in ipairs(tests or {}) do
      if t.failed then failed = failed + 1 else passed = passed + 1 end
    end

    local lines = {
      string.format("Java Tests  total:%d  pass:%d  fail:%d", #(tests or {}), passed, failed),
      string.rep("─", 60),
    }

    state.tests_by_line = {}
    for _, t in ipairs(tests or {}) do
      local mark = t.failed and "✗" or "✓"
      table.insert(lines, string.format("%s %s", mark, t.method or (t.fq_class or "<unknown>")))
      state.tests_by_line[#lines] = t
    end

    vim.bo[state.left_buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, lines)
    vim.bo[state.left_buf].modifiable = false

    vim.keymap.set("n", "<CR>", function()
      local lnum = vim.api.nvim_win_get_cursor(state.left_win)[1]
      render_right(state.tests_by_line[lnum])
    end, { buffer = state.left_buf, silent = true, desc = "Show selected test detail" })

    vim.keymap.set("n", "q", function()
      if state.left_win and vim.api.nvim_win_is_valid(state.left_win) then pcall(vim.api.nvim_win_close, state.left_win, true) end
      if state.right_win and vim.api.nvim_win_is_valid(state.right_win) then pcall(vim.api.nvim_win_close, state.right_win, true) end
    end, { buffer = state.left_buf, silent = true, desc = "Close test panel" })

    local first_line = 3
    if state.tests_by_line[first_line] then
      vim.api.nvim_set_current_win(state.left_win)
      vim.api.nvim_win_set_cursor(state.left_win, { first_line, 0 })
      render_right(state.tests_by_line[first_line])
      vim.api.nvim_set_current_win(state.left_win)
    else
      render_right(nil)
    end
  end

  vim.g._dapui_suppress_next_open = true
  jdtls_dap.test_class({
    after_test = function(_, tests)
      vim.schedule(function()
        open_panel(tests or {})
      end)
    end,
  })
end, { desc = "Run Java test class and open bottom summary panel" })

