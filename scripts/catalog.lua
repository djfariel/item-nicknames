-- Runtime prototype catalog for the tabbed target picker.

local icon = require("scripts.icon")
local prototype_links = require("scripts.prototype_links")
local row_model = require("scripts.row_model")
local signal_types = require("scripts.signal_types")

local catalog = {}

catalog.tabs = row_model.catalog_tab_specs

local cache = nil

local function prototype_name(name, prototype)
  if prototype == nil then
    return name
  end

  local value_type = type(prototype)
  if value_type == "table" or value_type == "userdata" then
    local ok, read_name = pcall(function()
      return prototype.name
    end)
    if ok and read_name and read_name ~= "" then
      return read_name
    end
  end

  return name
end

local function is_prototype_value(prototype)
  if prototype == nil then
    return false
  end

  local value_type = type(prototype)
  return value_type == "table" or value_type == "userdata"
end

local function add_entry(entries_by_name, name, tab_id, flag, prototype, runtime_prototypes)
  if not name or name == "" then
    return
  end

  local entry = entries_by_name[name]
  if not entry then
    entry = {
      n = name,
      tabs = {},
      flags = "",
      localized_name = prototype and prototype.localised_name or name,
      sprite = icon.sprite_for_prototype(prototype, row_model.flag_to_signal_type(flag)),
    }
    entries_by_name[name] = entry
  end

  entry.tabs[tab_id] = true
  entry.flags = row_model.set_flag(entry.flags, flag, true)

  if prototype and prototype.localised_name then
    entry.localized_name = prototype.localised_name
  end
end

function catalog.rebuild(runtime_prototypes)
  runtime_prototypes = runtime_prototypes or prototypes
  local entries_by_name = {}

  for _, tab in ipairs(catalog.tabs) do
    local collection = runtime_prototypes[tab.collection]
    if collection then
      for name, prototype in pairs(collection) do
        if is_prototype_value(prototype) then
          local proto_name = prototype_name(name, prototype)
          if proto_name and proto_name ~= "" then
            add_entry(entries_by_name, proto_name, tab.id, tab.flag, prototype, runtime_prototypes)
          end
        end
      end
    end
  end

  for name, entry in pairs(entries_by_name) do
    entry.available_y = prototype_links.available_types(name, runtime_prototypes)
  end

  local entries = {}
  for name, entry in pairs(entries_by_name) do
    entry.sort_key = name
    entries[#entries + 1] = entry
  end

  table.sort(entries, function(left, right)
    return left.sort_key < right.sort_key
  end)

  cache = {
    entries = entries,
    entries_by_name = entries_by_name,
  }

  return cache
end

function catalog.ensure_cache(runtime_prototypes)
  runtime_prototypes = runtime_prototypes or prototypes
  if not cache or not cache.entries or #cache.entries == 0 then
    catalog.rebuild(runtime_prototypes)
  end

  return cache
end

function catalog.invalidate()
  cache = nil
  prototype_links.invalidate_caches()
end

function catalog.tab_index(tab_id)
  for index, tab in ipairs(catalog.tabs) do
    if tab.id == tab_id then
      return index
    end
  end

  return 1
end

function catalog.tab_by_index(index)
  return catalog.tabs[index or 1]
end

function catalog.entries_for_tab(tab_id, runtime_prototypes)
  local data = catalog.ensure_cache(runtime_prototypes)
  local entries = {}

  for _, entry in ipairs(data.entries) do
    if entry.tabs[tab_id] then
      entries[#entries + 1] = entry
    end
  end

  return entries
end

function catalog.entry_for_name(name, runtime_prototypes)
  local data = catalog.ensure_cache(runtime_prototypes)
  return data.entries_by_name[name]
end

function catalog.selection_for_entry(entry, tab)
  if not entry then
    return nil
  end

  if tab and tab.tech_only then
    return {
      n = entry.n,
      y = "x",
    }
  end

  local suggested = prototype_links.suggest_type_flags(entry.n, prototypes)
  return {
    n = entry.n,
    y = suggested ~= "" and suggested or entry.available_y,
  }
end

function catalog.filter_entries(entries, query)
  query = (query or ""):lower()
  if query == "" then
    return entries
  end

  local filtered = {}
  for _, entry in ipairs(entries) do
    if entry.n:lower():find(query, 1, true)
        or (type(entry.localized_name) == "string" and entry.localized_name:lower():find(query, 1, true)) then
      filtered[#filtered + 1] = entry
    end
  end

  return filtered
end

function catalog.match_count_for_tab(tab_id, query, runtime_prototypes)
  local entries = catalog.entries_for_tab(tab_id, runtime_prototypes)
  return #catalog.filter_entries(entries, query)
end

return catalog
