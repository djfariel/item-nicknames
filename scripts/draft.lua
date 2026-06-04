local common = require("common")
local settings_read = require("scripts.settings_read")
local state = require("scripts.storage")

local M = {}

function M.applied_text()
  return settings_read.applied_definitions()
end

local function seed_editor_rows(player, text, parse_options)
  storage.item_nicknames.editor_rows[player.index] = state.ensure_row_uids(
    common.parse_rows(text or "", parse_options)
  )
end

function M.initialize_player(player)
  state.ensure_storage()

  if storage.item_nicknames.editor_rows[player.index] then
    for _, row in ipairs(storage.item_nicknames.editor_rows[player.index]) do
      common.normalize_row(row)
    end
    return
  end

  local applied = M.applied_text()
  if applied ~= "" then
    seed_editor_rows(player, applied, {ignore_disabled_prefix = true})
  end
end

return M
