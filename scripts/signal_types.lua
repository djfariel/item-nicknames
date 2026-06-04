-- Signal/prototype type taxonomy, prototype lookups, and target keys.

local signal_types = {}

signal_types.item_prototype_types = {
  "item",
  "ammo",
  "armor",
  "blueprint",
  "blueprint-book",
  "capsule",
  "copy-paste-tool",
  "deconstruction-item",
  "gun",
  "item-with-entity-data",
  "item-with-inventory",
  "item-with-label",
  "item-with-tags",
  "module",
  "rail-planner",
  "repair-tool",
  "selection-tool",
  "spidertron-remote",
  "tool",
  "upgrade-item",
}

signal_types.item_prototype_type_set = {}
for _, prototype_type in ipairs(signal_types.item_prototype_types) do
  signal_types.item_prototype_type_set[prototype_type] = true
end

signal_types.equipment_prototype_types = {
  "active-defense-equipment",
  "battery-equipment",
  "belt-immunity-equipment",
  "energy-shield-equipment",
  "generator-equipment",
  "inventory-bonus-equipment",
  "movement-bonus-equipment",
  "night-vision-equipment",
  "roboport-equipment",
  "solar-panel-equipment",
}

signal_types.space_location_prototype_types = {
  "space-location",
  "planet",
}

-- data.raw tables that never contain nicknameable entity prototypes.
signal_types.data_raw_non_entity_keys = {
  achievement = true,
  ["airborne-pollutant"] = true,
  ["ambient-sound"] = true,
  ammo = true,
  ["ammo-category"] = true,
  armor = true,
  arrow = true,
  ["artillery-flare"] = true,
  ["artillery-projectile"] = true,
  ["asteroid-chunk"] = true,
  ["autoplace-control"] = true,
  beam = true,
  blueprint = true,
  ["blueprint-book"] = true,
  ["burner-usage"] = true,
  capsule = true,
  ["chain-active-trigger"] = true,
  ["change-surface-achievement"] = true,
  ["collision-layer"] = true,
  ["combat-robot-count-achievement"] = true,
  ["complete-objective-achievement"] = true,
  ["construct-with-robots-achievement"] = true,
  ["copy-paste-tool"] = true,
  corpse = true,
  ["create-platform-achievement"] = true,
  ["custom-input"] = true,
  ["damage-type"] = true,
  ["deconstruct-with-robots-achievement"] = true,
  ["deconstruction-item"] = true,
  ["delayed-active-trigger"] = true,
  ["deliver-by-robots-achievement"] = true,
  ["deliver-category"] = true,
  ["deliver-impact-combination"] = true,
  ["deplete-resource-achievement"] = true,
  ["destroy-cliff-achievement"] = true,
  ["dont-build-entity-achievement"] = true,
  ["dont-craft-manually-achievement"] = true,
  ["dont-kill-manually-achievement"] = true,
  ["dont-research-before-researching-achievement"] = true,
  ["dont-use-entity-in-energy-production-achievement"] = true,
  ["editor-controller"] = true,
  ["entity-ghost"] = true,
  ["equip-armor-achievement"] = true,
  ["equipment-category"] = true,
  ["equipment-ghost"] = true,
  ["equipment-grid"] = true,
  explosion = true,
  fire = true,
  fluid = true,
  font = true,
  ["fuel-category"] = true,
  ["god-controller"] = true,
  ["group-attack-achievement"] = true,
  ["gui-style"] = true,
  gun = true,
  ["impact-category"] = true,
  item = true,
  ["item-entity"] = true,
  ["item-group"] = true,
  ["item-subgroup"] = true,
  ["item-with-entity-data"] = true,
  ["item-with-inventory"] = true,
  ["item-with-label"] = true,
  ["item-with-tags"] = true,
  ["kill-achievement"] = true,
  ["map-gen-presets"] = true,
  ["map-settings"] = true,
  module = true,
  ["module-category"] = true,
  ["module-transfer-achievement"] = true,
  ["mouse-cursor"] = true,
  ["noise-expression"] = true,
  ["noise-function"] = true,
  ["optimized-decorative"] = true,
  ["optimized-particle"] = true,
  ["particle-source"] = true,
  planet = true,
  ["player-damaged-achievement"] = true,
  ["place-equipment-achievement"] = true,
  procession = true,
  ["procession-layer-inheritance-group"] = true,
  ["produce-achievement"] = true,
  ["produce-per-hour-achievement"] = true,
  projectile = true,
  quality = true,
  recipe = true,
  ["recipe-category"] = true,
  ["remote-controller"] = true,
  ["repair-tool"] = true,
  ["research-achievement"] = true,
  ["research-with-science-pack-achievement"] = true,
  ["resource-category"] = true,
  ["selection-tool"] = true,
  ["shoot-achievement"] = true,
  shortcut = true,
  ["smoke-with-trigger"] = true,
  ["space-connection"] = true,
  ["space-connection-distance-traveled-achievement"] = true,
  ["space-location"] = true,
  ["space-platform-hub"] = true,
  ["space-platform-starter-pack"] = true,
  ["spectator-controller"] = true,
  ["speech-bubble"] = true,
  sprite = true,
  sticker = true,
  stream = true,
  surface = true,
  ["surface-property"] = true,
  technology = true,
  tile = true,
  ["tile-effect"] = true,
  ["tile-ghost"] = true,
  ["tips-and-tricks-item"] = true,
  ["tips-and-tricks-item-category"] = true,
  tool = true,
  ["train-path-achievement"] = true,
  ["trigger-target-type"] = true,
  ["trivial-smoke"] = true,
  tutorial = true,
  ["upgrade-item"] = true,
  ["use-entity-in-energy-production-achievement"] = true,
  ["use-item-achievement"] = true,
  ["utility-constants"] = true,
  ["utility-sounds"] = true,
  ["utility-sprites"] = true,
  ["virtual-signal"] = true,
}

