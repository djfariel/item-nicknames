-- Static identifiers, limits, and setting names shared across every stage.

local util = require("scripts.util")

local config = {}

config.applied_setting = "item-nicknames-definitions"
config.allow_mod_nicknames_setting = "item-nicknames-allow-mod-nicknames"
config.allow_mod_overwrite_setting = "item-nicknames-allow-mod-overwrite"
config.pack_setting_prefix = "item-nicknames-pack-"
config.registry_key = "__item_nicknames_registry"
config.overflow_marker_name = "item-nicknames-overflow-marker"
config.max_nickname_segment_length = 200
config.max_nickname_chunks = 16
config.font_name = "item-nicknames-invisible"
config.nickname_mark_open = "[font=" .. config.font_name .. "] "
config.nickname_mark_close = "[/font]"
config.shortcut_name = "item-nicknames-open"
config.focus_search_input = "item-nicknames-focus-search"
-- Packs overflow target keys in the hidden marker item's localised_description (not IN1).
config.overflow_key_delimiter = "|"

config.default_definitions = ""

function config.pack_setting_name(id)
  return config.pack_setting_prefix .. id
end

function config.pack_id_from_setting_name(name)
  if not util.starts_with(name, config.pack_setting_prefix) then
    return nil
  end

  return name:sub(#config.pack_setting_prefix + 1)
end

return config
