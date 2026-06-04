-- Parsing and serialization for nickname definitions.
--
-- Input format is IN1-only: in1_codec (prefix + base64) -> json_codec (row array) -> row_model.
-- parse_rows rejects any string without the IN1 prefix.

local config = require("scripts.config")
local pack_startup = require("scripts.pack_startup")
local in1_codec = require("scripts.in1_codec")
local row_expand = require("scripts.row_expand")
local row_model = require("scripts.row_model")
local util = require("scripts.util")

local definitions = {}

function definitions.clean_nicknames(value)
  value = value or ""
  value = value:gsub("%[/?font[^%]]*%]", "")
  value = value:gsub("%s+", " ")
  return util.trim(value)
end

function definitions.is_in1_text(text)
  return util.starts_with(text, row_model.format_prefix)
end

function definitions.parse_in1_rows(text, options)
  options = options or {}
  local wire_rows, decode_error = in1_codec.decode_rows(text)

  if not wire_rows then
    return {}, {"Invalid IN1 payload: " .. tostring(decode_error)}
  end

  local rows = {}
  local errors = {}

  for index, wire_row in ipairs(wire_rows) do
    if type(wire_row) ~= "table" then
      errors[#errors + 1] = "Row " .. index .. " is not an object."
      goto continue
    end

    if options.ignore_disabled_prefix and wire_row.d == true then
      goto continue
    end

    local row = row_model.normalize_row({
      n = wire_row.n,
      y = wire_row.y,
      w = wire_row.w,
      d = wire_row.d,
      h = wire_row.h,
    })

    if not row.n or row.n == "" then
      errors[#errors + 1] = "Row " .. index .. " is missing a target name."
    elseif row_model.nicknames(row) == "" then
      errors[#errors + 1] = "Row " .. index .. " has no nicknames."
    elseif row.y == "" then
      errors[#errors + 1] = "Row " .. index .. " has no type flags."
    else
      rows[#rows + 1] = row
    end

    ::continue::
  end

  return rows, errors
end

function definitions.parse_rows(text, options)
  text = text or ""
  if text == "" then
    return {}, {}
  end

  if definitions.is_in1_text(text) then
    return definitions.parse_in1_rows(text, options)
  end

  return {}, {"Not an IN1 string"}
end

function definitions.parse_definitions(text)
  local rows, errors = definitions.parse_rows(text, {ignore_disabled_prefix = true})
  return row_expand.merge_expanded_rows(rows, nil), errors
end

function definitions.discover_pack_ids()
  local ids = {}
  local seen = {}

  local function add(name)
    local pack_id = config.pack_id_from_setting_name(name)
    if pack_id and pack_id ~= "" and not seen[pack_id] then
      seen[pack_id] = true
      ids[#ids + 1] = pack_id
    end
  end

  if data and settings and settings.startup then
    for name in pairs(settings.startup) do
      add(name)
    end
  end

  if prototypes and prototypes.mod_setting then
    for name, prototype in pairs(prototypes.mod_setting) do
      if prototype.valid then
        add(name)
      end
    end
  end

  table.sort(ids)
  return ids
end

function definitions.parse_all_pack_definitions()
  local combined = {}
  local errors = {}

  for _, pack_id in ipairs(definitions.discover_pack_ids()) do
    local text = pack_startup.setting_text(pack_id)
    if text ~= "" then
      local parsed, pack_errors = definitions.parse_definitions(text)
      for _, error_message in ipairs(pack_errors) do
        errors[#errors + 1] = "Pack '" .. pack_id .. "': " .. error_message
      end

      util.merge_target_maps(combined, parsed)
    end
  end

  return combined, errors
end

function definitions.serialize_draft_rows(rows)
  return in1_codec.encode_rows(rows)
end

return definitions
