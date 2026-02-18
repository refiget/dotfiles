local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

-- Space previews (left) and notch focus pills (center) need independent tuning.
-- Increase space_preview_offset to push the left preview group rightwards.
local space_preview_offset = settings.space_preview_offset or 0
local notch_gap = settings.notch_gap or 80
local focus_apps_extra_gap = settings.focus_apps_extra_gap or 0

-- Allow independent positioning of the two notch pills.
-- - focus_index_gap controls the index pill distance from center (right padding)
-- - focus_apps_gap controls the apps pill distance from center (left padding)
local focus_index_gap = settings.focus_index_gap
local focus_index_x_offset = settings.focus_index_x_offset or 0
local focus_apps_gap = settings.focus_apps_gap

local index_gap = (type(focus_index_gap) == "number") and focus_index_gap or notch_gap
local apps_gap = (type(focus_apps_gap) == "number") and focus_apps_gap or (notch_gap + focus_apps_extra_gap)

-- Left preview group should not move; keep spacer but force width=0.
sbar.add("item", "preview.spacer", {
  position = "left",
  width = 0,
  drawing = false,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
})

-- Notch focus pills: left shows index, right shows apps of the current space.
-- Place them symmetrically around the center line by using equal padding away
-- from the center. (Works reliably across sketchybar versions.)
local focus_index = sbar.add("item", "space.focus.index", {
  position = "center",
  padding_right = index_gap,
  x_offset = focus_index_x_offset,
  icon = { drawing = false },
  label = {
    font = { family = settings.font.numbers, size = 13.0 },
    color = colors.white,
    string = "1",
    padding_left = 10,
    padding_right = 10,
  },
  background = { color = colors.bg1, corner_radius = 999, height = 26 },
})

local focus_apps = sbar.add("item", "space.focus.apps", {
  position = "center",
  padding_left = apps_gap,
  icon = { drawing = false },
  label = {
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.white,
    string = "—",
    padding_left = 10,
    padding_right = 10,
    y_offset = -1,
  },
  background = { color = colors.bg1, corner_radius = 999, height = 26 },
})

local current_space = 1
local apps_by_space = { [1] = "—", [2] = "—", [3] = "—" }

for i = 1, 3, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      font = { family = settings.font.numbers },
      string = i,
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
    if selected then
      current_space = i
      focus_index:set({ label = { string = tostring(i) } })
      focus_apps:set({ label = { string = apps_by_space[i] or "—" } })
    end

    -- Keep left preview pills visually static (no focus highlight).
    space:set({
      icon = { highlight = false },
      label = { highlight = false },
      background = { border_color = colors.bg2 }
    })
    space_bracket:set({
      background = { border_color = colors.bg2 }
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

space_window_observer:subscribe("space_windows_change", function(env)
  -- Limit noise: show at most N app icons, then "+N" overflow.
  local MAX_APPS = 4

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

  local sid = env.INFO.space
  apps_by_space[sid] = icon_line

  sbar.animate("tanh", 10, function()
    spaces[sid]:set({ label = icon_line })
    if sid == current_space then
      focus_apps:set({ label = { string = icon_line } })
    end
  end)
end)
