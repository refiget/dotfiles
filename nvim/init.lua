-- =============================================================================
--
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
-- =============================================================================

do
	local fn = vim.fn

	-- Silence noisy Python SyntaxWarning from some tools.
	vim.env.PYTHONWARNINGS = "ignore::SyntaxWarning"

	-- Keep config macOS/local-focused; no SSH/server-specific branching.
	if fn.isdirectory(fn.getcwd()) == 0 then
		vim.cmd("cd ~")
	end

	local function detect_python_host()
		local candidates = {
			fn.expand("~/venvs/nvim/bin/python3"),
			fn.expand("~/.venvs/nvim/bin/python3"),
			"/usr/local/opt/python@3/bin/python3",
			"/opt/homebrew/bin/python3",
			"/usr/local/bin/python3",
			"/usr/bin/python3",
		}
		for _, path in ipairs(candidates) do
			if fn.executable(path) == 1 then
				return path
			end
		end
		return "python3"
	end

	vim.g.python3_host_prog = detect_python_host()

	local function prepend_path(dir)
		if not dir or dir == "" then
			return
		end
		if fn.isdirectory(dir) == 0 then
			return
		end
		local path = vim.env.PATH or ""
		if not path:find(dir, 1, true) then
			vim.env.PATH = dir .. ":" .. path
		end
	end

	local function latest_dir_by_mtime(dirs)
		local latest, latest_time = nil, -1
		for _, dir in ipairs(dirs) do
			local t = fn.getftime(dir)
			if t > latest_time then
				latest, latest_time = dir, t
			end
		end
		return latest
	end

	local function latest_nvm_bin()
		local base = fn.expand("~/.nvm/versions/node")
		if fn.isdirectory(base) == 0 then
			return nil
		end
		local dirs = fn.glob(base .. "/v*", 1, 1)
		if not dirs or #dirs == 0 then
			return nil
		end
		local latest = latest_dir_by_mtime(dirs)
		if not latest then
			return nil
		end
		local bin = latest .. "/bin"
		if fn.isdirectory(bin) == 1 then
			return bin
		end
		return nil
	end

	local function python_host_bin()
		local host = vim.g.python3_host_prog
		if host and fn.executable(host) == 1 then
			return fn.fnamemodify(host, ":h")
		end
		return nil
	end

	-- Prefer python host venv, then mason bin.
	prepend_path(python_host_bin())
	prepend_path(fn.stdpath("data") .. "/mason/bin")

	-- Common JS toolchains / shims.
	for _, dir in ipairs({
		"~/.npm-global/bin",
		"~/.npm/bin",
		"~/.yarn/bin",
		"~/Library/Yarn/bin",
		"~/Library/pnpm",
		"~/.local/share/pnpm",
		"~/.volta/bin",
		"~/.asdf/shims",
		"~/.local/share/mise/shims",
		"~/.mise/shims",
		"~/.local/share/fnm",
		"~/.fnm",
	}) do
		prepend_path(fn.expand(dir))
	end
	prepend_path(latest_nvm_bin())

	local function npm_global_bin()
		if fn.executable("npm") ~= 1 then
			return nil
		end
		local ok, out = pcall(fn.systemlist, { "npm", "bin", "-g" })
		if not ok or not out or not out[1] or out[1] == "" then
			return nil
		end
		return out[1]
	end

	local function pnpm_global_bin()
		if fn.executable("pnpm") ~= 1 then
			return nil
		end
		local ok, out = pcall(fn.systemlist, { "pnpm", "bin", "-g" })
		if not ok or not out or not out[1] or out[1] == "" then
			return nil
		end
		return out[1]
	end

	local function yarn_global_bin()
		if fn.executable("yarn") ~= 1 then
			return nil
		end
		local ok, out = pcall(fn.systemlist, { "yarn", "global", "bin" })
		if not ok or not out or not out[1] or out[1] == "" then
			return nil
		end
		return out[1]
	end

	prepend_path(npm_global_bin())
	prepend_path(pnpm_global_bin())
	prepend_path(yarn_global_bin())

	local function shell_command_path(bin)
		local shell = vim.env.SHELL or vim.o.shell or "sh"
		local ok, out = pcall(fn.systemlist, { shell, "-lc", "command -v " .. bin })
		if not ok or not out or not out[1] or out[1] == "" then
			return nil
		end
		return out[1]
	end

	local function ensure_bin_in_path(bin)
		if fn.executable(bin) == 1 then
			return
		end
		local path = shell_command_path(bin)
		if path and path ~= "" then
			prepend_path(fn.fnamemodify(path, ":h"))
		end
	end

	for _, bin in ipairs({
		"pyright-langserver",
		"vscode-json-language-server",
		"yaml-language-server",
		"typescript-language-server",
		"bash-language-server",
	}) do
		ensure_bin_in_path(bin)
	end
