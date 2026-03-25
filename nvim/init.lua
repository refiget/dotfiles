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

	opt.updatetime = 100 -- hover 100 ms to show the  LSP menu
	opt.virtualedit = "block" -- enable us to move to blank arae
	opt.inccommand = "split" -- when using subtitute CMD, we can preview the outcome in the bottom(split)
	opt.showmode = false -- show the INSERT/NORMAL mode

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
--
--  Leader key : space
--  Local Leader : ,
--  `:verbose nmap <leader>b` to check the binding of `<leader>b`

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

keymap("n", "<C-g>", ":echo line('.') col('.')<CR>", opts)

-- Surround a word by brackets (, [, or (}.)
keymap("n", "<leader>(", "bi(<ESC>ea)<ESC>", opts)
keymap("n", "<leader>[", "bi[<ESC>ea]<ESC>", opts)
keymap("n", "<leader>{", "bi{<ESC>ea}<ESC>", opts)

keymap("n", "s", "<nop>")

keymap("n", "<leader>l", "<C-w>l", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>h", "<C-w>h", opts)

keymap("t", "<C-N>", "<C-\\><C-N>", opts)

-- == Run current file (Python/Java) ==
local function shellescape(v)
	return vim.fn.shellescape(v)
end

local function open_run_term(cmd)
	vim.cmd("botright 10split")
	if type(cmd) == "table" then
		vim.fn.termopen(cmd)
	else
		vim.fn.termopen(cmd)
	end
	vim.cmd("startinsert")
end

local function detect_java_root()
	local markers = { "conf.json", ".nvim-java.json", ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }
	local here = vim.fn.expand("%:p:h")
	local found = vim.fs.find(markers, { upward = true, path = here })[1]
	if found and found ~= "" then
		return vim.fs.dirname(found)
	end
	return vim.fn.getcwd()
end

local function run_python()
	vim.cmd("w")
	local file = vim.fn.expand("%:p")
	open_run_term({ "python3", file })
end

local function run_java()
	vim.cmd("w")
	local ok, project_cfg = pcall(require, "java.project_config")
	if not ok then
		vim.notify("java.project_config 未加载", vim.log.levels.ERROR)
		return
	end

	local root = detect_java_root()
	local cfg = project_cfg.load(root)
	local out_dir = root .. "/" .. (cfg.outputPath or "out")
	local main_class = cfg.mainClass
	if not main_class or main_class == "" then
		vim.notify("请先在 conf.json 配置 mainClass", vim.log.levels.WARN)
		return
	end

	local java_home = project_cfg.expand_path(cfg.jdkHome)
	local javac_bin = "javac"
	local java_bin = "java"
	if java_home and java_home ~= "" then
		local j = java_home .. "/bin/java"
		local c = java_home .. "/bin/javac"
		if vim.fn.executable(j) == 1 then
			java_bin = j
		end
		if vim.fn.executable(c) == 1 then
			javac_bin = c
		end
	end

	local cp_items = { out_dir }
	for _, pattern in ipairs(cfg.referencedLibraries or {}) do
		local expanded = project_cfg.expand_path(pattern)
		for _, jar in ipairs(vim.fn.glob(expanded, true, true)) do
			table.insert(cp_items, jar)
		end
	end
	local cp = table.concat(cp_items, ":")

	local src_parts = {}
	for _, p in ipairs(cfg.sourcePaths or {}) do
		table.insert(src_parts, shellescape(root .. "/" .. p))
	end
	local src_join = table.concat(src_parts, " ")

	local find_cmd = "find " .. src_join .. " -type f -name '*.java'"
	local script = table.concat({
		"cd " .. shellescape(root),
		"mkdir -p " .. shellescape(out_dir),
		"if ! " .. find_cmd .. " 2>/dev/null | grep -q .; then echo 'No Java sources found'; exit 1; fi",
		find_cmd .. " -print0 2>/dev/null | xargs -0 " .. shellescape(javac_bin) .. " -encoding UTF-8 -d " .. shellescape(out_dir) .. " -cp " .. shellescape(cp),
		shellescape(java_bin) .. " -cp " .. shellescape(cp) .. " " .. shellescape(main_class),
	}, "\n")

	open_run_term({ "zsh", "-lc", script })
end

local function run_current()
	local ft = vim.bo.filetype
	if ft == "python" then
		return run_python()
	elseif ft == "java" then
		return run_java()
	end
	vim.notify("当前文件类型暂不支持 R 运行: " .. ft, vim.log.levels.INFO)
end

keymap("n", "R", run_current, { silent = true, desc = "Run current file" })

-- vim.fn.getpos("'<")   to get the position of begining of Selected words
-- vim.fn.getpos("'>")  to get the position of end of Selected words
-- return {0, line, col, off}  0: for current windows
-- vim.api.nvim_win_set_cursor(0, {line, col}) move the cursor to the position

-- keymap('v', '<leader>b', function ()
-- 	begin_point_group = vim.fn.getpos("'<")
-- 	end_point_group = vim.fn.getpos("'>")
-- 	begin_point_line = begin_point_group[1]
-- 	begin_point_col = begin_point_group[2]
-- 	end_point_line = end_point_group[1]
-- 	end_point_col = end_point_group[2]
-- 	vim.api.nvim_win_set_cursor(0, {begin_point_line, begin_point_col})
-- 	vim.api.nvim_feedkeys(
--   vim.api.nvim_replace_termcodes("i(<Esc>", true, false, true),
--   "n",
--   true
-- )
-- 	vim.api.nvim_win_set_cursor(0, {end_point_line, end_point_col})
--   vim.api.nvim_replace_termcodes("a)<Esc>", true, false, true),
--   "n",
--   true
-- )
--
--
-- end

-- =============================================================================
--     _         _                           _
--    / \  _   _| |_ ___   ___ _ __ ___   __| |
--   / _ \| | | | __/ _ \ / __| '_ ` _ \ / _` |
--  / ___ \ |_| | || (_) | (__| | | | | | (_| |
-- /_/   \_\__,_|\__\___/ \___|_| |_| |_|\__,_|
-- =============================================================================

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
