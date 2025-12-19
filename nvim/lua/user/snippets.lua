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
  -- 如果coc补全可见，使用Tab选择下一项
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#next"](1)
  end
  -- 由于已经移除了coc-snippets，不再需要检查coc的snippet
  -- 否则，刷新coc补全
  return vim.fn["coc#refresh"]()
end, { silent = true, noremap = true, expr = true })

vim.keymap.set("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]],
  { silent = true, noremap = true, expr = true })

vim.keymap.set("i", "<C-Space>", "coc#refresh()", { silent = true, noremap = true, expr = true })