end

-- =============================================================================
--   ___        _   _
--  / _ \ _ __ | |_(_) ___  _ __  ___
-- | | | | '_ \| __| |/ _ \| '_ \/ __|
-- | |_| | |_) | |_| | (_) | | | \__ \
--  \___/| .__/ \__|_|\___/|_| |_|___/
--       |_|
-- =============================================================================

do
	local fn = vim.fn
	local opt = vim.opt

	opt.undolevels = 10000
	opt.undoreload = 10000
	opt.breakindent = true
	opt.linebreak = true
	opt.swapfile = false

	opt.exrc = true
	opt.secure = true

	opt.number = true
	opt.relativenumber = true

	-- Keep gutter width stable (avoid text shifting when diagnostics appear)
	opt.signcolumn = "yes"

	-- Focus cue on number column only.
	opt.cursorline = false

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

	-- Terminal/tmux friendly timeouts.
	opt.timeout = true
	opt.timeoutlen = 1000
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

	-- No extra bottom UI (tmux owns it).
	opt.ruler = false
	opt.showcmd = false

	-- Keep redraw timely (UI plugins may rely on it).
	opt.lazyredraw = false

	opt.visualbell = true
	opt.colorcolumn = "100"
	opt.re = 0

	opt.backupdir = fn.expand("$HOME/.config/nvim/tmp/backup,.")
	opt.directory = fn.expand("$HOME/.config/nvim/tmp/backup,.")

	-- Persistent undo files are stored in a local config directory:
	--   ~/.config/nvim/undo/
	-- (These files typically end with `.un~`.)
	do
		local undodir = fn.stdpath("config") .. "/undo"
		pcall(fn.mkdir, undodir, "p")
		opt.undodir = undodir
	end

	if fn.has("persistent_undo") == 1 then
		opt.undofile = true
	end

	vim.cmd("nohlsearch")
end

