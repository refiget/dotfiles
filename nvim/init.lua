-- ===================== init.lua =====================
-- 只负责加载各模块，逻辑分散到 lua 下的各目录
require("config")
require("user.plugin_manager")
require("plugin_config")
require("keymaps")
require("snippets")
require("config.tmux").setup_mode_sync()
require("config.ime").setup()

