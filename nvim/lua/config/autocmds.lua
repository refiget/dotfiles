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
  vim.api.nvim_set_hl(0, "StatusLine", { fg = s and s.fg or nil, bg = "#ffffff", bold = s and s.bold or false })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = snc and snc.fg or nil, bg = "#ffffff" })
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
        vim.api.nvim_set_hl(0, "StatusLine", { fg = s and s.fg or nil, bg = "#ffffff", bold = s and s.bold or false })
        vim.api.nvim_set_hl(0, "StatusLineNC", { fg = snc and snc.fg or nil, bg = "#ffffff" })
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

