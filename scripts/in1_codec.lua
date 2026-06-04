-- IN1 envelope: format_prefix + base64(json_codec row array).
-- Decode: strip prefix -> base64.decode -> json_codec.decode_rows.
-- Encode: json_codec.encode_rows(wire rows) -> base64.encode -> prefix.

local base64 = require("scripts.base64")
local json_codec = require("scripts.json_codec")
local row_model = require("scripts.row_model")
local util = require("scripts.util")

local in1_codec = {}

function in1_codec.encode_rows(rows)
  local wire_rows = {}

  for _, row in ipairs(rows or {}) do
    row = row_model.normalize_row(row)
    if row.n and row.n ~= "" and row_model.nicknames(row) ~= "" then
      wire_rows[#wire_rows + 1] = row_model.wire_row(row)
    end
  end

  local json = json_codec.encode_rows(wire_rows)
  return row_model.format_prefix .. base64.encode(json)
end

function in1_codec.decode_rows(text)
  if not text or text == "" then
    return {}
  end

  if not util.starts_with(text, row_model.format_prefix) then
    return nil, "Not an IN1 string"
  end

  local payload = text:sub(#row_model.format_prefix + 1)
  local decoded = base64.decode(payload)
  return json_codec.decode_rows(decoded)
end

return in1_codec
