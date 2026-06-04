-- Builds a single editor row frame and its child controls.

local common = require("common")
local constants = require("scripts.constants")
local checkbox = require("scripts.gui.checkbox")
local delete_button = require("scripts.gui.delete_button")
local editable_label = require("scripts.gui.editable_label")
local gui_tags = require("scripts.gui.tags")
local move_buttons = require("scripts.gui.move_buttons")
local row_status = require("scripts.gui.row_status")
local editor_storage = require("scripts.storage")
local icon = require("scripts.icon")
local prototype_links = require("scripts.prototype_links")
local row_model = require("scripts.row_model")
local rows = require("scripts.rows")

local row_prefixes = constants.row_prefixes
local editor_layout = constants.editor_layout

local M = {}

local TYPES_OPEN_SPRITE_CANDIDATES = {
  "utility/list_view",
  "utility/mod_category",
  "utility/rename_icon",
  "utility/search",
}

local types_open_sprite

local function get_types_open_sprite()
  if not types_open_sprite then
    types_open_sprite = icon.pick_sprite_path(TYPES_OPEN_SPRITE_CANDIDATES, "utility/rename_icon")
  end

  return types_open_sprite
end

local function child_tags(row_id, row_uid)
  return gui_tags.row_child_tags(row_id, row_uid)
end

local function row_tags(row_id, row_uid, row)
  row = common.normalize_row(row or {})
  return {
    item_nicknames_row_id = row_id,
    item_nicknames_row_uid = row_uid,
    item_nicknames_name = row.n or "",
    item_nicknames_y = row.y or "",
    item_nicknames_h = row.h or "",
  }
end

local function row_shell_style(row_index)
  if row_index % 2 == 0 then
    return "item_nicknames_row_shell_odd"
  end

  return "item_nicknames_row_shell_even"
end

-- Enable/disable row controls: tech rows lock type picker; others need a target for types.
function M.apply_row_state(row_frame, row_id, row, player)
  row = common.normalize_row(row)
  local has_target = row.n ~= nil and row.n ~= ""
  local is_tech = row_model.is_technology_row(row)

  local nickname_flow = row_frame[row_prefixes.nickname .. row_id]
  if nickname_flow and nickname_flow.valid then
    editable_label.set_enabled(nickname_flow, true)
  end

  local target = row_frame[row_prefixes.target .. row_id]
  if target and target.valid then
    target.enabled = true
  end

  local types_flow = row_frame[row_prefixes.types .. row_id]
  if types_flow and types_flow.valid then
    for _, child in ipairs(types_flow.children) do
      if is_tech then
        child.enabled = false
      else
        child.enabled = has_target
      end
    end
  end

  local linked = row_frame[row_prefixes.linked .. row_id]
  if linked and linked.valid then
    linked.enabled = true
  end

  local move_flow = rows.find_child(row_frame, row_prefixes.move .. row_id)
  if move_flow and move_flow.valid then
    for _, child in ipairs(move_flow.children) do
      child.enabled = true
    end
  end

  local delete = row_frame[row_prefixes.delete .. row_id]
  if delete and delete.valid then
    delete.enabled = true
  end

  local status = rows.find_child(row_frame, row_prefixes.status .. row_id)
  if status and status.valid then
    row_status.update(status, row, player)
  end
end

local function add_types_button(row_frame, row_id, row_uid, row)
  row = common.normalize_row(row)
  local has_target = row.n ~= nil and row.n ~= ""
  local is_tech = row_model.is_technology_row(row)

  local flow = row_frame.add({
    type = "flow",
    name = row_prefixes.types .. row_id,
    direction = "horizontal",
    tags = child_tags(row_id, row_uid),
    style = "item_nicknames_types_flow",
  })
  flow.style.width = editor_layout.types_width
  flow.style.vertical_align = "center"

  if is_tech then
    flow.add({
      type = "label",
      name = row_prefixes.types_label .. row_id,
      caption = rows.types_compact_caption(row),
      tooltip = rows.types_tooltip(row),
      tags = child_tags(row_id, row_uid),
      style = "item_nicknames_types_label",
    }).style.horizontally_stretchable = true
    return
  end

  flow.add({
    type = "sprite-button",
    name = row_prefixes.types_open .. row_id,
    sprite = get_types_open_sprite(),
    tooltip = {"item-nicknames.types-open-tooltip"},
    tags = child_tags(row_id, row_uid),
    style = "item_nicknames_types_open_button",
    enabled = has_target,
  }).style.size = {24, 24}

  local types_label = flow.add({
    type = "label",
    name = row_prefixes.types_label .. row_id,
    caption = rows.types_compact_caption(row),
    tooltip = rows.types_tooltip(row),
    tags = child_tags(row_id, row_uid),
    style = "item_nicknames_types_label",
  })
  types_label.style.horizontally_stretchable = true
  types_label.style.horizontally_squashable = true
