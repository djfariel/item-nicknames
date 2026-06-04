local common = require("common")

local status_sheet = "__core__/graphics/status.png"
local status_icon_size = 32

local function status_sprite(name, index)
  return {
    type = "sprite",
    name = name,
    filename = status_sheet,
    position = {(index - 1) * status_icon_size, 0},
    size = status_icon_size,
    flags = {"gui-icon"},
  }
end

data:extend({
  status_sprite("item-nicknames-status-ok", 1),
  status_sprite("item-nicknames-status-invalid", 2),
  status_sprite("item-nicknames-status-changed", 3),
  status_sprite("item-nicknames-status-disabled", 5),
  {
    type = "sprite",
    name = "item-nicknames-sort-arrow-up",
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = 16,
    flags = {"gui-icon"},
  },
  {
    type = "sprite",
    name = "item-nicknames-sort-arrow-down",
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = 16,
    flags = {"gui-icon"},
  },
  {
    type = "font",
    name = common.font_name,
    from = "default",
    size = 0,
  },
  {
    type = "custom-input",
    name = common.focus_search_input,
    linked_game_control = "focus-search",
    key_sequence = "",
    action = "lua",
    consuming = "none",
  },
  {
    type = "shortcut",
    name = common.shortcut_name,
    order = "z[item-nicknames]",
    action = "lua",
    localised_name = {"shortcut-name.item-nicknames-open"},
    localised_description = {"shortcut-description.item-nicknames-open"},
    icon = "__core__/graphics/icons/mip/custom-tag-icon.png",
    icon_size = 32,
    small_icon = "__core__/graphics/icons/mip/custom-tag-icon.png",
    small_icon_size = 32,
  },
  {
    type = "item",
    name = common.overflow_marker_name,
    icon = "__base__/graphics/icons/iron-plate.png",
    icon_size = 64,
    subgroup = "other",
    order = "z[item-nicknames-overflow-marker]",
    stack_size = 1,
    hidden = true,
    flags = {"hide-from-fuel-tooltip", "hide-from-bonus-gui"},
    localised_description = "",
  },
})
