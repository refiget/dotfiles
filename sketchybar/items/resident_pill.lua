local colors = require("colors")
local settings = require("settings")

local config_dir = os.getenv("CONFIG_DIR") or "$CONFIG_DIR"

-- Right-side pill that mimics the left space app glyph string.
-- It runs a small helper script that prints sketchybar key=value lines:
--   drawing=on/off
--   label=<glyphs>

local item = sbar.add("item", "resident.pill", {
  position = "right",
  drawing = false,
  icon = { drawing = false },
  label = {
    drawing = true,
    string = "",
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.white,
    padding_left = 10,
    padding_right = 10,
    y_offset = -1,
  },
  background = {
    color = colors.transparent,
    corner_radius = 999,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
})

-- Some sketchybar versions don't reliably apply script/update_freq via the Lua wrapper.
-- Use the sketchybar CLI to set them.
sbar.exec(
  "sketchybar --set "
    .. item.name
    .. " updates=on"
    .. " update_freq=5"
    .. " script=\"" .. config_dir .. "/helpers/resident_status.sh\""
)

item:subscribe({ "forced", "routine", "system_woke" }, function()
  item:set({})
end)

return { item.name }
