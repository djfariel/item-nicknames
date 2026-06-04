local constants = require("scripts.constants")
local rows = require("scripts.rows")
local state = require("scripts.storage")

local names = constants.names
local layout = constants.editor_layout

local M = {}

M.tag = "item_nicknames_sort_header"

local function arrow_name(column_id)
  return "item_nicknames_sort_arrow_" .. column_id
end

local function label_name(column_id)
  return "item_nicknames_sort_label_" .. column_id
end

local function column_is_active(column_id, sort_state)
  return sort_state and sort_state.column == column_id
end

local function arrow_style(column_id, sort_state)
  if column_is_active(column_id, sort_state) then
    if sort_state.ascending then
      return "item_nicknames_sort_desc_active"
    end

    return "item_nicknames_sort_asc_active"
  end

  return "item_nicknames_sort_asc_inactive"
end

local function label_button_style(column_id, sort_state)
  if column_is_active(column_id, sort_state) then
    return "item_nicknames_sort_header_label_button_active"
  end

  return "item_nicknames_sort_header_label_button"
end

local function toggle_sort_target(column_id, player)
  local sort_state = state.sort_state(player)
  if sort_state and sort_state.column == column_id then
    return column_id, not sort_state.ascending
  end

  return column_id, true
end

local function add_spacer(parent, width)
  local spacer = parent.add({type = "empty-widget"})
  spacer.style.width = width
  return spacer
end

local function add_sort_column(parent, column, sort_state)
  local cell = parent.add({
    type = "flow",
    direction = "horizontal",
    style = "item_nicknames_sort_header_column",
  })

  if column.width then
    cell.style.width = column.width
  end

  if column.stretch then
    cell.style.horizontally_stretchable = true
  end

  cell.add({
    type = "button",
    name = arrow_name(column.id),
    style = arrow_style(column.id, sort_state),
    tooltip = column.toggle_tooltip,
    tags = {sort_column = column.id, sort_arrow = true},
  })

  if column.caption then
    cell.add({
      type = "button",
      name = label_name(column.id),
      caption = column.caption,
      style = label_button_style(column.id, sort_state),
      tooltip = column.toggle_tooltip,
      tags = {sort_column = column.id, sort_label = true},
    })
  end
end

function M.is_sort_control(element)
  return element and element.valid and element.tags and element.tags.sort_column ~= nil
end

function M.build(parent, player)
  local sort_state = state.sort_state(player)
  local header = parent.add({
    type = "flow",
    name = names.sort_header,
    direction = "horizontal",
    style = "item_nicknames_sort_header",
    tags = {[M.tag] = true},
  })
  header.style.width = constants.editor_list_container_width()
  header.style.left_padding = layout.row_side_padding
  header.style.right_padding = layout.row_shell_right_padding

  add_sort_column(header, {
    id = "enabled",
    caption = {"item-nicknames.sort-header-enabled"},
    toggle_tooltip = {"item-nicknames.sort-enabled-toggle"},
    width = layout.checkbox_width,
  }, sort_state)

  add_spacer(header, constants.editor_leading_width() - layout.checkbox_width)

  add_sort_column(header, {
    id = "target",
    caption = {"item-nicknames.sort-header-target"},
    toggle_tooltip = {"item-nicknames.sort-target-toggle"},
    width = layout.target_width,
  }, sort_state)

  add_sort_column(header, {
    id = "types",
    caption = {"item-nicknames.sort-header-types"},
    toggle_tooltip = {"item-nicknames.sort-types-toggle"},
    width = layout.types_width,
  }, sort_state)

  add_spacer(header, layout.helper_width)

  add_sort_column(header, {
    id = "nickname",
    caption = {"item-nicknames.sort-header-nicknames"},
    toggle_tooltip = {"item-nicknames.sort-nickname-toggle"},
    width = layout.field_width,
    stretch = true,
  }, sort_state)

  add_spacer(header, layout.delete_width)

  return header
end

local function refresh_button(button, sort_state)
  if not (button and button.valid and button.tags and button.tags.sort_column) then
    return
  end

  local column_id = button.tags.sort_column

  if button.tags.sort_label then
    button.style = label_button_style(column_id, sort_state)
    return
  end

  if button.tags.sort_arrow then
    button.style = arrow_style(column_id, sort_state)
  end
end

local function walk_refresh(element, sort_state)
  if not (element and element.valid) then
    return
  end

  refresh_button(element, sort_state)

  for _, child in ipairs(element.children) do
    walk_refresh(child, sort_state)
  end
end

function M.refresh(player)
  local frame = player.gui.screen[names.frame]
  if not frame then
    return
  end

  local header = rows.find_child(frame, names.sort_header)
  if not header then
    return
  end

  walk_refresh(header, state.sort_state(player))
end

function M.click_target(element, player)
  if not M.is_sort_control(element) then
    return nil
  end

  if element.tags.sort_label or element.tags.sort_arrow then
    return toggle_sort_target(element.tags.sort_column, player)
  end

  return nil
end

return M
