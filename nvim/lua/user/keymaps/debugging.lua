local keymap = vim.keymap.set

keymap("n", "<F5>", function() require("dap").continue() end, { silent = true, desc = "DAP continue" })
keymap("n", "<F10>", function() require("dap").step_over() end, { silent = true, desc = "DAP step over" })
keymap("n", "<F11>", function() require("dap").step_into() end, { silent = true, desc = "DAP step into" })
keymap("n", "<F12>", function() require("dap").step_out() end, { silent = true, desc = "DAP step out" })
keymap("n", "<F9>", function() require("dap").toggle_breakpoint() end, { silent = true, desc = "DAP toggle breakpoint" })
keymap("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { silent = true, desc = "DAP conditional breakpoint" })
keymap("n", "<leader>dr", function() require("dap").repl.toggle() end, { silent = true, desc = "DAP REPL" })
keymap("n", "<leader>du", function() require("dapui").toggle() end, { silent = true, desc = "DAP UI toggle" })
