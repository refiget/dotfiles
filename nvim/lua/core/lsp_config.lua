local fn = vim.fn

local function check_lsp_deps()
  local warns = {}

  local mason_bin = fn.stdpath("data") .. "/mason/bin"

  local function has_exec(bin)
    if fn.executable(bin) == 1 then
      return true
    end
    local p = mason_bin .. "/" .. bin
    return fn.executable(p) == 1
  end

  local host = vim.g.python3_host_prog or "python3"
  if fn.executable(host) ~= 1 then
    table.insert(warns, "未检测到 python3 host (" .. host .. ")，请安装对应解释器（macOS: brew install python）")
  end

  local deps = {
    { "pyright-langserver", "Python LSP", "MasonInstall pyright" },
    { "lua-language-server", "Lua LSP", "MasonInstall lua-language-server" },
    { "vscode-json-language-server", "JSON LSP", "MasonInstall json-lsp" },
    { "yaml-language-server", "YAML LSP", "MasonInstall yaml-language-server" },
    { "typescript-language-server", "TypeScript/JavaScript LSP", "MasonInstall typescript-language-server" },
    { "bash-language-server", "Shell LSP", "MasonInstall bash-language-server" },
    { "black", "Python formatter", "MasonInstall black" },
    { "stylua", "Lua formatter", "MasonInstall stylua" },
    { "shfmt", "Shell formatter", "MasonInstall shfmt" },
    { "prettier", "Web formatter", "MasonInstall prettier" },
  }

  for _, dep in ipairs(deps) do
    local bin, name, install_hint = dep[1], dep[2], dep[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，可执行 :%s", name, bin, install_hint))
    end
  end

  if #warns > 0 then
    vim.schedule(function()
      vim.notify(
        table.concat(warns, "\n") .. "\n\n提示：Mason 安装后重启 Neovim 或执行 :LspRestart",
        vim.log.levels.WARN,
        { title = "LSP/Formatter 依赖检查" }
      )
    end)
  end
end

local function setup_lsp()

  local function on_attach(client, _bufnr)
    -- Formatting is handled by conform.nvim (single entrypoint).
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  local function file_exists(p)
    return p and p ~= "" and fn.filereadable(p) == 1
  end

  local function current_python_from_env()
    local venv = vim.env.VIRTUAL_ENV
    if not venv or venv == "" then
      return nil
    end

    local p = venv .. "/bin/python"
    if file_exists(p) then
      return p
    end

    p = venv .. "/bin/python3"
    if file_exists(p) then
      return p
    end

    return nil
  end

  local function current_venv_config()
    local venv = vim.env.VIRTUAL_ENV
    if not venv or venv == "" then
      return nil
    end

    local parent = fn.fnamemodify(venv, ":h")
    local base = fn.fnamemodify(venv, ":t")
    if parent and base and parent ~= "" and base ~= "" then
      return { venvPath = parent, venv = base }
    end

    return nil
  end

  local servers = {
    pyright = {
      on_attach = on_attach,
      -- Use only the currently activated virtual environment.
      on_new_config = function(new_config)
        local py = current_python_from_env()
        if not py then
          return
        end

        new_config.settings = new_config.settings or {}
        new_config.settings.python = new_config.settings.python or {}
        new_config.settings.python.pythonPath = py

        local venv_cfg = current_venv_config()
        if venv_cfg then
          new_config.settings.python.venvPath = venv_cfg.venvPath
          new_config.settings.python.venv = venv_cfg.venv
        end
      end,
      on_init = function(client)
        local py = current_python_from_env()
        if not py then
          return
        end

        client.config.settings = client.config.settings or {}
        client.config.settings.python = client.config.settings.python or {}
        client.config.settings.python.pythonPath = py

        local venv_cfg = current_venv_config()
        if venv_cfg then
          client.config.settings.python.venvPath = venv_cfg.venvPath
          client.config.settings.python.venv = venv_cfg.venv
        end

        pcall(function()
          client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end)
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            autoImportCompletions = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    },
    lua_ls = {
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
    jsonls = {},
    yamlls = {},
    ts_ls = {},
    bashls = {},
  }

  local ok_new = pcall(function()
    for name, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      vim.lsp.config(name, cfg)
    end
    vim.lsp.enable(vim.tbl_keys(servers))
  end)

  if not ok_new then
    local lspconfig = require("lspconfig")
    for name, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      lspconfig[name].setup(cfg)
    end
  end
end

local lsp_ui = require("core.lsp_ui_config")
vim.diagnostic.config(lsp_ui.diagnostics)

setup_lsp()
vim.defer_fn(check_lsp_deps, 200)
