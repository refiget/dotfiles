local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume_percent = sbar.add("item", "widgets.volume1", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "??%",
    padding_left = -1,
    drawing = false,
    font = { family = settings.font.numbers }
  },
})

local volume_icon = sbar.add("item", "widgets.volume2", {
  position = "right",
  padding_right = -1,
  popup = { align = "center" },
  icon = {
    string = icons.volume._100,
    width = 0,
    align = "left",
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = {
    width = 25,
    align = "left",
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_icon.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob= {
      -- Avoid SF Symbols glyphs here; use plain unicode so it never becomes tofu/garbage.
      string = "●",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})


local function flash_percent()
  volume_percent:set({ label = { drawing = true } })
  sbar.delay(2, function()
    volume_percent:set({ label = { drawing = false } })
  end)
end

volume_percent:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  volume_icon:set({ label = icon })
  volume_percent:set({ label = volume .. "%" })
  volume_slider:set({ slider = { percentage = volume } })
  flash_percent()
end)

local function volume_collapse_details()
  local drawing = volume_icon:query().popup.drawing == "on"
  if not drawing then return end
  volume_icon:set({ popup = { drawing = false } })
  sbar.remove('/volume.device\\.*/')
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume_icon:query().popup.drawing == "off"
  if should_draw then
    volume_icon:set({ popup = { drawing = true } })

    -- Optional dependency: SwitchAudioSource (device chooser). If missing, keep
    -- the slider popup only (no errors/no noise).
    sbar.exec("command -v SwitchAudioSource >/dev/null 2>&1 && echo ok || echo missing", function(res)
      if res:find("missing") then
        return
      end

      sbar.exec("SwitchAudioSource -t output -c", function(result)
        current_audio_device = result:sub(1, -2)
        sbar.exec("SwitchAudioSource -a -t output", function(available)
          local current = current_audio_device
          local counter = 0

          for device in string.gmatch(available, '[^\r\n]+') do
            local color = colors.grey
            if current == device then
              color = colors.white
            end

            sbar.add("item", "volume.device." .. counter, {
              position = "popup." .. volume_icon.name,
              width = popup_width,
              align = "center",
              label = { string = device, color = color },
              click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey .. ' --set $NAME label.color=' .. colors.white,
            })

            counter = counter + 1
          end
        end)
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end

  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", function(env)
  flash_percent()
  volume_scroll(env)
end)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)

-- Auto-hide popup when the cursor leaves the bar, or when focus/space changes.
volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
volume_icon:subscribe("mouse.exited.global", volume_collapse_details)
volume_icon:subscribe({"front_app_switched", "space_change", "display_change"}, volume_collapse_details)
volume_percent:subscribe({"front_app_switched", "space_change", "display_change"}, volume_collapse_details)

volume_percent:subscribe("mouse.scrolled", function(env)
  flash_percent()
  volume_scroll(env)
end)

return { volume_icon.name, volume_percent.name }
