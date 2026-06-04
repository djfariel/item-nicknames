local catalog = require("scripts.catalog")
local common = require("common")
local constants = require("scripts.constants")
local row_status = require("scripts.gui.row_status")
local editable_label = require("scripts.gui.editable_label")
local sort_header = require("scripts.gui.sort_header")
local target_picker = require("scripts.gui.target_picker")
local type_picker = require("scripts.gui.type_picker")
local titlebar = require("scripts.gui.titlebar")
local action_panel = require("scripts.gui.action_panel")
local row_builder = require("scripts.gui.row_builder")
local row_model = require("scripts.row_model")
local rows = require("scripts.rows")
local editor_storage = require("scripts.storage")

local names = constants.names
local row_prefixes = constants.row_prefixes
local M = {}

function M.apply_target_selection(player, row_uid, selection)
  selection = selection or {}
  local frame = player.gui.screen[names.frame]
  local rows_table = rows.rows_table_from_frame(frame)
  if not rows_table then
    return
  end

  rows.merge_visible_rows(player)
  rows.apply_storage_row_overrides(player, row_uid, {
    n = selection.n,
    y = selection.y,
    h = nil,
  })

  M.refresh_rows(player)
end

function M.open_target_picker(player, row_uid)
  target_picker.open(player, row_uid, function(selection)
    M.apply_target_selection(player, row_uid, selection)
  end)
end

function M.open_type_picker(player, row_uid)
  local row = rows.storage_row_by_uid(player, row_uid)
  if not row then
    return
  end

  type_picker.open(player, row, function(selection)
    rows.apply_storage_row_overrides(player, row_uid, {
      y = selection.y,
      h = selection.h,
    })
    M.refresh_rows(player)
  end)
end

