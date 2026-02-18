local settings = require("settings")
local app_icons = require("helpers.app_icons")
local colors = require("colors")

-- A minimal "resident apps" widget group.
-- Shows only icons (like the left-side app glyphs), and only when the app is running.

local apps = settings.resident_apps or {
  { name = "Clash Verge" },
  { name = "Kindavim" },
}

local items = {}

local function icon_for(app_name)
  return app_icons[app_name] or app_icons["Default"]
end

for i, app in ipairs(apps) do
  local name = app.name
  local proc = app.process or name

  local item = sbar.add("item", "widgets.resident." .. i, {
    position = "right",
    drawing = false,
    icon = { drawing = false },
    label = {
      string = icon_for(name),
      font = "sketchybar-app-font:Regular:16.0",
      color = colors.white,
      padding_left = 6,
      padding_right = 6,
    },
    click_script = app.click_script or ("open -a \"" .. name .. "\""),
    update_freq = app.update_freq or 5,
  })

  item:subscribe({ "routine", "system_woke" }, function()
    sbar.exec("pgrep -x \"" .. proc .. "\" >/dev/null 2>&1; echo $?", function(code)
      local running = tostring(code):match("^0") ~= nil
      item:set({ drawing = running })
    end)
  end)

  table.insert(items, item.name)
end

return items
