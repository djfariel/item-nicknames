-- Multi-target row model: compact type flags and normalization.
--
-- Wire keys (IN1 JSON objects): n=target, y=type flags, w=nicknames, d=disabled, h=helpers.
-- Flag "x" = technology-only row (not in matrix_flags). Helper "b" = also nickname fluid barrel item.

local signal_types = require("scripts.signal_types")
local util = require("scripts.util")

local trim = util.trim

local row_model = {}

row_model.format_prefix = "IN1."

-- Matrix type order (technology uses "x" only, not in matrix).
row_model.matrix_flags = {"i", "n", "r", "f", "p", "l", "o", "v", "a"}

row_model.flag_to_signal = {
  i = "item",
  n = "entity",
  r = "recipe",
  f = "fluid",
  p = "equipment",
  l = "tile",
  o = "space-location",
  v = "virtual-signal",
  a = "asteroid-chunk",
  x = "technology",
}

row_model.signal_to_flag = {
  item = "i",
  entity = "n",
  recipe = "r",
  fluid = "f",
  equipment = "p",
  tile = "l",
  ["space-location"] = "o",
  ["virtual-signal"] = "v",
  ["asteroid-chunk"] = "a",
  technology = "x",
}

-- Target picker tabs (canonical; catalog imports this list).
row_model.catalog_tab_specs = {
  {id = "item", flag = "i", collection = "item"},
  {id = "fluid", flag = "f", collection = "fluid"},
  {id = "entity", flag = "n", collection = "entity"},
  {id = "recipe", flag = "r", collection = "recipe"},
  {id = "equipment", flag = "p", collection = "equipment"},
  {id = "tile", flag = "l", collection = "tile"},
  {id = "space", flag = "o", collection = "space_location"},
  {id = "signal", flag = "v", collection = "virtual_signal"},
  {id = "asteroid", flag = "a", collection = "asteroid_chunk"},
  {id = "technology", flag = "x", collection = "technology", tech_only = true},
}

function row_model.sorted_flags(flags)
  flags = flags or ""
  local chars = {}

  for index = 1, #flags do
    chars[#chars + 1] = flags:sub(index, index)
  end

  table.sort(chars)
  return table.concat(chars)
end

function row_model.has_flag(flags, flag)
  if not flags or flags == "" or not flag or flag == "" then
    return false
  end

  for index = 1, #flags do
    if flags:sub(index, index) == flag then
      return true
    end
  end

  return false
end

function row_model.set_flag(flags, flag, enabled)
  flags = flags or ""
  local present = row_model.has_flag(flags, flag)
  if enabled and not present then
    return row_model.sorted_flags(flags .. flag)
  end
  if not enabled and present then
    local remaining = {}
    for index = 1, #flags do
      local current = flags:sub(index, index)
      if current ~= flag then
        remaining[#remaining + 1] = current
      end
    end
    return row_model.sorted_flags(table.concat(remaining))
  end
  return row_model.sorted_flags(flags)
end

function row_model.flag_to_signal_type(flag)
  return row_model.flag_to_signal[flag]
end

function row_model.is_technology_row(row)
  if not row then
    return false
  end

  return (row.y or "") == "x"
end

function row_model.is_disabled(row)
  return row.d == true
end

function row_model.nicknames(row)
  return trim(row.w or "")
end

function row_model.name(row)
  return trim(row.n or "")
end

function row_model.type_flags(row)
  return row.y or ""
end

function row_model.helpers(row)
  return row.h or ""
end

function row_model.normalize_row(row)
  if not row then
    return row
  end

  if row.n then
    row.n = trim(row.n)
  end

  if row.y then
    row.y = row_model.sorted_flags(row.y)
  end

  if row.h then
    row.h = row_model.sorted_flags(row.h)
  end

  if row.w then
    row.w = trim(row.w)
  end

  return row
end

function row_model.wire_row(row)
  row = row_model.normalize_row(row)
  local wire = {
    n = row.n,
    y = row.y,
    w = row.w,
  }

  if row.d == true then
    wire.d = true
  end

  if row.h and row.h ~= "" then
    wire.h = row.h
  end

  return wire
end

function row_model.row_signature(row)
  row = row_model.normalize_row(row)
  if not row.n or row.n == "" then
    return ""
  end

  return table.concat({
    row.d == true and "0" or "1",
    row.n,
    row_model.sorted_flags(row.y or ""),
    row_model.sorted_flags(row.h or ""),
    (row.w or ""):lower(),
  }, "\t")
end

-- Sprite path segment for Factorio icon paths (item/fluid/entity/...).
function row_model.resolve_sprite_path_type(signal_type, prototype_type)
  signal_type = signal_types.internal_signal_type(signal_type or "item")
  prototype_type = prototype_type or signal_type

  if signal_type == "fluid" or prototype_type == "fluid" then
    return "fluid"
  end
  if signal_type == "recipe" or prototype_type == "recipe" then
    return "recipe"
  end
  if signal_type == "technology" or prototype_type == "technology" then
    return "technology"
  end
  if signal_type == "tile" or prototype_type == "tile" then
    return "tile"
  end
  if signal_type == "virtual-signal" or prototype_type == "virtual-signal" then
    return "virtual-signal"
  end
  if signal_type == "asteroid-chunk" or prototype_type == "asteroid-chunk" then
    return "asteroid-chunk"
  end
  if signal_type == "space-location" or prototype_type == "space-location" or prototype_type == "planet" then
    return "space-location"
  end

  for _, equipment_type in ipairs(signal_types.equipment_prototype_types) do
    if prototype_type == equipment_type or signal_type == "equipment" then
      return "equipment"
    end
  end

  if signal_type == "entity" or prototype_type == "entity" or prototype_type == "plant" then
    return "entity"
  end

  return "item"
end

function row_model.primary_signal_type(row)
  if not row then
    return "item"
  end

  if row.y == "x" then
    return "technology"
  end

  for _, flag in ipairs(row_model.matrix_flags) do
    if row_model.has_flag(row.y, flag) then
      return row_model.flag_to_signal_type(flag)
    end
  end

  return "item"
end

return row_model
