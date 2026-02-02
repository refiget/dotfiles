local fn = vim.fn

local function check_lsp_deps()
  local warns = {}

  local function has_exec(bin)
    return fn.executable(bin) == 1
  end

  local host = vim.g.python3_host_prog or "python3"
  if fn.executable(host) ~= 1 then
    table.insert(warns, "未检测到 python3 host (" .. host .. ")，请安装对应解释器（Arch: pacman -S python；macOS: brew install python）")
  end

  local lsp_servers = {
    { "pyright-langserver", "npm install -g pyright", "Python" },
    { "lua-language-server", "brew install lua-language-server (macOS) or npm install -g lua-language-server (Linux)", "Lua" },
    { "vscode-json-language-server", "npm install -g vscode-langservers-extracted", "JSON" },
    { "yaml-language-server", "npm install -g yaml-language-server", "YAML" },
    { "typescript-language-server", "npm install -g typescript typescript-language-server", "TypeScript/JavaScript" },
    { "bash-language-server", "npm install -g bash-language-server", "Shell" }
  }
  local tools = {
    { "black", "pip install black", "Python formatter" },
    { "flake8", "pip install flake8", "Python linter" },
    { "stylua", "brew install stylua (macOS) or cargo install stylua", "Lua formatter" },
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

  local servers = {
    pyright = {
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

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

setup_lsp()
vim.defer_fn(check_lsp_deps, 200)

vim.keymap.set(
  "n",
  "<leader>f",
  function()
    vim.lsp.buf.format({ async = true })
  end,
  { silent = true, noremap = true, desc = "Format document with LSP" }
)
