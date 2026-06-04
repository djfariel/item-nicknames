local config = require("scripts.config")
local signal_types = require("scripts.signal_types")
local tokens = require("scripts.tokens")

local locale = {}

local prototype_name_prefix = {
  entity = "entity",
  fluid = "fluid",
  recipe = "recipe",
  technology = "technology",
  tile = "tile",
  equipment = "equipment",
  ["virtual-signal"] = "virtual-signal",
  ["space-location"] = "space-location",
  ["asteroid-chunk"] = "asteroid-chunk",
}

local function is_item_prototype(prototype)
  if not prototype then
    return false
  end

  for _, item_type in ipairs(signal_types.item_prototype_types) do
    if prototype.type == item_type then
      return true
    end
  end

  return false
end

local function name_key(prototype_type, name, signal_type)
  signal_type = signal_types.internal_signal_type(signal_type)

  if signal_type and signal_types.locale_category(signal_type) then
    return {signal_types.locale_category(signal_type) .. "." .. name}
  end

  if is_item_prototype({type = prototype_type}) then
    return {"item-name." .. name}
  end

  local prefix = prototype_name_prefix[prototype_type]
  if prefix then
    return {prefix .. "-name." .. name}
  end

  if prototype_type == "plant"
      or prototype_type == "simple-entity"
      or prototype_type == "simple-entity-with-force"
      or prototype_type == "simple-entity-with-owner"
      or prototype_type == "capture-robot" then
    return {"entity-name." .. name}
  end

  return {name}
end

function locale.find_item(name, get_prototype)
  return get_prototype("item", name)
end

function locale.of_item(item, get_prototype)
  if not item then
    return nil
  end

  if item.localised_name then
    return item.localised_name
  end

  if item.plant_result then
    return {"item-name." .. item.name}
  end

  if item.place_result then
    local planted = get_prototype("entity", item.place_result)
    if planted and planted.type ~= "plant" then
      return {"entity-name." .. item.place_result}
    end
  end

  if item.place_as_equipment_result then
    return {"equipment-name." .. item.place_as_equipment_result}
  end

  if item.place_as_tile then
    return {"tile-name." .. item.place_as_tile.result}
  end

  return {"item-name." .. item.name}
end

function locale.of_recipe(recipe, get_prototype)
  if not recipe then
    return nil
  end

  if recipe.localised_name then
    return recipe.localised_name
  end

  local main_product = recipe.main_product
  if main_product == "" then
    return {"recipe-name." .. recipe.name}
  elseif main_product and main_product == recipe.name then
    local item = locale.find_item(main_product, get_prototype)
    if item then
      return locale.of_item(item, get_prototype)
    end

    local fluid = get_prototype("fluid", main_product)
    if fluid then
      return locale.of(fluid, get_prototype)
    end
  end

  local results = recipe.results
  if results and #results == 1 and results[1].name == recipe.name then
    local result = results[1]
    local result_prototype = get_prototype(result.type, result.name)
    if result_prototype then
      return locale.of(result_prototype, get_prototype)
    end

    return name_key(result.type, result.name, result.type)
  end

  return {"recipe-name." .. recipe.name}
end

function locale.of(prototype, get_prototype, signal_type)
  if not prototype then
    return nil
  end

  if prototype.type == "recipe" then
    return locale.of_recipe(prototype, get_prototype)
  end

  if is_item_prototype(prototype) then
    return locale.of_item(prototype, get_prototype)
  end

  if prototype.localised_name then
    return prototype.localised_name
  end

  return name_key(prototype.type, prototype.name, signal_type)
end

local function data_get_prototype(prototype_type, name)
  if prototype_type == "item" then
    return signal_types.find_data_prototype("item", name)
  end

  local collection = data.raw[prototype_type]
  if collection and collection[name] then
    return collection[name]
  end

  return signal_types.find_data_prototype(prototype_type, name)
end

function locale.of_data(signal_type, name, prototype)
  prototype = prototype or signal_types.find_data_prototype(signal_type, name)
  return locale.of(prototype, data_get_prototype, signal_type)
