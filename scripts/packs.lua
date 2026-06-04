local common = require("common")
local settings_read = require("scripts.settings_read")

local M = {}

function M.pack_text(pack)
  return settings_read.startup_string(pack.setting_name)
end

function M.list_packs()
  -- Runtime enumeration uses prototypes.mod_setting; default_value is readable from each prototype.
  local packs = {}

  for name, prototype in pairs(prototypes.mod_setting) do
    local pack_id = common.pack_id_from_setting_name(name)
    if pack_id and prototype.valid then
      packs[#packs + 1] = {
        id = pack_id,
        setting_name = name,
        mod = prototype.mod,
        default_value = prototype.default_value or "",
        current_value = settings_read.startup_string(name),
      }
    end
  end

  table.sort(packs, function(a, b)
    if a.mod == b.mod then
      return a.id < b.id
    end

    return a.mod < b.mod
  end)

  return packs
end

function M.refresh_pack(pack)
  pack.current_value = M.pack_text(pack)
  return pack
end

function M.pack_rows(pack)
  local rows, errors = common.parse_rows(M.pack_text(pack) or "", {ignore_disabled_prefix = true})
  if #errors > 0 then
    return {}, errors
  end

  return rows, {}
end

function M.pack_setting_label(pack)
  return {"mod-setting-name." .. pack.setting_name}
end

return M
