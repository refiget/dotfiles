local colors = require("colors")
local settings = require("settings")

local ICON_IDLE = utf8.char(0xF0023)

-- 动画帧：f144a, f1440..f1449
local ACTIVE_ICONS = { utf8.char(0xF144A) }
for cp = 0xF1440, 0xF1449 do
  ACTIVE_ICONS[#ACTIVE_ICONS + 1] = utf8.char(cp)
end

-- 在 config.json 中配置："focus_timer_minutes": 30
local DURATION_MINUTES = tonumber(settings.focus_timer_minutes) or 30
local DURATION_SECONDS = math.max(1, math.floor(DURATION_MINUTES * 60))

-- 依赖：brew 安装的 confetti CLI（兼容 ARM/Intel macOS）
local CONFETTI_CMD = "if command -v confetti >/dev/null 2>&1; then confetti -p intense; elif [ -x /opt/homebrew/bin/confetti ]; then /opt/homebrew/bin/confetti -p intense; elif [ -x /usr/local/bin/confetti ]; then /usr/local/bin/confetti -p intense; fi"

-- 固定“最大文本宽度”，避免秒数跳动（按 XX:88 预留）
local LAYOUT = {
  icon = { padding_left = 5, padding_right = 3 },
  label = { width = 46, align = "left", padding_left = 0, padding_right = 8 },
}

local active = false
local frame = 1
local end_ts = nil

local capsule = sbar.add("item", "focus.capsule", {
  position = "right",
  updates = true,
  update_freq = 1,
  icon = {
    drawing = true,
    string = ICON_IDLE,
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    padding_left = LAYOUT.icon.padding_left,
    padding_right = LAYOUT.icon.padding_right,
  },
  label = {
    drawing = true,
    string = "XX:XX",
    color = colors.white,
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    width = LAYOUT.label.width,
    align = LAYOUT.label.align,
    padding_left = LAYOUT.label.padding_left,
    padding_right = LAYOUT.label.padding_right,
  },
  background = {
    color = colors.transparent,
    corner_radius = 999,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
  padding_left = 0,
  padding_right = 5,
})

local function set_idle()
  active = false
  frame = 1
  end_ts = nil
  capsule:set({
    icon = { string = ICON_IDLE },
    label = { string = "XX:XX" },
  })
end

local function trigger_confetti()
  sbar.exec(CONFETTI_CMD)
end

local function render_active()
  if not active or not end_ts then return end

  local remain = end_ts - os.time()
  if remain <= 0 then
    trigger_confetti()
    set_idle()
    return
  end

  local sec = remain % 60
  capsule:set({
    icon = { string = ACTIVE_ICONS[frame] },
    label = { string = string.format("XX:%02d", sec) },
  })

  frame = (frame % #ACTIVE_ICONS) + 1
end

set_idle()

capsule:subscribe({ "routine", "forced", "system_woke" }, function()
  if active then render_active() end
end)

capsule:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    set_idle()
    return
  end

  if active then
    set_idle()
    return
  end

  active = true
  frame = 1
  end_ts = os.time() + DURATION_SECONDS
  render_active()
end)

return { capsule.name }
