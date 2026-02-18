local app_icons = require("helpers.app_icons")

local M = {
  current_space = 1,
  apps_by_space = { [1] = "—", [2] = "—", [3] = "—" },
}

function M.format_apps_line(apps_table, max_apps)
  max_apps = max_apps or 4

  local app_names = {}
  for app, _ in pairs(apps_table or {}) do
    table.insert(app_names, app)
  end
  table.sort(app_names)

  local icons_out = {}
  local n_apps = #app_names
  for _, app in ipairs(app_names) do
    if #icons_out < max_apps then
      local lookup = app_icons[app]
      local icon = ((lookup == nil) and app_icons["Default"] or lookup)
      table.insert(icons_out, icon)
    end
  end

  local icon_line = table.concat(icons_out, "")
  if n_apps == 0 then
    icon_line = "—"
  elseif n_apps > max_apps then
    icon_line = icon_line .. " +" .. tostring(n_apps - max_apps)
  end

  return icon_line
end

function M.set_current_space(space_id)
  if type(space_id) ~= "number" then
    space_id = tonumber(space_id)
  end
  if not space_id then
    return
  end
  M.current_space = space_id
end

function M.set_apps_for_space(space_id, icon_line)
  if type(space_id) ~= "number" then
    space_id = tonumber(space_id)
  end
  if not space_id then
    return
  end
  M.apps_by_space[space_id] = icon_line
end

function M.get_apps_for_space(space_id)
  return M.apps_by_space[space_id] or "—"
end

return M
