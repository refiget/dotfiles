-- folke/trouble.nvim

return {
	"folke/trouble.nvim",
	event = "LspAttach",

	keys = {},

	config = function()
		require("trouble").setup(require("core.lsp_ui_config").trouble)
	end,
}