end

function locale.of_runtime(runtime_prototypes, signal_type, name)
  local prototype = signal_types.find_runtime_prototype(runtime_prototypes, signal_type, name)
  return locale.of(prototype, function(prototype_type, prototype_name)
    return signal_types.find_runtime_prototype(runtime_prototypes, prototype_type, prototype_name)
  end, signal_type)
end

function locale.append_nickname_chunks(base_name, font_open, font_close, chunks)
  chunks = chunks or {}
  if #chunks == 0 then
    if type(base_name) == "string" then
      return base_name
    end

    if type(base_name) == "table" then
      return base_name
    end

    return ""
  end

  local function append_suffix(result)
    result[#result + 1] = font_open
    for _, chunk in ipairs(chunks) do
      result[#result + 1] = chunk
    end
    result[#result + 1] = font_close
    return result
  end

  if type(base_name) == "string" then
    return append_suffix({"", {base_name}})
  end

  if type(base_name) == "table" then
    if base_name[1] == "?" then
      local result = {"", "?"}
      for i = 2, #base_name do
        result[#result + 1] = base_name[i]
      end
      return append_suffix(result)
    end

    if base_name[1] == "" then
      local result = {""}
      for i = 2, #base_name do
        result[#result + 1] = base_name[i]
      end
      return append_suffix(result)
    end

    return append_suffix({"", base_name})
  end

  return append_suffix({""})
end

function locale.append_nicknames(base_name, font_open, font_close, nicknames)
  if nicknames == nil or nicknames == "" then
    if type(base_name) == "string" then
      return base_name
    end

    if type(base_name) == "table" then
      return base_name
    end

    return ""
  end

  return locale.append_nickname_chunks(base_name, font_open, font_close, {nicknames})
end

function locale.is_placeable_item(prototype)
  if not prototype then
    return false
  end

  return prototype.place_result ~= nil
    or prototype.place_as_equipment_result ~= nil
    or prototype.place_as_tile ~= nil
end

function locale.is_bogus_item_name_key(localised_name, prototype)
  if not (prototype and locale.is_placeable_item(prototype)) then
    return false
  end

  if type(localised_name) ~= "table" or #localised_name ~= 1 then
    return false
  end

  return localised_name[1] == "item-name." .. prototype.name
end

function locale.strip_mod_nicknames(localised_name)
  if localised_name == nil then
    return nil
  end

  if type(localised_name) ~= "table" or localised_name[1] ~= "" then
    return localised_name
  end

  local font_marker = "[font=" .. config.font_name .. "]"
  local result = {""}

  for index = 2, #localised_name do
    local part = localised_name[index]
    if type(part) == "string" and part:find(font_marker, 1, true) == 1 then
      break
    end
    result[#result + 1] = part
  end

  if #result == 1 then
    return nil
  end

  if #result == 2 and type(result[2]) == "string" then
    return result[2]
  end

  return result
end

function locale.base_localised_name(prototype, signal_type, name)
  local existing = prototype.localised_name

  if locale.is_bogus_item_name_key(existing, prototype) then
    existing = nil
  end

  if existing ~= nil then
    local stripped = locale.strip_mod_nicknames(existing)
    if stripped ~= nil then
      return stripped
    end
  end

  return locale.of_data(signal_type, name, prototype)
end

function locale.apply_nickname_localised_name(prototype, signal_type, name, nicknames, overflow_targets)
  local base_name = locale.base_localised_name(prototype, signal_type, name)
  local chunks, overflow = tokens.chunk_nicknames(
    nicknames,
    config.max_nickname_segment_length,
    config.max_nickname_chunks
  )

  if overflow and overflow_targets then
    overflow_targets[signal_types.target_key(signal_type, name)] = true
    if #chunks == 0 then
      prototype.localised_name = base_name
      return
    end
  end

  prototype.localised_name = locale.append_nickname_chunks(
    base_name,
    config.nickname_mark_open,
    config.nickname_mark_close,
    chunks
  )
end

return locale
