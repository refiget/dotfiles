-- ===================== options.lua =====================
local fn = vim.fn
local opt = vim.opt

opt.undolevels = 10000
opt.undoreload = 10000
opt.breakindent = true
opt.linebreak = true
opt.swapfile = false
-- UI is configured in config/ui.lua (minimal chrome + lua winbar)
opt.exrc = true
opt.secure = true
opt.number = true
opt.relativenumber = true

-- Keep gutter width stable (avoid text shifting when diagnostics appear)
opt.signcolumn = "yes"
-- Keep focus cue on the number column; avoid a full-line highlight block
opt.cursorline = false
opt.expandtab = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.autoindent = true
opt.list = true
-- Keep listchars subtle to match tmux's low-chrome UI
opt.listchars = { tab = "| ", trail = "·" }

-- Hide the tildes (~) on empty lines (end-of-buffer filler)
opt.fillchars:append({ eob = " " })
opt.scrolloff = 4
-- Key sequence timeouts: keep terminal ESC/Meta sequences reliable (tmux friendly)
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeoutlen = 25
opt.viewoptions = { "cursor", "folds", "slash", "unix" }
opt.wrap = true
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.completeopt = { "menuone", "noselect" }
opt.updatetime = 100
opt.virtualedit = "block"
opt.inccommand = "split"
opt.showmode = false
opt.lazyredraw = true
opt.visualbell = true
opt.colorcolumn = "100"
opt.re = 0

opt.backupdir = fn.expand("$HOME/.config/nvim/tmp/backup,.")
opt.directory = fn.expand("$HOME/.config/nvim/tmp/backup,.")
opt.undodir = fn.expand("$HOME/.config/nvim/tmp/undo,.")

if fn.has("persistent_undo") == 1 then
  opt.undofile = true
end

vim.cmd("nohlsearch")
