local keymap = vim.keymap.set
local opts = { silent = true }

local function run_python()
  vim.cmd("w")
  local file = vim.fn.expand("%")
  vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "r", run_python, { silent = true, desc = "Run Python file" })

-- Molten-nvim keybindings (lazy-loaded)
local function setup_molten_keymaps()
  local ok, molten = pcall(require, "molten")
  if not ok then
    return
  end
  
  keymap("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten" })
  keymap("n", "<localleader>e", molten.evaluate_operator, { desc = "Evaluate operator" })
  keymap("n", "<localleader>rl", molten.evaluate_line, { desc = "Evaluate current line" })
  keymap("n", "<localleader>rr", molten.reevaluate_cell, { desc = "Re-evaluate last cell" })
  keymap("v", "<localleader>r", molten.evaluate_selection, { desc = "Evaluate selection" })
  keymap("n", "<localleader>oh", molten.hide_output, { desc = "Hide output" })
  keymap("n", "<localleader>os", molten.show_output, { desc = "Show output" })
end

-- Setup molten keymaps when the plugin is loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(args)
    if args.data == "molten-nvim" then
      setup_molten_keymaps()
    end
  end,
})
