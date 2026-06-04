local styles = data.raw["gui-style"].default

-- Must match status icon size in data/sprites.lua (__core__/graphics/status.png strip).
local status_icon_size = 32

styles.item_nicknames_description_frame = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  padding = 4,
  left_padding = 8,
  horizontally_stretchable = "on",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 4,
  },
}

styles.item_nicknames_description_frame_fixed_width = {
  type = "frame_style",
  parent = "item_nicknames_description_frame",
  width = 500,
}

styles.item_nicknames_row_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 2,
  vertical_align = "center",
  height = 36,
}

styles.item_nicknames_row_leading_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0,
  vertical_align = "center",
}

styles.item_nicknames_row_shell_base = {
  type = "frame_style",
  padding = 0,
  left_padding = 4,
  right_padding = 2,
  horizontally_stretchable = "on",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    parent = "item_nicknames_row_flow",
  },
}

local row_odd_tint = {235, 235, 235, 255}

styles.item_nicknames_row_shell_even = {
  type = "frame_style",
  parent = "item_nicknames_row_shell_base",
  graphical_set = {
    base = {position = {68, 0}, corner_size = 8},
  },
}

styles.item_nicknames_row_shell_odd = {
  type = "frame_style",
  parent = "item_nicknames_row_shell_base",
  graphical_set = {
    base = {position = {68, 0}, corner_size = 8, tint = row_odd_tint},
  },
}

styles.item_nicknames_row_status = {
  type = "image_style",
  size = status_icon_size,
  stretch_image_to_widget_size = true,
}

styles.item_nicknames_editable_label_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 2,
  vertical_align = "center",
  height = 28,
}

styles.item_nicknames_sort_header = {
  type = "horizontal_flow_style",
  horizontal_spacing = 4,
  vertical_align = "center",
  height = 24,
  bottom_padding = 2,
}

styles.item_nicknames_sort_header_column = {
  type = "horizontal_flow_style",
  horizontal_spacing = 2,
  vertical_align = "center",
}

local sort_label_graphical_set = {
  base = {position = {17, 17}, size = {1, 1}, opacity = 0},
}

styles.item_nicknames_sort_header_label_button = {
  type = "button_style",
  font = "default-bold",
  horizontal_align = "left",
  padding = 0,
  left_padding = 2,
  horizontally_squashable = "on",
  default_font_color = {128, 128, 128},
  hovered_font_color = {255, 255, 255},
  clicked_font_color = {255, 255, 255},
  default_graphical_set = sort_label_graphical_set,
  hovered_graphical_set = sort_label_graphical_set,
  clicked_graphical_set = sort_label_graphical_set,
}

styles.item_nicknames_sort_header_label_button_active = {
  type = "button_style",
  parent = "item_nicknames_sort_header_label_button",
  default_font_color = {255, 241, 86},
  hovered_font_color = {255, 241, 86},
  clicked_font_color = {255, 241, 86},
}

local sort_arrow = {
  size = {16, 16},
  scale = 0.5,
}

styles.item_nicknames_sort_asc_active = {
  type = "button_style",
  size = {8, 8},
  padding = 0,
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-active.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-hover.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-active.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
}

styles.item_nicknames_sort_asc_inactive = {
  type = "button_style",
  size = {8, 8},
  padding = 0,
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-hover.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
}

styles.item_nicknames_sort_desc_active = {
  type = "button_style",
  size = {8, 8},
  padding = 0,
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-hover.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = sort_arrow.size,
    scale = sort_arrow.scale,
  },
}

styles.item_nicknames_row_delete_button = {
  type = "button_style",
  parent = "transparent_button",
  size = {24, 32},
  right_padding = 4,
  invert_colors_of_picture_when_hovered_or_toggled = false,
  left_click_sound = "__core__/sound/gui-tool-button.ogg",
}

styles.item_nicknames_dialog_button = {
  type = "button_style",
  parent = "confirm_button_without_tooltip",
  default_graphical_set = styles.button.default_graphical_set,
  hovered_graphical_set = styles.button.hovered_graphical_set,
  clicked_graphical_set = styles.button.clicked_graphical_set,
  disabled_graphical_set = styles.button.disabled_graphical_set,
}

styles.item_nicknames_rows_table = {
  type = "table_style",
  horizontal_spacing = 0,
  vertical_spacing = 0,
  left_cell_padding = 4,
  right_cell_padding = 4,
  top_cell_padding = 2,
  bottom_cell_padding = 2,
}

styles.item_nicknames_rows_scroll = {
  type = "scroll_pane_style",
  parent = "naked_scroll_pane",
  padding = 0,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
}

styles.item_nicknames_target_button = {
  type = "button_style",
  parent = "transparent_button",
  horizontal_align = "left",
  padding = 0,
  left_padding = 2,
  single_line = true,
  horizontally_squashable = "on",
  default_font_color = {255, 255, 255},
  hovered_font_color = {255, 255, 255},
  clicked_font_color = {255, 255, 255},
}

