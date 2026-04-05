return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.jdtls = opts.servers.jdtls or {}

      local util = require("lspconfig.util")

      -- Prefer lightweight project markers so we don't force IntelliJ/Eclipse import behavior
      opts.servers.jdtls.root_dir = util.root_pattern(".cs61b-root", ".git")

      opts.servers.jdtls.settings = opts.servers.jdtls.settings or {}
      opts.servers.jdtls.settings.java = opts.servers.jdtls.settings.java or {}

      local cs61b_root = vim.fn.expand("~/Desktop/cs61b")
      local lib_dir = cs61b_root .. "/library-sp24"
      local referenced_libraries = {}
      if vim.fn.isdirectory(lib_dir) == 1 then
        referenced_libraries = vim.fn.glob(lib_dir .. "/*.jar", false, true)
      end

      opts.servers.jdtls.settings.java.project = {
        sourcePaths = { "src", "tests" },
        outputPath = "out",
        referencedLibraries = referenced_libraries,
      }


      opts.servers.jdtls.handlers = opts.servers.jdtls.handlers or {}
      local default_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
      local diag_timers = vim.g._jdtls_diag_timers or {}
      vim.g._jdtls_diag_timers = diag_timers
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

        local uri = result and result.uri or nil
        if not uri then
          return default_publish(err, result, ctx, config)
        end

        local existing = diag_timers[uri]
        if existing then
          existing:stop()
          existing:close()
          diag_timers[uri] = nil
        end

        local timer = vim.loop.new_timer()
        diag_timers[uri] = timer
        timer:start(350, 0, vim.schedule_wrap(function()
          local current = diag_timers[uri]
          if current then
            current:stop()
            current:close()
            diag_timers[uri] = nil
          end
          default_publish(err, result, ctx, config)
        end))
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
