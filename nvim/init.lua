-- Early core keymaps (must be available before VeryLazy)
local map = vim.keymap.set
local opts = { silent = true, noremap = true }
map("n", "J", "5j", opts)
map("n", "K", "5k", opts)
map("x", "J", "5j", opts)
map("x", "K", "5k", opts)

require("config.lazy")
