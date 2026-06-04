-- Safe reads against prototype objects (data- and runtime-stage).

local M = {}

function M.safe_read(prototype, key)
  if prototype == nil then
    return nil
  end

  local ok, value = pcall(function()
    return prototype[key]
  end)

  if ok then
    return value
  end

  return nil
end

function M.safe_index(value, index)
  if value == nil then
    return nil
  end

  local ok, result = pcall(function()
    return value[index]
  end)

  if ok then
    return result
  end

  return nil
end

return M
