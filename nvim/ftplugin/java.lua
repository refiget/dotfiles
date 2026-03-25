local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
  return
end

local project_cfg = require("java.project_config")

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers) or vim.fn.getcwd()

local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

local data_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local config_dir = data_path .. "/config_mac"
local launcher = vim.fn.glob(data_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

if launcher == "" then
  vim.notify("未找到 jdtls launcher，请先 :MasonInstall jdtls", vim.log.levels.WARN)
  return
end

local cfg, cfg_path, exists = project_cfg.load(root_dir)

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local function on_attach(client, _bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local function show_project_info()
  vim.notify(table.concat(project_cfg.info_lines(cfg, cfg_path, exists), "\n"), vim.log.levels.INFO, { title = "Java Project" })
end

local function init_project_config()
  local path, err = project_cfg.write_default(root_dir)
  if err then
    vim.notify("初始化 Java 项目配置失败: " .. err, vim.log.levels.ERROR)
    return
  end
  vim.cmd("edit " .. path)
end

vim.api.nvim_buf_create_user_command(0, "JavaProjectInfo", show_project_info, {})
vim.api.nvim_buf_create_user_command(0, "JavaProjectInit", init_project_config, {})
vim.api.nvim_buf_create_user_command(0, "JavaProjectReload", function()
  vim.cmd("LspRestart")
end, {})

vim.keymap.set("n", "<localleader>ji", show_project_info, { buffer = 0, desc = "Java project info" })
vim.keymap.set("n", "<localleader>jc", init_project_config, { buffer = 0, desc = "Create/edit Java project config" })
vim.keymap.set("n", "<localleader>jl", "<cmd>JavaProjectReload<CR>", { buffer = 0, desc = "Reload Java LSP" })

jdtls.start_or_attach({
  cmd = {
    project_cfg.java_exec(cfg),
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=WARN",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", config_dir,
    "-data", workspace_dir,
  },
  root_dir = root_dir,
  settings = project_cfg.to_jdtls_settings(cfg),
  capabilities = capabilities,
  on_attach = on_attach,
  init_options = {
    bundles = {},
  },
})
