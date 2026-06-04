local common = require("common")

data:extend({
  {
    type = "string-setting",
    name = common.applied_setting,
    setting_type = "startup",
    default_value = common.default_definitions,
    allow_blank = true,
    order = "a",
  },
  {
    type = "bool-setting",
    name = common.allow_mod_nicknames_setting,
    setting_type = "startup",
    default_value = true,
    order = "b",
  },
  {
    type = "bool-setting",
    name = common.allow_mod_overwrite_setting,
    setting_type = "startup",
    default_value = true,
    order = "c",
  },
})
