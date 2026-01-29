-- ===================== init.lua =====================
-- 只负责加载各模块，逻辑分散到 lua/user 下
require("user.core")
require("user.clipboard")
require("user.plugin_manager")
require("user.cmp")
require("user.keymaps")
require("user.snippets")
require("user.lsp_config")
require("user.treesitter_config")
require("user.tmux").setup_mode_sync()
require("user.ime").setup()
