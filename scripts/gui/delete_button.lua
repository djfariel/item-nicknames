local M = {}

M.style = "item_nicknames_row_delete_button"
M.width = 24
M.height = 32

---@param parent LuaGuiElement
---@param options table name, tooltip?, tags?, index?
function M.add(parent, options)
  options = options or {}

  local props = {
    type = "sprite-button",
    name = options.name,
    style = M.style,
    sprite = "utility/trash",
    hovered_sprite = "utility/trash_white",
    clicked_sprite = "utility/trash_white",
    tooltip = options.tooltip,
    tags = options.tags,
  }

  local button
  if options.index then
    button = parent.add(props, options.index)
  else
    button = parent.add(props)
  end

  button.style.size = {M.width, M.height}
  return button
end

return M
