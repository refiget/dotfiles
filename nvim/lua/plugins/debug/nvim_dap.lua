-- mfussenegger/nvim-dap

return {
  "mfussenegger/nvim-dap",
  lazy = false,
  config = function()
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

    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#343746" })
    vim.fn.sign_define("DapStopped", {
      text = "▶",
      texthl = "DapStopped",
      numhl = "",
      linehl = "DapStoppedLine",
    })
  end,

  --  ____  _               _             _
  -- / ___|| |__   ___  ___| | _____ _ __| |_ ___
  -- \___ \| '_ \ / _ \/ __| |/ / _ \ '__| __/ __|
  --  ___) | | | |  __/ (__|   <  __/ |  | |_\__ \
  -- |____/|_| |_|\___|\___|_|\_\___|_|   \__|___/
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

    { "<localleader>dc", function() require("dap").continue() end, desc = "DAP continue", mode = "n" },
    { "<localleader>dn", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
    { "<localleader>di", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
    { "<localleader>do", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
    { "<localleader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint", mode = "n" },
    { "<localleader>dC", function() require("dap").clear_breakpoints() end, desc = "DAP clear breakpoints", mode = "n" },
    { "<localleader>dr", function() require("dap").repl.toggle() end, desc = "DAP REPL toggle", mode = "n" },
    { "<localleader>dq", function() require("dap").terminate() end, desc = "DAP terminate", mode = "n" },

    { "<localleader>dd", function() require("dap").continue() end, desc = "DAP start/continue", mode = "n" },
    { "<localleader>dj", function() require("dap").step_over() end, desc = "DAP step over", mode = "n" },
    { "<localleader>dk", function() require("dap").step_into() end, desc = "DAP step into", mode = "n" },
    { "<localleader>dl", function() require("dap").step_out() end, desc = "DAP step out", mode = "n" },
    { "<localleader>de", function() require("dap").set_exception_breakpoints({ "raised", "uncaught" }) end, desc = "DAP break on exceptions", mode = "n" },
  },
}
