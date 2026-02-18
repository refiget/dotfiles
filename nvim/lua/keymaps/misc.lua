local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<leader>sw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Diagnostics (float)
-- Keep <leader>e for nvim-tree.
keymap("n", "<leader>ld", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Diagnostics: float" })
