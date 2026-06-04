-- Prototype relationship lookups for type auto-fill, barrel helper, and linked rows.

local prototype_util = require("scripts.prototype_util")
local row_model = require("scripts.row_model")
local signal_types = require("scripts.signal_types")

local prototype_links = {}

local safe_read = prototype_util.safe_read
local safe_index = prototype_util.safe_index

local barrel_cache = nil
local available_types_cache = {}

local function data_find(signal_type, name)
  return signal_types.find_data_prototype(signal_type, name)
end

local function runtime_find(runtime_prototypes, signal_type, name)
  if not runtime_prototypes then
    return nil
  end

  return signal_types.find_runtime_prototype(runtime_prototypes, signal_type, name)
end

local function item_prototype(item_name, runtime_prototypes)
  if runtime_prototypes then
    return runtime_prototypes.item[item_name]
  end

  return data_find("item", item_name)
end

function prototype_links.invalidate_caches()
  barrel_cache = nil
  available_types_cache = {}
  signal_types.invalidate_entity_prototype_cache()
end

local function build_barrel_cache(runtime_prototypes)
  if barrel_cache then
    return
  end

  barrel_cache = {}
  local collection
  if runtime_prototypes then
    collection = runtime_prototypes.item
  elseif data and data.raw then
    collection = data.raw.item
  elseif prototypes then
    collection = prototypes.item
  end

  if not collection then
    return
  end

  for item_name, prototype in pairs(collection) do
    local name = safe_read(prototype, "name") or item_name
    local fluid_name = name:match("^(.+)%-barrel$")
    if fluid_name and not barrel_cache[fluid_name] then
      barrel_cache[fluid_name] = name
    end

    local fluidbox = safe_read(prototype, "fluidbox")
    local first = safe_index(fluidbox, 1)
    local filter = first and safe_read(first, "filter")
    if filter and not barrel_cache[filter] then
      barrel_cache[filter] = name
    end
  end
end

function prototype_links.type_exists(name, signal_type, runtime_prototypes)
  signal_type = signal_types.internal_signal_type(signal_type)

  if runtime_prototypes then
    return runtime_find(runtime_prototypes, signal_type, name) ~= nil
  end

  if data and data.raw then
    return data_find(signal_type, name) ~= nil
  end

  if prototypes then
    return runtime_find(prototypes, signal_type, name) ~= nil
  end

  return false
end

function prototype_links.available_types(name, runtime_prototypes)
  name = name or ""
  if name == "" then
    return ""
  end

  local cache_key = (runtime_prototypes and "runtime" or "data") .. ":" .. name
  if available_types_cache[cache_key] then
    return available_types_cache[cache_key]
  end

  local flags = {}

  for _, flag in ipairs(row_model.matrix_flags) do
    local signal_type = row_model.flag_to_signal_type(flag)
    if prototype_links.type_exists(name, signal_type, runtime_prototypes) then
      flags[#flags + 1] = flag
    end
  end

  local result = row_model.sorted_flags(table.concat(flags))
  available_types_cache[cache_key] = result
  return result
end

function prototype_links.barrel_item_for_fluid(fluid_name, runtime_prototypes)
  fluid_name = fluid_name or ""
  if fluid_name == "" then
    return nil
  end

  build_barrel_cache(runtime_prototypes)
  return barrel_cache[fluid_name]
end

function prototype_links.placed_entity_for_item(item_name, runtime_prototypes)
  local item = item_prototype(item_name, runtime_prototypes)
  if not item then
    return nil
  end

  local place_result = safe_read(item, "place_result")
  if place_result then
    return place_result
  end

  local plant_result = safe_read(item, "plant_result")
  if plant_result then
    return plant_result
  end

  return nil
end

function prototype_links.equipment_for_item(item_name, runtime_prototypes)
  local item = item_prototype(item_name, runtime_prototypes)
  if not item then
    return nil
  end

  return safe_read(item, "place_as_equipment_result")
end

function prototype_links.tile_for_item(item_name, runtime_prototypes)
  local item = item_prototype(item_name, runtime_prototypes)
  if not item then
    return nil
  end

  local place_as_tile = safe_read(item, "place_as_tile")
  if not place_as_tile then
    return nil
  end

  return safe_read(place_as_tile, "result")
end

function prototype_links.linked_suggestions(name, runtime_prototypes)
  name = name or ""
  local suggestions = {}

  local placed_entity = prototype_links.placed_entity_for_item(name, runtime_prototypes)
  if placed_entity and placed_entity ~= name then
    if prototype_links.type_exists(placed_entity, "entity", runtime_prototypes) then
      suggestions[#suggestions + 1] = {
        kind = "placed_entity",
        n = placed_entity,
        y = "n",
      }
    end
  end

  local equipment = prototype_links.equipment_for_item(name, runtime_prototypes)
  if equipment and equipment ~= name then
    if prototype_links.type_exists(equipment, "equipment", runtime_prototypes) then
      suggestions[#suggestions + 1] = {
        kind = "equipment",
        n = equipment,
        y = "p",
      }
    end
  end

  local tile = prototype_links.tile_for_item(name, runtime_prototypes)
  if tile and tile ~= name then
    if prototype_links.type_exists(tile, "tile", runtime_prototypes) then
      suggestions[#suggestions + 1] = {
        kind = "tile",
        n = tile,
        y = "l",
      }
    end
  end

  return suggestions
end

function prototype_links.suggest_type_flags(name, runtime_prototypes)
  local available = prototype_links.available_types(name, runtime_prototypes)
  if available == "" then
    return available
  end

  local item = item_prototype(name, runtime_prototypes)
  if item then
    local flags = available
    local equipment = prototype_links.equipment_for_item(name, runtime_prototypes)
    if equipment and prototype_links.type_exists(equipment, "equipment", runtime_prototypes) then
      flags = row_model.set_flag(flags, "p", true)
    end
    local tile = prototype_links.tile_for_item(name, runtime_prototypes)
    if tile and prototype_links.type_exists(tile, "tile", runtime_prototypes) then
      flags = row_model.set_flag(flags, "l", true)
    end
    return flags
  end

  return available
end

return prototype_links
