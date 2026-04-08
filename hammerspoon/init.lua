local log = hs.logger.new("scratchpad", "info")

local YABAI_BIN = "/opt/homebrew/bin/yabai"
local TOGGLE_MODS = { "alt" }
local TOGGLE_KEY = "s"
local SWITCH_MODS = { "alt", "shift" }
local SWITCH_KEY = "s"

local SCRATCHPADS = {
  emacs = {
    key = "emacs",
    label = "Emacs",
    app = "Emacs",
    geometry = {
      widthRatio = 0.6528,
      heightRatio = 0.5568,
      rightMarginRatio = 0.0122,
      bottomMarginRatio = 0.0251,
    },
  },
  obsidian = {
    key = "obsidian",
    label = "Obsidian",
    app = "Obsidian",
    geometry = {
      widthRatio = 0.62,
      heightRatio = 0.72,
      rightMarginRatio = 0.02,
      bottomMarginRatio = 0.03,
    },
  },
}

local state = {
  cachedWindowIds = {},
  currentTarget = "emacs",
}

local function scratchpadFor(target)
  return target and SCRATCHPADS[string.lower(target)] or nil
end

local function ensureSwitchHud()
  if state.switchHud then return state.switchHud end

  local screenFrame = hs.screen.mainScreen():frame()
  local width = 260
  local height = 56
  local x = math.floor(screenFrame.x + (screenFrame.w - width) / 2)
  local y = math.floor(screenFrame.y + screenFrame.h - height - 90)

  local canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })
  canvas:level(hs.canvas.windowLevels.overlay)
  canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  canvas[1] = {
    type = "rectangle",
    action = "fill",
    roundedRectRadii = { xRadius = 16, yRadius = 16 },
    fillColor = { hex = "#1f2335", alpha = 0.92 },
  }
  canvas[2] = {
    type = "text",
    text = "Scratchpad: Emacs",
    textSize = 20,
    textColor = { hex = "#c0caf5", alpha = 1 },
    textAlignment = "center",
    frame = { x = 0, y = 14, w = width, h = 28 },
  }
  canvas:alpha(0)

  state.switchHud = canvas
  return canvas
end

local function showSwitchAlert(text)
  local hud = ensureSwitchHud()
  hud[2].text = text
  hud:show()
  hud:alpha(1)

  if state.switchHudTimer then
    state.switchHudTimer:stop()
    state.switchHudTimer = nil
  end

  state.switchHudTimer = hs.timer.doAfter(0.7, function()
    if state.switchHud then
      state.switchHud:hide(0.12)
    end
  end)
end

local function appByName(appName)
  return hs.application.get(appName)
end

local function appIsFrontmost(appName)
  local frontmostApp = hs.application.frontmostApplication()
  return frontmostApp and frontmostApp:name() == appName
end

local function decodeJson(output, label)
  if not output or output == "" then return nil end
  local cleaned = tostring(output):gsub("^%s+", ""):gsub("%s+$", "")
  local data = hs.json.decode(cleaned)
  if type(data) == "table" then return data end
  log.e("Failed to decode " .. label .. " JSON. Raw output: " .. cleaned)
  return nil
end

local function runYabai(args)
  local cmd = YABAI_BIN .. " -m " .. args
  local output, ok, _, rc = hs.execute(cmd)
  if not ok then
    log.e("yabai command failed (" .. tostring(rc) .. "): " .. cmd .. " :: " .. tostring(output))
  end
  return ok, output
end

local function currentSpaceIndex()
  local ok, output = runYabai("query --spaces --space")
  if not ok then return nil end
  local data = decodeJson(output, "space query")
  return data and data.index or nil
end

local function currentDisplayFrame()
  local ok, output = runYabai("query --displays --display")
  if not ok then return nil end
  local data = decodeJson(output, "display query")
  if not data or type(data.frame) ~= "table" then return nil end
  return data.frame
end

local function queryWindow(windowId)
  local ok, output = runYabai("query --windows --window " .. windowId)
  if not ok then return nil end
  return decodeJson(output, "window query")
end

local function queryAllWindows()
  local ok, output = runYabai("query --windows")
  if not ok then return nil end
  return decodeJson(output, "windows query")
end

local function focusWindow(windowId)
  runYabai("window --focus " .. windowId)
end

local function moveWindowToSpace(windowId, targetSpace)
  local ok = runYabai("window " .. windowId .. " --space " .. targetSpace)
  if not ok then return false end

  for _ = 1, 4 do
    hs.timer.usleep(40000)
    local data = queryWindow(windowId)
    if data and tostring(data.space) == tostring(targetSpace) then
      log.i("Moved window " .. windowId .. " to space " .. targetSpace)
      return true
    end
  end

  local final = queryWindow(windowId)
  log.w("Move not confirmed. target=" .. tostring(targetSpace) .. " actual=" .. tostring(final and final.space))
  return false
end

local function findAppWindow(appName)
  local windows = queryAllWindows()
  if type(windows) ~= "table" then return nil end

  for _, win in ipairs(windows) do
    if win.app == appName and not win["is-minimized"] then
      state.cachedWindowIds[appName] = win.id
      return win
    end
  end

  return nil
end

local function cachedAppWindow(appName)
  local cachedWindowId = state.cachedWindowIds[appName]
  if cachedWindowId then
    local win = queryWindow(cachedWindowId)
    if win and win.app == appName then return win end
    state.cachedWindowIds[appName] = nil
  end
  return findAppWindow(appName)
end

