-- GUI tree helpers (recursive child lookup, ancestor by name prefix).

local constants = require("scripts.constants")

local M = {}

function M.find_child(element, name)
  if not (element and element.valid) then
    return nil
  end

  if element[name] then
    return element[name]
  end

  for _, child in ipairs(element.children) do
    local found = M.find_child(child, name)
    if found then
      return found
    end
  end
end

function M.find_ancestor_by_prefix(element, prefix)
  if element then
    element = element.parent
  end

  while element and element.valid do
    if constants.starts_with(element.name, prefix) then
      return element
    end

    element = element.parent
  end

  return nil
end

return M
