return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("config.lsp")
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    keys = {
      { "gd", "<cmd>Lspsaga goto_definition<CR>", desc = "Go to definition", mode = "n" },
      { "gi", "<cmd>Lspsaga goto_implementation<CR>", desc = "Go to implementation", mode = "n" },
      { "gr", "<cmd>Lspsaga lsp_finder<CR>", desc = "Go to references", mode = "n" },
      { "<leader>K", "<cmd>Lspsaga hover_doc<CR>", desc = "Show hover information", mode = "n" },
      { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code action", mode = "n" },
      { "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Show line diagnostics", mode = "n" },
      { "cr", "<cmd>Lspsaga rename<CR>", desc = "Rename with LSP", mode = "n" },
    },
    config = function()
      local ok, lspsaga = pcall(require, "lspsaga")
      if not ok then
        return
      end
      lspsaga.setup({
        lightbulb = {
          enable = false,
          sign = false,
          virtual_text = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
        ui = {
          border = "rounded",
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    event = "LspAttach",
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<CR>", desc = "Toggle trouble", mode = "n" },
    },
    config = function()
      local ok, trouble = pcall(require, "trouble")
      if not ok then
        return
      end
      trouble.setup({})
    end,
  },
}
