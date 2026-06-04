local constants = require("scripts.constants")
local rows = require("scripts.rows")
local state = require("scripts.storage")
local editor = require("scripts.gui.editor")

local names = constants.names

local M = {}

function M.sort_rows(row_list, key_fn, ascending)
  table.sort(row_list, function(left, right)
    local left_key = key_fn(left)
    local right_key = key_fn(right)
    if left_key == right_key then
      return rows.signal_sort_key(left) < rows.signal_sort_key(right)
    end
    if ascending == false then
      return left_key > right_key
    end
    return left_key < right_key
  end)
end

function M.apply_sort(player, key_fn, ascending)
  local rows_table = rows.rows_table_from_frame(player.gui.screen[names.frame])
  if not rows_table then
    return
  end

  rows.merge_visible_rows(player)
  local row_list = rows.collect_ui_rows(rows_table, player)
  M.sort_rows(row_list, key_fn, ascending)
  editor.populate_ui_rows(rows_table, row_list, player)
end

function M.sort_by_localized_name(player, ascending)
  local frame = player.gui.screen[names.frame]
  local rows_table = rows.rows_table_from_frame(frame)
  if not rows_table then
    return
  end

  local row_list = rows.collect_ui_rows(rows_table, player)
  if #row_list <= 1 then
    return
  end

  rows.merge_visible_rows(player)
  row_list = rows.collect_ui_rows(rows_table, player)

  local localised_names = {}
  for index, row in ipairs(row_list) do
    localised_names[index] = rows.search_translation_string(row)
  end

  local requests = player.request_translations(localised_names)
  if not requests then
    return
  end

  local request_map = {}
  for index, request_id in ipairs(requests) do
    row_list[index].localized_sort_key = rows.signal_sort_key(row_list[index])
    request_map[request_id] = index
  end

  state.ensure_storage()
  storage.item_nicknames.translation_sorts[player.index] = {
    rows = row_list,
    request_map = request_map,
    remaining = #requests,
    ascending = ascending ~= false,
  }
end

function M.handle_sort_translation(player, event_id, translated, result)
  state.ensure_storage()
  local player_sort = storage.item_nicknames.translation_sorts[player.index]
  if not player_sort then
    return false
  end

  local row_index = player_sort.request_map[event_id]
  if not row_index then
    return false
  end

  if translated then
    player_sort.rows[row_index].localized_sort_key = rows.visible_translation(result)
  end
  player_sort.remaining = player_sort.remaining - 1

  if player_sort.remaining > 0 then
    return "pending"
  end

  storage.item_nicknames.translation_sorts[player.index] = nil

  local rows_table = rows.rows_table_from_frame(player.gui.screen[names.frame])
  if not rows_table then
    return "complete"
  end

  M.sort_rows(player_sort.rows, function(row)
    return row.localized_sort_key or rows.signal_sort_key(row)
  end, player_sort.ascending)
  editor.populate_ui_rows(rows_table, player_sort.rows, player)
  return "complete"
end

return M
