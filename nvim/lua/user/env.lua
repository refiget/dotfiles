-- ===================== env.lua =====================
local fn = vim.fn

vim.env.PYTHONWARNINGS = "ignore::SyntaxWarning"
if fn.isdirectory(fn.getcwd()) == 0 then
  vim.cmd("cd ~")
end

local function detect_python_host()
  local candidates = {
    fn.expand("~/venvs/nvim/bin/python3"),
    fn.expand("~/.venvs/nvim/bin/python3"),
    "/usr/local/opt/python@3/bin/python3",
    "/opt/homebrew/bin/python3",
    "/usr/local/bin/python3",
    "/usr/bin/python3",
  }
  for _, path in ipairs(candidates) do
    if fn.executable(path) == 1 then
      return path
    end
  end
  return "python3"
end

vim.g.python3_host_prog = detect_python_host()

local function prepend_path(dir)
  if not dir or dir == "" then
    return
  end
  if fn.isdirectory(dir) == 0 then
    return
  end
  local path = vim.env.PATH or ""
  if not path:find(dir, 1, true) then
    vim.env.PATH = dir .. ":" .. path
  end
end

local function python_host_bin()
  local host = vim.g.python3_host_prog
  if host and fn.executable(host) == 1 then
    return fn.fnamemodify(host, ":h")
  end
  return nil
end

prepend_path(python_host_bin())

local function npm_global_bin()
  if fn.executable("npm") ~= 1 then
    return nil
  end
  local ok, out = pcall(fn.systemlist, { "npm", "bin", "-g" })
  if not ok or not out or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

prepend_path(npm_global_bin())

local function pnpm_global_bin()
  if fn.executable("pnpm") ~= 1 then
    return nil
  end
  local ok, out = pcall(fn.systemlist, { "pnpm", "bin", "-g" })
  if not ok or not out or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

local function yarn_global_bin()
  if fn.executable("yarn") ~= 1 then
    return nil
  end
  local ok, out = pcall(fn.systemlist, { "yarn", "global", "bin" })
  if not ok or not out or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

prepend_path(pnpm_global_bin())
prepend_path(yarn_global_bin())
