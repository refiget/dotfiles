-- glepnir/lspsaga.nvim

return {
	"glepnir/lspsaga.nvim",
	event = "LspAttach",

	keys = {},

	config = function()
		require("lspsaga").setup(require("core.lsp_ui_config").lspsaga)
	end,
}
