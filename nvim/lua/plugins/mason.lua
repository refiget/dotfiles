return {
  {
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
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local ok, mlsp = pcall(require, "mason-lspconfig")
      if not ok then
        return
      end
      mlsp.setup({
        -- Keep this minimal. Your actual server setup lives in config/lsp.lua.
        -- We only make sure the binaries are present.
        ensure_installed = {
          "pyright",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      local ok, mdap = pcall(require, "mason-nvim-dap")
      if not ok then
        return
      end
      mdap.setup({
        ensure_installed = {
          "python", -- installs debugpy
        },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },
}
