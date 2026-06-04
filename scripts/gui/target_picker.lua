local catalog = require("scripts.catalog")
local constants = require("scripts.constants")
local dialogs = require("scripts.gui.dialogs")
local picker_base = require("scripts.gui.picker_base")
local row_model = require("scripts.row_model")

local M = {}

local picker_names = constants.picker_names

local TAB_COLUMN_WIDTH = 96
local CONTENT_WIDTH = 480
local BODY_PADDING = 8
local SCROLL_PADDING = 4
local SCROLL_WIDTH_INSET = 8
local INNER_WIDTH = CONTENT_WIDTH - BODY_PADDING * 2
local SCROLL_WIDTH = INNER_WIDTH - SCROLL_WIDTH_INSET
local PICKER_BODY_HEIGHT = 400
local PICKER_CELL_WIDTH = 48
local PICKER_CELL_SPACING = 2

local function picker_column_count()
  local inner = SCROLL_WIDTH - SCROLL_PADDING * 2
  return math.max(1, math.floor((inner + PICKER_CELL_SPACING) / (PICKER_CELL_WIDTH + PICKER_CELL_SPACING)))
end

local picker = picker_base.new(picker_names.frame)

local function badge_flow(parent, entry)
  local row_flow = parent.add({
    type = "flow",
    direction = "horizontal",
  })
  row_flow.style.horizontal_spacing = 0
  row_flow.style.horizontal_align = "center"

  for _, flag in ipairs(row_model.matrix_flags) do
    if row_model.has_flag(entry.available_y or entry.flags, flag) then
      row_flow.add({
        type = "label",
        caption = flag,
        style = "item_nicknames_type_badge",
      })
    end
  end

  if row_model.has_flag(entry.flags, "x") then
    row_flow.add({
      type = "label",
      caption = "x",
      style = "item_nicknames_type_badge",
    })
  end
end

local function update_status(frame, entry_count)
  local status = frame[picker_names.status]
  if not (status and status.valid) then
    return
  end

  if entry_count == 0 then
    status.caption = {"item-nicknames.picker-empty"}
  else
    status.caption = {"item-nicknames.picker-count", entry_count}
  end
end

local function update_search_hint(context)
  local hint = context.search_hint
  if not (hint and hint.valid) then
    return
  end

  hint.visible = (context.query or "") == ""
end

local function refresh_tab_buttons(context)
  local active_id = catalog.tab_by_index(context.tab_index).id
  local searching = (context.query or "") ~= ""

  for tab_id, button in pairs(context.tab_buttons) do
    if button.valid then
      local is_active = tab_id == active_id
      local empty = searching and catalog.match_count_for_tab(tab_id, context.query, prototypes) == 0

      if empty then
        button.style = is_active
          and "item_nicknames_picker_tab_empty_active"
          or "item_nicknames_picker_tab_empty"
      elseif is_active then
        button.style = "item_nicknames_picker_tab_active"
      else
        button.style = "item_nicknames_picker_tab"
      end
    end
  end
end