-- Clipboard / OSC52 (native)
do
	-- Keep default register logic; clipboard is provider-driven.
	vim.opt.clipboard = ""

	local function base64_encode(data)
		local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		return (
			(data:gsub(".", function(x)
				local r, byte = "", x:byte()
				for _ = 8, 1, -1 do
					r = r .. (byte % 2 ^ 1)
					byte = math.floor(byte / 2)
				end
				return r
			end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
				if #x < 6 then
					return ""
				end
				local c = 0
				for i = 1, 6 do
					c = c * 2 + x:sub(i, i)
				end
				return b:sub(c + 1, c + 1)
			end) .. ({ "", "==", "=" })[#data % 3 + 1]
		)
	end

	local function osc52_copy(lines, _)
		local data = table.concat(lines, "\n")
		local max = tonumber(vim.env.OSC52_MAX_BYTES or "100000") or 100000
		if max > 0 and #data > max then
			return
		end

		local esc = base64_encode(data)
		local osc = string.format("\x1b]52;c;%s\x07", esc)
		if vim.env.TMUX then
			osc = string.format("\x1bPtmux;\x1b%s\x1b\\", osc)
		end

		local tty = vim.env.TTY or "/dev/tty"
		local ok, fd = pcall(vim.loop.fs_open, tty, "w", 0)
		if ok and fd then
			vim.loop.fs_write(fd, osc, -1)
			vim.loop.fs_close(fd)
		else
			io.write(osc)
		end
	end

	local function osc52_paste()
		-- Cannot read system clipboard from remote terminal; fallback to default register.
		return vim.fn.split(vim.fn.getreg('"'), "\n")
	end

	local has_builtin_osc52 = vim.ui and vim.ui.clipboard and vim.ui.clipboard.osc52

	-- Optional: force OSC52 (terminal must support it)
	-- Usage: NVIM_CLIPBOARD_OSC52=1 nvim
	if vim.env.NVIM_CLIPBOARD_OSC52 == "1" then
		if has_builtin_osc52 then
			vim.g.clipboard = {
				name = "osc52",
				copy = {
					["+"] = vim.ui.clipboard.osc52.copy("+"),
					["*"] = vim.ui.clipboard.osc52.copy("*"),
				},
				paste = {
					["+"] = vim.ui.clipboard.osc52.paste("+"),
					["*"] = vim.ui.clipboard.osc52.paste("*"),
				},
				cache_enabled = 0,
			}
		else
			vim.g.clipboard = {
				name = "osc52",
				copy = { ["+"] = osc52_copy, ["*"] = osc52_copy },
				paste = { ["+"] = osc52_paste, ["*"] = osc52_paste },
				cache_enabled = 0,
			}
		end
	end
end

-- Unified highlight policy (native)
-- description --
-- content --
local function Crab_apply_highlights_policy()
	local function palette()
		local ok, p = pcall(function()
			return require("catppuccin.palettes").get_palette("mocha")
		end)
		if ok and p then
			return p
		end
		return {
			text = "#cdd6f4",
			base = "#1e1e2e",
			mantle = "#181825",
			surface0 = "#313244",
			surface1 = "#45475a",
			surface2 = "#585b70",
			overlay0 = "#6c7086",
			red = "#f38ba8",
			yellow = "#f9e2af",
			mauve = "#cba6f7",
		}
	end

	local p = palette()
	local bar_bg = "#1E1E2E"

	-- Floating windows (Noice/cmp/telescope/dap-ui/notify) should have a real background
	-- even when the main editor uses transparent background.
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = p.text, bg = p.base })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.surface2, bg = p.base })

	-- (Plugin-owned UI) Pmenu*/Notify highlights are configured in their plugin specs.

	-- Bars background (explicit, global)
	vim.api.nvim_set_hl(0, "StatusLine", { fg = p.text, bg = bar_bg })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = p.overlay0, bg = bar_bg })

	vim.api.nvim_set_hl(0, "WinBar", { fg = p.text, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarNC", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarMeta", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarPath", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarPathNC", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarFile", { fg = p.text, bg = bar_bg, bold = true })
	vim.api.nvim_set_hl(0, "WinBarFileNC", { fg = p.text, bg = bar_bg, bold = true })
	vim.api.nvim_set_hl(0, "WinBarDiagNone", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarDiagWarn", { fg = p.yellow, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarDiagErr", { fg = p.red, bg = bar_bg })
	vim.api.nvim_set_hl(0, "WinBarMod", { fg = p.mauve, bg = bar_bg, bold = true })

	vim.api.nvim_set_hl(0, "TabLine", { fg = p.overlay0, bg = bar_bg })
	vim.api.nvim_set_hl(0, "TabLineSel", { fg = p.text, bg = bar_bg, bold = true })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = bar_bg })

	vim.api.nvim_set_hl(0, "WinSeparator", { fg = p.surface0 })
	vim.api.nvim_set_hl(0, "VertSplit", { fg = p.surface0 })

	-- (Plugin-owned UI) DAP UI / Telescope border highlights live in their plugin specs.
end

-- Apply once now.
pcall(Crab_apply_highlights_policy)

