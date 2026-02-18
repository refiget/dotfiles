-- Config module initialization
require("config.core")
require("config.clipboard")
require("config.options")
require("config.autocmds")
require("config.env")

-- UI highlight policy (must load before UI modules that link groups)
require("config.highlights").setup()

require("config.ime").setup()
require("config.tmux").setup_mode_sync()
require("config.ui").setup()
