-- GUI click dispatch and row action handlers for the editor.

local actions = require("scripts.actions")
local constants = require("scripts.constants")
local dialogs = require("scripts.gui.dialogs")
local gui_util = require("scripts.gui_util")
local editor = require("scripts.gui.editor")
local search = require("scripts.search")
local sort = require("scripts.sort")
local sort_header = require("scripts.gui.sort_header")
local state = require("scripts.storage")
local rows = require("scripts.rows")

local names = constants.names
local row_prefixes = constants.row_prefixes

local M = {}

local function rows_table_from_element(element)
  local row_frame = gui_util.find_ancestor_by_prefix(element, row_prefixes.row)
  return row_frame and row_frame.parent
end

local function handle_search_toggle(player)
  search.toggle_editor_search(player)
end

local function handle_add(player)
  rows.merge_visible_rows(player)
  local all_rows = state.editor_rows(player)
  local new_row = {
    d = false,
    n = nil,
    y = "",
    w = "",
    row_uid = state.next_row_id(),
  }
  all_rows[#all_rows + 1] = new_row
  rows.set_row_baseline(player, new_row.row_uid, "")
  editor.refresh_rows(player)
end

local function handle_reset_applied(player)
  local text = actions.reset_source_text(player)
  if rows.would_load_change_memory(player, text, {ignore_disabled_prefix = true}) then
    actions.request_unsaved_confirm(player, "reset_applied")
  else
    actions.load_editor_from_text(player, text, {ignore_disabled_prefix = true})
  end
end

local function handle_import_back(player)
  dialogs.destroy_named(player, names.import_frame)
  dialogs.reopen_editor(player)
end

local function handle_export_ok(player)
  dialogs.destroy_named(player, names.export_frame)
  actions.reopen_after_export(player)
end

local function handle_export_select_all(player)
  local frame = player.gui.screen[names.export_frame]
  if not frame then
    return
  end

  local textbox = rows.find_child(frame, names.export_text)
  if not (textbox and textbox.valid) then
    return
  end

  player.opened = frame
  textbox.focus()
  textbox.select_all()
end

local function handle_error_dismiss(player)
  dialogs.destroy_named(player, names.error_frame)
  dialogs.reopen_editor_or_import(player)
end

local function handle_confirm_cancel(player)
  dialogs.destroy_named(player, names.close_confirm_frame)
  state.clear_pending_confirm(player)
  state.clear_pending_import_text(player)
  dialogs.reopen_editor_or_import(player)
end

local function handle_confirm_ok(player)
  dialogs.destroy_named(player, names.close_confirm_frame)
  local action = state.pending_confirm_action(player)
  state.clear_pending_confirm(player)
  actions.handle_confirm_discard(player, action)
end

local function handle_types_button(player, element)
  if not element.enabled then
    return
  end

  local row_uid = element.tags.item_nicknames_row_uid or element.tags.item_nicknames_row_id
  rows.merge_visible_rows(player)
  local row = rows.storage_row_by_uid(player, row_uid)
  if not row or not row.n or row.n == "" then
    return
  end

  editor.open_type_picker(player, row_uid)
end

function M.handle_row_toggle_click(player, element)
  if constants.starts_with(element.name, row_prefixes.enabled) then
    local rows_table = rows_table_from_element(element)
    if rows_table then
      rows.merge_visible_rows(player)
      rows.apply_storage_row_overrides(player, element.tags.item_nicknames_row_uid or element.tags.item_nicknames_row_id, {
        d = not element.toggled,
      })
      editor.populate_ui_rows(rows_table, rows.collect_ui_rows(rows_table, player), player)
    end
    return true
  end

  return false
end

local function handle_move_up(player, element)
  local row_id = element.tags.item_nicknames_row_id
  local rows_table = rows_table_from_element(element)
  if rows_table then
    editor.move_row_by_offset(rows_table, row_id, -1, player)
  end
end

local function handle_move_down(player, element)
  local row_id = element.tags.item_nicknames_row_id
  local rows_table = rows_table_from_element(element)
  if rows_table then
    editor.move_row_by_offset(rows_table, row_id, 1, player)
  end
end

function M.handle_sort_header_click(player, element)
  local column, ascending = sort_header.click_target(element, player)
  if not column then
    return false
  end

  state.set_search_field_focused(player, false)
  state.set_sort_state(player, column, ascending)

  if column == "enabled" then
    sort.apply_sort(player, rows.enabled_sort_key, ascending)
  elseif column == "target" then
    sort.sort_by_localized_name(player, ascending)
  elseif column == "types" then
    sort.apply_sort(player, rows.type_sort_key, ascending)
  elseif column == "nickname" then
    sort.apply_sort(player, rows.nickname_sort_key, ascending)
  end

  sort_header.refresh(player)
  return true
end

local function handle_delete_row(player, element)
  local row_frame = element.parent
  local rows_table = row_frame and row_frame.parent
  if not (row_frame and row_frame.valid and rows_table and rows_table.valid) then
    return
  end
  local row_id = element.tags.item_nicknames_row_id
  local row_uid = element.tags.item_nicknames_row_uid
  local row_element = rows_table[row_prefixes.row .. row_id]
  if not row_element then
    return
  end

  row_element.destroy()
  local remaining = {}
  for _, row in ipairs(state.editor_rows(player)) do
    if row.row_uid ~= row_uid then
      remaining[#remaining + 1] = row
    end
  end
  state.set_editor_rows(player, remaining)
  rows.remove_row_baseline(player, row_uid)
  editor.populate_ui_rows(rows_table, rows.collect_ui_rows(rows_table, player), player)
end

local function handle_target_button(player, element)
  local row_uid = element.tags.item_nicknames_row_uid or element.tags.item_nicknames_row_id
  editor.open_target_picker(player, row_uid)
end

local function handle_linked_add(player, element)
  local linked_name = element.tags.item_nicknames_linked_name
  local linked_y = element.tags.item_nicknames_linked_y
  local row_uid = element.tags.item_nicknames_row_uid
  local stored = rows.storage_row_by_uid(player, row_uid)
  local nicknames = stored and (stored.w or "") or ""
  editor.add_linked_row(player, row_uid, linked_name, linked_y, nicknames)
end

local click_handlers = {
  [names.search_toggle] = handle_search_toggle,
  [names.add] = handle_add,
  [names.reset_applied] = handle_reset_applied,
  [names.import] = function(player) actions.show_import_dialog(player) end,
  [names.import_back] = handle_import_back,
  [names.import_ok] = function(player) actions.import_from_dialog(player) end,
  [names.packs] = function(player) actions.show_packs_dialog(player) end,
  [names.packs_back] = function(player) actions.show_packs_back(player) end,
  [names.pack_open] = function(player, element) actions.open_pack_editor(player, element) end,
  [names.pack_back] = function(player) actions.show_pack_back(player) end,
  [names.export] = function(player) actions.export_pending(player) end,
  [names.close] = function(player) actions.request_close_editor(player) end,
  [names.export_select_all] = handle_export_select_all,
  [names.export_ok] = handle_export_ok,
  [names.error_back] = handle_error_dismiss,
  [names.error_ok] = handle_error_dismiss,
  [names.close_confirm_cancel] = handle_confirm_cancel,
  [names.close_confirm_ok] = handle_confirm_ok,
}

local prefix_handlers = {
  {prefix = row_prefixes.up, fn = handle_move_up},
  {prefix = row_prefixes.down, fn = handle_move_down},
  {prefix = row_prefixes.delete, fn = handle_delete_row},
  {prefix = row_prefixes.target, fn = handle_target_button},
  {prefix = row_prefixes.types_open, fn = handle_types_button},
  {prefix = row_prefixes.linked, fn = handle_linked_add},
}

function M.dispatch_click(player, element)
  local handler = click_handlers[element.name]
  if handler then
    handler(player, element)
    return
  end

  for _, entry in ipairs(prefix_handlers) do
    if constants.starts_with(element.name, entry.prefix) then
      entry.fn(player, element)
      return
    end
  end
end

return M
