return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local util = require("lspconfig.util")

      opts.root_dir = function(path)
        return util.root_pattern(".cs61b-root", ".git")(path)
      end

      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}

      local cs61b_root = vim.fn.expand("~/Desktop/cs61b")
      local lib_dir = cs61b_root .. "/library-sp24"
      local referenced_libraries = {}
      if vim.fn.isdirectory(lib_dir) == 1 then
        referenced_libraries = vim.fn.glob(lib_dir .. "/*.jar", false, true)
      end

      opts.settings.java.project = {
        sourcePaths = { "src", "tests" },
        outputPath = "out",
        referencedLibraries = referenced_libraries,
      }
    end,
  },
}
