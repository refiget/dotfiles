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
        -- Resident tools shown on the right (icon-only)
        resident_status = {
            { name = "Clash Verge", pattern = "clash%-verge|verge%-mihomo" },
            { name = "Keyboard Maestro", pattern = "Keyboard Maestro Engine" },
            { name = "kindaVim", pattern = "kindaVim" },
            { name = "Karabiner-Elements", pattern = "Karabiner%-Menu|karabiner_console_user_server|Karabiner%-Core%-Service" },
        },
        widgets_right_bracket = false,
        disable_right_widgets = true,
        notch_gap = 80,
        focus_index_gap = false,         -- if set (number), overrides notch_gap for index pill
        focus_index_pad_left = 0,       -- extra fine-tune for index pill only (moves it right)
        focus_apps_gap = false,          -- if set (number), overrides notch_gap+focus_apps_extra_gap for apps pill
        focus_apps_extra_gap = 0,
        space_preview_offset = 0,
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
