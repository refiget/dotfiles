local lunajson = require 'lunajson'

local file = require("utils.file")
local tbl = require("utils.tbl")

local function load_config()
    local config = {
        bar_height = 40,
        calendar = {
            click_script = "open -a Calendar"
        },
        clipboard = {
            max_items = 5
        },
        -- Font configuration
        font = require("helpers.default_font"),
        group_paddings = 10,
        -- Widgets shown on the right. Default to ultra-minimal: hide system stats widgets
        -- and show only resident apps.
        hide_widgets = { "battery", "volume", "wifi" },
        resident_apps = {
            { name = "Clash Verge" },
            { name = "Kindavim" },
        },
        widgets_right_bracket = false,
        disable_right_widgets = true,
        notch_gap = 80,
        icons = "NerdFont", -- alternatively available: sf-symbols
        paddings = 3,
        python_command = "python",
        stocks = {
            default_symbol = { symbol = "^GSPC", name = "S&P 500" },
            symbols = {
                { symbol = "^DJI", name = "Dow" },
                { symbol = "^IXIC", name = "Nasdaq" },
                { symbol = "^RUT", name = "Russell 2K" }
            }
        },
        weather = {
            location = false,
            use_shortcut = false
        }
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
