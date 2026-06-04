local common = require("common")
local constants = require("scripts.constants")
local draft = require("scripts.draft")
local dialogs = require("scripts.gui.dialogs")
local editor = require("scripts.gui.editor")
local pack_gui = require("scripts.gui.packs")
local packs = require("scripts.packs")
local rows = require("scripts.rows")
local state = require("scripts.storage")

local names = constants.names

local M = {}

function M.request_unsaved_confirm(player, action)
  state.set_pending_confirm_action(player, action)
  dialogs.show_close_confirm(player)
end

function M.request_close_editor(player)
  if state.is_pack_editor(player) then
    rows.merge_visible_rows(player)
    dialogs.destroy_frame(player)
    pack_gui.show_packs_dialog(player)
    return
  end

  dialogs.destroy_frame(player)
end

function M.load_editor_from_text(player, text, parse_options)
  state.set_editor_rows(player, state.ensure_row_uids(common.parse_rows(text or "", parse_options)))
  rows.capture_row_baselines(player, state.editor_rows(player), {replace = true})

  local rows_table = rows.rows_table_from_frame(player.gui.screen[names.frame])
  if rows_table then
    editor.populate_ui_rows(rows_table, editor.filtered_rows(player), player)
  end
end

function M.reset_source_text(player)
  local context = state.editor_context(player)
  if context.mode == "pack" and context.pack then
    local pack = packs.refresh_pack(context.pack)
    context.pack = pack
    state.set_editor_context(player, context)
    return pack.current_value or ""
  end

  return draft.applied_text()
end

function M.show_import_dialog(player)
  dialogs.show_import_dialog(player)
end

function M.import_from_dialog(player)
  local import_frame = player.gui.screen[names.import_frame]
  if not import_frame then
    return
  end

  local textbox = rows.find_child(import_frame, names.import_text)
  if not (textbox and textbox.valid) then
    return
  end

  local text = textbox.text
  local parsed_rows
  local parse_ok = pcall(function()
    local parsed, parse_errors = common.parse_rows(text)
    if #parse_errors > 0 then
      error("invalid import")
    end

    local validation_errors = rows.validate_rows(parsed)
    if #validation_errors > 0 then
      error("invalid import")
    end

    parsed_rows = parsed
  end)

  if not parse_ok or not parsed_rows then
    dialogs.show_import_invalid_prompt(player)
    return
  end

  if rows.would_load_change_memory(player, text) then
    state.set_pending_import_text(player, text)
    M.request_unsaved_confirm(player, "import_apply")
    return
  end

  dialogs.destroy_named(player, names.import_frame)
  M.load_editor_from_text(player, text)
  dialogs.reopen_editor(player)
end

function M.export_pending(player)
  local row_list = rows.merge_visible_rows(player)
  local errors = rows.validate_rows(row_list)
  if #errors > 0 then
    dialogs.show_validation_error_prompt(player, errors, rows)
    return
  end

  local text = common.serialize_draft_rows(row_list)
  local context = state.editor_context(player)
  if context.mode == "pack" and context.pack then
    dialogs.show_export_prompt(player, text, {
      {"item-nicknames.pack-export-message-1"},
      {"item-nicknames.pack-export-message-2", context.pack.setting_name},
    })
    return
  end

  dialogs.show_export_prompt(player, text)
end

function M.handle_confirm_discard(player, action)
  if action == "reset_applied" then
    M.load_editor_from_text(player, M.reset_source_text(player), {ignore_disabled_prefix = true})
    dialogs.reopen_editor(player)
  elseif action == "import_apply" then
    local text = state.pending_import_text(player)
    state.clear_pending_import_text(player)
    dialogs.destroy_named(player, names.import_frame)
    M.load_editor_from_text(player, text)
    dialogs.reopen_editor(player)
  end
end

function M.show_packs_dialog(player)
  rows.merge_visible_rows(player)
  pack_gui.show_packs_dialog(player)
end

function M.open_pack_editor(player, element)
  rows.merge_visible_rows(player)
  pack_gui.open_pack_from_element(player, element)
end

function M.show_pack_back(player)
  rows.merge_visible_rows(player)
  dialogs.destroy_frame(player)
  pack_gui.show_packs_dialog(player)
end

function M.show_packs_back(player)
  dialogs.destroy_named(player, names.packs_frame)
  state.ensure_storage()
  storage.item_nicknames.active_pack = nil
  state.set_editor_context(player, {mode = "user"})

  local frame = player.gui.screen[names.frame]
  if frame and frame.valid then
    dialogs.reopen_editor(player)
  else
    editor.build_user_frame(player, dialogs)
  end
end

function M.reopen_after_export(player)
  dialogs.reopen_editor(player)
end

return M
