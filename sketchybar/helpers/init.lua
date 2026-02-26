-- Add the sketchybar module to Lua cpath (robust for launchd/non-login envs)
local home = os.getenv("HOME")
if not home or home == "" then
  local user = os.getenv("USER") or ""
  if user ~= "" then home = "/Users/" .. user end
end

if home and home ~= "" then
  package.cpath = package.cpath .. ";" .. home .. "/.local/share/sketchybar_lua/?.so"
end

-- Build helper binaries from the config directory (not current working dir)
local config_dir = os.getenv("CONFIG_DIR")
if not config_dir or config_dir == "" then
  if home and home ~= "" then
    config_dir = home .. "/.config/sketchybar"
  end
end

if config_dir and config_dir ~= "" then
  os.execute('(cd "' .. config_dir .. '/helpers" && make) >/dev/null 2>&1')
end