local function populate_grid(player)
  local context = picker.context(player)
  if not context or not context.grid.valid then
    return
  end

  local tab_id = catalog.tab_by_index(context.tab_index).id
  local grid = context.grid
  grid.clear()

  local entries = catalog.entries_for_tab(tab_id, prototypes)
  entries = catalog.filter_entries(entries, context.query)

  for index = 1, #entries do
    local entry = entries[index]
    local cell = grid.add({
      type = "flow",
      direction = "vertical",
      style = "item_nicknames_picker_cell",
    })

    cell.add({
      type = "sprite-button",
      name = picker_names.entry_prefix .. tab_id .. "_" .. index,
      sprite = entry.sprite,
      tooltip = entry.localized_name or entry.n,
      tags = {
        item_nicknames_picker_name = entry.n,
        item_nicknames_picker_tab = tab_id,
      },
    }).style.size = {40, 40}

    badge_flow(cell, entry)
  end

  update_status(context.frame, #entries)
  refresh_tab_buttons(context)
  update_search_hint(context)
end

local function set_tab(player, tab_index)
  local context = picker.context(player)
  if not context then
    return
  end

  context.tab_index = tab_index
  populate_grid(player)
end

function M.open(player, row_uid, callback)
  picker.close(player)
  catalog.invalidate()
  catalog.ensure_cache(prototypes)

  local frame = player.gui.screen.add({
    type = "frame",
    name = picker_names.frame,
    direction = "vertical",
    caption = {"item-nicknames.picker-title"},
  })
  frame.auto_center = true

  picker.set_context(player, {
    row_uid = row_uid,
    callback = callback,
    tab_index = 1,
    query = "",
    frame = frame,
    tab_buttons = {},
  })

  local context = picker.context(player)

  local main_row = frame.add({
    type = "flow",
    name = picker_names.main,
    direction = "horizontal",
    style = "item_nicknames_picker_main",
  })
  main_row.style.height = PICKER_BODY_HEIGHT

  local tabs_column = main_row.add({
    type = "flow",
    name = picker_names.tabs_column,
    direction = "vertical",
    style = "item_nicknames_picker_tab_column",
  })
  tabs_column.style.width = TAB_COLUMN_WIDTH
  tabs_column.style.height = PICKER_BODY_HEIGHT
  tabs_column.style.vertically_stretchable = false

  for index, tab_def in ipairs(catalog.tabs) do
    local button = tabs_column.add({
      type = "button",
      name = picker_names.tab_prefix .. tab_def.id,
      caption = {"item-nicknames.picker-tab-" .. tab_def.id},
      tags = {item_nicknames_picker_tab_index = index},
      style = index == 1 and "item_nicknames_picker_tab_active" or "item_nicknames_picker_tab",
    })
    context.tab_buttons[tab_def.id] = button
  end

  local body = main_row.add({
    type = "frame",
    name = picker_names.body,
    direction = "vertical",
    style = "item_nicknames_picker_body",
  })
  body.style.width = CONTENT_WIDTH
  body.style.height = PICKER_BODY_HEIGHT
  body.style.vertically_stretchable = true

  local search_box = body.add({
    type = "flow",
    name = picker_names.search_box,
    direction = "vertical",
  })
  search_box.style.width = INNER_WIDTH

  context.search = search_box.add({
    type = "textfield",
    name = picker_names.search,
    icon = {
      type = "utility",
      name = "search",
    },
    tooltip = {"item-nicknames.picker-search"},
  })
  context.search.style.width = INNER_WIDTH

  context.search_hint = search_box.add({
    type = "label",
    name = picker_names.search_hint,
    caption = {"item-nicknames.picker-search"},
    style = "item_nicknames_picker_search_hint",
    ignored_by_interaction = true,
  })
  context.search_hint.style.top_margin = -28
  context.search_hint.style.left_margin = 28
  context.search_hint.style.width = INNER_WIDTH - 36

  local scroll = body.add({
    type = "scroll-pane",
    name = picker_names.scroll,
    style = "item_nicknames_picker_scroll",
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never",
  })
  scroll.style.width = SCROLL_WIDTH
  scroll.style.vertically_stretchable = true
  scroll.style.horizontally_stretchable = false
  scroll.style.maximal_height = PICKER_BODY_HEIGHT - 48

  context.grid = scroll.add({
    type = "table",
    name = picker_names.grid,
    column_count = picker_column_count(),
    style = "item_nicknames_picker_table",
  })

  frame.add({
    type = "label",
    name = picker_names.status,
    caption = "",
  }).style.single_line = false

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

  set_tab(player, 1)
  dialogs.open_over_editor(player, frame)
end

function M.handle_click(player, element)
  if element.name == picker_names.cancel then
    picker.destroy(player)
    return true
  end

  if constants.starts_with(element.name, picker_names.tab_prefix) then
    local tab_index = element.tags and element.tags.item_nicknames_picker_tab_index
    if not tab_index then
      local tab_id = element.name:sub(#picker_names.tab_prefix + 1)
      tab_index = catalog.tab_index(tab_id)
    end
    if tab_index then
      set_tab(player, tab_index)
    end
    return true
  end

  if constants.starts_with(element.name, picker_names.entry_prefix) then
    local context = picker.context(player)
    if not context then
      return true
    end

    local name = element.tags.item_nicknames_picker_name
    local tab_id = element.tags.item_nicknames_picker_tab
    local entry = catalog.entry_for_name(name, prototypes)
    local tab = catalog.tab_by_index(catalog.tab_index(tab_id))
    local selection = catalog.selection_for_entry(entry, tab)

    if selection and context.callback then
      context.callback(selection)
    end

    picker.destroy(player)
    return true
  end

  return false
end

function M.handle_text_changed(player, element)
  if element.name ~= picker_names.search then
    return false
  end

  local context = picker.context(player)
  if not context or not context.frame.valid then
    return false
  end

  context.query = element.text or ""
  populate_grid(player)
  return true
end

function M.handle_tab_changed(_player, _element)
  return false
end

function M.is_open(player)
  return picker.is_open(player)
end

return M
