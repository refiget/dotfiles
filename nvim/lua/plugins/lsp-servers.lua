return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local common = require("lsp.common")
      local java = require("lsp.java")
      local python = require("lsp.python")

      opts.servers = vim.tbl_deep_extend("force", common.base_servers(), opts.servers or {})
      python.setup(opts.servers)
      java.setup(opts.servers)
    end,
  },
}
