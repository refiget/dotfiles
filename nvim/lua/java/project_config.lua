local M = {}

-- Preferred project config names (first one is used by :JavaProjectInit).
M.filenames = { "conf.json", ".nvim-java.json" }

M.defaults = {
  sourcePaths = { "src", "tests" },
  testSourcePaths = { "tests" },
  outputPath = "out",
  referencedLibraries = { "~/libs/java/**/*.jar" },
  mainClass = nil,
  -- Optional: absolute/~/ path to JDK home, e.g. "~/jdks/temurin-21.jdk/Contents/Home"
  jdkHome = nil,
  -- JDTLS process itself requires Java 21+ (new upstream baseline).
  launchJdkHome = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
}

local function normalize(cfg)
  cfg = cfg or {}
  local merged = vim.deepcopy(M.defaults)
  for k, v in pairs(cfg) do
    merged[k] = v
  end

  if type(merged.sourcePaths) ~= "table" then
    merged.sourcePaths = vim.deepcopy(M.defaults.sourcePaths)
  end
  if type(merged.testSourcePaths) ~= "table" then
    merged.testSourcePaths = vim.deepcopy(M.defaults.testSourcePaths)
  end
  if type(merged.referencedLibraries) ~= "table" then
    merged.referencedLibraries = vim.deepcopy(M.defaults.referencedLibraries)
  end
  if type(merged.outputPath) ~= "string" or merged.outputPath == "" then
    merged.outputPath = M.defaults.outputPath
  end
  if merged.jdkHome ~= nil and (type(merged.jdkHome) ~= "string" or merged.jdkHome == "") then
    merged.jdkHome = nil
  end
  if merged.launchJdkHome ~= nil and (type(merged.launchJdkHome) ~= "string" or merged.launchJdkHome == "") then
    merged.launchJdkHome = nil
  end

  return merged
end

local function join(root_dir, name)
  return root_dir .. "/" .. name
end

function M.expand_path(path)
  if not path or path == "" then
    return path
  end
  return vim.fn.expand(path)
end

function M.find_path(root_dir)
  if not root_dir or root_dir == "" then
    return nil, nil
  end

  for _, name in ipairs(M.filenames) do
    local p = join(root_dir, name)
    if vim.fn.filereadable(p) == 1 then
      return p, name
    end
  end

  return join(root_dir, M.filenames[1]), M.filenames[1]
end

function M.load(root_dir)
  local config_path = M.find_path(root_dir)
  if not config_path or vim.fn.filereadable(config_path) ~= 1 then
    return normalize(), config_path, false
  end

  local lines = vim.fn.readfile(config_path)
  local raw = table.concat(lines, "\n")
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= "table" then
    vim.notify("Java 项目配置解析失败: " .. config_path, vim.log.levels.WARN)
    return normalize(), config_path, false
  end

  return normalize(decoded), config_path, true
end

function M.write_default(root_dir)
  local path = M.find_path(root_dir)
  if not path then
    return nil, "invalid root"
  end
  if vim.fn.filereadable(path) == 1 then
    return path, nil
  end

  local content = vim.json.encode(M.defaults)
  vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
  return path, nil
end

function M.java_exec_for_jdtls(cfg)
  local candidates = {
    cfg and cfg.launchJdkHome,
    "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
    cfg and cfg.jdkHome,
  }

  for _, home in ipairs(candidates) do
    home = M.expand_path(home)
    if home and home ~= "" then
      local bin = home .. "/bin/java"
      if vim.fn.executable(bin) == 1 then
        return bin
      end
    end
  end

  return "java"
end

function M.to_jdtls_settings(cfg)
  local settings = {
    java = {
      project = {
        sourcePaths = cfg.sourcePaths,
        outputPath = cfg.outputPath,
        referencedLibraries = cfg.referencedLibraries,
      },
    },
  }

  local jdk_home = M.expand_path(cfg.jdkHome)
  if jdk_home and jdk_home ~= "" then
    settings.java.configuration = {
      runtimes = {
        { name = "JavaSE-17", path = jdk_home, default = true },
      },
    }
  end

  return settings
end

function M.info_lines(cfg, path, exists)
  local libs = vim.tbl_map(function(v)
    return M.expand_path(v)
  end, cfg.referencedLibraries or {})

  return {
    "Java 项目配置: " .. (path or "(none)"),
    "存在: " .. tostring(exists),
    "sourcePaths: " .. table.concat(cfg.sourcePaths or {}, ", "),
    "testSourcePaths: " .. table.concat(cfg.testSourcePaths or {}, ", "),
    "outputPath: " .. tostring(cfg.outputPath),
    "referencedLibraries: " .. table.concat(libs, ", "),
    "mainClass: " .. tostring(cfg.mainClass),
    "jdkHome: " .. tostring(M.expand_path(cfg.jdkHome)),
    "launchJdkHome: " .. tostring(M.expand_path(cfg.launchJdkHome)),
  }
end

return M
