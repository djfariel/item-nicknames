local constants = require("scripts.constants")
local row_model = require("scripts.row_model")
local rows = require("scripts.rows")
local state = require("scripts.storage")
local editor = require("scripts.gui.editor")

local names = constants.names

local M = {}

function M.editor_frame(player)
  local frame = player.gui.screen[names.frame]
  if frame and frame.valid and player.opened == frame then
    return frame
  end
end

function M.search_field_from_frame(frame)
  return rows.find_child(frame, names.search)
end

function M.set_search_visible(frame, visible)
  local search_flow = rows.find_child(frame, names.search_flow)
  if search_flow then
    search_flow.visible = visible
  end

  local search_toggle = rows.find_child(frame, names.search_toggle)
  if search_toggle then
    search_toggle.toggled = visible
  end
end

function M.search_is_visible(frame)
  local search_flow = rows.find_child(frame, names.search_flow)
  return search_flow and search_flow.visible
end

function M.close_editor_search(player, frame)
  rows.merge_visible_rows(player)
  state.set_active_search(player, "")
  M.set_search_visible(frame, false)
  state.set_search_field_focused(player, false)
  editor.populate_all_rows(player)
end

function M.open_editor_search(player, frame)
  state.set_active_search(player, "")
  M.set_search_visible(frame, true)

  local search = M.search_field_from_frame(frame)
  if search then
    search.text = ""
    search.focus()
    state.set_search_field_focused(player, true)
  end
end

function M.focus_editor_search(player)
  local frame = M.editor_frame(player)
  if not frame then
    return false
  end

  if M.search_is_visible(frame) then
    local search = M.search_field_from_frame(frame)
    if search then
      search.focus()
      state.set_search_field_focused(player, true)
    end
  else
    M.open_editor_search(player, frame)
  end
  return true
end

function M.toggle_editor_search(player)
  local frame = M.editor_frame(player)
  if not frame then
    return false
  end

  if M.search_is_visible(frame) then
    M.close_editor_search(player, frame)
  else
    M.open_editor_search(player, frame)
  end
  return true
end

function M.request_search_translations(player)
  local row_list = state.editor_rows(player)
  local cached = state.localized_names(player)
  local strings = {}
  local row_uids = {}

  for _, row in ipairs(row_list) do
    if row_model.name(row) ~= "" and not cached[row.row_uid] then
      strings[#strings + 1] = rows.search_translation_string(row)
      row_uids[#row_uids + 1] = row.row_uid
    end
  end

  if #strings == 0 then
    return
  end

  local requests = player.request_translations(strings)
  if not requests then
    return
  end

  state.ensure_storage()
  storage.item_nicknames.search_translation_requests[player.index] = storage.item_nicknames.search_translation_requests[player.index] or {}
  for index, request_id in ipairs(requests) do
    storage.item_nicknames.search_translation_requests[player.index][request_id] = row_uids[index]
  end
end

function M.handle_search_translation(player, event_id, translated, result)
  state.ensure_storage()
  local search_requests = storage.item_nicknames.search_translation_requests[player.index]
  if not search_requests or not search_requests[event_id] then
    return false
  end

  if translated then
    state.localized_names(player)[search_requests[event_id]] = rows.visible_translation(result)
  end
  search_requests[event_id] = nil

  if state.active_search(player) ~= "" then
    editor.refresh_rows(player)
  end
  return true
end

return M