-- IME / tmux / UI helpers (registered later in Autocmd section)
-- description --
-- content --
local Crab_setup_ime = function()
	if vim.loop.os_uname().sysname ~= "Darwin" then
		return
	end

	local switcher
	if vim.fn.executable("im-select") == 1 then
		switcher = { cmd = "im-select" }
	elseif vim.fn.executable("macism") == 1 then
		switcher = { cmd = "macism" }
	else
		return
	end

	local default_english = vim.env.NVIM_IME_DEFAULT_ENG or "com.apple.keylayout.ABC"
	local last_ime = nil

	local function current_ime()
		local out = vim.fn.systemlist({ switcher.cmd })
		return out[1] or ""
	end

	local function switch_im(mode)
		if mode == "insert" then
			if last_ime and last_ime ~= "" and last_ime ~= default_english then
				vim.fn.jobstart({ switcher.cmd, last_ime }, { detach = true })
			end
			return
		end

		local current = current_ime()
		if current ~= "" and current ~= default_english then
			last_ime = current
		end
		vim.fn.jobstart({ switcher.cmd, default_english }, { detach = true })
	end

	-- Start in English to avoid initial state mismatch.
	switch_im("normal")

	local group = vim.api.nvim_create_augroup("IMEAutoSwitch", { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			switch_im("insert")
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			switch_im("normal")
		end,
	})
end

local Crab_setup_tmux_mode_sync = function()
	local function set_tmux_mode(mode)
		if not vim.env.TMUX then
			return
		end
		local cmd = string.format(
			"tmux set-environment -g TMUX_MODE %s 2>/dev/null && tmux run-shell ~/.config/tmux/scripts/update_theme_color.sh",
			mode
		)
		vim.fn.jobstart({ "bash", "-lc", cmd }, { detach = true })
	end

	local group = vim.api.nvim_create_augroup("TmuxModeSync", { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			set_tmux_mode("insert")
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			set_tmux_mode("normal")
		end,
	})
end

-- UI / winbar (native)

local Crab_ui = {}

