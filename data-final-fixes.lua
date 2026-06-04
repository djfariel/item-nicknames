-- Applies merged nicknames to prototype localised_name at load time.
local common = require("common")
local prototype_links = require("scripts.prototype_links")

prototype_links.invalidate_caches()

local configured = settings.startup[common.applied_setting]
local definitions = configured and configured.value or ""
local user_entries, errors = common.parse_definitions(definitions)

local pack_entries, pack_errors = common.parse_all_pack_definitions()
for _, error_message in ipairs(pack_errors) do
  errors[#errors + 1] = error_message
end

local pack_target_count = 0
for _ in pairs(pack_entries) do
  pack_target_count = pack_target_count + 1
end
local pack_ids = common.discover_pack_ids()
if #pack_ids > 0 and pack_target_count == 0 then
  log("Item Nicknames: no nickname rows loaded from packs (" .. table.concat(pack_ids, ", ") .. ").")
end

for _, error_message in ipairs(errors) do
  log("Item Nicknames: " .. error_message)
end

local allow_mod = settings.startup[common.allow_mod_nicknames_setting]
allow_mod = allow_mod == nil or allow_mod.value ~= false

local allow_overwrite = settings.startup[common.allow_mod_overwrite_setting]
allow_overwrite = allow_overwrite == nil or allow_overwrite.value ~= false

local registry = _G[common.registry_key]
local augmented_registry = {}

if registry then
  for index = 1, #registry do
    augmented_registry[index] = registry[index]
  end
end

local nickname_entries = common.merge_nickname_registry(
  augmented_registry,
  pack_entries,
  user_entries,
  allow_mod,
  allow_overwrite
)

local overflow_targets = {}
local entry_keys = {}
for key in pairs(nickname_entries) do
  entry_keys[#entry_keys + 1] = key
end
table.sort(entry_keys)

for _, key in ipairs(entry_keys) do
  local entry = nickname_entries[key]
  local prototype = common.find_data_prototype(entry.signal_type, entry.name)

  if prototype then
    common.apply_nickname_localised_name(
      prototype,
      entry.signal_type,
      entry.name,
      entry.nicknames,
      overflow_targets
    )
  end
end

local overflow_keys = {}
for overflow_key in pairs(overflow_targets) do
  overflow_keys[#overflow_keys + 1] = overflow_key
end
table.sort(overflow_keys)

if #overflow_keys > 0 then
  for _, overflow_key in ipairs(overflow_keys) do
    log("Item Nicknames: nickname text for '" .. overflow_key .. "' exceeds the per-item limit. Remove nicknames or split them across fewer targets.")
  end

  local marker = common.find_data_prototype("item", common.overflow_marker_name)
  if marker then
    marker.localised_description = table.concat(overflow_keys, common.overflow_key_delimiter)
  end
end
