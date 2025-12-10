-- ===================== init.lua =====================
-- === Load Core Modules ===
require("user.core")
require("user.plugins")
require("user.keymaps")

-- === Coc Extensions (auto-install) ===
vim.g.coc_global_extensions = {
  "coc-pyright",
  "coc-json",
  "coc-tsserver",
}
-- === LuaSnip Setup ===
-- Load LuaSnip safely
local ok, ls = pcall(require, "luasnip")
if not ok then
  print("LuaSnip not found — did you run :PlugInstall?")
  return
end

-- LuaSnip global configuration
ls.config.set_config({
  history = true,                         -- keep last snippet for jumping
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
})


-- === Load Snippets ===
-- Load your custom Lua snippets (in dotfiles)
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/dotfiles/nvim/lua/snippets" })
-- Load friendly-snippets (community snippets)
require("luasnip.loaders.from_vscode").lazy_load()

-- === Keymaps for Snippet Expansion ===
-- Tab for expand/jump; fallback to indent when no snippet/ completion
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  -- Luasnip expansion/jump takes priority
  if ls.expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  -- coc completion confirm if popup visible
  local pumvisible = vim.fn.pumvisible() == 1
  if pumvisible then
    return vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
  end
  -- trigger coc completion when there are words before cursor
  if has_words_before() then
    return vim.api.nvim_replace_termcodes("<C-Space>", true, true, true)
  end
  return "<Tab>"
end, { expr = true, silent = true, noremap = true })




-- 尝试使用内置的 osc52
local function paste()
  return {
    vim.fn.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype('')
  }
end

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste,
  },
}
vim.opt.clipboard = "unnamedplus"
vim.g.coc_global_extensions = {
  "coc-pyright",
  "coc-json",
  "coc-yaml",
  "coc-tsserver",
  "coc-sh",
  "coc-snippets"
}

