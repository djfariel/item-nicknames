local constants = require("scripts.constants")
local dialogs = require("scripts.gui.dialogs")
local editor = require("scripts.gui.editor")
local overflow_label = require("scripts.gui.overflow_label")
local packs = require("scripts.packs")
local rows = require("scripts.rows")
local state = require("scripts.storage")

local names = constants.names
local dialog_content_width = constants.dialog_content_width
local packs_layout = constants.packs_layout

local M = {}

local function packs_scroll_width()
  return dialog_content_width - packs_layout.scroll_width_inset - constants.inset_frame_padding * 2
end

local function add_pack_list(parent, pack_list)
  local scroll_width = packs_scroll_width()
  local card_width = scroll_width - constants.inset_frame_padding * 2

  local list_inset = parent.add({
    type = "frame",
    direction = "vertical",
    style = "item_nicknames_packs_list_inset",
  })
  list_inset.style.width = dialog_content_width
  list_inset.style.height = packs_layout.list_height + constants.inset_frame_padding * 2
  list_inset.style.top_margin = 8
  list_inset.style.vertically_stretchable = false

  local scroll = list_inset.add({
    type = "scroll-pane",
    style = "item_nicknames_packs_scroll",
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never",
  })
  scroll.style.width = scroll_width
  scroll.style.height = packs_layout.list_height
  scroll.style.vertically_stretchable = false
  scroll.style.horizontally_stretchable = false

  local list_flow = scroll.add({
    type = "flow",
    direction = "vertical",
    style = "item_nicknames_pack_list_flow",
  })
  list_flow.style.width = card_width

  for index, pack in ipairs(pack_list) do
    local card = list_flow.add({
      type = "frame",
      direction = "horizontal",
      style = "item_nicknames_pack_row_card",
    })
    card.style.width = card_width

    card.add({
      type = "label",
      caption = packs.pack_setting_label(pack),
    })

    local spacer = card.add({type = "empty-widget"})
    spacer.style.horizontally_stretchable = true

    local open = card.add({
      type = "button",
      name = names.pack_open,
      caption = {"item-nicknames.packs-open"},
      tags = {
        item_nicknames_pack_index = index,
        item_nicknames_pack_id = pack.id,
      },
    })
    dialogs.compact_dialog_button(open)
  end
end

function M.show_packs_dialog(player)
  state.ensure_storage()
  storage.item_nicknames.active_pack = nil
  dialogs.destroy_named(player, names.packs_frame)

  local frame = player.gui.screen.add({
    type = "frame",
    name = names.packs_frame,
    direction = "vertical",
    caption = {"item-nicknames.packs-title"},
  })
  frame.auto_center = true

  local text_panel = frame.add({
    type = "frame",
    direction = "vertical",
    style = "item_nicknames_description_frame_fixed_width",
  })
  text_panel.style.width = dialog_content_width

  text_panel.add({
    type = "label",
    caption = {"item-nicknames.packs-message"},
  }).style.single_line = false

  overflow_label.add(text_panel)

  local pack_list = packs.list_packs()
  if #pack_list == 0 then
    text_panel.add({
      type = "label",
      caption = {"item-nicknames.packs-empty"},
    }).style.single_line = false
  else
    add_pack_list(frame, pack_list)
    storage.item_nicknames.pack_list_cache = pack_list
  end

  local button_flow = frame.add({
    type = "flow",
    direction = "horizontal",
    style = "dialog_buttons_horizontal_flow",
  })
  local back = button_flow.add({
    type = "button",
    name = names.packs_back,
    caption = {"item-nicknames.back"},
    style = "back_button",
  })
  dialogs.compact_dialog_button(back)

  dialogs.open_over_editor(player, frame)
end

function M.pack_from_element(element)
  local index = element.tags.item_nicknames_pack_index
  if not index then
    return nil
  end

  state.ensure_storage()
  local pack_list = storage.item_nicknames.pack_list_cache or {}
  return pack_list[index]
end

function M.open_pack_editor(player, pack)
  if not pack then
    return
  end

  pack = packs.refresh_pack(pack)
  state.clear_pack_editor_rows(player, pack.id)
  rows.clear_row_baselines(player, pack.id)
  storage.item_nicknames.active_pack = pack
  dialogs.destroy_named(player, names.packs_frame)
  editor.build_pack_frame(player, dialogs, pack)
end

function M.open_pack_from_element(player, element)
  M.open_pack_editor(player, M.pack_from_element(element))
end

function M.active_pack(player)
  state.ensure_storage()
  return storage.item_nicknames.active_pack
end

return M
