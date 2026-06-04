local common = require("common")
local packs = require("scripts.packs")
local settings_read = require("scripts.settings_read")

local M = {}

function M.ensure_storage()
  storage.item_nicknames = storage.item_nicknames or {}
  storage.item_nicknames.next_row_id = storage.item_nicknames.next_row_id or 1
  storage.item_nicknames.editor_rows = storage.item_nicknames.editor_rows or {}
  storage.item_nicknames.active_searches = storage.item_nicknames.active_searches or {}
  storage.item_nicknames.localized_names = storage.item_nicknames.localized_names or {}
  storage.item_nicknames.search_translation_requests = storage.item_nicknames.search_translation_requests or {}
  storage.item_nicknames.translation_sorts = storage.item_nicknames.translation_sorts or {}
  storage.item_nicknames.search_focused = storage.item_nicknames.search_focused or {}
  storage.item_nicknames.ignore_editor_close = storage.item_nicknames.ignore_editor_close or {}
  storage.item_nicknames.pending_confirm_action = storage.item_nicknames.pending_confirm_action or {}
  storage.item_nicknames.pending_import_text = storage.item_nicknames.pending_import_text or {}
  storage.item_nicknames.pack_list_cache = storage.item_nicknames.pack_list_cache or {}
  storage.item_nicknames.pack_editor_rows = storage.item_nicknames.pack_editor_rows or {}
  storage.item_nicknames.editor_context = storage.item_nicknames.editor_context or {}
  storage.item_nicknames.active_pack = storage.item_nicknames.active_pack
  storage.item_nicknames.sort_state = storage.item_nicknames.sort_state or {}
  storage.item_nicknames.ui_populating = storage.item_nicknames.ui_populating or {}
  storage.item_nicknames.row_baseline_signatures = storage.item_nicknames.row_baseline_signatures or {}
  storage.item_nicknames.row_baseline_captured = storage.item_nicknames.row_baseline_captured or {}
end

function M.next_row_id()
  M.ensure_storage()
  local id = storage.item_nicknames.next_row_id
  storage.item_nicknames.next_row_id = id + 1
  return id
end

function M.ensure_row_uids(rows)
  for _, row in ipairs(rows) do
    common.normalize_row(row)
    row.row_uid = row.row_uid or M.next_row_id()
  end
  return rows
end

function M.editor_context(player)
  M.ensure_storage()
  return storage.item_nicknames.editor_context[player.index] or {mode = "user"}
end

function M.set_editor_context(player, context)
  M.ensure_storage()
  storage.item_nicknames.editor_context[player.index] = context
end

function M.is_pack_editor(player)
  return M.editor_context(player).mode == "pack"
end

function M.editor_rows(player)
  M.ensure_storage()
  local context = M.editor_context(player)

  if context.mode == "pack" and context.pack then
    local pack_id = context.pack.id
    storage.item_nicknames.pack_editor_rows[player.index] = storage.item_nicknames.pack_editor_rows[player.index] or {}

    if not storage.item_nicknames.pack_editor_rows[player.index][pack_id] then
      storage.item_nicknames.pack_editor_rows[player.index][pack_id] = M.ensure_row_uids(
        select(1, packs.pack_rows(context.pack))
      )
    end

    return storage.item_nicknames.pack_editor_rows[player.index][pack_id]
  end

  if not storage.item_nicknames.editor_rows[player.index] then
    storage.item_nicknames.editor_rows[player.index] = M.ensure_row_uids(
      common.parse_rows(settings_read.applied_definitions(), {ignore_disabled_prefix = true})
    )
  end
  return storage.item_nicknames.editor_rows[player.index]
end

function M.set_editor_rows(player, row_list)
  M.ensure_storage()
  local context = M.editor_context(player)

  if context.mode == "pack" and context.pack then
    storage.item_nicknames.pack_editor_rows[player.index] = storage.item_nicknames.pack_editor_rows[player.index] or {}
    storage.item_nicknames.pack_editor_rows[player.index][context.pack.id] = row_list
    return
  end

  storage.item_nicknames.editor_rows[player.index] = row_list
end

function M.clear_pack_editor_rows(player, pack_id)
  M.ensure_storage()
  local pack_rows = storage.item_nicknames.pack_editor_rows[player.index]
  if pack_rows then
    pack_rows[pack_id] = nil
  end
end

function M.active_search(player)
  M.ensure_storage()
  return storage.item_nicknames.active_searches[player.index] or ""
end

function M.set_active_search(player, value)
  M.ensure_storage()
  storage.item_nicknames.active_searches[player.index] = common.clean_nicknames(value or ""):lower()
end

function M.localized_names(player)
  M.ensure_storage()
  storage.item_nicknames.localized_names[player.index] = storage.item_nicknames.localized_names[player.index] or {}
  return storage.item_nicknames.localized_names[player.index]
end

function M.search_field_focused(player)
  M.ensure_storage()
  return storage.item_nicknames.search_focused[player.index] == true
end

function M.set_search_field_focused(player, focused)
  M.ensure_storage()
  if focused then
    storage.item_nicknames.search_focused[player.index] = true
  else
    storage.item_nicknames.search_focused[player.index] = nil
  end
end

function M.set_pending_confirm_action(player, action)
  M.ensure_storage()
  storage.item_nicknames.pending_confirm_action[player.index] = action
end

function M.pending_confirm_action(player)
  M.ensure_storage()
  return storage.item_nicknames.pending_confirm_action[player.index]
end

function M.clear_pending_confirm(player)
  M.ensure_storage()
  storage.item_nicknames.pending_confirm_action[player.index] = nil
end

function M.set_pending_import_text(player, text)
  M.ensure_storage()
  storage.item_nicknames.pending_import_text[player.index] = text
end

function M.pending_import_text(player)
  M.ensure_storage()
  return storage.item_nicknames.pending_import_text[player.index]
end

function M.clear_pending_import_text(player)
  M.ensure_storage()
  storage.item_nicknames.pending_import_text[player.index] = nil
end

function M.set_ignore_editor_close(player)
  M.ensure_storage()
  storage.item_nicknames.ignore_editor_close[player.index] = true
end

function M.consume_ignore_editor_close(player)
  if not player then
    return false
  end

  M.ensure_storage()
  if storage.item_nicknames.ignore_editor_close[player.index] then
    storage.item_nicknames.ignore_editor_close[player.index] = nil
    return true
  end

  return false
end

function M.sort_state(player)
  M.ensure_storage()
  return storage.item_nicknames.sort_state[player.index]
end

function M.set_sort_state(player, column, ascending)
  M.ensure_storage()
  storage.item_nicknames.sort_state[player.index] = {
    column = column,
    ascending = ascending,
  }
end

function M.ui_populating(player)
  M.ensure_storage()
  return storage.item_nicknames.ui_populating[player.index] == true
end

function M.set_ui_populating(player, populating)
  M.ensure_storage()
  if populating then
    storage.item_nicknames.ui_populating[player.index] = true
  else
    storage.item_nicknames.ui_populating[player.index] = nil
  end
end

return M
