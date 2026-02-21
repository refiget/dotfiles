-- rcarriga/nvim-dap-ui

return {
  "rcarriga/nvim-dap-ui",
  lazy = false,
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
  keys = {
    { "<localleader>du", function() _G.DAPUI_UX.toggle() end, desc = "DAP UI toggle", mode = "n" },
    { "<localleader>dU", function() _G.DAPUI_UX.open_reset() end, desc = "DAP UI open (reset)", mode = "n" },
    { "<localleader>dp", function() _G.DAPUI_UX.float("breakpoints") end, desc = "DAP UI: breakpoints (float)", mode = "n" },
    { "<localleader>dw", function() _G.DAPUI_UX.float("watches") end, desc = "DAP UI: watches (float)", mode = "n" },
    { "<localleader>ds", function() _G.DAPUI_UX.float("stacks") end, desc = "DAP UI: stacks (float)", mode = "n" },
  },

  config = function()
    local ok_dap, dap = pcall(require, "dap")
    local ok_ui, dapui = pcall(require, "dapui")
    if not ok_dap or not ok_ui then
      return
    end

    --  _   _ ___
    -- | | | |_ _|
    -- | | | || |
    -- | |_| || |
    --  \___/|___|
    -- UI
    dapui.setup({
      expand_lines = true,
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "▶",
      },
      controls = { enabled = false },
      layouts = {
        {
          position = "right",
          size = 34,
          elements = {
            { id = "scopes", size = 0.7 },
            { id = "stacks", size = 0.3 },
          },
        },
        {
          position = "bottom",
          size = 9,
          elements = {
            { id = "console", size = 1.0 },
          },
        },
      },
      floating = {
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
      },
      windows = { indent = 1 },
      indent_lines = false,
      render = {
        max_type_length = 30,
        max_value_lines = 50,
      },
    })

    local function apply_dapui_hl()
      vim.api.nvim_set_hl(0, "DapUIFloatBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "DapUIBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "DapUIValue", { link = "Normal" })
      vim.api.nvim_set_hl(0, "DapUIVariable", { link = "Normal" })
      vim.api.nvim_set_hl(0, "DapUIType", { link = "Type" })
      vim.api.nvim_set_hl(0, "DapUIModifiedValue", { link = "DiagnosticWarn" })
      vim.api.nvim_set_hl(0, "DapUIStoppedThread", { link = "DiagnosticError" })
      vim.api.nvim_set_hl(0, "DapUIStoppedThreadText", { link = "DiagnosticError" })
      vim.api.nvim_set_hl(0, "DapUIFrameName", { link = "Normal" })
      vim.api.nvim_set_hl(0, "DapUISource", { link = "Comment" })
      vim.api.nvim_set_hl(0, "DapUILineNumber", { link = "LineNr" })
      vim.api.nvim_set_hl(0, "DapUISeparator", { link = "WinSeparator" })
      vim.api.nvim_set_hl(0, "DapUISeparatorActive", { link = "WinSeparator" })
    end

    apply_dapui_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        pcall(apply_dapui_hl)
      end,
    })

    -- Statusline policy (plugin-owned UX):
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

    vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "WinEnter", "BufEnter", "FileType" }, {
      group = vim.api.nvim_create_augroup("DapUiStatuslinePolicy", { clear = true }),
      callback = function()
        pcall(apply_laststatus_for_current_win)
      end,
    })

    _G.DAPUI_UX = _G.DAPUI_UX or {}

    local function owner_alive()
      local ob = vim.g._dapui_owner_buf
      local ot = vim.g._dapui_owner_tab
      if not ob or not vim.api.nvim_buf_is_valid(ob) then
        return false
      end
      if not ot or not vim.api.nvim_tabpage_is_valid(ot) then
        return false
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(ot)) do
        if vim.api.nvim_win_get_buf(win) == ob then
          return true
        end
      end
      return false
    end

    function _G.DAPUI_UX.toggle()
      vim.g._dapui_owner_buf = vim.api.nvim_get_current_buf()
      vim.g._dapui_owner_tab = vim.api.nvim_get_current_tabpage()
      dapui.toggle()
    end

    function _G.DAPUI_UX.open_reset()
      vim.g._dapui_owner_buf = vim.api.nvim_get_current_buf()
      vim.g._dapui_owner_tab = vim.api.nvim_get_current_tabpage()
      dapui.open({ reset = true })
    end

    function _G.DAPUI_UX.float(element)
      dapui.float_element(element, { enter = true })
    end

    local group = vim.api.nvim_create_augroup("DapUiUX", { clear = true })

    vim.api.nvim_create_autocmd("QuitPre", {
      group = group,
      callback = function()
        local cur = vim.api.nvim_get_current_buf()
        if vim.g._dapui_owner_buf and cur == vim.g._dapui_owner_buf then
          pcall(dapui.close)
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWipeout", "TabClosed" }, {
      group = group,
      callback = function()
        vim.schedule(function()
          if not owner_alive() then
            pcall(dapui.close)
          end
        end)
      end,
    })

    dap.listeners.after.event_initialized["dapui_config"] = function() end
    dap.listeners.before.event_terminated["dapui_config"] = function() end
    dap.listeners.before.event_exited["dapui_config"] = function() end
  end,
}
