local keymap = vim.keymap.set
local opts = { silent = true }

keymap({ "n", "x" }, "d", "d", opts)
keymap({ "n", "x" }, "D", "D", opts)

keymap("n", "x", '"_x', opts)
keymap("n", "X", '"_X', opts)

keymap("n", "c", '"_c', opts)
keymap("n", "C", '"_C', opts)
keymap("x", "c", '"_c', opts)
keymap("x", "C", '"_C', opts)
