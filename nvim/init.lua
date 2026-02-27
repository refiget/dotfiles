-- =============================================================================
--   ____        _     _         _   _ _   _ __  __
--  | __ )  ___ | |__ ( )___    | \ | | \ | |  \/  |
--  |  _ \ / _ \| '_ \|// __|   |  \| |  \| | |\/| |
--  | |_) | (_) | |_) | \__ \   | |\  | |\  | |  | |
--  |____/ \___/|_.__/  |___/   |_| \_|_| \_|_|  |_|
--
-- =============================================================================
-- Neovim entrypoint.

vim.opt.termguicolors = true
require("config.lazy")

-- =============================================================================
--  _____
-- | ____|_ ____   __
-- |  _| | '_ \ \ / /
-- | |___| | | \ V /
-- |_____|_| |_|\_/
--
-- =============================================================================

do
	local fn = vim.fn
	local nvim_python_path = fn.expand("~/venvs/nvim/bin/python3") -- expand to the abs path according to OS

	-- = `vim.g.python3_host_prog` is the python provider of nvim. =
	-- = use `:checkhealth provider` to check the provider path(nvim venv path)
	vim.g.python3_host_prog = nvim_python_path
end

-- =============================================================================
--   ___        _   _
--  / _ \ _ __ | |_(_) ___  _ __  ___
-- | | | | '_ \| __| |/ _ \| '_ \/ __|
-- | |_| | |_) | |_| | (_) | | | \__ \
--  \___/| .__/ \__|_|\___/|_| |_|___/
--       |_|
--
-- =============================================================================

do
	local fn = vim.fn
	local opt = vim.opt

	opt.number = true
	opt.relativenumber = true

	-- Keep gutter width stable (avoid text shifting when diagnostics appear)
	opt.signcolumn = "yes"

	-- Focus cue on number column only.
	opt.cursorline = true

	opt.expandtab = false
	opt.tabstop = 2
	opt.shiftwidth = 2
	opt.softtabstop = 2
	opt.autoindent = true

	opt.list = true
	opt.listchars = { tab = "| ", trail = "·" }

	-- Hide end-of-buffer tildes.
	opt.fillchars:append({ eob = " " })

	-- Keep at least N lines visible above/below the cursor.
	vim.o.scrolloff = 5

	opt.splitbelow = true
	opt.splitright = true

	opt.ignorecase = true
	opt.smartcase = true

	opt.completeopt = { "menuone", "noselect" }

	opt.updatetime = 100
	opt.virtualedit = "block"
	opt.inccommand = "split"
	opt.showmode = false

	opt.backupdir = fn.expand("$HOME/.config/nvim/tmp/backup,.")
	opt.directory = fn.expand("$HOME/.config/nvim/tmp/backup,.")

	-- Persist undo files in Neovim state dir (clean + centralized).
	-- e.g. ~/.local/state/nvim/undo (Linux) / ~/Library/... on macOS
	do
		local undodir = vim.fn.stdpath("state") .. "/undo"
		pcall(vim.fn.mkdir, undodir, "p")
		opt.undodir = undodir
		opt.undofile = true
	end

	vim.cmd("nohlsearch")
end

-- UI
require("core.ui").setup()

-- =============================================================================
--  ____  _   _  ___  ____ _____ ____ _   _ _____ ____
-- / ___|| | | |/ _ \|  _ \_   _/ ___| | | |_   _/ ___|
-- \___ \| |_| | | | | |_) || || |   | | | | | | \___ \
--  ___) |  _  | |_| |  _ < | || |___| |_| | | |  ___) |
-- |____/|_| |_|\___/|_| \_\|_| \____|\___/  |_| |____/
-- =============================================================================

local keymap = vim.keymap.set
local opts = { silent = true, noremap = true }

-- Basic
keymap("n", ";", ":", { desc = "Command mode" })
keymap("n", "Q", ":q<CR>", opts)
keymap("n", "Y", '"+yy', opts)
keymap("v", "Y", '"+y', opts)
keymap("n", "<leader><CR>", ":nohlsearch<CR>", opts)

keymap("n", "J", "5j", opts)
keymap("n", "K", "5k", opts)
keymap("x", "J", "5j", opts)
keymap("x", "K", "5k", opts)

-- Surround a word by brackets (, [, or (}.)
-- keymap("n", "<leader>b", "bi(<ESC>ea)<ESC>", opts)

keymap("n", "s", "<nop>")

keymap("n", "<leader>l", "<C-w>l", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>h", "<C-w>h", opts)

keymap("t", "<C-N>", "<C-\\><C-N>", opts)

-- == Run current Python file ==
local function run_python()
	vim.cmd("w")
	local file = vim.fn.expand("%") -- "%": path of current file
	vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "R", run_python, { silent = true, desc = "Run Python file" })

-- =============================================================================
--     _         _                           _
--    / \  _   _| |_ ___   ___ _ __ ___   __| |
--   / _ \| | | | __/ _ \ / __| '_ ` _ \ / _` |
--  / ___ \ |_| | || (_) | (__| | | | | | (_| |
-- /_/   \_\__,_|\__\___/ \___|_| |_| |_|\__,_|
-- =============================================================================

-- Restore cursor to last edit position (official-style BufReadPost recipe).
local RESTORE_CURSOR_SKIP_FT = { gitcommit = true, gitrebase = true, svn = true, hgcommit = true }

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("RestoreLastCursorPosition", { clear = true }),
	callback = function()
		if vim.bo.buftype ~= "" or RESTORE_CURSOR_SKIP_FT[vim.bo.filetype] then
			return
		end

		local last = vim.fn.line([['"]])
		if last > 1 and last <= vim.fn.line("$") then
			vim.schedule(function()
				pcall(vim.cmd, [[normal! g`"]])
			end)
		end
	end,
})
