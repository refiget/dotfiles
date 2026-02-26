local colors = require("colors")
local settings = require("settings")
local space_state = require("services.space_state")
local has_lunajson, lunajson = pcall(require, "lunajson")

-- Notch focus pills
local notch_gap = settings.notch_gap or 80
local focus_apps_extra_gap = settings.focus_apps_extra_gap or 0

local focus_index_gap = settings.focus_index_gap
local focus_index_pad_left = settings.focus_index_pad_left or 0
local focus_apps_gap = settings.focus_apps_gap

local index_gap = (type(focus_index_gap) == "number") and focus_index_gap or notch_gap
local apps_gap = (type(focus_apps_gap) == "number") and focus_apps_gap or (notch_gap + focus_apps_extra_gap)

local function space_display(id)
  return tostring(id)
end

local focus_index = sbar.add("item", "space.focus.index", {
  position = "center",
  padding_left = focus_index_pad_left,
  padding_right = index_gap,
  icon = { drawing = false },
  label = {
    font = { family = settings.font.numbers, size = 18.0 },
    color = colors.white,
    string = space_display(space_state.current_space),
    padding_left = 14,
    padding_right = 14,
  },
  background = {
    color = colors.transparent,
    corner_radius = 10,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
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
  background = {
    color = colors.transparent,
    corner_radius = 999,
    height = 26,
    border_width = 2,
    border_color = colors.bg2,
  },
})

local current_apps_gap = apps_gap

local function set_apps_gap(gap)
  local rounded = math.max(0, math.floor((tonumber(gap) or current_apps_gap) + 0.5))
  current_apps_gap = rounded
  focus_apps:set({ padding_left = rounded })
end

local function get_outer_rect(q)
  if not q then return nil end

  if q.bounding_rects then
    for _, rect in pairs(q.bounding_rects) do
      if rect and rect.origin and rect.size then
        local x = tonumber(rect.origin[1])
        local w = tonumber(rect.size[1])
        if x and w then
          return { left = x, right = x + w }
        end
      end
    end
  end

  local g = q.geometry
  if g then
    local x = tonumber(g.x)
    local w = tonumber(g.width)
    if x and w then
      return { left = x - (w / 2), right = x + (w / 2) }
    end
  end

  return nil
end

-- Dynamic symmetry by INNER content edges:
-- left target  = right inner edge of index content
-- right target = left inner edge of apps content
local function rebalance_to_screen_center()
  local iq = focus_index:query()
  local aq = focus_apps:query()
  if not iq or not aq then return end

  local irect = get_outer_rect(iq)
  local arect = get_outer_rect(aq)
  if not irect or not arect then return end

  local i_label_pr = tonumber(iq.label and iq.label.padding_right) or 0
  local a_label_pl = tonumber(aq.label and aq.label.padding_left) or 0

  local index_right_inner = irect.right - i_label_pr
  local apps_left_inner = arect.left + a_label_pl

  if not has_lunajson then
    return
  end

  sbar.exec("sketchybar --query displays", function(raw)
    local ok, displays = pcall(lunajson.decode, raw)
    if not ok or type(displays) ~= "table" or type(displays[1]) ~= "table" then
      return
    end

    local frame = displays[1].frame or {}
    local cx = (tonumber(frame.x) or 0) + (tonumber(frame.w) or 0) / 2

    local d_left = cx - index_right_inner
    local d_right = apps_left_inner - cx
    local err = d_right - d_left

    if math.abs(err) >= 1 then
      set_apps_gap(current_apps_gap - err)
    end
  end)
end

local align_observer = sbar.add("item", "space.focus.align_observer", {
  drawing = false,
  updates = true,
  update_freq = 2,
})

align_observer:subscribe({ "forced", "routine", "system_woke", "display_change" }, rebalance_to_screen_center)

local M = {}

function M.set_space(space_id)
  space_state.set_current_space(space_id)
  focus_index:set({ label = { string = space_display(space_state.current_space) } })
  focus_apps:set({ label = { string = space_state.get_apps_for_space(space_state.current_space) } })
  rebalance_to_screen_center()
end

function M.set_apps_for_space(space_id, icon_line)
  space_state.set_apps_for_space(space_id, icon_line)
  if tonumber(space_id) == space_state.current_space then
    focus_apps:set({ label = { string = icon_line } })
    rebalance_to_screen_center()
  end
end

-- Initial pass after module load
rebalance_to_screen_center()

return M
