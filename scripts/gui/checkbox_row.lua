-- Checkbox + caption row (type picker options).

local checkbox = require("scripts.gui.checkbox")

local M = {}

function M.add(parent, options)
  options = options or {}
  local row_flow = parent.add({
    type = "flow",
    direction = "horizontal",
    style = options.row_style or "item_nicknames_type_picker_row",
  })

  checkbox.add(row_flow, {
    name = options.checkbox_name,
    checked = options.checked,
    tooltip = options.tooltip,
    style = options.checkbox_style or checkbox.style_large,
  })

  row_flow.add({
    type = "label",
    caption = options.caption,
    tooltip = options.tooltip,
  }).style.vertically_stretchable = true

  return row_flow
end

return M
