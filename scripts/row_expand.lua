-- Expand multi-target rows into per-signal-type apply targets.

local prototype_links = require("scripts.prototype_links")
local row_model = require("scripts.row_model")
local signal_types = require("scripts.signal_types")
local util = require("scripts.util")

local row_expand = {}

function row_expand.expand_row(row, runtime_prototypes)
  row = row_model.normalize_row(row)
  if row_model.is_disabled(row) then
    return {}
  end

  local name = row_model.name(row)
  local nicknames = row_model.nicknames(row)
  if name == "" or nicknames == "" then
    return {}
  end

  local targets = {}
  local flags = row_model.type_flags(row)

  for index = 1, #flags do
    local flag = flags:sub(index, index)
    local signal_type = row_model.flag_to_signal_type(flag)
    if signal_type and prototype_links.type_exists(name, signal_type, runtime_prototypes) then
      targets[#targets + 1] = {
        signal_type = signal_types.internal_signal_type(signal_type),
        name = name,
        nicknames = nicknames,
      }
    end
  end

  local helpers = row_model.helpers(row)
  if row_model.has_flag(helpers, "b") and row_model.has_flag(flags, "f") then
    local barrel = prototype_links.barrel_item_for_fluid(name, runtime_prototypes)
    if barrel then
      targets[#targets + 1] = {
        signal_type = "item",
        name = barrel,
        nicknames = nicknames,
      }
    end
  end

  return targets
end

function row_expand.expand_rows(rows, runtime_prototypes)
  local expanded = {}

  for _, row in ipairs(rows or {}) do
    for _, target in ipairs(row_expand.expand_row(row, runtime_prototypes)) do
      expanded[#expanded + 1] = target
    end
  end

  return expanded
end

function row_expand.merge_expanded_rows(rows, runtime_prototypes)
  local parsed = {}

  for _, target in ipairs(row_expand.expand_rows(rows, runtime_prototypes)) do
    local key = signal_types.target_key(target.signal_type, target.name)
    util.merge_target_maps(parsed, {
      [key] = {
        signal_type = target.signal_type,
        name = target.name,
        nicknames = target.nicknames,
      },
    })
  end

  return parsed
end

return row_expand
