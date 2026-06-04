-- Whitespace-delimited nickname token math: dedupe, set ops, and chunking.

local config = require("scripts.config")

local tokens = {}

function tokens.dedupe_tokens(text)
  local seen = {}
  local result = {}

  for token in (text or ""):gmatch("%S+") do
    local lower = token:lower()
    if not seen[lower] then
      seen[lower] = true
      result[#result + 1] = token
    end
  end

  return table.concat(result, " ")
end

function tokens.token_list(text)
  local list = {}
  text = tokens.dedupe_tokens(text or "")

  for token in text:gmatch("%S+") do
    list[#list + 1] = token
  end

  return list
end

function tokens.join_tokens(token_list)
  return table.concat(token_list, " ")
end

function tokens.remove_tokens(token_list, remove_list)
  local remove_set = {}
  for _, token in ipairs(remove_list or {}) do
    remove_set[token:lower()] = true
  end

  local result = {}
  for _, token in ipairs(token_list or {}) do
    if not remove_set[token:lower()] then
      result[#result + 1] = token
    end
  end

  return result
end

function tokens.union_tokens(existing, added)
  local seen = {}
  local result = {}

  for _, token in ipairs(existing or {}) do
    local lower = token:lower()
    if not seen[lower] then
      seen[lower] = true
      result[#result + 1] = token
    end
  end

  for _, token in ipairs(added or {}) do
    local lower = token:lower()
    if not seen[lower] then
      seen[lower] = true
      result[#result + 1] = token
    end
  end

  return result
end

function tokens.chunk_nicknames(text, max_len, max_chunks)
  max_len = max_len or config.max_nickname_segment_length
  max_chunks = max_chunks or config.max_nickname_chunks

  local deduped = tokens.dedupe_tokens(text or "")
  if deduped == "" then
    return {}, false
  end

  local chunks = {}
  local current = ""

  local function push_current()
    if current ~= "" then
      chunks[#chunks + 1] = current
      current = ""
    end
  end

  for token in deduped:gmatch("%S+") do
    local candidate = current == "" and token or (current .. " " .. token)
    if #candidate <= max_len then
      current = candidate
    else
      push_current()
      if #token > max_len then
        return {}, true
      end
      current = token
    end
  end

  push_current()

  if #chunks > max_chunks then
    return {}, true
  end

  return chunks, false
end

return tokens
