return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    config = function()
      -- Breakpoint / stopped signs
      -- Requested:
      --   - normal breakpoint: ● (red)
      --   - conditional breakpoint: ◆ (red)
      --   - current execution line: ▶ (red)
      local red = "#ff5555"
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = red })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = red })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = red })

      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DapBreakpoint",
        numhl = "",
        linehl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DapBreakpointCondition",
        numhl = "",
        linehl = "",
      })
      -- Subtle stopped-line highlight (low chrome, but clearer state)
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#343746" })
      vim.fn.sign_define("DapStopped", {
        text = "▶",
        texthl = "DapStopped",
        numhl = "",
        linehl = "DapStoppedLine",
      })
    end,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue", mode = "n" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint", mode = "n" },
      {
        "<localleader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "DAP conditional breakpoint",
        mode = "n",
      },

      -- Localleader-based mappings (more reliable than <F-keys> under macOS/tmux)
      { "<localleader>dc", function() require("dap").continue() end, desc = "DAP continue", mode = "n" },
      { "<localleader>dn", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
      { "<localleader>di", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
      { "<localleader>do", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
      { "<localleader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint", mode = "n" },
      { "<localleader>dC", function() require("dap").clear_breakpoints() end, desc = "DAP clear breakpoints", mode = "n" },
      { "<localleader>dr", function() require("dap").repl.toggle() end, desc = "DAP REPL toggle", mode = "n" },
      { "<localleader>dq", function() require("dap").terminate() end, desc = "DAP terminate", mode = "n" },

      -- More conventional aliases (short, VSCode-ish semantics)
      { "<localleader>dd", function() require("dap").continue() end, desc = "DAP start/continue", mode = "n" },
      { "<localleader>dj", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
      { "<localleader>dk", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
      { "<localleader>dl", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
      { "<localleader>de", function() require("dap").set_exception_breakpoints({ "raised", "uncaught" }) end, desc = "DAP break on exceptions", mode = "n" },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = {
      {
        "<localleader>df",
        function()
          -- Debug *current file* (beginner-friendly, no Treesitter needed)
          local dap = require("dap")
          local fn = vim.fn

          local function exists(path)
            return path and path ~= "" and fn.filereadable(path) == 1
          end

          local function find_project_python()
            local venv = vim.env.VIRTUAL_ENV
            if venv and venv ~= "" then
              local p = venv .. "/bin/python"
              if exists(p) then
                return p
              end
            end

            local root = fn.getcwd()
            for _, p in ipairs({
              root .. "/.venv/bin/python",
              root .. "/.venv/bin/python3",
              root .. "/venv/bin/python",
              root .. "/venv/bin/python3",
            }) do
              if exists(p) then
                return p
              end
            end

            local mason_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            if exists(mason_py) then
              return mason_py
            end

            return vim.g.python3_host_prog or "python3"
          end

          dap.run({
            type = "python",
            request = "launch",
            name = "Launch current file",
            program = fn.expand("%:p"),
            cwd = fn.getcwd(),
            pythonPath = find_project_python(),
            justMyCode = true,
            console = "integratedTerminal",
          })
        end,
        desc = "DAP: debug current file (Python)",
        mode = "n",
      },
      {
        "<localleader>dt",
        function()
          require("dap-python").test_method()
        end,
        desc = "DAP: debug pytest method",
        mode = "n",
      },
      {
        "<localleader>dT",
        function()
          require("dap-python").test_class()
        end,
        desc = "DAP: debug pytest class",
        mode = "n",
      },
    },
    config = function()
      local ok, dap_python = pcall(require, "dap-python")
      if not ok then
        return
      end

      local fn = vim.fn

      local function exists(path)
        return path and path ~= "" and fn.filereadable(path) == 1
      end

      local function find_project_python()
        -- Prefer active venv
        local venv = vim.env.VIRTUAL_ENV
        if venv and venv ~= "" then
          local p = venv .. "/bin/python"
          if exists(p) then
            return p
          end
        end

        -- Prefer per-project venv inside cwd (like LSP)
        local root = fn.getcwd()
        local candidates = {
          root .. "/.venv/bin/python",
          root .. "/.venv/bin/python3",
          root .. "/venv/bin/python",
          root .. "/venv/bin/python3",
        }
        for _, p in ipairs(candidates) do
          if exists(p) then
            return p
          end
        end

        -- Fallback: Mason debugpy venv (stable adapter)
        local mason_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        if exists(mason_py) then
          return mason_py
        end

        -- Last resort
        return vim.g.python3_host_prog or "python3"
      end

      -- IMPORTANT:
      -- dap-python's setup() argument is the *adapter* python used to run debugpy.adapter.
      -- Using the project venv here is fragile because many projects don't have debugpy installed.
      -- Prefer Mason's debugpy venv for the adapter, while using the project python for running code.
      local mason_adapter_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if exists(mason_adapter_py) then
        dap_python.setup(mason_adapter_py)
      else
        -- Fallback: best-effort (may require `pip install debugpy` in the selected venv)
        dap_python.setup(find_project_python())
      end

      -- Make <localleader>df a predictable entry point.
      -- If no explicit DAP configuration exists, nvim-dap-python will use defaults.
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      { "<localleader>du", function() _G.DAPUI_UX.toggle() end, desc = "DAP UI toggle", mode = "n" },
      { "<localleader>dU", function() _G.DAPUI_UX.open_reset() end, desc = "DAP UI open (reset)", mode = "n" },
      { "<localleader>dp", function() _G.DAPUI_UX.float("breakpoints") end, desc = "DAP UI: breakpoints (float)", mode = "n" },
      { "<localleader>dw", function() _G.DAPUI_UX.float("watches") end, desc = "DAP UI: watches (float)", mode = "n" },
      { "<localleader>ds", function() _G.DAPUI_UX.float("stacks") end, desc = "DAP UI: stacks (float)", mode = "n" },

      -- Stable leader aliases (space leader is more reliable than localleader in some tmux/iTerm2 setups)
      { "<leader>dp", function() _G.DAPUI_UX.float("breakpoints") end, desc = "DAP UI: breakpoints (float)", mode = "n" },
      { "<leader>dw", function() _G.DAPUI_UX.float("watches") end, desc = "DAP UI: watches (float)", mode = "n" },
      { "<leader>ds", function() _G.DAPUI_UX.float("stacks") end, desc = "DAP UI: stacks (float)", mode = "n" },
      { "<leader>du", function() _G.DAPUI_UX.toggle() end, desc = "DAP UI toggle", mode = "n" },
      { "<leader>dU", function() _G.DAPUI_UX.open_reset() end, desc = "DAP UI open (reset)", mode = "n" }
    },
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      local ok_ui, dapui = pcall(require, "dapui")
      if not ok_dap or not ok_ui then
        return
      end
      -- DAP UI: match the repo's low-chrome Dracula/tmux aesthetic
      -- Newbie / low-chrome layout:
      -- - Right: Scopes + Stacks only (high-frequency)
      -- - Bottom: Console only (error/output)
      -- - Breakpoints/Watches: open as floats on demand
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
        controls = {
          enabled = false,
        },
        layouts = {
          {
            position = "right",
            -- Slimmer right panel (less "cheap bar" feel on small screens)
            size = 34,
            elements = {
              { id = "scopes", size = 0.7 },
              { id = "stacks", size = 0.3 },
            },
          },
          {
            position = "bottom",
            -- Slimmer console; you can always open floats for details
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
        -- Remove the chunky section separators; rely on the global WinSeparator styling.
        indent_lines = false,
        render = {
          max_type_length = 30,
          max_value_lines = 50,
        },
      })

      -- Highlights: keep borders/separators consistent with config.ui
      local function apply_dapui_hl()
        -- Link to existing UI groups where possible
        vim.api.nvim_set_hl(0, "DapUIFloatBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "DapUIBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "DapUIValue", { link = "Normal" })
        vim.api.nvim_set_hl(0, "DapUIVariable", { link = "Normal" })
        vim.api.nvim_set_hl(0, "DapUIType", { link = "Type" })
        vim.api.nvim_set_hl(0, "DapUIModifiedValue", { link = "DiagnosticWarn" })
        vim.api.nvim_set_hl(0, "DapUIStoppedThread", { link = "DiagnosticError" })
        vim.api.nvim_set_hl(0, "DapUIStoppedThreadText", { link = "DiagnosticError" })
        vim.api.nvim_set_hl(0, "DapUIFrameName", { link = "Title" })
        vim.api.nvim_set_hl(0, "DapUISource", { link = "Comment" })
        vim.api.nvim_set_hl(0, "DapUILineNumber", { link = "LineNr" })
        -- Separators: keep them subtle (same as splits)
        vim.api.nvim_set_hl(0, "DapUISeparator", { link = "WinSeparator" })
        vim.api.nvim_set_hl(0, "DapUISeparatorActive", { link = "WinSeparator" })
      end

      apply_dapui_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          pcall(apply_dapui_hl)
        end,
      })

      -- DAP UI UX helper:
      -- - Toggle remembers the "owner" buffer/tab (where you opened it)
      -- - When that buffer/tab is closed, auto-close DAP UI
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

      -- Important: close DAP UI *before* quitting the owner window.
      -- This prevents ending up in a "blank" buffer/window after `Q`/`:q`/`:wq`.
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

      -- Newbie / low-noise: don't auto-open/close on session start/end.
      -- Use ,du to toggle when you actually want the UI.
      dap.listeners.after.event_initialized["dapui_config"] = function() end
      dap.listeners.before.event_terminated["dapui_config"] = function() end
      dap.listeners.before.event_exited["dapui_config"] = function() end
    end,
  },
}