end

local function add_helper_slot(row_frame, row_id, row_uid, row)
  row = common.normalize_row(row)
  local suggestions = prototype_links.linked_suggestions(row.n, prototypes)

  local helper_flow = row_frame.add({
    type = "flow",
    direction = "horizontal",
  })
  helper_flow.style.width = editor_layout.helper_width

  if #suggestions == 0 then
    helper_flow.add({type = "empty-widget"}).style.horizontally_stretchable = true
    return helper_flow
  end

  local suggestion = suggestions[1]
  helper_flow.add({
    type = "button",
    name = row_prefixes.linked .. row_id,
    caption = {"item-nicknames.linked-add", suggestion.n},
    tooltip = {"item-nicknames.linked-add-tooltip", suggestion.n},
    tags = {
      item_nicknames_row_id = row_id,
      item_nicknames_row_uid = row_uid,
      item_nicknames_linked_name = suggestion.n,
      item_nicknames_linked_y = suggestion.y,
    },
    style = "item_nicknames_types_button",
  }).style.horizontally_stretchable = true

  return helper_flow
end

local function add_target_button(row_frame, row_id, row_uid, row)
  row = common.normalize_row(row)
  local sprite = icon.sprite_for_row(row, prototypes)

  local flow = row_frame.add({
    type = "flow",
    name = row_prefixes.target .. row_id,
    direction = "horizontal",
    tags = child_tags(row_id, row_uid),
    style = "item_nicknames_target_flow",
  })
  flow.style.width = editor_layout.target_width
  flow.style.vertical_align = "center"

  local icon_size = editor_layout.target_icon_size
  flow.add({
    type = "sprite-button",
    sprite = sprite,
    tooltip = {"item-nicknames.target-tooltip"},
    tags = child_tags(row_id, row_uid),
  }).style.size = {icon_size, icon_size}

  local has_target = row.n ~= nil and row.n ~= ""
  local name_button = flow.add({
    type = "button",
    caption = rows.target_caption(row),
    tooltip = {"item-nicknames.target-tooltip"},
    tags = child_tags(row_id, row_uid),
    style = has_target and "item_nicknames_target_button" or "item_nicknames_target_button_empty",
  })
  name_button.style.horizontally_stretchable = true
  name_button.style.horizontally_squashable = true
  name_button.style.maximal_width = editor_layout.target_width - icon_size - 2

  return flow
end

function M.add_row(rows_table, row, row_index, player)
  row = common.normalize_row(row or {})
  local row_id = editor_storage.next_row_id()
  local row_uid = row.row_uid or row_id

  local row_frame = rows_table.add({
    type = "frame",
    name = row_prefixes.row .. row_id,
    direction = "horizontal",
    style = row_shell_style(row_index),
    tags = row_tags(row_id, row_uid, row),
  })

  local leading_flow = row_frame.add({
    type = "flow",
    direction = "horizontal",
    style = "item_nicknames_row_leading_flow",
  })
  leading_flow.style.width = constants.editor_leading_width()

  checkbox.add(leading_flow, {
    name = row_prefixes.enabled .. row_id,
    checked = not row_model.is_disabled(row),
    tooltip = {"item-nicknames.enabled-tooltip"},
    tags = child_tags(row_id, row_uid),
    style = checkbox.style,
  }).style.width = editor_layout.checkbox_width

  row_status.add(leading_flow, {
    name = row_prefixes.status .. row_id,
    row = row,
    player = player,
    tags = child_tags(row_id, row_uid),
  })

  local move_flow = leading_flow.add({
    type = "flow",
    name = row_prefixes.move .. row_id,
    direction = "vertical",
    tags = child_tags(row_id, row_uid),
  })
  move_flow.style.width = editor_layout.move_width

  move_buttons.add(move_flow, row_id, row_uid)

  add_target_button(row_frame, row_id, row_uid, row)
  add_types_button(row_frame, row_id, row_uid, row)
  add_helper_slot(row_frame, row_id, row_uid, row)

  editable_label.add(row_frame, {
    name = row_prefixes.nickname .. row_id,
    text = row_model.nicknames(row),
    default_caption = {"item-nicknames.nickname-empty"},
    width = editor_layout.field_width,
    tooltip = {"item-nicknames.nickname-tooltip"},
    tags = child_tags(row_id, row_uid),
  })

  delete_button.add(row_frame, {
    name = row_prefixes.delete .. row_id,
    tooltip = {"item-nicknames.delete-row"},
    tags = child_tags(row_id, row_uid),
  })

  M.apply_row_state(row_frame, row_id, row, player)
end

return M
