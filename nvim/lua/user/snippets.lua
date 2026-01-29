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

-- 补全/跳转按键由 cmp.lua 统一管理，避免重复映射
