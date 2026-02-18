local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<leader>sw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Diagnostics (float)
keymap("n", "<leader>e", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Diagnostics: float" })
