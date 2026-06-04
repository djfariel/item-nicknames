-- Read startup setting strings (control and data stages).

local config = require("scripts.config")

local M = {}

function M.startup_string(setting_name)
  local setting = settings.startup and settings.startup[setting_name]
  return setting and setting.value or ""
end

function M.applied_definitions()
  return M.startup_string(config.applied_setting)
end

function M.pack_definitions(pack_id)
  return M.startup_string(config.pack_setting_name(pack_id))
end

return M
