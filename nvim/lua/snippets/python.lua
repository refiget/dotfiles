local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local snippets = {
  -- 触发词：doctest
  -- 用法：在 Python 文件里，插入模式输入 doctest 然后按 <Tab>（你当前的 LuaSnip 映射）
  s({
    trig = "doctest",
    wordTrig = false,  -- 不使用单词边界，允许在任何位置触发
  }, {
    t('if __name__ == "__main__":'),
    t({ "", "    import doctest" }),
    t({ "", "    doctest.testmod(verbose=" }),
    i(1, "True"),
    t(")"),
  }),
}

ls.add_snippets("python", snippets, { key = "python-custom" })