for _, equipment_type in ipairs(signal_types.equipment_prototype_types) do
  signal_types.data_raw_non_entity_keys[equipment_type] = true
end

signal_types.excluded_prototype_types = {
  fluid = true,
  recipe = true,
  technology = true,
  ["virtual-signal"] = true,
  ["space-location"] = true,
  planet = true,
  tile = true,
  ["asteroid-chunk"] = true,
}

for _, item_type in ipairs(signal_types.item_prototype_types) do
  signal_types.excluded_prototype_types[item_type] = true
end

for _, equipment_type in ipairs(signal_types.equipment_prototype_types) do
  signal_types.excluded_prototype_types[equipment_type] = true
end

signal_types.data_prototype_types = {
  item = signal_types.item_prototype_types,
  fluid = {"fluid"},
  ["virtual-signal"] = {"virtual-signal"},
  entity = {"entity"},
  equipment = signal_types.equipment_prototype_types,
  recipe = {"recipe"},
  technology = {"technology"},
  tile = {"tile"},
  ["space-location"] = signal_types.space_location_prototype_types,
  ["asteroid-chunk"] = {"asteroid-chunk"},
}

signal_types.locale_categories = {
  item = "item-name",
  fluid = "fluid-name",
  ["virtual-signal"] = "virtual-signal-name",
  entity = "entity-name",
  equipment = "equipment-name",
  recipe = "recipe-name",
  technology = "technology-name",
  tile = "tile-name",
  ["space-location"] = "space-location-name",
  ["asteroid-chunk"] = "asteroid-chunk-name",
}

signal_types.runtime_prototype_collections = {
  item = "item",
  fluid = "fluid",
  ["virtual-signal"] = "virtual_signal",
  entity = "entity",
  equipment = "equipment",
  recipe = "recipe",
  technology = "technology",
  tile = "tile",
  ["space-location"] = "space_location",
  ["asteroid-chunk"] = "asteroid_chunk",
}

local entity_prototype_cache = nil
local entity_table_keys = nil

local function is_entity_like_prototype(prototype)
  if type(prototype) ~= "table" or prototype.name == nil or prototype.type == nil then
    return false
  end

  if signal_types.excluded_prototype_types[prototype.type] then
    return false
  end

  if prototype.type:match("%-achievement$") then
    return false
  end

  return true
end

local function ensure_entity_table_keys()
  if entity_table_keys then
    return entity_table_keys
  end

  entity_table_keys = {}
  for raw_key, collection in pairs(data.raw) do
    if not signal_types.data_raw_non_entity_keys[raw_key] and type(collection) == "table" then
      entity_table_keys[#entity_table_keys + 1] = raw_key
    end
  end

  return entity_table_keys
end

function signal_types.invalidate_entity_prototype_cache()
  entity_prototype_cache = nil
  entity_table_keys = nil
end

function signal_types.find_entity_data_prototype(name)
  if not data or not data.raw then
    return prototypes and prototypes.entity[name] or nil
  end

  if entity_prototype_cache == nil then
    entity_prototype_cache = {}
  end

  local cached = entity_prototype_cache[name]
  if cached ~= nil then
    return cached == false and nil or cached
  end

  for _, raw_key in ipairs(ensure_entity_table_keys()) do
    local collection = data.raw[raw_key]
    local prototype = collection and collection[name]
    if type(prototype) == "table" and prototype.name == name and is_entity_like_prototype(prototype) then
      entity_prototype_cache[name] = prototype
      return prototype
    end
  end

  entity_prototype_cache[name] = false
  return nil
end

function signal_types.internal_signal_type(signal_type)
  if signal_type == nil or signal_type == "" then
    return "item"
  end

  return signal_type
end

function signal_types.locale_category(signal_type)
  signal_type = signal_types.internal_signal_type(signal_type)
  return signal_types.locale_categories[signal_type]
end

function signal_types.target_key(signal_type, name)
  signal_type = signal_types.internal_signal_type(signal_type)
  return signal_type .. ":" .. name
end

function signal_types.find_data_prototype(signal_type, name)
  signal_type = signal_types.internal_signal_type(signal_type)

  if not data or not data.raw then
    if prototypes then
      return signal_types.find_runtime_prototype(prototypes, signal_type, name)
    end

    return nil
  end

  if signal_type == "entity" then
    return signal_types.find_entity_data_prototype(name)
  end

  local prototype_types = signal_types.data_prototype_types[signal_type]

  if prototype_types then
    for _, prototype_type in ipairs(prototype_types) do
      local raw = data.raw[prototype_type]
      if raw and raw[name] then
        return raw[name]
      end
    end
  end

  local direct = data.raw[signal_type]
  if direct and direct[name] then
    return direct[name]
  end

  return nil
end

function signal_types.find_runtime_prototype(runtime_prototypes, signal_type, name)
  signal_type = signal_types.internal_signal_type(signal_type)

  -- At runtime every item subtype (ammo, armor, gun, ...) lives under
  -- prototypes.item; LuaPrototypes has no per-subtype collection and errors
  -- when indexed with one, unlike data.raw during the data stage.
  if signal_type == "item" then
    return runtime_prototypes.item[name]
  end

  local collection = signal_types.runtime_prototype_collections[signal_type]
  if collection and runtime_prototypes[collection] then
    return runtime_prototypes[collection][name]
  end

  return nil
end

return signal_types
