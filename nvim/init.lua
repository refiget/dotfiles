-- Early core keymaps (must be available before VeryLazy)
local map = vim.keymap.set
local opts = { silent = true, noremap = true }
map("n", "J", "5j", opts)
map("n", "K", "5k", opts)
map("x", "J", "5j", opts)
map("x", "K", "5k", opts)

-- Keep K/J behavior even if plugins/LSP try to claim K later
local function enforce_jk(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    pcall(vim.keymap.del, "n", "K", { buffer = buf })
    pcall(vim.keymap.del, "x", "K", { buffer = buf })
    pcall(vim.keymap.del, "n", "J", { buffer = buf })
    pcall(vim.keymap.del, "x", "J", { buffer = buf })
    vim.keymap.set("n", "J", "5j", { buffer = buf, silent = true, noremap = true })
    vim.keymap.set("n", "K", "5k", { buffer = buf, silent = true, noremap = true })
    vim.keymap.set("x", "J", "5j", { buffer = buf, silent = true, noremap = true })
    vim.keymap.set("x", "K", "5k", { buffer = buf, silent = true, noremap = true })
  end)
end

vim.api.nvim_create_autocmd({ "LspAttach", "FileType", "BufEnter" }, {
  callback = function(args)
    enforce_jk(args.buf)
  end,
})

require("config.lazy")
