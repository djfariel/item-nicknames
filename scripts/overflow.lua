local common = require("common")

local M = {}

local function description_text(description)
  if type(description) == "string" then
    return description
  end

  if type(description) == "table" then
    for i = #description, 1, -1 do
      local part = description[i]
      if type(part) == "string" and part ~= "" and part ~= "?" then
        return part
      end
    end
  end

  return ""
end

function M.read_overflow_keys()
  local marker = prototypes.item[common.overflow_marker_name]
  if not marker then
    return {}
  end

  local description = description_text(marker.localised_description)
  if description == "" then
    return {}
  end

  local keys = {}
  local delimiter = common.overflow_key_delimiter
  for key in description:gmatch("[^" .. delimiter .. "]+") do
    keys[#keys + 1] = key
  end

  return keys
end

function M.overflow_message()
  local keys = M.read_overflow_keys()
  if #keys == 0 then
    return nil
  end

  return {"item-nicknames.overflow-warning", table.concat(keys, ", ")}
end

return M
