-- Row reorder up/down sprite buttons.

local constants = require("scripts.constants")
local gui_tags = require("scripts.gui.tags")

local row_prefixes = constants.row_prefixes
local layout = constants.editor_layout

local M = {}

function M.add(parent, row_id, row_uid)
  local tags = gui_tags.row_child_tags(row_id, row_uid)
  local move_button_size = {layout.move_width, layout.move_button_height}

  local up = parent.add({
    type = "sprite-button",
    name = row_prefixes.up .. row_id,
    sprite = "item-nicknames-sort-arrow-up",
    tooltip = {"item-nicknames.move-up"},
    tags = tags,
  })
  up.style.size = move_button_size

  local down = parent.add({
    type = "sprite-button",
    name = row_prefixes.down .. row_id,
    sprite = "item-nicknames-sort-arrow-down",
    tooltip = {"item-nicknames.move-down"},
    tags = tags,
  })
  down.style.size = move_button_size

  return up, down
end

return M
