local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

for i = 1, 3, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 8,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 10,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
    popup = { background = { border_width = 5, border_color = colors.black } }
  })

  spaces[i] = space

  -- Single item bracket for space items to achieve double border on highlight
  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })

  -- Padding space
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
        scale = 0.2
      }
    }
  })

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    space:set({
      icon = { highlight = selected, },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 }
    })
    space_bracket:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
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

-- spaces_indicator removed (icon + "Spaces" label)
-- local spaces_indicator = sbar.add("item", { ... })

space_window_observer:subscribe("space_windows_change", function(env)
  -- Limit noise: show at most N app icons, then "+N" overflow.
  local MAX_APPS = 6

  -- Ensure stable ordering (avoid jitter): sort app names.
  local app_names = {}
  for app, _ in pairs(env.INFO.apps) do
    table.insert(app_names, app)
  end
  table.sort(app_names)

  local icons_out = {}
  local n_apps = #app_names
  for _, app in ipairs(app_names) do
    if #icons_out < MAX_APPS then
      local lookup = app_icons[app]
      local icon = ((lookup == nil) and app_icons["Default"] or lookup)
      table.insert(icons_out, icon)
    end
  end

  local icon_line = table.concat(icons_out, "")
  if n_apps == 0 then
    icon_line = "—"
  elseif n_apps > MAX_APPS then
    icon_line = icon_line .. " +" .. tostring(n_apps - MAX_APPS)
  end

  sbar.animate("tanh", 10, function()
    spaces[env.INFO.space]:set({ label = icon_line })
  end)
end)

-- spaces_indicator subscriptions removed