function M.add_linked_row(player, row_uid, linked_name, linked_y, nicknames)
  rows.merge_visible_rows(player)
  local all_rows = editor_storage.editor_rows(player)
  local linked_row = common.normalize_row({
    n = linked_name,
    y = linked_y,
    w = nicknames or "",
    row_uid = editor_storage.next_row_id(),
  })
  all_rows[#all_rows + 1] = linked_row
  rows.set_row_baseline(player, linked_row.row_uid, rows.row_signature(linked_row))
  M.refresh_rows(player)
end

function M.populate_ui_rows(rows_table, row_list, player)
  editor_storage.ensure_storage()
  if player then
    editor_storage.set_ui_populating(player, true)
  end

  rows_table.clear()
  storage.item_nicknames.current_startup_signatures = rows.startup_row_signatures(player)

  if #row_list == 0 then
    row_builder.add_row(rows_table, {n = nil, y = "", w = "", row_uid = editor_storage.next_row_id()}, 1, player)
    storage.item_nicknames.current_startup_signatures = nil
    if player then
      editor_storage.set_ui_populating(player, false)
    end
    return
  end

  for index, row in ipairs(row_list) do
    common.normalize_row(row)
    row_builder.add_row(rows_table, row, index, player)
  end

  storage.item_nicknames.current_startup_signatures = nil

  if player then
    editor_storage.set_ui_populating(player, false)
  end
end

function M.move_row_by_offset(rows_table, row_id, offset, player)
  local row_list = rows.collect_ui_rows(rows_table, player)
  local index
  for row_index, row in ipairs(row_list) do
    if row.row_id == row_id then
      index = row_index
      break
    end
  end

  if not index then
    return false
  end

  local target_index = index + offset
  if target_index < 1 or target_index > #row_list then
    return false
  end

  row_list[index], row_list[target_index] = row_list[target_index], row_list[index]
  M.populate_ui_rows(rows_table, row_list, player)
  return true
end

function M.row_matches_search(player, row)
  local query = editor_storage.active_search(player)
  if query == "" then
    return true
  end

  row = common.normalize_row(row)
  local id = (row.n or ""):lower()
  local nicknames = common.clean_nicknames(row_model.nicknames(row)):lower()
  local localized = editor_storage.localized_names(player)[row.row_uid] or ""

  return id:find(query, 1, true) ~= nil
    or nicknames:find(query, 1, true) ~= nil
    or localized:find(query, 1, true) ~= nil
end

function M.filtered_rows(player)
  local row_list = editor_storage.editor_rows(player)
  local filtered = {}

  for _, row in ipairs(row_list) do
    if M.row_matches_search(player, row) then
      filtered[#filtered + 1] = row
    end
  end

  return filtered
end

function M.populate_all_rows(player)
  local rows_table = rows.rows_table_from_frame(player.gui.screen[names.frame])
  if rows_table then
    M.populate_ui_rows(rows_table, editor_storage.editor_rows(player), player)
  end
end

function M.refresh_rows(player)
  local rows_table = rows.rows_table_from_frame(player.gui.screen[names.frame])
  if rows_table then
    M.populate_ui_rows(rows_table, M.filtered_rows(player), player)
  end
end

function M.update_row_indicator(row_frame, row_override, player)
  if not (row_frame and row_frame.valid) then
    return
  end

  local row = row_override or rows.row_from_frame(row_frame, player)
  if not row then
    return
  end

  local status = rows.find_child(row_frame, row_prefixes.status .. row_frame.tags.item_nicknames_row_id)
  if status and status.valid then
    row_status.update(status, row, player)
  end
end

function M.on_nickname_changed(player, element, nicknames)
  M.update_row_indicator_from_element(player, element, {
    w = nicknames,
    nicknames = nicknames,
  })
end

function M.update_row_indicator_from_element(player, element, overrides)
  local row_frame = editable_label.row_frame_from(element)
  if not (row_frame and row_frame.valid) then
    row_frame = element.parent
  end
  if not (row_frame and row_frame.valid) then
    return
  end

  rows.merge_visible_rows(player)
  local row_uid = row_frame.tags.item_nicknames_row_uid or row_frame.tags.item_nicknames_row_id
  rows.apply_storage_row_overrides(player, row_uid, overrides)
  local row = rows.storage_row_by_uid(player, row_uid) or rows.row_from_frame(row_frame, player)
  if not row then
    return
  end
  M.update_row_indicator(row_frame, row, player)
end

function M.build_frame(player, dialogs, options)
  options = options or {mode = "user"}
  local mode = options.mode or "user"
  local pack = options.pack
  local is_pack = mode == "pack" and pack ~= nil

  catalog.ensure_cache(prototypes)

  if is_pack then
    editor_storage.set_editor_context(player, {mode = "pack", pack = pack})
    storage.item_nicknames.active_pack = pack
  else
    editor_storage.set_editor_context(player, {mode = "user"})
    storage.item_nicknames.active_pack = nil
  end

  dialogs.destroy_frame(player)

  local frame = player.gui.screen.add({
    type = "frame",
    name = names.frame,
    direction = "vertical",
  })
  frame.auto_center = true

  titlebar.build(frame, {is_pack = is_pack, pack = pack})

  local body = frame.add({
    type = "flow",
    direction = "horizontal",
  })
  body.style.horizontal_spacing = 12

  local list_column = body.add({
    type = "flow",
    direction = "vertical",
  })

  sort_header.build(list_column, player)

  local scroll = list_column.add({
    type = "scroll-pane",
    name = names.rows_scroll,
    style = "item_nicknames_rows_scroll",
    vertical_scroll_policy = "always",
    horizontal_scroll_policy = "auto",
  })
  scroll.style.width = constants.editor_list_width()
  scroll.style.height = 360

  local rows_table = scroll.add({
    type = "table",
    name = names.rows_table,
    style = "item_nicknames_rows_table",
    column_count = 1,
  })
  rows_table.style.width = constants.editor_row_width()
  editor_storage.editor_rows(player)
  rows.ensure_row_baselines_captured(player)
  editor_storage.set_active_search(player, "")
  M.populate_ui_rows(rows_table, M.filtered_rows(player), player)

  action_panel.build(body, {is_pack = is_pack, pack = pack})

  player.opened = frame
end

function M.build_user_frame(player, dialogs)
  M.build_frame(player, dialogs, {mode = "user"})
end

function M.build_pack_frame(player, dialogs, pack)
  M.build_frame(player, dialogs, {mode = "pack", pack = pack})
end

return M
