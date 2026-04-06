return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local common = require("lsp.common")
      local python = require("lsp.python")
      local java = require("lsp.java")

      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, common.base_servers())

      -- Ensure LSP does not claim `K` (we use K for 5k globally)
      local star = opts.servers["*"]
      if type(star) == "table" and type(star.keys) == "table" then
        local filtered = {}
        for _, k in ipairs(star.keys) do
          local lhs = k[1]
          if lhs ~= "K" then
            table.insert(filtered, k)
          end
        end
        star.keys = filtered
      end
      python.setup(opts.servers)
      java.setup(opts.servers)
    end,
  },
}
