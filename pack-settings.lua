-- Settings-stage helper for nickname pack mods.
--
-- Registers startup setting item-nicknames-pack-<id> with optional IN1 default.
-- Item Nicknames auto-discovers only settings with this prefix; arbitrary setting
-- names are ignored. No data.lua or control.lua is required.
--
-- settings.lua:
--   if mods["item-nicknames"] then
--     require("__item-nicknames__/pack-settings").register("my-pack", {
--       default = require("pack-definitions"),
--       order = "pack-my-pack",
--     })
--   end
--
-- Localize the setting for players, e.g. in locale/en/my-mod.cfg:
--   [mod-setting-name]
--   item-nicknames-pack-my-pack=My Pack nicknames

local common = require("common")

local pack_settings = {}

function pack_settings.register(id, opts)
  opts = opts or {}
  if not id or id == "" then
    error("Item Nicknames pack-settings.register: id is required.")
  end

  data:extend({
    {
      type = "string-setting",
      name = common.pack_setting_name(id),
      setting_type = "startup",
      default_value = opts.default or "",
      allow_blank = true,
      order = opts.order or ("pack-" .. id),
    },
  })
end

return pack_settings
