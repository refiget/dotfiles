local colors = require("colors")
local settings = require("settings")
local space_state = require("services.space_state")

local focus = require("items.space_focus")

local spaces = {}
local SPACE_ICONS = {
  [1] = utf8.char(0xF03A6),
  [2] = utf8.char(0xF03A9),
  [3] = utf8.char(0xF03AC),
}

for i = 1, 3, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      font = { family = settings.font.numbers, size = 19.0 },
      string = SPACE_ICONS[i] or i,
      padding_left = 6,
      padding_right = 6,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 4,
      color = colors.white,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
      string = space_state.get_apps_for_space(i),
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.transparent,
      border_width = 2,
      height = 26,
      corner_radius = 10,
      border_color = colors.bg2,
    },
    popup = { background = { border_width = 5, border_color = colors.black } },
  })

  spaces[i] = space

  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.transparent,
      height = 28,
      border_width = 0,
    },
  })

  sbar.add("space", "space.padding." .. i, {
    space = i,
    script = "",
    width = settings.group_paddings,
  })

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left = 5,
    padding_right = 0,
    background = {
      drawing = true,
      image = {
        corner_radius = 9,
        scale = 0.2,
      },
    },
  })

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    if selected then
      focus.set_space(i)
    end

    -- Keep left preview pills visually static (no focus highlight).
    space:set({
      icon = { highlight = false },
      label = { highlight = false },
      background = { border_color = colors.bg2 },
    })
    space_bracket:set({ background = { border_color = colors.transparent } })
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" or env.MODIFIER == "shift" then
      space_popup:set({ background = { image = "space." .. env.SID } })
      space:set({ popup = { drawing = "toggle" } })
    else
      local op = (env.BUTTON == "right") and "--destroy" or "--focus"
      sbar.exec("yabai -m space " .. op .. " " .. env.SID)
    end
  end)

  space:subscribe("mouse.exited", function(_)
    space:set({ popup = { drawing = false } })
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe("space_windows_change", function(env)
  local MAX_APPS = 4
  local icon_line = space_state.format_apps_line(env.INFO.apps, MAX_APPS)
  local sid = env.INFO.space

  space_state.set_apps_for_space(sid, icon_line)

  sbar.animate("tanh", 10, function()
    spaces[sid]:set({ label = { string = icon_line } })
  end)

  focus.set_apps_for_space(sid, icon_line)
end)
