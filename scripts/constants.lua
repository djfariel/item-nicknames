local M = {}

M.names = {
  frame = "item_nicknames_frame",
  rows_scroll = "item_nicknames_rows_scroll",
  rows_table = "item_nicknames_rows_table",
  help_text = "item_nicknames_help_text",
  overflow_warning = "item_nicknames_overflow_warning",
  add = "item_nicknames_add",
  search_flow = "item_nicknames_search_flow",
  search_toggle = "item_nicknames_search_toggle",
  search = "item_nicknames_search",
  reset_applied = "item_nicknames_reset_applied",
  import = "item_nicknames_import",
  import_frame = "item_nicknames_import_frame",
  import_text = "item_nicknames_import_text",
  import_ok = "item_nicknames_import_ok",
  import_back = "item_nicknames_import_back",
  packs = "item_nicknames_packs",
  packs_frame = "item_nicknames_packs_frame",
  packs_back = "item_nicknames_packs_back",
  pack_open = "item_nicknames_pack_open",
  pack_back = "item_nicknames_pack_back",
  export = "item_nicknames_export",
  close = "item_nicknames_close",
  export_frame = "item_nicknames_export_frame",
  export_text = "item_nicknames_export_text",
  export_select_all = "item_nicknames_export_select_all",
  export_ok = "item_nicknames_export_ok",
  export_back = "item_nicknames_export_back",
  close_confirm_frame = "item_nicknames_close_confirm_frame",
  close_confirm_cancel = "item_nicknames_close_confirm_cancel",
  close_confirm_ok = "item_nicknames_close_confirm_ok",
  error_frame = "item_nicknames_error_frame",
  error_ok = "item_nicknames_error_ok",
  error_back = "item_nicknames_error_back",
  sort_flow = "item_nicknames_sort_flow",
  sort_header = "item_nicknames_sort_header",
}

M.picker_names = {
  frame = "item_nicknames_target_picker_frame",
  main = "item_nicknames_target_picker_main",
  tabs_column = "item_nicknames_target_picker_tabs_column",
  body = "item_nicknames_target_picker_body",
  search = "item_nicknames_target_picker_search",
  search_box = "item_nicknames_target_picker_search_box",
  search_hint = "item_nicknames_target_picker_search_hint",
  scroll = "item_nicknames_target_picker_scroll",
  grid = "item_nicknames_target_picker_grid",
  status = "item_nicknames_target_picker_status",
  cancel = "item_nicknames_target_picker_cancel",
  entry_prefix = "item_nicknames_target_picker_entry_",
  tab_prefix = "item_nicknames_target_picker_tab_",
}

M.type_picker_names = {
  frame = "item_nicknames_type_picker_frame",
  list = "item_nicknames_type_picker_list",
  cancel = "item_nicknames_type_picker_cancel",
  ok = "item_nicknames_type_picker_ok",
  flag_prefix = "item_nicknames_type_picker_flag_",
  barrel = "item_nicknames_type_picker_barrel",
}

M.row_prefixes = {
  row = "item_nicknames_row_",
  move = "item_nicknames_row_move_",
  up = "item_nicknames_row_up_",
  down = "item_nicknames_row_down_",
  enabled = "item_nicknames_row_enabled_",
  status = "item_nicknames_row_status_",
  target = "item_nicknames_row_target_",
  types = "item_nicknames_row_types_",
  types_open = "item_nicknames_row_types_open_",
  types_label = "item_nicknames_row_types_label_",
  linked = "item_nicknames_row_linked_",
  nickname = "item_nicknames_row_nickname_",
  delete = "item_nicknames_row_delete_",
}

M.dialog_content_width = 500
M.dialog_textbox_height = 200
M.inset_frame_padding = 4
M.inset_frame_left_padding = 8

M.packs_layout = {
  list_height = 280,
  scroll_width_inset = 8,
  row_spacing = 6,
}
M.dialog_button_minimal_width = 96
M.dialog_button_wide_minimal_width = 144
M.editor_discard_button_minimal_width = 136

M.editor_layout = {
  checkbox_width = 24,
  status_width = 32,
  move_width = 28,
  move_button_height = 16,
  target_width = 168,
  target_icon_size = 32,
  types_width = 76,
  helper_width = 36,
  field_width = 265,
  delete_width = 24,
  row_spacing = 4,
  row_padding = 4,
  row_side_padding = 4,
  row_shell_right_padding = 2,
  row_height = 36,
  sort_header_height = 24,
  sort_header_bottom_padding = 2,
  scrollbar_width = 16,
}

function M.inset_inner_width(content_width)
  return content_width - M.inset_frame_left_padding - M.inset_frame_padding
end

function M.editor_leading_width()
  local layout = M.editor_layout
  return layout.checkbox_width + layout.status_width + layout.move_width
end

function M.editor_row_width()
  local layout = M.editor_layout
  local fixed_width = M.editor_leading_width() + layout.target_width + layout.types_width
    + layout.helper_width + layout.field_width + layout.delete_width
  return fixed_width + (6 * layout.row_spacing) + layout.row_padding + layout.row_side_padding
end

function M.editor_list_width()
  return M.editor_row_width() + M.editor_layout.scrollbar_width
end

function M.editor_list_container_width()
  return M.editor_list_width()
end

local util = require("scripts.util")

function M.starts_with(value, prefix)
  return util.starts_with(value, prefix)
end

M.reopen_on_close = {
  [M.names.export_frame] = true,
  [M.names.close_confirm_frame] = true,
  [M.names.error_frame] = true,
  [M.names.import_frame] = true,
  [M.names.packs_frame] = true,
}

return M
