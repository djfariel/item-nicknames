-- Row status lamp from __core__/graphics/status.png (32px icons in a horizontal strip).

local common = require("common")
local row_model = require("scripts.row_model")
local rows = require("scripts.rows")

local M = {}

M.sheet = "__core__/graphics/status.png"
M.icon_size = 32

M.sprites = {
  ok = "item-nicknames-status-ok",
  invalid = "item-nicknames-status-invalid",
  changed = "item-nicknames-status-changed",
  disabled = "item-nicknames-status-disabled",
}

M.style = "item_nicknames_row_status"

local tooltip_keys = {
  [M.sprites.ok] = "item-nicknames.row-status-ok",
  [M.sprites.invalid] = "item-nicknames.row-status-invalid",
  [M.sprites.changed] = "item-nicknames.row-status-changed",
  [M.sprites.disabled] = "item-nicknames.row-status-disabled",
}

function M.sprite_for_row(row, player)
  row = common.normalize_row(row)

  if row_model.is_disabled(row) then
    return M.sprites.disabled
  end

  if rows.row_is_invalid(row) then
    return M.sprites.invalid
  end

  if rows.row_is_changed(row, player) then
    return M.sprites.changed
  end

  return M.sprites.ok
end

function M.tooltip_for_sprite(sprite)
  local key = tooltip_keys[sprite]
  return key and {key} or ""
end

function M.add(parent, options)
  options = options or {}
  local row = options.row or {}
  local sprite = M.sprite_for_row(row, options.player)

  local element = parent.add({
    type = "sprite",
    name = options.name,
    sprite = sprite,
    tooltip = M.tooltip_for_sprite(sprite),
    tags = options.tags,
    style = options.style or M.style,
  })

  element.style.width = M.icon_size
  element.style.height = M.icon_size
  return element
end

function M.update(element, row, player)
  if not (element and element.valid) then
    return
  end

  local sprite = M.sprite_for_row(row, player)
  element.sprite = sprite
  element.tooltip = M.tooltip_for_sprite(sprite)
end

return M