do
	local function is_normal_file_buf(bufnr)
		bufnr = bufnr or 0
		if vim.bo[bufnr].buftype ~= "" then
			return false
		end
		local ft = vim.bo[bufnr].filetype
		if ft == "" then
			return false
		end
		local deny = {
			["TelescopePrompt"] = true,
			["TelescopeResults"] = true,
			["NvimTree"] = true,
			["Trouble"] = true,
			["help"] = true,
			["lazy"] = true,
			["dapui_scopes"] = true,
			["dapui_stacks"] = true,
			["dapui_breakpoints"] = true,
			["dapui_watches"] = true,
			["dapui_console"] = true,
			["dap-repl"] = true,
		}
		return not deny[ft]
	end

	local function tmux_theme_color()
		local c = vim.env.TMUX_THEME_COLOR
		if type(c) == "string" and c:match("^#%x%x%x%x%x%x$") then
			return c
		end
		return "#b294bb"
	end

	local function diag_counts(bufnr)
		bufnr = bufnr or 0
		local c = vim.b[bufnr]._ui_diag_counts
		if c then
			return c
		end
		return { e = 0, w = 0 }
	end

	function Crab_ui.update_diag_cache(bufnr)
		bufnr = bufnr or 0
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		local diags = vim.diagnostic.get(bufnr)
		local e, w = 0, 0
		for _, d in ipairs(diags) do
			if d.severity == vim.diagnostic.severity.ERROR then
				e = e + 1
			elseif d.severity == vim.diagnostic.severity.WARN then
				w = w + 1
			end
		end
		vim.b[bufnr]._ui_diag_counts = { e = e, w = w }
	end

	function _G.Crab_winbar()
		if not is_normal_file_buf(0) then
			return ""
		end

		local name = vim.api.nvim_buf_get_name(0)
		if name == "" then
			return ""
		end

		local rel = vim.fn.fnamemodify(name, ":~:.")
		local tail = vim.fn.fnamemodify(rel, ":t")
		local head = rel:sub(1, #rel - #tail)

		local c = diag_counts(0)
		local diag_hl = "WinBarDiagNone"
		if (c.e or 0) > 0 then
			diag_hl = "WinBarDiagErr"
		elseif (c.w or 0) > 0 then
			diag_hl = "WinBarDiagWarn"
		end

		local modified = vim.bo.modified
		local diag_slot = (diag_hl == "WinBarDiagNone") and " ·" or " ●"
		local mod_slot = modified and " ●" or "  "

		local is_cur = (vim.api.nvim_get_current_win() == vim.g.statusline_winid)
		local hl_path = is_cur and "WinBarPath" or "WinBarPathNC"
		local hl_file = is_cur and "WinBarFile" or "WinBarFileNC"

		local left = string.format("%%#%s#%s%%#%s#%s", hl_path, head, hl_file, tail)
		local right = string.format("%%#WinBarMeta#│%%#%s#%s%%#WinBarMod#%s", diag_hl, diag_slot, mod_slot)

		return string.format(" %%<%s%%=%s %%#WinBar#", left, right)
	end

	function Crab_ui.apply_highlights()
		local accent = tmux_theme_color()

		-- Transparent background cohesion (tmux-style)
		vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })

		-- Winbar palette (Catppuccin Mocha-ish)
		local text = "#cdd6f4"
		local subtext1 = "#bac2de"
		local subtext0 = "#a6adc8"
		local overlay0 = "#6c7086"

		vim.api.nvim_set_hl(0, "WinBar", { fg = text })
		vim.api.nvim_set_hl(0, "WinBarNC", { fg = subtext0 })
		vim.api.nvim_set_hl(0, "WinBarMeta", { fg = overlay0 })

		vim.api.nvim_set_hl(0, "WinBarPath", { fg = subtext0 })
		vim.api.nvim_set_hl(0, "WinBarPathNC", { fg = overlay0 })

		vim.api.nvim_set_hl(0, "WinBarFile", { fg = text, bold = true })
		vim.api.nvim_set_hl(0, "WinBarFileNC", { fg = subtext1, bold = true })

		vim.api.nvim_set_hl(0, "WinBarDiagNone", { fg = overlay0 })
		vim.api.nvim_set_hl(0, "WinBarDiagWarn", { link = "DiagnosticWarn" })
		vim.api.nvim_set_hl(0, "WinBarDiagErr", { link = "DiagnosticError" })
		vim.api.nvim_set_hl(0, "WinBarMod", { fg = accent, bold = true })

		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent, bold = true })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

		vim.api.nvim_set_hl(0, "NonText", { fg = "#181825" })
		vim.api.nvim_set_hl(0, "Whitespace", { fg = "#181825" })
	end

	function Crab_ui.setup_static()
		-- Minimal chrome: let tmux own the persistent bottom UI.
		vim.opt.fillchars:append({
			vert = "│",
			horiz = "─",
			horizup = "┴",
			horizdown = "┬",
			vertleft = "┤",
			vertright = "├",
			verthoriz = "┼",
		})

		vim.opt.laststatus = 0
		vim.opt.showtabline = 0

		-- Use lua-powered winbar.
		vim.o.winbar = "%{%v:lua.Crab_winbar()%}"

		Crab_ui.apply_highlights()
	end
end

Crab_ui.setup_static()

-- =============================================================================
--  _  __
-- | |/ /___ _   _ _ __  ___
-- | ' // _ \ | | | '_ \/ __|
-- | . \  __/ |_| | |_) \__ \
-- |_|\_\___|\__, | .__/|___/
--           |___/|_|
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

-- Keep undo breakpoints for punctuation (insert mode)
for _, key in ipairs({ ",", ".", "!", "?", ";", ":" }) do
	keymap("i", key, key .. "<C-g>u", opts)
end

keymap("n", "s", "<nop>")

