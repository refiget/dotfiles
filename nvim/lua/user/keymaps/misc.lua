local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<leader>sw", ":set wrap!<CR>", { desc = "Toggle wrap" })
