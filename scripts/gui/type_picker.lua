local checkbox = require("scripts.gui.checkbox")
local checkbox_row = require("scripts.gui.checkbox_row")
local constants = require("scripts.constants")
local dialogs = require("scripts.gui.dialogs")
local picker_base = require("scripts.gui.picker_base")
local icon = require("scripts.icon")
local prototype_links = require("scripts.prototype_links")
local row_model = require("scripts.row_model")
local rows = require("scripts.rows")

local M = {}

local picker_names = constants.type_picker_names
local picker = picker_base.new(picker_names.frame)

local function type_picker_title(row)
  row = row_model.normalize_row(row or {})
  local target_name = row.n

  if not target_name or target_name == "" then
    return {"item-nicknames.type-picker-title"}
  end

  return {
    "item-nicknames.type-picker-title-named",
    icon.sprite_for_row(row, prototypes),
    target_name,
  }
end

local function selected_flags_from_row(row)
  local selected = {}

  for _, flag in ipairs(row_model.matrix_flags) do
    selected[flag] = row_model.has_flag(row.y, flag)
  end

  return selected
end

local function selection_from_context(context)
  local flags = ""

  for _, flag in ipairs(row_model.matrix_flags) do
    if context.selected_flags[flag] and row_model.has_flag(context.available_y, flag) then
      flags = flags .. flag
    end
  end

  local y = row_model.sorted_flags(flags)
  local h = nil

  if context.show_barrel and context.selected_flags.f and context.barrel then
    h = "b"
  end

  return {y = y, h = h}
end

local function add_option_row(parent, flag, context)
  checkbox_row.add(parent, {
    checkbox_name = picker_names.flag_prefix .. flag,
    checked = context.selected_flags[flag],
    caption = {"item-nicknames.type-flag-tooltip-" .. flag},
    tooltip = {"item-nicknames.type-flag-tooltip-" .. flag},
  })
end

local function available_flags(available_y)
  local flags = {}

  for _, flag in ipairs(row_model.matrix_flags) do
    if row_model.has_flag(available_y, flag) then
      flags[#flags + 1] = flag
    end
  end

  return flags
end

function M.open(player, row, callback)
  picker.close(player)

  row = row_model.normalize_row(row or {})
  local available_y = prototype_links.available_types(row.n or "", prototypes)
  local show_barrel = row_model.has_flag(available_y, "f")
    and prototype_links.barrel_item_for_fluid(row.n, prototypes) ~= nil

  picker.set_context(player, {
    callback = callback,
    available_y = available_y,
    selected_flags = selected_flags_from_row(row),
    barrel = row_model.has_flag(row.h, "b"),
    show_barrel = show_barrel,
  })

  local frame = player.gui.screen.add({
    type = "frame",
    name = picker_names.frame,
    direction = "vertical",
    caption = type_picker_title(row),
  })
  frame.auto_center = true

  local content = frame.add({
    type = "frame",
    direction = "vertical",
    style = "item_nicknames_description_frame_fixed_width",
  })
  content.style.width = 320

  content.add({
    type = "label",
    caption = {"item-nicknames.type-picker-help"},
  }).style.single_line = false

  local list = content.add({
    type = "flow",
    name = picker_names.list,
    direction = "vertical",
    style = "item_nicknames_type_picker_list",
  })

  local context = picker.context(player)
  local flags = available_flags(available_y)
  local has_options = #flags > 0 or show_barrel

  for _, flag in ipairs(flags) do
    add_option_row(list, flag, context)
  end

  if show_barrel then
    checkbox_row.add(list, {
      checkbox_name = picker_names.barrel,
      checked = context.barrel,
      caption = {"item-nicknames.barrel-helper"},
      tooltip = {"item-nicknames.barrel-helper-tooltip"},
    })
  end

  if not has_options then
    list.add({
      type = "label",
      caption = {"item-nicknames.type-picker-no-options"},
    }).style.single_line = false
  end

  local button_flow = frame.add({
    type = "flow",
    direction = "horizontal",
    style = "dialog_buttons_horizontal_flow",
  })

  button_flow.add({
    type = "button",
    name = picker_names.cancel,
    caption = {"item-nicknames.cancel"},
    style = "back_button",
  })

  local pusher = button_flow.add({type = "empty-widget"})
  pusher.style.horizontally_stretchable = true

  button_flow.add({
    type = "button",
    name = picker_names.ok,
    caption = {"item-nicknames.ok"},
    style = "confirm_button",
    enabled = has_options,
  })

  dialogs.open_over_editor(player, frame)
end

function M.handle_click(player, element)
  local context = picker.context(player)
  if not context then
    return false
  end

  if element.name == picker_names.cancel then
    picker.destroy(player)
    return true
  end

  if element.name == picker_names.ok then
    if context.callback then
      context.callback(selection_from_context(context))
    end
    picker.destroy(player)
    return true
  end

  if constants.starts_with(element.name, picker_names.flag_prefix) then
    local flag = element.name:sub(#picker_names.flag_prefix + 1)
    context.selected_flags[flag] = element.toggled == true
    checkbox.after_click(element)
    if flag == "f" and not element.toggled then
      context.barrel = false
      local frame = player.gui.screen[picker_names.frame]
      local list = frame and rows.find_child(frame, picker_names.list)
      local barrel = list and list[picker_names.barrel]
      if barrel and barrel.valid then
        barrel.toggled = false
        checkbox.after_click(barrel)
      end
    end
    return true
  end

  if element.name == picker_names.barrel then
    context.barrel = element.toggled == true
    checkbox.after_click(element)
    return true
  end

  return false
end

function M.is_open(player)
  return picker.is_open(player)
end

return M
