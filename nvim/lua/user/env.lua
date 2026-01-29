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
