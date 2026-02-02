-- ===================== init.lua =====================
-- 只负责加载各模块，逻辑分散到 lua 下的各目录
require("config")  -- Load the `init.lua` under `config`
require("config.lazy")
require("keymaps")
require("snippets")

local commit = {
	[[ the usage of `local M`
	- when we need to call certain function when files loading.
	- Use `funcion M.example_func()`  and `return M` to return a table.
	- Use `.example_func()` when `require`.
	]]
}

