-- Config module initialization
require("config.core")
require("config.clipboard")
require("config.options")
require("config.autocmds")
require("config.env")
require("config.ime").setup()
require("config.tmux").setup_mode_sync()
require("config.ui").setup()
