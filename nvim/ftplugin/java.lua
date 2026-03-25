local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
  return
end

local root_dir = vim.fs.dirname(vim.fs.find({ ".git", "proj.iml" }, { upward = true })[1])
if not root_dir or root_dir == "" then
  root_dir = vim.fn.getcwd()
end

local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name
local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

if launcher == "" then
  vim.notify("jdtls launcher not found, run :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

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
    "-configuration", jdtls_path .. "/config_mac",
    "-data", workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      project = {
        sourcePaths = { "src", "tests" },
        outputPath = "out",
        referencedLibraries = {
          "/Users/mac/Desktop/cs61b/library-sp24/*.jar",
        },
      },
    },
  },
})

local function is_test_file()
  local name = vim.api.nvim_buf_get_name(0)
  return name:match("Test.java") or name:match("/tests/")
end

local function has_main()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, l in ipairs(lines) do
    if l:match("public%s+static%s+void%s+main") then
      return true
    end
  end
  return false
end

function _G.RunSmart()
  if is_test_file() then
    if type(jdtls.test_nearest_method) == "function" then
      jdtls.test_nearest_method()
    else
      vim.notify("jdtls.test_nearest_method is unavailable", vim.log.levels.WARN)
    end
    return
  end

  if has_main() then
    if type(jdtls.run_main) == "function" then
      jdtls.run_main()
    else
      vim.notify("jdtls.run_main is unavailable in this version", vim.log.levels.WARN)
    end
    return
  end

  vim.notify("No runnable entry found", vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>r", RunSmart, { buffer = 0, desc = "Java: smart run/test" })
