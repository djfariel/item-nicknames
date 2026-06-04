local common = require("common")
local checkbox = require("scripts.gui.checkbox")
local constants = require("scripts.constants")
local gui_util = require("scripts.gui_util")
local draft = require("scripts.draft")
local editable_label = require("scripts.gui.editable_label")
local icon = require("scripts.icon")
local locale = require("locale")
local row_model = require("scripts.row_model")
local state = require("scripts.storage")

local names = constants.names
local row_prefixes = constants.row_prefixes

local M = {}

function M.toggle_checked(element)
  return checkbox.is_checked(element)
end

local function type_flag_segments(row, style)
  row = common.normalize_row(row)
  local segments = {}

  local function flag_locale(flag)
    if style == "tooltip" then
      return {"item-nicknames.type-flag-tooltip-" .. flag}
    end
    return {"item-nicknames.type-flag-" .. flag}
  end

  if row_model.is_technology_row(row) then
    segments[#segments + 1] = flag_locale("x")
    return segments
  end

  for _, flag in ipairs(row_model.matrix_flags) do
    if row_model.has_flag(row.y, flag) then
      segments[#segments + 1] = flag_locale(flag)
    end
  end

  if row_model.has_flag(row.h, "b") then
    if style == "tooltip" then
      segments[#segments + 1] = {"item-nicknames.barrel-helper"}
    else
      segments[#segments + 1] = {"item-nicknames.type-flag-b"}
    end
  end

  return segments
end

local function join_type_segments(segments, empty_key, separator)
  if #segments == 0 then
    return empty_key
  end

  if #segments == 1 then
    return segments[1]
  end

  local caption = {"", segments[1]}
  for index = 2, #segments do
    if separator then
      caption[#caption + 1] = separator
    end
    caption[#caption + 1] = segments[index]
  end

  return caption
end

function M.types_caption(row)
  return join_type_segments(type_flag_segments(row, "tooltip"), {"item-nicknames.types-empty"}, ", ")
end

function M.types_tooltip(row)
  return M.types_caption(row)
end

function M.types_compact_caption(row)
  return join_type_segments(type_flag_segments(row, "compact"), {"item-nicknames.types-empty-short"}, nil)
end

function M.copy_row(row)
  row = common.normalize_row(row)
  return {
    n = row.n,
    y = row.y,
    w = row.w,
    d = row.d,
    h = row.h,
    row_uid = row.row_uid,
  }
end

function M.row_signature(row)
  row = common.normalize_row(M.copy_row(row or {}))
  row.w = common.clean_nicknames(row_model.nicknames(row))
  return row_model.row_signature(row)
end

function M.baseline_scope(player)
  local context = state.editor_context(player)
  if context.mode == "pack" and context.pack then
    return context.pack.id
  end

  return "user"
end

function M.baseline_store(player)
  state.ensure_storage()
  local index = player.index
  storage.item_nicknames.row_baseline_signatures[index] = storage.item_nicknames.row_baseline_signatures[index] or {}
  local scope = M.baseline_scope(player)
  storage.item_nicknames.row_baseline_signatures[index][scope] = storage.item_nicknames.row_baseline_signatures[index][scope] or {}
  return storage.item_nicknames.row_baseline_signatures[index][scope]
end

function M.get_row_baseline(player, row_uid)
  if not row_uid then
    return nil
  end

  return M.baseline_store(player)[tostring(row_uid)]
end

function M.set_row_baseline(player, row_uid, signature)
  if not row_uid then
    return
  end

  M.baseline_store(player)[tostring(row_uid)] = signature
end

function M.remove_row_baseline(player, row_uid)
  if not row_uid then
    return
  end

  M.baseline_store(player)[tostring(row_uid)] = nil
end

function M.clear_row_baselines(player, scope)
  state.ensure_storage()
  local index = player.index
  if scope then
    if storage.item_nicknames.row_baseline_signatures[index] then
      storage.item_nicknames.row_baseline_signatures[index][scope] = nil
    end
    if storage.item_nicknames.row_baseline_captured[index] then
      storage.item_nicknames.row_baseline_captured[index][scope] = nil
    end
    return
  end

  storage.item_nicknames.row_baseline_signatures[index] = nil
  storage.item_nicknames.row_baseline_captured[index] = nil
end

function M.capture_row_baselines(player, row_list, options)
  options = options or {}
  local store = M.baseline_store(player)

  if options.replace then
    for key in pairs(store) do
      store[key] = nil
    end
  end

  for _, row in ipairs(row_list or {}) do
    if row.row_uid then
      local uid = tostring(row.row_uid)
      if options.replace or store[uid] == nil then
        store[uid] = M.row_signature(row)
      end
    end
  end
end

function M.ensure_row_baselines_captured(player)
  state.ensure_storage()
  local index = player.index
  local scope = M.baseline_scope(player)
  storage.item_nicknames.row_baseline_captured[index] = storage.item_nicknames.row_baseline_captured[index] or {}

  if storage.item_nicknames.row_baseline_captured[index][scope] then
    return
  end

  storage.item_nicknames.row_baseline_captured[index][scope] = true
  M.capture_row_baselines(player, state.editor_rows(player), {replace = true})
end

function M.startup_row_signatures(player)
  if player then
    local context = state.editor_context(player)
    if context.mode == "pack" and context.pack then
      local signatures = {}
      for _, row in ipairs(common.parse_rows(context.pack.current_value or "", {ignore_disabled_prefix = true})) do
        signatures[M.row_signature(row)] = true
      end
      return signatures
    end
  end

  local signatures = {}
  for _, row in ipairs(common.parse_rows(draft.applied_text())) do
    signatures[M.row_signature(row)] = true
  end
  return signatures
end

function M.row_is_changed(row, player)
  local signature = M.row_signature(row)
  if signature == "" then
    return false
  end

  if player and row.row_uid then
    local baseline = M.get_row_baseline(player, row.row_uid)
    if baseline ~= nil then
      return signature ~= baseline
    end
  end

  local signatures = storage.item_nicknames.current_startup_signatures or M.startup_row_signatures(player)
  return not signatures[signature]
end

function M.find_child(element, name)
  return gui_util.find_child(element, name)
end

function M.rows_table_from_frame(frame)
  if not (frame and frame.valid) then
    return nil
  end

  local scroll = M.find_child(frame, names.rows_scroll)
  return scroll and scroll[names.rows_table] or nil
end

function M.sync_row_frame_tags(row_frame, row)
  if not (row_frame and row_frame.valid) then
    return
  end

  row = common.normalize_row(row or {})
  local tags = row_frame.tags
  tags.item_nicknames_name = row.n or ""
  tags.item_nicknames_y = row.y or ""
  tags.item_nicknames_h = row.h or ""
  row_frame.tags = tags
end

function M.row_from_frame(row_frame, player)
  if not (row_frame and row_frame.valid) then
    return nil
  end

  local row_id = row_frame.tags.item_nicknames_row_id
  local row_uid = row_frame.tags.item_nicknames_row_uid or row_id
  local enabled_toggle = M.find_child(row_frame, row_prefixes.enabled .. row_id)
  local nickname_flow = row_frame[row_prefixes.nickname .. row_id]
  local stored = player and M.storage_row_by_uid(player, row_uid) or nil
  local name = (stored and stored.n) or row_frame.tags.item_nicknames_name or ""
  local y = (stored and stored.y) or row_frame.tags.item_nicknames_y or ""
  local h = stored and stored.h or row_frame.tags.item_nicknames_h or ""

  return common.normalize_row({
    row_id = row_id,
    row_uid = row_uid,
    d = not M.toggle_checked(enabled_toggle),
    n = name ~= "" and name or nil,
    y = y,
    h = h ~= "" and h or nil,
    w = editable_label.read_value(nickname_flow),
  })
end

function M.collect_ui_rows(rows_table, player)
  local rows = {}

  for _, child in ipairs(rows_table.children) do
    if constants.starts_with(child.name, row_prefixes.row) then
      local row = M.row_from_frame(child, player)
      if row then
        rows[#rows + 1] = row
      end
    end
  end

  return rows
end

function M.signal_sort_key(row)
  row = common.normalize_row(row)
  return (row.n or "") .. ":" .. (row.y or "")
end

function M.enabled_sort_key(row)
  return row_model.is_disabled(row) and 0 or 1
end

function M.type_sort_key(row)
  return row_model.sorted_flags(row_model.type_flags(row))
end

function M.nickname_sort_key(row)
  return common.clean_nicknames(row_model.nicknames(row)):lower()
end

function M.visible_translation(value)
  value = value or ""
  value = value:gsub("%[font=" .. common.font_name .. "%].-%[/font%]", "")
  return common.clean_nicknames(value):lower()
end

function M.prototype_localised_name(row)
  row = common.normalize_row(row)
  local name = row.n
  if not name then
    return M.signal_sort_key(row)
  end

  local signal_type = row_model.primary_signal_type(row)
  local prototype = common.find_runtime_prototype(prototypes, signal_type, name)
  if prototype and prototype.localised_name then
    local stripped = common.strip_mod_nicknames(prototype.localised_name)
    if stripped ~= nil then
      return stripped
    end
    return prototype.localised_name
  end

  return locale.of_runtime(prototypes, signal_type, name) or M.signal_sort_key(row)
end

function M.search_translation_string(row)
  local base = M.prototype_localised_name(row)
  local nicknames = common.clean_nicknames(row_model.nicknames(row))
  if nicknames == "" then
    return base
  end

  return locale.append_nicknames(base, " ", "", nicknames)
end

-- Sync visible UI rows into storage; when search hides rows, preserve hidden rows in storage order.
function M.merge_visible_rows(player)
  local frame = player.gui.screen[names.frame]
  local rows_table = M.rows_table_from_frame(frame)
  if not rows_table then
    return state.editor_rows(player)
  end

  local visible = M.collect_ui_rows(rows_table, player)
  local all_rows = state.editor_rows(player)

  local index_by_uid = {}
  for index, row in ipairs(all_rows) do
    if row.row_uid then
      index_by_uid[tostring(row.row_uid)] = index
    end
  end

  local storage_in_sync = true
  for _, row in ipairs(visible) do
    local uid = row.row_uid and tostring(row.row_uid)
    if not uid or not index_by_uid[uid] then
      storage_in_sync = false
      break
    end
  end

  if not storage_in_sync then
    local visible_uids = {}
    for _, row in ipairs(visible) do
      visible_uids[tostring(row.row_uid)] = true
    end

    local merged = {}
    for _, row in ipairs(visible) do
      merged[#merged + 1] = M.copy_row(row)
    end

    for _, row in ipairs(all_rows) do
      local uid = row.row_uid and tostring(row.row_uid)
      if uid and not visible_uids[uid] then
        merged[#merged + 1] = M.copy_row(row)
      end
    end

    state.set_editor_rows(player, merged)
    return merged
  end

  for _, row in ipairs(visible) do
    local uid = row.row_uid and tostring(row.row_uid)
    if uid and index_by_uid[uid] then
      local stored = all_rows[index_by_uid[uid]]
      stored.d = row.d
      stored.n = row.n
      stored.y = row.y
      stored.h = row.h
      stored.w = row.w
    end
  end

  return all_rows
end

function M.storage_row_by_uid(player, row_uid)
  local uid = tostring(row_uid)
  for _, row in ipairs(state.editor_rows(player)) do
    if row.row_uid and tostring(row.row_uid) == uid then
      return row
    end
  end

  return nil
end

function M.apply_storage_row_overrides(player, row_uid, overrides)
  if not overrides then
    return
  end

  local stored = M.storage_row_by_uid(player, row_uid)
  if not stored then
    stored = {
      row_uid = row_uid,
      d = false,
      n = nil,
      y = "",
      w = "",
    }
    state.editor_rows(player)[#state.editor_rows(player) + 1] = stored
  end

  for key, value in pairs(overrides) do
    stored[key] = value
  end

  if overrides.h == nil and overrides.y ~= nil then
    stored.h = nil
  end

  common.normalize_row(stored)

  if overrides.n ~= nil or overrides.y ~= nil or overrides.h ~= nil then
    local rows_table = M.rows_table_from_frame(player.gui.screen[names.frame])
    if rows_table then
      for _, child in ipairs(rows_table.children) do
        if constants.starts_with(child.name, row_prefixes.row) then
          local uid = tostring(child.tags.item_nicknames_row_uid or child.tags.item_nicknames_row_id)
          if uid == tostring(row_uid) then
            M.sync_row_frame_tags(child, stored)
            break
          end
        end
      end
    end
  end
end

function M.sync_nickname_fields_from_storage(player)
  local rows_table = M.rows_table_from_frame(player.gui.screen[names.frame])
  if not rows_table then
    return
  end

  local rows_by_uid = {}
  for _, row in ipairs(state.editor_rows(player)) do
    if row.row_uid then
      rows_by_uid[tostring(row.row_uid)] = row
    end
  end

  for _, child in ipairs(rows_table.children) do
    if constants.starts_with(child.name, row_prefixes.row) then
      local row_id = child.tags.item_nicknames_row_id
      local row_uid = tostring(child.tags.item_nicknames_row_uid or row_id)
      local stored = rows_by_uid[row_uid]
      local nickname_flow = child[row_prefixes.nickname .. row_id]
      if stored and nickname_flow and nickname_flow.valid then
        editable_label.set_value(nickname_flow, stored.w or "")
      end
    end
  end
end

function M.sync_ui_rows_to_storage(player)
  local rows_table = M.rows_table_from_frame(player.gui.screen[names.frame])
  if not rows_table then
    return
  end

  for _, child in ipairs(rows_table.children) do
    if constants.starts_with(child.name, row_prefixes.row) then
      local row = M.row_from_frame(child, player)
      if row and row.row_uid then
        M.apply_storage_row_overrides(player, row.row_uid, {
          d = row.d,
          n = row.n,
          y = row.y,
          h = row.h,
          w = row.w,
        })
      end
    end
  end
end

function M.would_load_change_memory(player, text, parse_options)
  M.merge_visible_rows(player)
  local current = common.serialize_draft_rows(state.editor_rows(player))
  local loaded = common.serialize_draft_rows(common.parse_rows(text or "", parse_options))
  return current ~= loaded
end

function M.row_is_invalid(row)
  row = common.normalize_row(row)

  if row_model.is_disabled(row) or row_model.is_technology_row(row) then
    return false
  end

  local name = row.n
  local nicknames = common.clean_nicknames(row_model.nicknames(row))
  local type_flags = row.y or ""

  if (not name or name == "") and nicknames == "" and type_flags == "" then
    return true
  end

  if name and nicknames ~= "" and type_flags == "" then
    return true
  end

  if name and nicknames == "" then
    return true
  end

  if not name and nicknames ~= "" then
    return true
  end

  return false
end

local validation_error_messages = {
  missing_type_flags = {"item-nicknames.error-missing-type-flags"},
  missing_nickname = {"item-nicknames.error-missing-nickname"},
  missing_signal = {"item-nicknames.error-missing-signal"},
}

function M.validate_rows(rows)
  local errors = {}

  for _, row in ipairs(rows) do
    row = common.normalize_row(row)
    local nicknames = common.clean_nicknames(row_model.nicknames(row))
    if row.n and nicknames ~= "" then
      row.w = nicknames
      if not row_model.is_disabled(row) and (row.y or "") == "" then
        errors[#errors + 1] = "missing_type_flags"
      end
    elseif not row_model.is_disabled(row) and row.n and nicknames == "" then
      errors[#errors + 1] = "missing_nickname"
    elseif not row_model.is_disabled(row) and not row.n and nicknames ~= "" then
      errors[#errors + 1] = "missing_signal"
    end
  end

  return errors
end

function M.summarize_validation_errors(errors)
  local counts = {}
  local order = {}

  for _, error_id in ipairs(errors or {}) do
    if validation_error_messages[error_id] then
      if not counts[error_id] then
        counts[error_id] = 0
        order[#order + 1] = error_id
      end
      counts[error_id] = counts[error_id] + 1
    end
  end

  return order, counts, #errors
end

function M.error_text(errors)
  local order, counts, total = M.summarize_validation_errors(errors)
  local result = {"", {"item-nicknames.invalid-with-count", total}}

  for _, error_id in ipairs(order) do
    result[#result + 1] = "\n"
    local count = counts[error_id]
    if count > 1 then
      result[#result + 1] = {"item-nicknames.validation-error-with-count", validation_error_messages[error_id], count}
    else
      result[#result + 1] = validation_error_messages[error_id]
    end
  end

  return result
end

function M.target_caption(row)
  row = common.normalize_row(row)
  if not row.n or row.n == "" then
    return {"item-nicknames.target-empty"}
  end

  return row.n
end

function M.target_sprite(row)
  return icon.sprite_for_row(row, prototypes)
end

return M