keymap("n", "<leader>l", "<C-w>l", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>h", "<C-w>h", opts)

keymap("t", "<C-N>", "<C-\\><C-N>", opts)

-- Delete/change behavior
keymap({ "n", "x" }, "d", "d", { silent = true })
keymap({ "n", "x" }, "D", "D", { silent = true })

keymap("n", "x", '"+x', { silent = true })
keymap("n", "X", '"+X', { silent = true })

keymap("n", "c", '"_c', { silent = true })
keymap("n", "C", '"_C', { silent = true })
keymap("x", "c", '"_c', { silent = true })
keymap("x", "C", '"_C', { silent = true })

-- Misc
keymap("n", "<leader>sw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Diagnostics keymaps are plugin-owned (LSP/diagnostics stack). Intentionally omitted for now.

-- Tabs (wrap)
-- description --
-- content --
local function tab_cycle(delta)
	local total = vim.fn.tabpagenr("$")
	if total <= 1 then
		return
	end
	local current = vim.fn.tabpagenr()
	local count = vim.v.count1
	local target = ((current - 1 + delta * count) % total) + 1
	vim.cmd("tabnext " .. target)
end

keymap("n", "gt", function()
	tab_cycle(1)
end, { silent = true, noremap = true, desc = "Tab next (wrap)" })

keymap("n", "gT", function()
	tab_cycle(-1)
end, { silent = true, noremap = true, desc = "Tab prev (wrap)" })

-- Run current Python file
-- description --
-- content --
local function run_python()
	vim.cmd("w")
	local file = vim.fn.expand("%")
	vim.cmd("botright 10split | term python3 " .. file)
end

keymap("n", "R", run_python, { silent = true, desc = "Run Python file" })

-- =============================================================================
--     _         _                        _
--    / \  _   _| |_ ___   ___ _ __ ___  | |__
--   / _ \| | | | __/ _ \ / __| '_ ` _ \ | '_ \
--  / ___ \ |_| | || (_) | (__| | | | | || |_) |
-- /_/   \_\__,_|\__\___/ \___|_| |_| |_||_.__/
-- =============================================================================

-- Markdown: save on mode change (if enabled by Typora flow)
vim.api.nvim_create_autocmd("ModeChanged", {
	group = vim.api.nvim_create_augroup("AutosaveMarkdownOnModeChange", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end
		if vim.bo.filetype ~= "markdown" then
			return
		end
		if vim.g.markdown_autosave_enabled == false then
			return
		end
		if not vim.bo.modified then
			return
		end
		if not vim.bo.modifiable or vim.bo.readonly then
			return
		end

		vim.cmd("silent! update")
	end,
})

-- Typora (Markdown UX)
-- description --
-- content --
do
	local function url_encode(text)
		return (text:gsub("([^%w%-_%.~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end))
	end

	local function open_in_typora()
		vim.cmd("w")
		local file = vim.fn.expand("%:p")

		local layout = vim.g.typora_rectangle_layout or "markdown"
		local url = "rectangle-pro://execute-layout?name=" .. url_encode(layout)

		-- enable autosave-on-mode-change (see AutosaveMarkdownOnModeChange)
		vim.g.markdown_autosave_enabled = true

		vim.fn.jobstart({ "open", "-a", "Typora", file }, { detach = true })
		vim.defer_fn(function()
			vim.fn.jobstart({ "open", url }, { detach = true })
			vim.fn.jobstart({ "yabai", "-m", "space", "--layout", "bsp" }, { detach = true })
		end, 200)
	end

	-- Typora keymap: buffer-local
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			keymap("n", "<localleader>t", open_in_typora, {
				buffer = true,
				silent = true,
				desc = "Typora: open + Rectangle layout",
			})
		end,
	})
end

-- Statusline policy for DAP UI is plugin-owned and lives in lua/plugins/debug/nvim_dap_ui.lua

-- Highlights policy: re-apply on colorscheme changes.
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		pcall(Crab_apply_highlights_policy)
		pcall(Crab_ui.apply_highlights)
	end,
})

-- UI: diagnostic cache
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter" }, {
	callback = function(args)
		local bufnr = (args and args.buf) or 0
		pcall(Crab_ui.update_diag_cache, bufnr)
	end,
})

-- UI: keep tmux accent in sync (re-apply only when changed)
-- description --
-- content --
do
	local last = vim.env.TMUX_THEME_COLOR or ""
	vim.fn.timer_start(2000, function()
		local cur = vim.env.TMUX_THEME_COLOR or ""
		if cur ~= last then
			last = cur
			pcall(Crab_ui.apply_highlights)
		end
	end, { ["repeat"] = -1 })
end

-- Enable IME + tmux mode sync
pcall(Crab_setup_ime)
pcall(Crab_setup_tmux_mode_sync)
