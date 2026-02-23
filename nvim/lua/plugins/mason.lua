-- williamboman/mason.nvim

return {
	"williamboman/mason.nvim",
	cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },

	keys = {
		{ "<leader>m", "<cmd>Mason<CR>", desc = "Mason", mode = "n" },
	},

	config = function()
		local ok, mason = pcall(require, "mason")
		if not ok then
			return
		end
		mason.setup({
			ui = {
				border = "rounded",
			},
		})
	end,
}
