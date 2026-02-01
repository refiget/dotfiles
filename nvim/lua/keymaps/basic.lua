vim.g.mapleader = " "
vim.g.maplocalleader = ","
local keymap = vim.keymap.set
local opts = { silent = true, noremap = true }

keymap("n", ";", ":", { desc = "Command mode" })
keymap("n", "Q", ":q<CR>", opts)
keymap("n", "Y", '"+yy', opts)
keymap("v", "Y", '"+y', opts)
keymap("n", "<leader><CR>", ":nohlsearch<CR>", opts)

keymap("n", "J", "5j", opts)
keymap("n", "K", "5k", opts)
keymap("x", "J", "5j", opts)
keymap("x", "K", "5k", opts)

for _, key in ipairs({ ",", ".", "!", "?", ";", ":" }) do
  keymap("i", key, key .. "<C-g>u", opts)
end

keymap("n", "s", "<nop>")

keymap("n", "<leader>l", "<C-w>l", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>h", "<C-w>h", opts)

keymap("t", "<C-N>", "<C-\\><C-N>", opts)
