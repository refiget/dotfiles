local lunajson = require 'lunajson'

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

  local config_filepath = os.getenv("CONFIG_DIR") .. "/config.json"
  local content, error = file.read(config_filepath)
  if not error then
    local json_content = lunajson.decode(content)
    tbl.merge(config, json_content)
  end

  return config
end

return load_config()
