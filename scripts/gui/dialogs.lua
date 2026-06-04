local constants = require("scripts.constants")
local state = require("scripts.storage")

local names = constants.names
local dialog_content_width = constants.dialog_content_width
local dialog_button_minimal_width = constants.dialog_button_minimal_width
local dialog_textbox_height = constants.dialog_textbox_height

local M = {}

function M.compact_dialog_button(button, minimal_width)
  button.style.horizontally_stretchable = false
  button.style.minimal_width = minimal_width or dialog_button_minimal_width
end

function M.destroy_named(player, frame_name)
  local frame = player.gui.screen[frame_name]
  if frame then
    frame.destroy()
  end
end

function M.destroy_frame(player)
  local frame = player.gui.screen[names.frame]
  if frame then
    state.set_ignore_editor_close(player)
    frame.destroy()
  end
end

function M.open_over_editor(player, modal_frame)
  state.set_ignore_editor_close(player)
  player.opened = modal_frame
end

function M.reopen_editor(player)
  state.consume_ignore_editor_close(player)
  local frame = player.gui.screen[names.frame]
  if frame and frame.valid then
    player.opened = frame
  end
end

function M.reopen_editor_or_import(player)
  local import_frame = player.gui.screen[names.import_frame]
  if import_frame and import_frame.valid then
    player.opened = import_frame
    return
  end

  local editor_frame = player.gui.screen[names.frame]
  if editor_frame and editor_frame.valid then
    player.opened = editor_frame
    return
  end

  local packs_frame = player.gui.screen[names.packs_frame]
  if packs_frame and packs_frame.valid then
    player.opened = packs_frame
    return
  end

  M.reopen_editor(player)
end

function M.add_description_frame(frame, content_width)
  local content = frame.add({
    type = "frame",
    direction = "vertical",
    style = "item_nicknames_description_frame_fixed_width",
  })
  content.style.width = content_width or dialog_content_width
  return content
end

function M.add_messages(content, messages)
  for _, message in ipairs(messages or {}) do
    content.add({
      type = "label",
      caption = message,
    }).style.single_line = false
  end
end

function M.add_dialog_textbox(content, options)
  options = options or {}
  local textbox = content.add({
    type = "text-box",
    name = options.name,
    text = options.text or "",
  })
  textbox.word_wrap = true
  textbox.style.width = options.width or constants.inset_inner_width(dialog_content_width)
  textbox.style.height = options.height or dialog_textbox_height
  return textbox
end

function M.add_button_row(frame, buttons)
  local button_flow = frame.add({
    type = "flow",
    direction = "horizontal",
    style = "dialog_buttons_horizontal_flow",
  })

  local needs_pusher = false
  for index, button_config in ipairs(buttons or {}) do
    if button_config.pusher_before then
      local pusher = button_flow.add({type = "empty-widget"})
      pusher.style.horizontally_stretchable = true
      needs_pusher = false
    end

    local button = button_flow.add({
      type = "button",
      name = button_config.name,
      caption = button_config.caption,
      style = button_config.style or "item_nicknames_dialog_button",
      enabled = button_config.enabled,
    })

    if button_config.enabled == false then
      button.enabled = false
    end

    M.compact_dialog_button(button, button_config.minimal_width)
    needs_pusher = button_config.push_confirm == true
  end

  if needs_pusher then
    local pusher = button_flow.add({type = "empty-widget"})
    pusher.style.horizontally_stretchable = true
  end

  return button_flow
end

function M.build_dialog(player, config)
  local frame = player.gui.screen.add({
    type = "frame",
    name = config.name,
    direction = "vertical",
    caption = config.title,
  })
  frame.auto_center = true

  local content = M.add_description_frame(frame, config.content_width)
  M.add_messages(content, config.messages)

  if config.textbox then
    M.add_dialog_textbox(content, config.textbox)
  end

  if config.buttons then
    M.add_button_row(frame, config.buttons)
  elseif config.back or config.confirm then
    local buttons = {}
    if config.back then
      buttons[#buttons + 1] = {
        name = config.back.name,
        caption = config.back.caption or {"item-nicknames.back"},
        style = config.back.style or "back_button",
      }
    end
    if config.confirm then
      buttons[#buttons + 1] = {
        name = config.confirm.name,
        caption = config.confirm.caption,
        style = config.confirm.style or "confirm_button",
        minimal_width = config.confirm.minimal_width,
        pusher_before = config.back ~= nil,
      }
    end
    M.add_button_row(frame, buttons)
  end

  return frame
end

function M.show_dialog(player, config)
  if config.destroy then
    M.destroy_named(player, config.destroy)
  end

  M.open_over_editor(player, M.build_dialog(player, config))
end

function M.show_export_prompt(player, text, custom_messages)
  M.destroy_named(player, names.export_frame)

  local frame = M.build_dialog(player, {
    name = names.export_frame,
    title = {"item-nicknames.export-title"},
    messages = custom_messages or {
      {"item-nicknames.export-message-1"},
      {"item-nicknames.export-message-2"},
    },
    textbox = {
      name = names.export_text,
      text = text or "",
    },
    buttons = {
      {
        name = names.export_select_all,
        caption = {"item-nicknames.export-select-all"},
        style = "item_nicknames_dialog_button",
      },
      {
        name = names.export_ok,
        caption = {"item-nicknames.ok"},
        style = "confirm_button",
        pusher_before = true,
      },
    },
  })

  M.open_over_editor(player, frame)
end

function M.show_import_dialog(player)
  M.destroy_named(player, names.import_frame)

  local frame = M.build_dialog(player, {
    name = names.import_frame,
    title = {"item-nicknames.import-title"},
    messages = {
      {"item-nicknames.import-message"},
    },
    textbox = {
      name = names.import_text,
    },
    buttons = {
      {
        name = names.import_back,
        caption = {"item-nicknames.back"},
        style = "back_button",
      },
      {
        name = names.import_ok,
        caption = {"item-nicknames.import-confirm"},
        style = "confirm_button",
        pusher_before = true,
      },
    },
  })

  M.open_over_editor(player, frame)
end

function M.show_import_invalid_prompt(player)
  M.show_dialog(player, {
    destroy = names.error_frame,
    name = names.error_frame,
    title = {"item-nicknames.import-invalid-title"},
    messages = {
      {"item-nicknames.import-invalid"},
      {"item-nicknames.import-invalid-hint"},
    },
    confirm = {
      name = names.error_ok,
      caption = {"item-nicknames.ok"},
    },
  })
end

function M.show_close_confirm(player)
  M.show_dialog(player, {
    destroy = names.close_confirm_frame,
    name = names.close_confirm_frame,
    title = {"item-nicknames.confirmation"},
    messages = {
      {"item-nicknames.replace-confirm"},
    },
    back = {name = names.close_confirm_cancel},
    confirm = {
      name = names.close_confirm_ok,
      caption = {"item-nicknames.discard-changes"},
      style = "red_confirm_button",
      minimal_width = constants.dialog_button_wide_minimal_width,
    },
  })
end

function M.show_validation_error_prompt(player, errors, rows_module)
  M.show_dialog(player, {
    destroy = names.error_frame,
    name = names.error_frame,
    title = {"item-nicknames.confirmation"},
    messages = {
      rows_module.error_text(errors),
    },
    back = {name = names.error_back},
    confirm = {
      name = names.error_ok,
      caption = {"item-nicknames.ok"},
    },
  })
end

return M