styles.item_nicknames_target_button_empty = {
  type = "button_style",
  parent = "item_nicknames_target_button",
  default_font_color = {160, 160, 160},
  hovered_font_color = {180, 180, 180},
  clicked_font_color = {180, 180, 180},
}

styles.item_nicknames_target_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 2,
  vertical_align = "center",
}

styles.item_nicknames_type_badge = {
  type = "label_style",
  font = "default-tiny-bold",
  default_font_color = {180, 180, 180},
}

styles.item_nicknames_types_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 2,
  vertical_align = "center",
}

styles.item_nicknames_types_label = {
  type = "label_style",
  font = "default-bold",
  horizontal_align = "left",
  single_line = true,
  horizontally_squashable = "on",
  left_padding = 2,
  default_font_color = {180, 180, 180},
}

styles.item_nicknames_editable_label_display = {
  type = "label_style",
  horizontal_align = "left",
  single_line = true,
  horizontally_squashable = "on",
}

styles.item_nicknames_types_button = {
  type = "button_style",
  parent = "slot_button",
  horizontal_align = "left",
  padding = 4,
  single_line = true,
}

styles.item_nicknames_types_open_button = {
  type = "button_style",
  parent = "tool_button",
  padding = 2,
}

styles.item_nicknames_type_picker_list = {
  type = "vertical_flow_style",
  vertical_spacing = 4,
}

styles.item_nicknames_type_picker_row = {
  type = "horizontal_flow_style",
  horizontal_spacing = 8,
  vertical_align = "center",
}

styles.item_nicknames_checkbox = {
  type = "button_style",
  parent = "transparent_button",
  size = {24, 24},
  padding = 0,
}

styles.item_nicknames_checkbox_large = {
  type = "button_style",
  parent = "item_nicknames_checkbox",
  size = {32, 32},
}

styles.item_nicknames_picker_main = {
  type = "horizontal_flow_style",
  horizontal_spacing = 8,
  vertical_align = "top",
}

styles.item_nicknames_picker_tab_column = {
  type = "vertical_flow_style",
  vertical_spacing = 0,
  horizontal_align = "left",
  width = 96,
}

styles.item_nicknames_picker_tab = {
  type = "button_style",
  parent = "tool_button",
  font = "default",
  horizontally_stretchable = "on",
  vertical_align = "center",
  minimal_width = 96,
  height = 40,
  minimal_height = 40,
  maximal_height = 40,
  padding = 4,
}

styles.item_nicknames_picker_tab_active = {
  type = "button_style",
  parent = "tool_button",
  font = "default",
  horizontally_stretchable = "on",
  vertical_align = "center",
  minimal_width = 96,
  height = 40,
  minimal_height = 40,
  maximal_height = 40,
  padding = 4,
  default_font_color = {r = 1, g = 1, b = 1},
  hovered_font_color = {r = 1, g = 1, b = 1},
  clicked_font_color = {r = 1, g = 1, b = 1},
}

styles.item_nicknames_picker_tab_empty = {
  type = "button_style",
  parent = "item_nicknames_picker_tab",
  default_font_color = {100, 100, 100},
  hovered_font_color = {130, 130, 130},
  clicked_font_color = {115, 115, 115},
}

styles.item_nicknames_picker_tab_empty_active = {
  type = "button_style",
  parent = "item_nicknames_picker_tab_active",
  default_font_color = {150, 150, 150},
  hovered_font_color = {175, 175, 175},
  clicked_font_color = {165, 165, 165},
}

styles.item_nicknames_picker_search_hint = {
  type = "label_style",
  font = "default",
  default_font_color = {128, 128, 128},
  single_line = true,
}

styles.item_nicknames_packs_list_inset = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  padding = 4,
  vertically_stretchable = "off",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
}

styles.item_nicknames_packs_scroll = {
  type = "scroll_pane_style",
  parent = "list_box_in_shallow_frame_scroll_pane",
  padding = 4,
}

styles.item_nicknames_pack_list_flow = {
  type = "vertical_flow_style",
  vertical_spacing = 6,
}

styles.item_nicknames_pack_row_card = {
  type = "frame_style",
  parent = "item_nicknames_row_shell_even",
  left_padding = 12,
  right_padding = 8,
  top_padding = 8,
  bottom_padding = 8,
  horizontally_stretchable = "on",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    vertical_align = "center",
  },
}

styles.item_nicknames_picker_body = {
  type = "frame_style",
  parent = "inside_deep_frame",
  vertically_stretchable = "on",
  horizontally_stretchable = "off",
  padding = 8,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 8,
  },
}

styles.item_nicknames_picker_scroll = {
  type = "scroll_pane_style",
  parent = "deep_scroll_pane",
  padding = 4,
}

styles.item_nicknames_picker_table = {
  type = "table_style",
  horizontal_spacing = 2,
  vertical_spacing = 2,
}

styles.item_nicknames_picker_cell = {
  type = "vertical_flow_style",
  vertical_spacing = 2,
  horizontal_align = "center",
  width = 48,
}
