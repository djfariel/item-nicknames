-- Resolve nickname pack IN1 text from startup settings (data stage).

local settings_read = require("scripts.settings_read")

local pack_startup = {}

function pack_startup.setting_text(pack_id)
  return settings_read.pack_definitions(pack_id)
end

return pack_startup
