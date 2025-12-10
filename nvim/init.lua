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
local function feedkeys(keys, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode or "", true)
end

local function check_backspace()
  local col = vim.fn.col(".") - 1
  return col <= 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- Tab 优先 Luasnip，其次 coc 补全，可回退缩进
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if ls.expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#confirm"]()
  end
  if not check_backspace() then
    vim.fn["coc#refresh"]()
    return ""
  end
  return "<Tab>"
end, { silent = true, noremap = true, expr = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#prev"](1)
  end
  if ls.jumpable(-1) then
    return "<Plug>luasnip-jump-prev"
  end
  return "<S-Tab>"
end, { silent = true, noremap = true, expr = true })




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

