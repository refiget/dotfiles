-- rcarriga/nvim-dap-ui

return {
	"rcarriga/nvim-dap-ui",
	lazy = false,
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	keys = {
		{
			"<localleader>du",
			function()
				require("dapui").open()
				if vim.bo.filetype == "python" and type(_G.Crab_dap_python_launch_current) == "function" then
					_G.Crab_dap_python_launch_current()
				else
					require("dap").continue()
				end
			end,
			desc = "DAP UI open + start debug",
			mode = "n",
		},
	},

	config = function()
		local ok_dap, dap = pcall(require, "dap")
		local ok_ui, dapui = pcall(require, "dapui")
		if not ok_dap or not ok_ui then
			return
		end

		dapui.setup({
			expand_lines = true,
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			icons = {
				expanded = "▾",
				collapsed = "▸",
				current_frame = "▶",
			},
			controls = { enabled = false },
			layouts = {
				{
					position = "right",
					size = 34,
					elements = {
						{ id = "scopes", size = 0.7 },
						{ id = "stacks", size = 0.3 },
					},
				},
				{
					position = "bottom",
					size = 9,
					elements = {
						{ id = "console", size = 1.0 },
					},
				},
			},
			windows = { indent = 1 },
			indent_lines = false,
			render = {
				max_type_length = 30,
				max_value_lines = 50,
			},
		})

		local function apply_dapui_hl()
			vim.api.nvim_set_hl(0, "DapUIFloatBorder", { link = "FloatBorder" })
			vim.api.nvim_set_hl(0, "DapUIBorder", { link = "FloatBorder" })
			vim.api.nvim_set_hl(0, "DapUIValue", { link = "Normal" })
			vim.api.nvim_set_hl(0, "DapUIVariable", { link = "Normal" })
			vim.api.nvim_set_hl(0, "DapUIType", { link = "Type" })
			vim.api.nvim_set_hl(0, "DapUIModifiedValue", { link = "DiagnosticWarn" })
			vim.api.nvim_set_hl(0, "DapUIStoppedThread", { link = "DiagnosticError" })
			vim.api.nvim_set_hl(0, "DapUIStoppedThreadText", { link = "DiagnosticError" })
			vim.api.nvim_set_hl(0, "DapUIFrameName", { link = "Normal" })
			vim.api.nvim_set_hl(0, "DapUISource", { link = "Comment" })
			vim.api.nvim_set_hl(0, "DapUILineNumber", { link = "LineNr" })
			vim.api.nvim_set_hl(0, "DapUISeparator", { link = "WinSeparator" })
			vim.api.nvim_set_hl(0, "DapUISeparatorActive", { link = "WinSeparator" })
		end

		apply_dapui_hl()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				pcall(apply_dapui_hl)
			end,
		})

		-- Keep statusline hidden globally.
		vim.opt.laststatus = 0

		-- Close DAP UI automatically when debugging ends.
		dap.listeners.before.event_terminated["dapui_auto_close"] = function()
			pcall(dapui.close)
		end
		dap.listeners.before.event_exited["dapui_auto_close"] = function()
			pcall(dapui.close)
		end
		dap.listeners.before.disconnect["dapui_auto_close"] = function()
			pcall(dapui.close)
		end
	end,
}
