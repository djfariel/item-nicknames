-- Facade for data-stage modules.

local common = {}

local function merge(module)
  for key, value in pairs(module) do
    common[key] = value
  end
end

merge(require("scripts.config"))
merge(require("scripts.tokens"))
merge(require("scripts.signal_types"))
merge(require("scripts.definitions"))
merge(require("scripts.row_model"))
merge(require("scripts.row_expand"))
merge(require("scripts.prototype_links"))
merge(require("scripts.registry"))

local locale = require("locale")
common.strip_mod_nicknames = locale.strip_mod_nicknames
common.apply_nickname_localised_name = locale.apply_nickname_localised_name

return common
