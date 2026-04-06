-- Early core keymaps (must be available before VeryLazy)
local map = vim.keymap.set
local opts = { silent = true, noremap = true }
map("n", "J", "5j", opts)
map("n", "K", "5k", opts)
map("x", "J", "5j", opts)
map("x", "K", "5k", opts)

-- Keep K/J behavior even after LSP buffer-local mappings attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local b = args.buf
    vim.keymap.set("n", "J", "5j", { buffer = b, silent = true, noremap = true })
    vim.keymap.set("n", "K", "5k", { buffer = b, silent = true, noremap = true })
    vim.keymap.set("x", "J", "5j", { buffer = b, silent = true, noremap = true })
    vim.keymap.set("x", "K", "5k", { buffer = b, silent = true, noremap = true })
  end,
})

require("config.lazy")
