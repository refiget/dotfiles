-- ===================== snippets.lua =====================
-- LuaSnip 初始化与按键
local ok, ls = pcall(require, "luasnip")
if not ok then
  print("LuaSnip not found — did you run :Lazy sync?")
  return
end

ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
})

-- 直接导入snippet文件，使用vim.fn.expand处理~符号
local snippet_dir = vim.fn.expand("~/dotfiles/nvim/lua/snippets")
dofile(snippet_dir .. "/python.lua")
dofile(snippet_dir .. "/markdown.lua")
require("luasnip.loaders.from_vscode").lazy_load()

vim.keymap.set("i", "<Tab>", function()
  -- 优先检查LuaSnip的snippet
  if ls.expand_or_jumpable() then
    return "<Plug>luasnip-expand-or-jump"
  end
  -- 检查nvim-cmp补全是否可见
  local cmp = require("cmp")
  if cmp.visible() then
    return cmp.mapping.confirm({ select = true })
  end
  -- 否则返回Tab
  return "\t"
end, { silent = true, noremap = true, expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  -- 检查LuaSnip是否可以跳回
  if ls.jumpable(-1) then
    return "<Plug>luasnip-jump-prev"
  end
  -- 检查nvim-cmp补全是否可见
  local cmp = require("cmp")
  if cmp.visible() then
    cmp.select_prev_item()
    return ""
  end
  -- 否则返回C-h
  return "\b"
end, { silent = true, noremap = true, expr = true })

vim.keymap.set("i", "<C-Space>", function()
  local cmp = require("cmp")
  cmp.complete()
  return ""
end, { silent = true, noremap = true, expr = true })

