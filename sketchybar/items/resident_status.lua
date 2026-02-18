local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

-- Right-side: show only key resident background tools (icon-only, like left-side app glyphs).
-- These are intentionally minimal and only draw when the process is present.

local resident = settings.resident_status or {
  {
    name = "Clash Verge",
    -- Show a network/proxy indicator (SF Symbol) rather than an app-font icon.
    glyph = icons.wifi.vpn,
    glyph_font = "SF Pro:Regular:14.0",
    -- The UI process is "clash-verge" (lowercase) on your machine; also track mihomo core.
    pattern = "clash%-verge|verge%-mihomo|clash%-verge%-service",
  },
  {
    name = "Keyboard Maestro",
    pattern = "Keyboard Maestro Engine",
  },
  {
    name = "kindaVim",
    pattern = "kindaVim",
  },
  {
    name = "Karabiner-Elements",
    -- Use app-font keyboard icon (available in sketchybar-app-font)
    glyph = ":keyboard_maestro:",
    pattern = "Karabiner%-Menu|karabiner_console_user_server|Karabiner%-Core%-Service",
  },
}

local items = {}

local function icon_for(app_name)
  return app_icons[app_name] or app_icons["Default"]
end

for i, app in ipairs(resident) do
  local label_string = app.glyph or icon_for(app.name)
  local label_font = app.glyph_font or "sketchybar-app-font:Regular:16.0"

  local item = sbar.add("item", "resident." .. i, {
    position = "right",
    drawing = false,
    icon = { drawing = false },
    label = {
      drawing = true,
      string = label_string,
      font = label_font,
      color = colors.white,
      padding_left = 6,
      padding_right = 6,
    },
    click_script = app.click_script or ("open -a \"" .. app.name .. "\""),
    update_freq = app.update_freq or 5,
  })

  item:subscribe({ "forced", "routine", "system_woke" }, function()
    local pat = app.pattern
    -- Use pgrep -f for robustness (matches full command line).
    sbar.exec("pgrep -f \"" .. pat .. "\" >/dev/null 2>&1; echo $?", function(code)
      local running = tostring(code):match("^0") ~= nil
      item:set({ drawing = running })
    end)
  end)

  table.insert(items, item.name)
end

-- Add a subtle trailing padding so the right edge doesn't feel cramped.
sbar.add("item", "resident.padding", {
  position = "right",
  width = 10,
  drawing = true,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
})

table.insert(items, "resident.padding")

return items
