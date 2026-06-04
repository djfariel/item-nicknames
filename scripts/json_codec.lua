-- Minimal JSON encoder/decoder for IN1 row arrays (strings and booleans only).

local json_codec = {}

local function escape_string(value)
  value = value:gsub("\\", "\\\\")
  value = value:gsub('"', '\\"')
  value = value:gsub("\n", "\\n")
  value = value:gsub("\r", "\\r")
  value = value:gsub("\t", "\\t")
  return value
end

function json_codec.encode_string(value)
  return '"' .. escape_string(tostring(value)) .. '"'
end

function json_codec.encode_row(row)
  local parts = {}

  if row.n then
    parts[#parts + 1] = '"n":' .. json_codec.encode_string(row.n)
  end

  if row.y and row.y ~= "" then
    parts[#parts + 1] = '"y":' .. json_codec.encode_string(row.y)
  end

  if row.w and row.w ~= "" then
    parts[#parts + 1] = '"w":' .. json_codec.encode_string(row.w)
  end

  if row.d == true then
    parts[#parts + 1] = '"d":true'
  end

  if row.h and row.h ~= "" then
    parts[#parts + 1] = '"h":' .. json_codec.encode_string(row.h)
  end

  return "{" .. table.concat(parts, ",") .. "}"
end

function json_codec.encode_rows(rows)
  local encoded = {}

  for _, row in ipairs(rows or {}) do
    encoded[#encoded + 1] = json_codec.encode_row(row)
  end

  return "[" .. table.concat(encoded, ",") .. "]"
end

local function skip_whitespace(text, index)
  while index <= #text do
    local char = text:sub(index, index)
    if char ~= " " and char ~= "\n" and char ~= "\r" and char ~= "\t" then
      break
    end
    index = index + 1
  end

  return index
end

local function decode_string(text, index)
  if text:sub(index, index) ~= '"' then
    return nil, index
  end

  index = index + 1
  local parts = {}

  while index <= #text do
    local char = text:sub(index, index)
    if char == '"' then
      return table.concat(parts), index + 1
    end

    if char == "\\" then
      local next_char = text:sub(index + 1, index + 1)
      if next_char == "n" then
        parts[#parts + 1] = "\n"
      elseif next_char == "r" then
        parts[#parts + 1] = "\r"
      elseif next_char == "t" then
        parts[#parts + 1] = "\t"
      elseif next_char == '"' or next_char == "\\" then
        parts[#parts + 1] = next_char
      else
        parts[#parts + 1] = next_char
      end
      index = index + 2
    else
      parts[#parts + 1] = char
      index = index + 1
    end
  end

  return nil, index
end

local function decode_value(text, index)
  index = skip_whitespace(text, index)
  local char = text:sub(index, index)

  if char == '"' then
    return decode_string(text, index)
  end

  if text:sub(index, index + 3) == "true" then
    return true, index + 4
  end

  if text:sub(index, index + 4) == "false" then
    return false, index + 5
  end

  return nil, index
end

local function decode_object(text, index)
  if text:sub(index, index) ~= "{" then
    return nil, index
  end

  index = index + 1
  local object = {}

  while index <= #text do
    index = skip_whitespace(text, index)
    if text:sub(index, index) == "}" then
      return object, index + 1
    end

    local key
    key, index = decode_string(text, index)
    if not key then
      return nil, index
    end

    index = skip_whitespace(text, index)
    if text:sub(index, index) ~= ":" then
      return nil, index
    end
    index = index + 1

    local value
    value, index = decode_value(text, index)
    object[key] = value

    index = skip_whitespace(text, index)
    local next_char = text:sub(index, index)
    if next_char == "}" then
      return object, index + 1
    end
    if next_char ~= "," then
      return nil, index
    end
    index = index + 1
  end

  return nil, index
end

function json_codec.decode_rows(text)
  text = text or ""
  local index = skip_whitespace(text, 1)

  if text:sub(index, index) ~= "[" then
    return nil, "Expected array"
  end

  index = index + 1
  local rows = {}

  while index <= #text do
    index = skip_whitespace(text, index)
    if text:sub(index, index) == "]" then
      return rows
    end

    local row
    row, index = decode_object(text, index)
    if not row then
      return nil, "Invalid row object"
    end
    rows[#rows + 1] = row

    index = skip_whitespace(text, index)
    local next_char = text:sub(index, index)
    if next_char == "]" then
      return rows
    end
    if next_char ~= "," then
      return nil, "Expected comma or ]"
    end
    index = index + 1
  end

  return nil, "Unterminated array"
end

return json_codec
