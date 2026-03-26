local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local function find_root()
  local root = require("jdtls.setup").find_root({ ".git", "conf.json", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle", "build.gradle.kts" })
  return (root and root ~= "") and root or vim.fn.getcwd()
end

local function load_project_cfg(root_dir)
  local cfg = {
    sourcePaths = { "src", "tests" },
    outputPath = "out",
    referencedLibraries = { "lib/**/*.jar" },
  }

  local conf = root_dir .. "/conf.json"
  if vim.fn.filereadable(conf) == 1 then
    local raw = table.concat(vim.fn.readfile(conf), "\n")
    local ok_json, data = pcall(vim.json.decode, raw)
    if ok_json and type(data) == "table" then
      if type(data.sourcePaths) == "table" then cfg.sourcePaths = data.sourcePaths end
      if type(data.outputPath) == "string" and data.outputPath ~= "" then cfg.outputPath = data.outputPath end
      if type(data.referencedLibraries) == "table" then cfg.referencedLibraries = data.referencedLibraries end
    end
  end

  return cfg
end

local function collect_bundles()
  local bundles = {}
  local paths = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar", true, true)
  vim.list_extend(bundles, paths)

  local debug = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
  vim.list_extend(bundles, debug)
  return bundles
end

local root_dir = find_root()
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

local mason_jdtls = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local launcher = vim.fn.glob(mason_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher == "" then
  vim.notify("jdtls not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
  return
end

local cfg = load_project_cfg(root_dir)

vim.api.nvim_buf_create_user_command(0, "JavaProjectInit", function()
  local conf = root_dir .. "/conf.json"
  if vim.fn.filereadable(conf) == 0 then
    local tpl = vim.json.encode({
      sourcePaths = { "src", "tests" },
      outputPath = "out",
      referencedLibraries = { "/absolute/path/to/lib/**/*.jar" },
    })
    vim.fn.writefile(vim.split(tpl, "\n", { plain = true }), conf)
  end
  vim.cmd("edit " .. conf)
end, { desc = "Create/open Java project conf.json" })

jdtls.start_or_attach({
  cmd = {
    "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java",
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
    "-configuration", mason_jdtls .. "/config_mac",
    "-data", workspace_dir,
  },
  root_dir = root_dir,
  init_options = {
    bundles = collect_bundles(),
  },
  settings = {
    java = {
      project = {
        sourcePaths = cfg.sourcePaths,
        outputPath = cfg.outputPath,
        referencedLibraries = cfg.referencedLibraries,
      },
    },
  },
})


vim.keymap.set("n", ",jm", function()
  local ok_dap, jdtls_dap = pcall(require, "jdtls.dap")
  local ok_core, dap = pcall(require, "dap")
  if not (ok_dap and ok_core) then
    vim.notify("jdtls.dap / nvim-dap not available", vim.log.levels.WARN)
    return
  end
  jdtls_dap.setup_dap_main_class_configs({
    verbose = true,
    on_ready = function()
      vim.schedule(function()
        pcall(function()
          require("dap").repl.open({}, "botright 10split")
        end)
        dap.continue()
      end)
    end,
  })
end, { buffer = 0, desc = "Java: run main (jdtls in bottom split)" })


-- enable java dap adapter (required for main/test runners)
jdtls.setup_dap({ hotcodereplace = "auto" })
