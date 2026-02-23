-- mfussenegger/nvim-dap-python

local fn = vim.fn

local function exists(path)
	return path and path ~= "" and fn.filereadable(path) == 1
end

local function current_python()
	local venv = vim.env.VIRTUAL_ENV
	if venv and venv ~= "" then
		local p = venv .. "/bin/python"
		if exists(p) then
			return p
		end
		p = venv .. "/bin/python3"
		if exists(p) then
			return p
		end
	end

	return vim.g.python3_host_prog or "python3"
end

local function debugpy_adapter_python()
	local mason_py = fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
	if exists(mason_py) then
		return mason_py
	end
	return current_python()
end

return {
	"mfussenegger/nvim-dap-python",
	ft = "python",
	dependencies = { "mfussenegger/nvim-dap" },

	keys = {
		{
			"<localleader>df",
			function()
				_G.Crab_dap_python_launch_current()
			end,
			desc = "DAP: debug current file (Python)",
			mode = "n",
		},
		{
			"<localleader>dt",
			function()
				require("dap-python").test_method()
			end,
			desc = "DAP: debug pytest method",
			mode = "n",
		},
		{
			"<localleader>dT",
			function()
				require("dap-python").test_class()
			end,
			desc = "DAP: debug pytest class",
			mode = "n",
		},
	},

	config = function()
		local ok, dap_python = pcall(require, "dap-python")
		if not ok then
			return
		end

		_G.Crab_dap_python_launch_current = function()
			require("dap").run({
				type = "python",
				request = "launch",
				name = "Launch current file",
				program = fn.expand("%:p"),
				cwd = fn.getcwd(),
				pythonPath = current_python(),
				justMyCode = true,
				console = "integratedTerminal",
			})
		end

		dap_python.setup(debugpy_adapter_python())
	end,
}
