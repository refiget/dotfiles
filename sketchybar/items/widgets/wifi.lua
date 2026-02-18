local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0")

local popup_width = 220

local wifi_up = sbar.add("item", "widgets.wifi1", {
  drawing = false,
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    string = icons.wifi.upload,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 8.5,
    },
    width = 38,
    align = "right",
    color = colors.red,
    string = "???",
  },
  y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
  drawing = false,
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    string = icons.wifi.download,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 8.5,
    },
    width = 38,
    align = "right",
    color = colors.blue,
    string = "???",
  },
  y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  popup = { align = "center", height = 30 },
  icon = {
    font = {
      style = settings.font.style_map["Bold"],
      size = 16.0,
    },
  },
  label = { drawing = false },
})

-- Background around the item
local ssid = sbar.add("item", {
  position = "popup." .. wifi.name,
  width = popup_width,
  icon = {
    font = {
      style = settings.font.style_map["Bold"]
    },
    string = icons.wifi.router,
  },
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"]
    },
    max_chars = 12,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15
  }
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 24,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

local function format_rate(s)
  if not s or s == "" then return "—" end
  -- Common formats: "000 Bps" or "021KBps" / "1.2MBps"
  if s:match("^0+%s*Bps$") or s:match("^000%s+Bps$") or s:match("^000") then
    return "—"
  end
  local out = s:gsub("Bps$", "/s")
  out = out:gsub("bps$", "/s")
  out = out:gsub("%s+", "")
  -- strip leading zeros in the number part
  out = out:gsub("^0+(%d)", "%1")
  -- Make it shorter: KB/s -> K/s, MB/s -> M/s, GB/s -> G/s
  out = out:gsub("KB/s", "K/s")
  out = out:gsub("MB/s", "M/s")
  out = out:gsub("GB/s", "G/s")
  return out
end

local hide_timer = 0

local function show_rates()
  wifi_up:set({ drawing = true })
  wifi_down:set({ drawing = true })
end

local function hide_rates_later()
  hide_timer = hide_timer + 1
  local token = hide_timer
  sbar.delay(3, function()
    if token ~= hide_timer then return end
    wifi_up:set({ drawing = false })
    wifi_down:set({ drawing = false })
  end)
end

wifi_up:subscribe("network_update", function(env)
  local up = format_rate(env.upload)
  local down = format_rate(env.download)

  local up_color = (up == "—") and colors.grey or colors.red
  local down_color = (down == "—") and colors.grey or colors.blue

  wifi_up:set({
    icon = { color = up_color },
    label = { string = up, color = up_color }
  })
  wifi_down:set({
    icon = { color = down_color },
    label = { string = down, color = down_color }
  })

  if up == "—" and down == "—" then
    hide_rates_later()
  else
    show_rates()
    hide_rates_later()
  end
end)

wifi:subscribe({"wifi_change", "system_woke", "front_app_switched", "space_change", "display_change"}, function(env)
  sbar.exec("ipconfig getifaddr en0", function(ip)
    local connected = not (ip == "")
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    })
  end)
  sbar.exec("scutil --nc list | grep 'Connected'", function(result)
    local connected = not (result == "")
    if connected then
      wifi:set({
        icon = {
          string = icons.wifi.vpn,
          color = colors.white,
        },
      })
    end
  end)
end)

local function hide_details()
  wifi:set({ popup = { drawing = false } })
end

local function toggle_details(env)
  local should_draw = wifi:query().popup.drawing == "off"
  if not should_draw then
    hide_details()
    return
  end

  -- Privacy-first default: show SSID only.
  -- Advanced details (hostname/ip/router) only on right-click or shift.
  local advanced = (env and (env.BUTTON == "right" or env.MODIFIER == "shift"))

  wifi:set({ popup = { drawing = true }})

  -- Always show SSID (truncated)
  sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
    ssid:set({ label = result })
  end)

  -- Hide sensitive fields unless explicitly requested
  hostname:set({ drawing = advanced })
  ip:set({ drawing = advanced })
  mask:set({ drawing = advanced })
  router:set({ drawing = advanced })

  if not advanced then return end

  sbar.exec("networksetup -getcomputername", function(result)
    hostname:set({ label = result })
  end)
  sbar.exec("ipconfig getifaddr en0", function(result)
    ip:set({ label = result })
  end)
  sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
    mask:set({ label = result })
  end)
  sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
    router:set({ label = result })
  end)
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
-- Auto-hide popup when leaving the bar, or when focus/space changes.
wifi:subscribe("mouse.exited.global", hide_details)
ssid:subscribe("mouse.exited.global", hide_details)
hostname:subscribe("mouse.exited.global", hide_details)
ip:subscribe("mouse.exited.global", hide_details)
mask:subscribe("mouse.exited.global", hide_details)
router:subscribe("mouse.exited.global", hide_details)

wifi:subscribe({"front_app_switched", "space_change", "display_change"}, hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align="center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)

return { wifi.name, wifi_up.name, wifi_down.name }
