-- Resolve prototype icons to GUI sprite paths.

local prototype_util = require("scripts.prototype_util")
local row_model = require("scripts.row_model")
local signal_types = require("scripts.signal_types")

local icon = {}

local PLACEHOLDER_SPRITE = "utility/questionmark"
local safe_read = prototype_util.safe_read

local function runtime_prototype_fields(prototype)
  local name
  local prototype_type

  pcall(function()
    name = prototype.name
    prototype_type = prototype.type
  end)

  return name, prototype_type
end

local function is_runtime_prototype(prototype)
  if prototype == nil then
    return false
  end

  if type(prototype) == "userdata" then
    return true
  end

  if type(prototype) ~= "table" then
    return false
  end

  local object_name = safe_read(prototype, "object_name")
  if type(object_name) == "string" and object_name:sub(1, 3) == "Lua" then
    return true
  end

  -- Data-stage tables return nil for missing keys; runtime prototypes error.
  return not pcall(function()
    local _ = prototype.icon
  end)
end

local function default_sprite_for_signal_type(_signal_type)
  return PLACEHOLDER_SPRITE
end

local function sprite_path_type(signal_type, prototype_type)
  return row_model.resolve_sprite_path_type(signal_type, prototype_type)
end

local function sprite_path_for(signal_type, name, prototype_type)
  if not name or name == "" then
    return PLACEHOLDER_SPRITE
  end

  return sprite_path_type(signal_type, prototype_type) .. "/" .. name
end

local function pick_valid_sprite_path(candidates, fallback)
  fallback = fallback or PLACEHOLDER_SPRITE

  if helpers and helpers.is_valid_sprite_path then
    for _, path in ipairs(candidates) do
      if path and path ~= "" and helpers.is_valid_sprite_path(path) then
        return path
      end
    end

    if helpers.is_valid_sprite_path(fallback) then
      return fallback
    end

    return PLACEHOLDER_SPRITE
  end

  for _, path in ipairs(candidates) do
    if path and path ~= "" and not path:find("/unknown$") and not path:find("/$") then
      return path
    end
  end

  return PLACEHOLDER_SPRITE
end

local function runtime_sprite_path(signal_type, name, prototype_type)
  if not name or name == "" then
    return PLACEHOLDER_SPRITE
  end

  local path_type = sprite_path_type(signal_type, prototype_type)
  local candidates = {path_type .. "/" .. name}

  if path_type == "entity" then
    candidates[#candidates + 1] = "item/" .. name
  elseif path_type == "item" then
    candidates[#candidates + 1] = "entity/" .. name
  end

  return pick_valid_sprite_path(candidates, default_sprite_for_signal_type(signal_type))
end

local function icon_from_data_prototype(prototype, fallback)
  if not prototype then
    return fallback
  end

  local icon_value = safe_read(prototype, "icon")
  if icon_value then
    return icon_value
  end

  local icons = safe_read(prototype, "icons")
  if icons and icons[1] and icons[1].icon then
    return icons[1].icon
  end

  return fallback
end

function icon.primary_signal_type(row)
  return row_model.primary_signal_type(row)
end

function icon.prototype_for_row(row, runtime_prototypes)
  row = row_model.normalize_row(row)
  local name = row_model.name(row)
  if name == "" then
    return nil
  end

  local signal_type = icon.primary_signal_type(row)
  runtime_prototypes = runtime_prototypes or prototypes
  if runtime_prototypes then
    return signal_types.find_runtime_prototype(runtime_prototypes, signal_type, name)
  end

  return signal_types.find_data_prototype(signal_type, name)
end

function icon.sprite_for_prototype(prototype, signal_type)
  signal_type = signal_types.internal_signal_type(signal_type or "item")

  if not prototype then
    return PLACEHOLDER_SPRITE
  end

  if is_runtime_prototype(prototype) then
    local name, prototype_type = runtime_prototype_fields(prototype)
    return runtime_sprite_path(signal_type, name, prototype_type)
  end

  local fallback = sprite_path_for(signal_type, prototype.name, prototype.type)
  return pick_valid_sprite_path({icon_from_data_prototype(prototype, fallback)}, fallback)
end

function icon.sprite_for_row(row, runtime_prototypes)
  row = row_model.normalize_row(row)
  local signal_type = icon.primary_signal_type(row)
  local prototype = icon.prototype_for_row(row, runtime_prototypes)
  return icon.sprite_for_prototype(prototype, signal_type)
end

function icon.pick_sprite_path(candidates, fallback)
  return pick_valid_sprite_path(candidates, fallback)
end

return icon
