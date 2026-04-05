return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local common = require("lsp.common")
      opts.ensure_installed = common.mason_ensure_installed()
    end,
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      local function install_pkg(pkg)
        local ok, p = pcall(mr.get_package, pkg)
        if ok and p and not p:is_installed() then
          p:install()
        end
      end

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          install_pkg(tool)
        end
      end)

      vim.api.nvim_create_user_command("InstallApp", function()
        local set = {}

        for _, tool in ipairs((opts.ensure_installed or {})) do
          set[tool] = true
        end

        local ok_map, mappings = pcall(require, "mason-lspconfig.mappings")
        if ok_map then
          local lsp_to_pkg = mappings.get_mason_map().lspconfig_to_package or {}
          local lsp_opts = require("lazy.core.config").plugins["nvim-lspconfig"]
          local servers = (((lsp_opts or {}).opts or {}).servers or {})
          for name, _ in pairs(servers) do
            local pkg = lsp_to_pkg[name]
            if pkg then
              set[pkg] = true
            end
          end
        end

        local list = {}
        for pkg, _ in pairs(set) do
          table.insert(list, pkg)
        end
        table.sort(list)

        mr.refresh(function()
          for _, pkg in ipairs(list) do
            install_pkg(pkg)
          end
          vim.notify("Mason installing: " .. table.concat(list, ", "))
        end)
      end, { desc = "Install all mason-managed tools from current config" })

      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("InstallApp")
      end, { desc = "Alias: install all missing Mason tools" })
    end,
  },
}
