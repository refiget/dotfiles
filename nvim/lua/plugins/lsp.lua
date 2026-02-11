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
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvimtools/none-ls-extras.nvim" },
    config = function()
      local ok, null_ls = pcall(require, "null-ls")
      if not ok then
        return
      end
      local sources = {}
      local function has_exec(bin)
        return vim.fn.executable(bin) == 1
      end
      if has_exec("black") and null_ls.builtins.formatting.black then
        table.insert(sources, null_ls.builtins.formatting.black)
      end
      if has_exec("stylua") and null_ls.builtins.formatting.stylua then
        table.insert(sources, null_ls.builtins.formatting.stylua)
      end
      -- flake8 disabled: too noisy for formatting/style (e.g., blank-line complaints)
      -- If you want it back, re-enable here or use ruff with a curated rule set.
      null_ls.setup({
        sources = sources,
      })
    end,
  },
}
