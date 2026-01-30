local keymap = vim.keymap.set
local opts = { silent = true }

local function run_python()
  vim.cmd("w")
  local file = vim.fn.expand("%")
  vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "r", run_python, { silent = true, desc = "Run Python file" })

-- Molten-nvim keybindings
keymap("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten" })
keymap("n", "<localleader>e", require("molten").evaluate_operator, { desc = "Evaluate operator" })
keymap("n", "<localleader>rl", require("molten").evaluate_line, { desc = "Evaluate current line" })
keymap("n", "<localleader>rr", require("molten").reevaluate_cell, { desc = "Re-evaluate last cell" })
keymap("v", "<localleader>r", require("molten").evaluate_selection, { desc = "Evaluate selection" })
keymap("n", "<localleader>oh", require("molten").hide_output, { desc = "Hide output" })
keymap("n", "<localleader>os", require("molten").show_output, { desc = "Show output" })
