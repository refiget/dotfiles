return {
  { "mfussenegger/nvim-dap", lazy = false },
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
