local has_lunajson, lunajson = pcall(require, 'lunajson')

local file = require("utils.file")
local tbl = require("utils.tbl")

local function load_config()
  local config = {
    bar_height = 40,

    -- Font configuration
    font = require("helpers.default_font"),

    -- Shared spacing
    paddings = 3,
    group_paddings = 10,

    -- Left/center space pills
    notch_gap = 80,
    focus_index_gap = false,
    focus_index_pad_left = 0,
    focus_apps_gap = false,
    focus_apps_extra_gap = 0,

    -- Icon pack: NerdFont | sf-symbols
    icons = "NerdFont",
  }

  local config_dir = os.getenv("CONFIG_DIR")
  if not config_dir or config_dir == "" then
    local home = os.getenv("HOME")
    if home and home ~= "" then
      config_dir = home .. "/.config/sketchybar"
    else
      config_dir = "."
    end
  end

  local config_filepath = config_dir .. "/config.json"
  local content, error = file.read(config_filepath)
  if not error and has_lunajson then
    local ok, json_content = pcall(lunajson.decode, content)
    if ok and type(json_content) == "table" then
      tbl.merge(config, json_content)
    end
  end

  return config
end

return load_config()
