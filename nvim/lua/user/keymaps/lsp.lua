local keymap = vim.keymap.set

keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true, desc = "Go to definition" })
keymap("n", "gi", "<cmd>Lspsaga goto_implementation<CR>", { silent = true, desc = "Go to implementation" })
keymap("n", "gr", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, desc = "Go to references" })
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true, desc = "Show hover information" })
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Code action" })
keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, desc = "Show line diagnostics" })
keymap("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { silent = true, desc = "Toggle trouble" })
keymap("n", "cr", "<cmd>Lspsaga rename<CR>", { silent = true, desc = "Rename with LSP" })

vim.keymap.set(
  "n",
  "<leader>f",
  function()
    vim.lsp.buf.format({ async = true })
  end,
  { silent = true, noremap = true, desc = "Format document with LSP" }
)
