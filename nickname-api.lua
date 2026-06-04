-- Data-stage API for programmatic nickname contributions from other mods.
--
-- Require from your mod's data.lua or data-updates.lua (not data-final-fixes.lua):
--
--   if mods["item-nicknames"] then
--     local api = require("__item-nicknames__/nickname-api")
--     api.add("item", "my-belt", "green tier 4", {source = "my-mod"})
--     api.add_from_text("IN1....", {source = "my-mod"})
--   end
--
-- Programmatic contributions are not user-editable and do not appear in the
-- Nickname packs editor. They respect Allow mod nicknames / Allow mod overwrites.
-- For user-editable shipped nicknames, use pack-settings.register instead.

local common = require("common")

local api = {}

local function registry()
  if not _G[common.registry_key] then
    _G[common.registry_key] = {}
  end

  return _G[common.registry_key]
end

local function push_entry(entry)
  registry()[#registry() + 1] = entry
end

local function normalize_opts(opts)
  opts = opts or {}
  return {
    source = opts.source or "unknown",
  }
end

local function normalize_tokens(nicknames)
  if type(nicknames) == "table" then
    return common.token_list(table.concat(nicknames, " "))
  end

  return common.token_list(nicknames or "")
end

function api.add(signal_type, name, nicknames, opts)
  opts = normalize_opts(opts)
  local tokens = normalize_tokens(nicknames)
  if #tokens == 0 then
    return
  end

  push_entry({
    source = opts.source,
    op = "add",
    signal_type = common.internal_signal_type(signal_type),
    name = name,
    tokens = tokens,
  })
end

function api.remove(signal_type, name, tokens, opts)
  opts = normalize_opts(opts)
  local remove_tokens = normalize_tokens(tokens)
  if #remove_tokens == 0 then
    return
  end

  push_entry({
    source = opts.source,
    op = "remove",
    signal_type = common.internal_signal_type(signal_type),
    name = name,
    tokens = remove_tokens,
  })
end

function api.clear(signal_type, name, opts)
  opts = normalize_opts(opts)
  push_entry({
    source = opts.source,
    op = "clear",
    signal_type = common.internal_signal_type(signal_type),
    name = name,
    tokens = {},
  })
end

function api.add_from_text(text, opts)
  opts = normalize_opts(opts)
  local rows, errors = common.parse_rows(text or "", {ignore_disabled_prefix = true})
  if #errors > 0 then
    log("Item Nicknames API (" .. opts.source .. "): skipped invalid nickname text.")
    return
  end

  for _, row in ipairs(rows) do
    if row.d ~= true then
      push_entry({
        source = opts.source,
        op = "add_row",
        row = row,
      })
    end
  end
end

return api
