local colors = require("colors")
local settings = require("settings")
local space_state = require("services.space_state")

-- Notch focus pills
local notch_gap = settings.notch_gap or 80
local focus_apps_extra_gap = settings.focus_apps_extra_gap or 0

local focus_index_gap = settings.focus_index_gap
local focus_index_pad_left = settings.focus_index_pad_left or 0
local focus_apps_gap = settings.focus_apps_gap

local index_gap = (type(focus_index_gap) == "number") and focus_index_gap or notch_gap
local apps_gap = (type(focus_apps_gap) == "number") and focus_apps_gap or (notch_gap + focus_apps_extra_gap)

local focus_index = sbar.add("item", "space.focus.index", {
  position = "center",
  padding_left = focus_index_pad_left,
  padding_right = index_gap,
  icon = { drawing = false },
  label = {
    font = { family = settings.font.numbers, size = 13.0 },
    color = colors.white,
    string = tostring(space_state.current_space),
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
    string = space_state.get_apps_for_space(space_state.current_space),
    padding_left = 10,
    padding_right = 10,
    y_offset = -1,
  },
  background = { color = colors.bg1, corner_radius = 999, height = 26 },
})

local M = {}

function M.set_space(space_id)
  space_state.set_current_space(space_id)
  focus_index:set({ label = { string = tostring(space_state.current_space) } })
  focus_apps:set({ label = { string = space_state.get_apps_for_space(space_state.current_space) } })
end

function M.set_apps_for_space(space_id, icon_line)
  space_state.set_apps_for_space(space_id, icon_line)
  if tonumber(space_id) == space_state.current_space then
    focus_apps:set({ label = { string = icon_line } })
  end
end

return M
