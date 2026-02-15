local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
  height = settings.bar_height,
  color = colors.transparent,
  margin = 8,
  corner_radius = 12,
  padding_right = 8,
  padding_left = 8,

  -- With menu-guard enabled, keep this at 0 (the guard will hide SketchyBar
  -- when the menu bar reveal zone is active).
  y_offset = 0,

  -- Let the macOS menu bar / menus appear above SketchyBar
  topmost = "off"
})
