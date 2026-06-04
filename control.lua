local common = require("common")
local actions = require("scripts.actions")
local catalog = require("scripts.catalog")
local constants = require("scripts.constants")
local checkbox = require("scripts.gui.checkbox")
local dialogs = require("scripts.gui.dialogs")
local editable_label = require("scripts.gui.editable_label")
local editor = require("scripts.gui.editor")
local handlers = require("scripts.handlers")
local target_picker = require("scripts.gui.target_picker")
local type_picker = require("scripts.gui.type_picker")
local draft = require("scripts.draft")
local rows = require("scripts.rows")
local search = require("scripts.search")
local sort = require("scripts.sort")
local sort_header = require("scripts.gui.sort_header")
local state = require("scripts.storage")

local names = constants.names
local row_prefixes = constants.row_prefixes

script.on_init(function()
  state.ensure_storage()
  for _, player in pairs(game.players) do
    draft.initialize_player(player)
  end
end)

script.on_configuration_changed(function()
  state.ensure_storage()
  catalog.invalidate()
  for _, player in pairs(game.players) do
    draft.initialize_player(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    draft.initialize_player(player)
  end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= common.shortcut_name then
    return
  end

  local player = game.get_player(event.player_index)
  if player then
    editor.build_user_frame(player, dialogs)
  end
end)

script.on_event(common.focus_search_input, function(event)
  local player = game.get_player(event.player_index)
  if player then
    search.focus_editor_search(player)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not (element and element.valid) then
    return
  end

  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  checkbox.after_click(element)

  if editable_label.handle_click(player, element, editor.on_nickname_changed) then
    return
  end

  if element.tags and element.tags.item_nicknames_row_uid then
    local parent = element.parent
    if parent and parent.valid and constants.starts_with(parent.name, row_prefixes.target) then
      editor.open_target_picker(player, element.tags.item_nicknames_row_uid or element.tags.item_nicknames_row_id)
      return
    end
  end

  if handlers.handle_sort_header_click(player, element) then
    return
  end

  if handlers.handle_row_toggle_click(player, element) then
    return
  end

  if type_picker.handle_click(player, element) then
    return
  end

  if target_picker.handle_click(player, element) then
    return
  end

  local frame = search.editor_frame(player)
  if frame then
    if element.name == names.search then
      state.set_search_field_focused(player, true)
    elseif element.name ~= names.search_toggle then
      state.set_search_field_focused(player, false)
    end
  end

  handlers.dispatch_click(player, element)
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local element = event.element
  if not (element and element.valid) then
    return
  end

  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if target_picker.handle_tab_changed(player, element) then
    return
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  local element = event.element
  if not (element and element.valid) then
    return
  end

  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if target_picker.handle_text_changed(player, element) then
    return
  end

  if element.name == names.search then
    local frame = player.gui.screen[names.frame]
    if not frame or not search.search_is_visible(frame) then
      return
    end

    state.set_search_field_focused(player, true)
    rows.merge_visible_rows(player)
    state.set_active_search(player, element.text)
    search.request_search_translations(player)
    editor.refresh_rows(player)
  end
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
  local element = event.element
  if not (element and element.valid) then
    return
  end

  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  editable_label.try_handle_confirmed(player, element, editor.on_nickname_changed)
end)

script.on_event(defines.events.on_string_translated, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if search.handle_search_translation(player, event.id, event.translated, event.result) then
    return
  end

  local sort_result = sort.handle_sort_translation(player, event.id, event.translated, event.result)
  if sort_result == "complete" then
    sort_header.refresh(player)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  local element = event.element

  if element and element.valid and editable_label.try_handle_closed(player, element) then
    return
  end

  if not (element and element.valid) then
    return
  end

  if element.name == names.frame then
    if player and state.consume_ignore_editor_close(player) then
      return
    end

    -- Editor lost focus to a picker or sub-dialog; keep the frame on screen.
    if player and element.valid then
      local opened = player.opened
      if opened and opened.valid and opened.name ~= names.frame then
        return
      end
    end

    if player and search.search_is_visible(element) and state.search_field_focused(player) then
      search.close_editor_search(player, element)
      player.opened = element
      return
    end

    if player then
      actions.request_close_editor(player)
    else
      element.destroy()
    end
  elseif constants.reopen_on_close[element.name] then
    state.consume_ignore_editor_close(player)
    element.destroy()
    if player then
      dialogs.reopen_editor(player)
    end
  end
end)