local function appWindowIsVisibleInSpace(win, targetSpace)
  if not win then return false end
  return tostring(win.space) == tostring(targetSpace)
    and not win["is-hidden"]
    and not win["is-minimized"]
end

local function withAppWindow(appName, retries, delaySeconds, callback)
  local function attempt(remaining)
    local win = cachedAppWindow(appName)
    if win then
      callback(win)
      return
    end
    if remaining <= 0 then
      callback(nil)
      return
    end
    hs.timer.doAfter(delaySeconds, function() attempt(remaining - 1) end)
  end
  attempt(retries)
end

local function applyScratchpadGeometry(windowId, geometry)
  local frame = currentDisplayFrame()
  if not frame then
    log.w("Could not determine current display frame")
    return false
  end

  local win = queryWindow(windowId)
  if not win then
    log.w("Could not query window before applying geometry")
    return false
  end

  local displayX = math.floor(frame.x)
  local displayY = math.floor(frame.y)
  local displayW = math.floor(frame.w)
  local displayH = math.floor(frame.h)
  local targetW = math.floor(displayW * geometry.widthRatio)
  local targetH = math.floor(displayH * geometry.heightRatio)
  local rightMargin = math.floor(displayW * geometry.rightMarginRatio)
  local bottomMargin = math.floor(displayH * geometry.bottomMarginRatio)
  local targetX = displayX + displayW - targetW - rightMargin
  local targetY = displayY + displayH - targetH - bottomMargin

  if not win["is-floating"] then
    runYabai("window " .. windowId .. " --toggle float")
  end

  runYabai("window " .. windowId .. " --grid 1:1:0:0:1:1")
  runYabai("window " .. windowId .. " --resize abs:" .. targetW .. ":" .. targetH)
  runYabai("window " .. windowId .. " --move abs:" .. targetX .. ":" .. targetY)
  log.i("Applied scratchpad geometry: " .. targetW .. "x" .. targetH .. " @ " .. targetX .. "," .. targetY)
  return true
end

local function hideApp(appName)
  local app = appByName(appName)
  local win = cachedAppWindow(appName)

  if win and not win["is-minimized"] then
    runYabai("window --minimize " .. win.id)
  end

  if app then
    app:hide()
    log.i("Hiding " .. appName)
    return true
  end

  return win ~= nil
end

local function hideAllScratchpads()
  for _, pad in pairs(SCRATCHPADS) do
    hideApp(pad.app)
  end
end

local function revealScratchpad(targetSpace, pad)
  local app = appByName(pad.app)

  if not targetSpace then
    log.w("Could not determine current yabai space; falling back to app activate")
    if app then app:activate() else hs.application.launchOrFocus(pad.app) end
    return true
  end

  if not app then
    hs.application.launchOrFocus(pad.app)
    log.i("Launching " .. pad.app)
  else
    app:unhide()
  end

  withAppWindow(pad.app, 20, 0.1, function(win)
    if not win then
      log.w("yabai did not report a window for " .. pad.app)
      local launched = appByName(pad.app)
      if launched then launched:activate() end
      return
    end

    if win["is-minimized"] then
      runYabai("window --deminimize " .. win.id)
      hs.timer.usleep(50000)
    end

    if tostring(win.space) ~= tostring(targetSpace) then
      local moved = moveWindowToSpace(win.id, targetSpace)
      if not moved then
        local fallbackApp = appByName(pad.app)
        if fallbackApp then fallbackApp:activate() end
        log.w("Move failed; fell back to app activate")
        return
      end
    end

    applyScratchpadGeometry(win.id, pad.geometry)
    focusWindow(win.id)
    log.i("Moved and focused " .. pad.app .. " window")
  end)

  return true
end

function toggleScratchpad(target)
  local pad = scratchpadFor(target)
  if not pad then
    hs.alert.show("Unknown scratchpad: " .. tostring(target))
    log.w("Unknown scratchpad target: " .. tostring(target))
    return false
  end

  log.i("toggleScratchpad(" .. pad.key .. ") called")

  local app = appByName(pad.app)
  local targetSpace = currentSpaceIndex()
  local existingWin = cachedAppWindow(pad.app)

  if targetSpace and existingWin and appWindowIsVisibleInSpace(existingWin, targetSpace) and app then
    return hideApp(pad.app)
  end

  if appIsFrontmost(pad.app) and app then
    return hideApp(pad.app)
  end

  return revealScratchpad(targetSpace, pad)
end

local function cycleScratchpadTarget()
  hideAllScratchpads()
  if state.currentTarget == "emacs" then
    state.currentTarget = "obsidian"
  else
    state.currentTarget = "emacs"
  end

  local pad = scratchpadFor(state.currentTarget)
  if pad then
    hs.alert.show("Scratchpad: " .. pad.label)
    log.i("Switched scratchpad target to " .. pad.key)
  end
end

local function toggleCurrentScratchpad()
  return toggleScratchpad(state.currentTarget)
end

hs.hotkey.bind(TOGGLE_MODS, TOGGLE_KEY, toggleCurrentScratchpad)
hs.hotkey.bind(SWITCH_MODS, SWITCH_KEY, cycleScratchpadTarget)

hs.urlevent.bind("scratchpad", function(_, params, _)
  local target = params and (params.target or params.app)
  if not target then
    hs.alert.show("Missing scratchpad target")
    log.w("scratchpad URL called without target/app parameter")
    return
  end
  state.currentTarget = string.lower(target)
  toggleScratchpad(target)
end)

log.i("Hammerspoon config loaded: alt+s toggles current scratchpad, alt+shift+s switches Emacs/Obsidian, plus hammerspoon://scratchpad?target=emacs|obsidian")
