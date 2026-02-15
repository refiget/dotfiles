local fn = vim.fn

local function check_lsp_deps()
  local warns = {}

  local function has_exec(bin)
    return fn.executable(bin) == 1
  end

  local host = vim.g.python3_host_prog or "python3"
  if fn.executable(host) ~= 1 then
    table.insert(warns, "未检测到 python3 host (" .. host .. ")，请安装对应解释器（macOS: brew install python）")
  end

  local lsp_servers = {
    { "pyright-langserver", "npm install -g pyright", "Python" },
    { "lua-language-server", "brew install lua-language-server", "Lua" },
    { "vscode-json-language-server", "npm install -g vscode-langservers-extracted", "JSON" },
    { "yaml-language-server", "npm install -g yaml-language-server", "YAML" },
    { "typescript-language-server", "npm install -g typescript typescript-language-server", "TypeScript/JavaScript" },
    { "bash-language-server", "npm install -g bash-language-server", "Shell" }
  }
  local tools = {
    { "black", "pip install black", "Python formatter" },
    -- flake8 intentionally disabled (too noisy for style rules)
    { "stylua", "brew install stylua", "Lua formatter" },
  }

  for _, server in ipairs(lsp_servers) do
    local bin, install_cmd, lang = server[1], server[2], server[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，请安装：%s", lang, bin, install_cmd))
    end
  end
  for _, tool in ipairs(tools) do
    local bin, install_cmd, name = tool[1], tool[2], tool[3]
    if not has_exec(bin) then
      table.insert(warns, string.format("未检测到 %s (%s)，请安装：%s", name, bin, install_cmd))
    end
  end

  if #warns > 0 then
    vim.schedule(function()
      vim.notify(table.concat(warns, "\n"), vim.log.levels.WARN, { title = "LSP 依赖检查" })
    end)
  end
end

local function setup_lsp()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  local function file_exists(p)
    return p and p ~= "" and fn.filereadable(p) == 1
  end

  local function path_join(a, b)
    if a:sub(-1) == "/" then
      return a .. b
    end
    return a .. "/" .. b
  end

  local function detect_project_python(root_dir)
    -- Prefer active venv if Neovim was launched inside one
    local venv = vim.env.VIRTUAL_ENV
    if venv and venv ~= "" then
      local p = path_join(venv, "bin/python")
      if file_exists(p) then
        return p
      end
      p = path_join(venv, "bin/python3")
      if file_exists(p) then
        return p
      end
    end

    -- Then prefer .venv/ or venv/ inside the project root
    local candidates = {
      root_dir .. "/.venv/bin/python",
      root_dir .. "/.venv/bin/python3",
      root_dir .. "/venv/bin/python",
      root_dir .. "/venv/bin/python3",
      root_dir .. "/.env/bin/python",
      root_dir .. "/.env/bin/python3",
    }
    for _, p in ipairs(candidates) do
      if file_exists(p) then
        return p
      end
    end

    return nil
  end

  local function detect_pyright_venv(root_dir, python_path)
    -- Prefer explicit project-local venv names
    local venv_names = { ".venv", "venv", ".env" }
    for _, name in ipairs(venv_names) do
      local p1 = root_dir .. "/" .. name .. "/bin/python"
      local p2 = root_dir .. "/" .. name .. "/bin/python3"
      if file_exists(p1) or file_exists(p2) then
        return { venvPath = root_dir, venv = name }
      end
    end

    -- If python comes from an activated venv, set venvPath/venv from VIRTUAL_ENV
    local venv = vim.env.VIRTUAL_ENV
    if venv and venv ~= "" then
      local parent = fn.fnamemodify(venv, ":h")
      local base = fn.fnamemodify(venv, ":t")
      if parent and base and parent ~= "" and base ~= "" then
        return { venvPath = parent, venv = base }
      end
    end

    -- Fallback: try to infer from python_path like /.../<name>/bin/python
    if python_path and python_path ~= "" then
      local venv_dir = fn.fnamemodify(python_path, ":h:h")
      local parent = fn.fnamemodify(venv_dir, ":h")
      local base = fn.fnamemodify(venv_dir, ":t")
      if parent and base and parent ~= "" and base ~= "" then
        return { venvPath = parent, venv = base }
      end
    end

    return nil
  end

  local servers = {
    pyright = {
      -- Make pyright automatically use ./.venv or ./venv when present
      -- Note: Neovim's new vim.lsp.config path may not always apply on_new_config;
      -- we also set it again in on_init and notify the server.
      on_new_config = function(new_config, root_dir)
        local py = detect_project_python(root_dir)
        if py then
          new_config.settings = new_config.settings or {}
          new_config.settings.python = new_config.settings.python or {}

          new_config.settings.python.pythonPath = py

          local venv_cfg = detect_pyright_venv(root_dir, py)
          if venv_cfg then
            new_config.settings.python.venvPath = venv_cfg.venvPath
            new_config.settings.python.venv = venv_cfg.venv
          end
        end
      end,
      on_init = function(client)
        local root_dir = client.config.root_dir
        if not root_dir or root_dir == "" then
          return
        end

        local py = detect_project_python(root_dir)
        if not py then
          return
        end

        client.config.settings = client.config.settings or {}
        client.config.settings.python = client.config.settings.python or {}
        client.config.settings.python.pythonPath = py

        local venv_cfg = detect_pyright_venv(root_dir, py)
        if venv_cfg then
          client.config.settings.python.venvPath = venv_cfg.venvPath
          client.config.settings.python.venv = venv_cfg.venv
        end

        -- Push updated settings to server
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

-- Diagnostics: keep the UI stable across mode changes.
-- update_in_insert=true avoids the "only updates after leaving insert" feeling.
-- Diagnostic signs (left gutter): use minimalist symbols instead of E/W/H/I
local diag_signs = {
  [vim.diagnostic.severity.ERROR] = "●",
  [vim.diagnostic.severity.WARN] = "●",
  [vim.diagnostic.severity.INFO] = "·",
  [vim.diagnostic.severity.HINT] = "·",
}

vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 2,
    prefix = "·",
  },
  signs = {
    text = diag_signs,
  },
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

setup_lsp()
vim.defer_fn(check_lsp_deps, 200)
