-- Editor window title bar: title, drag handle, search field, and close button.

local constants = require("scripts.constants")
local packs = require("scripts.packs")

local names = constants.names

local M = {}

M.search_field_width = 240

function M.build(frame, options)
  options = options or {}
  local is_pack = options.is_pack
  local pack = options.pack

  local titlebar = frame.add({
    type = "flow",
    direction = "horizontal",
    style = "frame_header_flow",
  })

  titlebar.add({
    type = "label",
    caption = is_pack
      and {"item-nicknames.title-pack", packs.pack_setting_label(pack)}
      or {"item-nicknames.title-overrides"},
    style = "frame_title",
  })

  local dragger = titlebar.add({
    type = "empty-widget",
    style = "draggable_space_header",
  })
  dragger.style.horizontally_stretchable = true
  dragger.style.height = 24
  dragger.drag_target = frame

  local search_flow = titlebar.add({
    type = "flow",
    name = names.search_flow,
    direction = "horizontal",
  })
  search_flow.visible = false

  local search = search_flow.add({
    type = "textfield",
    name = names.search,
    tooltip = {"item-nicknames.search-tooltip"},
  })
  search.style.width = M.search_field_width

  titlebar.add({
    type = "sprite-button",
    name = names.search_toggle,
    sprite = "utility/search",
    style = "frame_action_button",
    tooltip = {"item-nicknames.search-toggle"},
  })

  titlebar.add({
    type = "sprite-button",
    name = names.close,
    sprite = "utility/close",
    hovered_sprite = "utility/close_black",
    clicked_sprite = "utility/close_black",
    style = "cancel_close_button",
  })

  return titlebar
end

return M
