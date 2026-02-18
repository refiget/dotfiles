local settings = require("settings")
local tbl = require("utils.tbl")

local group = require("items.widgets.group")

local widgets = {
    "battery",
    "volume",
    "wifi",
    "background_apps",
}

local group_items = {}

for _, widget in ipairs(widgets) do
  if tbl.get_index_by_value(settings.hide_widgets, widget) == -1 then
    local ok, mod = pcall(require, "items.widgets." .. widget)
    if ok and type(mod) == "table" then
      for _, name in ipairs(mod) do
        table.insert(group_items, name)
      end
    end
  end
end

group.make_right_bracket(group_items)
