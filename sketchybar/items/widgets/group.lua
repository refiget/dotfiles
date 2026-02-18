local colors = require("colors")
local settings = require("settings")

local M = {}

function M.make_right_bracket(item_names)
  if not item_names or #item_names == 0 then
    return nil
  end

  local bracket = sbar.add("bracket", "widgets.right.bracket", item_names, {
    background = { color = colors.bg1, corner_radius = 999, height = 28 },
  })

  -- Single padding for the whole right widget group
  sbar.add("item", "widgets.right.padding", {
    position = "right",
    width = settings.group_paddings,
  })

  return bracket
end

return M
