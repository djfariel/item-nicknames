-- Shared string and table helpers.

local util = {}

function util.trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function util.starts_with(value, prefix)
  return type(value) == "string" and value:sub(1, #prefix) == prefix
end

-- Merge parsed nickname targets keyed by signal_types.target_key.
function util.merge_target_maps(into, from)
  for key, entry in pairs(from or {}) do
    if into[key] then
      into[key].nicknames = into[key].nicknames .. " " .. entry.nicknames
    else
      into[key] = entry
    end
  end

  return into
end

return util
