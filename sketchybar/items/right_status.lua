local colors = require("colors")
local settings = require("settings")

local config_dir = os.getenv("CONFIG_DIR")
if not config_dir or config_dir == "" then
  local home = os.getenv("HOME")
  config_dir = (home and home ~= "") and (home .. "/.config/sketchybar") or "."
end

local item = sbar.add("item", "right.status", {
  position = "right",
  icon = { drawing = false },
  label = {
    drawing = true,
    string = "时间:󰥔 --:--  状态󰾆 --%  󰍛 --.-G",
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    padding_left = 12,
    padding_right = 12,
    y_offset = -1,
  },
  background = {
    color = colors.transparent,
    corner_radius = 999,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
  padding_left = 0,
  padding_right = 5,
})

sbar.exec(
  "chmod +x \"" .. config_dir .. "/helpers/status_line.sh\" && sketchybar --set "
    .. item.name
    .. " updates=on"
    .. " update_freq=10"
    .. " script=\"" .. config_dir .. "/helpers/status_line.sh\""
)

item:subscribe({ "forced", "routine", "system_woke" }, function()
  item:set({})
end)

return { item.name }
