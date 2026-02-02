local keymap = vim.keymap.set
local opts = { silent = true }

local function run_python()
  vim.cmd("w")
  local file = vim.fn.expand("%")
  vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "R", run_python, { silent = true, desc = "Run Python file" })
