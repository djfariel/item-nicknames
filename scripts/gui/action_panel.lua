-- Editor right-hand column: help/overflow text and the action buttons.

local constants = require("scripts.constants")
local overflow_label = require("scripts.gui.overflow_label")

local names = constants.names
local editor_layout = constants.editor_layout

local M = {}

M.button_spacing = 4
M.column_width = constants.editor_discard_button_minimal_width * 2 + M.button_spacing

function M.build(body, options)
  options = options or {}
  local is_pack = options.is_pack
  local pack = options.pack

  local column_width = M.column_width

  local right_column = body.add({
    type = "flow",
    direction = "vertical",
  })
  right_column.style.width = column_width
  right_column.style.vertically_stretchable = true
  right_column.style.vertical_spacing = 8

  local help_frame = right_column.add({
    type = "frame",
    direction = "vertical",
    style = "item_nicknames_description_frame",
  })
  help_frame.style.width = column_width
  help_frame.style.top_margin = editor_layout.sort_header_height + editor_layout.sort_header_bottom_padding + 2

  local explanation = help_frame.add({
    type = "label",
    name = names.help_text,
    caption = is_pack
      and {"item-nicknames.pack-help", pack.setting_name}
      or {"item-nicknames.help"},
  })
  explanation.style.single_line = false

  if not is_pack then
    overflow_label.add(help_frame, {name = names.overflow_warning})
  end

  local actions_spacer = right_column.add({type = "empty-widget"})
  actions_spacer.style.vertically_stretchable = true

  local actions = right_column.add({type = "flow", direction = "vertical"})
  actions.style.vertical_spacing = M.button_spacing

  local add_btn = actions.add({
    type = "button",
    name = names.add,
    caption = {"item-nicknames.add"},
    style = "green_button",
  })
  add_btn.style.width = column_width

  local export_btn = actions.add({
    type = "button",
    name = names.export,
    caption = {"item-nicknames.export"},
    tooltip = is_pack and {"item-nicknames.export-pack-tooltip"} or {"item-nicknames.export-tooltip"},
  })
  export_btn.style.width = column_width

  if not is_pack then
    local packs_btn = actions.add({
      type = "button",
      name = names.packs,
      caption = {"item-nicknames.packs"},
      tooltip = {"item-nicknames.packs-tooltip"},
    })
    packs_btn.style.width = column_width
  end

  local secondary_actions = actions.add({type = "flow", direction = "horizontal"})
  secondary_actions.style.horizontal_spacing = M.button_spacing

  local function style_secondary_button(button)
    button.style.minimal_width = constants.editor_discard_button_minimal_width
    button.style.horizontally_stretchable = true
    button.style.horizontally_squashable = false
  end

  local reset_applied = secondary_actions.add({
    type = "button",
    name = names.reset_applied,
    caption = {"item-nicknames.reset-applied"},
    tooltip = is_pack and {"item-nicknames.reset-pack-tooltip"} or {"item-nicknames.reset-applied-tooltip"},
    style = "red_button",
  })
  style_secondary_button(reset_applied)

  if is_pack then
    local pack_back = secondary_actions.add({
      type = "button",
      name = names.pack_back,
      caption = {"item-nicknames.pack-back"},
      tooltip = {"item-nicknames.pack-back-tooltip"},
      style = "red_button",
    })
    style_secondary_button(pack_back)
  else
    local import_btn = secondary_actions.add({
      type = "button",
      name = names.import,
      caption = {"item-nicknames.import"},
      tooltip = {"item-nicknames.import-tooltip"},
      style = "red_button",
    })
    style_secondary_button(import_btn)
  end

  return right_column
end

return M
