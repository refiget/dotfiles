local log = hs.logger.new("scratchpad", "info")

-- -----------------------------------------------------------------------------
-- Config
-- -----------------------------------------------------------------------------

local EMACS_APP_NAME = "Emacs"
local HOTKEY_MODS = { "alt" }
local HOTKEY_KEY = "s"
local YABAI_BIN = "/opt/homebrew/bin/yabai"

local GEOMETRY = {
  widthRatio = 0.6528,
  heightRatio = 0.5568,
  rightMarginRatio = 0.0122,
  bottomMarginRatio = 0.0251,
}

local state = {
  cachedWindowId = nil,
}

-- -----------------------------------------------------------------------------
-- Generic helpers
-- -----------------------------------------------------------------------------

local function emacsApp()
  return hs.application.get(EMACS_APP_NAME)
end

local function emacsIsFrontmost()
  local frontmostApp = hs.application.frontmostApplication()
  return frontmostApp and frontmostApp:name() == EMACS_APP_NAME
end

local function decodeJson(output, label)
  if not output or output == "" then return nil end

  local cleaned = tostring(output):gsub("^%s+", ""):gsub("%s+$", "")
  local data = hs.json.decode(cleaned)

  if type(data) == "table" then
    return data
  end

  log.e("Failed to decode " .. label .. " JSON. Raw output: " .. cleaned)
  return nil
end

-- -----------------------------------------------------------------------------
-- yabai helpers
-- -----------------------------------------------------------------------------

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

  local data = decodeJson(output, "window query")
  if data and data.app == EMACS_APP_NAME then
    state.cachedWindowId = data.id
    return data
  end

  return nil
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
      log.i("Moved Emacs window " .. windowId .. " to space " .. targetSpace)
      return true
    end
  end

  local final = queryWindow(windowId)
  log.w("Move not confirmed. target=" .. tostring(targetSpace) .. " actual=" .. tostring(final and final.space))
  return false
end

-- -----------------------------------------------------------------------------
-- Emacs window lookup/cache
-- -----------------------------------------------------------------------------

local function findEmacsWindow()
  local windows = queryAllWindows()
  if type(windows) ~= "table" then return nil end

  for _, win in ipairs(windows) do
    if win.app == EMACS_APP_NAME and not win["is-minimized"] then
      state.cachedWindowId = win.id
      return win
    end
  end

  return nil
end

local function cachedEmacsWindow()
  if state.cachedWindowId then
    local win = queryWindow(state.cachedWindowId)
    if win then
      return win
    end
    state.cachedWindowId = nil
  end

  return findEmacsWindow()
end

local function emacsWindowIsVisibleInSpace(win, targetSpace)
  if not win then return false end

  return tostring(win.space) == tostring(targetSpace)
    and not win["is-hidden"]
    and not win["is-minimized"]
end

local function withEmacsWindow(retries, delaySeconds, callback)
  local function attempt(remaining)
    local win = cachedEmacsWindow()
    if win then
      callback(win)
      return
    end

    if remaining <= 0 then
      callback(nil)
      return
    end

    hs.timer.doAfter(delaySeconds, function()
      attempt(remaining - 1)
    end)
  end

  attempt(retries)
end

-- -----------------------------------------------------------------------------
-- Scratchpad geometry/actions
-- -----------------------------------------------------------------------------

local function applyScratchpadGeometry(windowId)
  local frame = currentDisplayFrame()
  if not frame then
    log.w("Could not determine current display frame")
    return false
  end

  local win = queryWindow(windowId)
  if not win then
    log.w("Could not query Emacs window before applying geometry")
    return false
  end

  local displayX = math.floor(frame.x)
  local displayY = math.floor(frame.y)
  local displayW = math.floor(frame.w)
  local displayH = math.floor(frame.h)

  local targetW = math.floor(displayW * GEOMETRY.widthRatio)
  local targetH = math.floor(displayH * GEOMETRY.heightRatio)
  local rightMargin = math.floor(displayW * GEOMETRY.rightMarginRatio)
  local bottomMargin = math.floor(displayH * GEOMETRY.bottomMarginRatio)
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

local function hideEmacs()
  local app = emacsApp()
  if not app then return false end

  app:hide()
  log.i("Hiding Emacs")
  return true
end

local function revealEmacsInSpace(targetSpace)
  local app = emacsApp()

  if not targetSpace then
    log.w("Could not determine current yabai space; falling back to app activate")
    if app then
      app:activate()
    else
      hs.application.launchOrFocus(EMACS_APP_NAME)
    end
    return true
  end

  if not app then
    hs.application.launchOrFocus(EMACS_APP_NAME)
    log.i("Launching Emacs")
  else
    app:unhide()
  end

  withEmacsWindow(20, 0.1, function(win)
    if not win then
      log.w("yabai did not report an Emacs window")
      local launched = emacsApp()
      if launched then launched:activate() end
      return
    end

    if tostring(win.space) ~= tostring(targetSpace) then
      local moved = moveWindowToSpace(win.id, targetSpace)
      if not moved then
        local fallbackApp = emacsApp()
        if fallbackApp then fallbackApp:activate() end
        log.w("Move failed; fell back to app activate")
        return
      end
    end

    applyScratchpadGeometry(win.id)
    focusWindow(win.id)
    log.i("Moved and focused Emacs window")
  end)

  return true
end

function toggleEmacsScratchpad()
  log.i("toggleEmacsScratchpad() called")

  local app = emacsApp()
  local targetSpace = currentSpaceIndex()
  local existingWin = cachedEmacsWindow()

  if targetSpace and existingWin and emacsWindowIsVisibleInSpace(existingWin, targetSpace) and app then
    return hideEmacs()
  end

  if emacsIsFrontmost() and app then
    return hideEmacs()
  end

  return revealEmacsInSpace(targetSpace)
end

-- -----------------------------------------------------------------------------
-- Entrypoints
-- -----------------------------------------------------------------------------

hs.hotkey.bind(HOTKEY_MODS, HOTKEY_KEY, toggleEmacsScratchpad)

hs.urlevent.bind("toggle-emacs-scratchpad", function(_, _, _)
  toggleEmacsScratchpad()
end)

log.i("Hammerspoon config loaded: alt+s and hammerspoon://toggle-emacs-scratchpad are ready")
