-- ===================== env.lua =====================
local fn = vim.fn

vim.env.PYTHONWARNINGS = "ignore::SyntaxWarning"

-- Environment
-- Keep config macOS/local-focused; no SSH/server-specific branching.
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

local function latest_dir_by_mtime(dirs)
  local latest = nil
  local latest_time = -1
  for _, dir in ipairs(dirs) do
    local t = fn.getftime(dir)
    if t > latest_time then
      latest = dir
      latest_time = t
    end
  end
  return latest
end

local function latest_nvm_bin()
  local base = fn.expand("~/.nvm/versions/node")
  if fn.isdirectory(base) == 0 then
    return nil
  end
  local dirs = fn.glob(base .. "/v*", 1, 1)
  if not dirs or #dirs == 0 then
    return nil
  end
  local latest = latest_dir_by_mtime(dirs)
  if not latest then
    return nil
  end
  local bin = latest .. "/bin"
  if fn.isdirectory(bin) == 1 then
    return bin
  end
  return nil
end

local function python_host_bin()
  local host = vim.g.python3_host_prog
  if host and fn.executable(host) == 1 then
    return fn.fnamemodify(host, ":h")
  end
  return nil
end

prepend_path(python_host_bin())
prepend_path(fn.stdpath("data") .. "/mason/bin")

for _, dir in ipairs({
  "~/.npm-global/bin",
  "~/.npm/bin",
  "~/.yarn/bin",
  "~/Library/Yarn/bin",
  "~/Library/pnpm",
  "~/.local/share/pnpm",
  "~/.volta/bin",
  "~/.asdf/shims",
  "~/.local/share/mise/shims",
  "~/.mise/shims",
  "~/.local/share/fnm",
  "~/.fnm",
}) do
  prepend_path(fn.expand(dir))
end
prepend_path(latest_nvm_bin())

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

local function shell_command_path(bin)
  local shell = vim.env.SHELL or vim.o.shell or "sh"
  local ok, out = pcall(fn.systemlist, { shell, "-lc", "command -v " .. bin })
  if not ok or not out or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

local function ensure_bin_in_path(bin)
  if fn.executable(bin) == 1 then
    return
  end
  local path = shell_command_path(bin)
  if path and path ~= "" then
    prepend_path(fn.fnamemodify(path, ":h"))
  end
end

for _, bin in ipairs({
  "pyright-langserver",
  "vscode-json-language-server",
  "yaml-language-server",
  "typescript-language-server",
  "bash-language-server",
}) do
  ensure_bin_in_path(bin)
end
