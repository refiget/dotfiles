local M = {}

M.filename = ".nvim-java.json"

M.defaults = {
  sourcePaths = { "src/main/java", "src/test/java" },
  testSourcePaths = { "src/test/java" },
  outputPath = "out",
  referencedLibraries = { "lib/**/*.jar" },
  mainClass = nil,
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

  return merged
end

function M.path(root_dir)
  if not root_dir or root_dir == "" then
    return nil
  end
  return root_dir .. "/" .. M.filename
end

function M.load(root_dir)
  local config_path = M.path(root_dir)
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
  local path = M.path(root_dir)
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

function M.to_jdtls_settings(cfg)
  return {
    java = {
      project = {
        sourcePaths = cfg.sourcePaths,
        outputPath = cfg.outputPath,
        referencedLibraries = cfg.referencedLibraries,
      },
    },
  }
end

function M.info_lines(cfg, path, exists)
  return {
    "Java 项目配置: " .. (path or "(none)"),
    "存在: " .. tostring(exists),
    "sourcePaths: " .. table.concat(cfg.sourcePaths or {}, ", "),
    "testSourcePaths: " .. table.concat(cfg.testSourcePaths or {}, ", "),
    "outputPath: " .. tostring(cfg.outputPath),
    "referencedLibraries: " .. table.concat(cfg.referencedLibraries or {}, ", "),
    "mainClass: " .. tostring(cfg.mainClass),
  }
end

return M
