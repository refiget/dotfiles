return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.jdtls = opts.servers.jdtls or {}

      local util = require("lspconfig.util")

      opts.servers.jdtls.root_dir = util.root_pattern(".cs61b-root", ".project", ".git")

      opts.servers.jdtls.settings = opts.servers.jdtls.settings or {}
      opts.servers.jdtls.settings.java = opts.servers.jdtls.settings.java or {}
      opts.servers.jdtls.settings.java.project = {
        sourcePaths = { "src", "tests" },
        outputPath = "out",
        referencedLibraries = { vim.fn.expand("~/Desktop/cs61b/library-sp24/*.jar") },
      }


      opts.servers.jdtls.handlers = opts.servers.jdtls.handlers or {}
      local default_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
      opts.servers.jdtls.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if result and result.diagnostics then
          local filtered = {}
          for _, d in ipairs(result.diagnostics) do
            local msg = d.message or ""
            local ignore = msg:match("is never used")
              or msg:match("is never read")
              or msg:match("The import .- is never used")
              or msg:match("The value of the local variable .- is not used")
              or msg:match("The declared package .- does not match the expected package")
            if not ignore then
              table.insert(filtered, d)
            end
          end
          result.diagnostics = filtered
        end
        return default_publish(err, result, ctx, config)
      end

      -- Force jdtls to run on JDK 21 (independent of your shell JAVA_HOME)
      local mason = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local launcher = vim.fn.glob(mason .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local config = mason .. "/config_mac"

      opts.servers.jdtls.cmd = {
        "/opt/homebrew/opt/openjdk@21/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=WARN",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        launcher,
        "-configuration",
        config,
        "-data",
        vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
      }
    end,
  },
}
