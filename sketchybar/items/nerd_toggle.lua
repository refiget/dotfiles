local colors = require("colors")
local settings = require("settings")

local ICON_OFF = utf8.char(0xF00BA)
local ICON_ON = utf8.char(0xF168C)

local enabled = false

local item = sbar.add("item", "nerd.toggle", {
  position = "right",
  icon = {
    string = ICON_OFF,
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
    padding_left = 14,
    padding_right = 14,
  },
  label = { drawing = false },
  background = {
    color = colors.transparent,
    corner_radius = 10,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
  padding_left = 0,
  padding_right = 5,
})

item:subscribe("mouse.clicked", function()
  enabled = not enabled
  item:set({
    icon = { string = enabled and ICON_ON or ICON_OFF },
  })

  -- 触发 Hyper+R (ctrl+alt+cmd+shift+r)
  sbar.exec("osascript -e 'tell application \"System Events\" to keystroke \"r\" using {control down, option down, command down, shift down}'")
end)

return { item.name }
