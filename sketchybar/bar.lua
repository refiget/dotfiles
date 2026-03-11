local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
  height = settings.bar_height,
  color = colors.transparent,
  margin = 0,
  corner_radius = 0,
  padding_right = 0,
  padding_left = 5,

  -- Slightly tuck the bar upward so it feels thinner visually.
  y_offset = -7,

  -- Let the macOS menu bar / menus appear above SketchyBar
  topmost = "off"
})
