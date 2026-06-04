-- RFC 4648 base64 encode/decode for IN1 settings payloads.

local base64 = {}

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local lookup = {}

for index = 1, #alphabet do
  lookup[alphabet:sub(index, index)] = index - 1
end

function base64.encode(data)
  if data == "" then
    return ""
  end

  local parts = {}
  local index = 1
  local length = #data

  while index <= length do
    local b1 = data:byte(index)
    local b2 = index + 1 <= length and data:byte(index + 1) or nil
    local b3 = index + 2 <= length and data:byte(index + 2) or nil

    local n = b1 * 65536 + (b2 or 0) * 256 + (b3 or 0)
    local c1 = math.floor(n / 262144) % 64
    local c2 = math.floor(n / 4096) % 64
    local c3 = math.floor(n / 64) % 64
    local c4 = n % 64

    parts[#parts + 1] = alphabet:sub(c1 + 1, c1 + 1)
      .. alphabet:sub(c2 + 1, c2 + 1)
      .. (b2 and alphabet:sub(c3 + 1, c3 + 1) or "=")
      .. (b3 and alphabet:sub(c4 + 1, c4 + 1) or "=")

    index = index + 3
  end

  return table.concat(parts)
end

function base64.decode(data)
  if data == "" then
    return ""
  end

  data = data:gsub("[^%w%+%/=]", "")
  local parts = {}
  local index = 1
  local length = #data

  while index <= length do
    local c1 = lookup[data:sub(index, index)]
    local c2 = lookup[data:sub(index + 1, index + 1)]
    local c3_char = data:sub(index + 2, index + 2)
    local c4_char = data:sub(index + 3, index + 3)
    local c3 = c3_char ~= "=" and lookup[c3_char] or nil
    local c4 = c4_char ~= "=" and lookup[c4_char] or nil

    if c1 == nil or c2 == nil then
      break
    end

    local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)
    parts[#parts + 1] = string.char(math.floor(n / 65536) % 256)

    if c3 ~= nil then
      parts[#parts + 1] = string.char(math.floor(n / 256) % 256)
    end

    if c4 ~= nil then
      parts[#parts + 1] = string.char(n % 256)
    end

    index = index + 4
  end

  return table.concat(parts)
end

return base64
