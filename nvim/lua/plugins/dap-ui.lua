return {
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      opts = opts or {}
      -- Keep only REPL at bottom; remove watches/console panels.
      opts.layouts = {
        {
          position = "bottom",
          size = 12,
          elements = {
            { id = "repl", size = 1.0 },
          },
        },
      }
      return opts
    end,
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Disable auto-close behavior from distro defaults.
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil

      -- Keep auto-open.
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
    end,
  },
}
