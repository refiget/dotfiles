return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue", mode = "n" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint", mode = "n" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "DAP conditional breakpoint",
        mode = "n",
      },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok, dap_python = pcall(require, "dap-python")
      if not ok then
        return
      end
      local python = vim.g.python3_host_prog or "python3"
      dap_python.setup(python)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI toggle", mode = "n" },
    },
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      local ok_ui, dapui = pcall(require, "dapui")
      if not ok_dap or not ok_ui then
        return
      end
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
