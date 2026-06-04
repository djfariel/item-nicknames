-- Merges mod API contributions with user definitions during prototype loading.

local row_expand = require("scripts.row_expand")
local row_model = require("scripts.row_model")
local signal_types = require("scripts.signal_types")
local tokens = require("scripts.tokens")

local registry = {}

-- Merge order: (1) mod API add/add_row if allow_mod, (2) mod remove/clear if allow_overwrite,
-- (3) nickname pack startup settings, (4) Custom Nicknames (user). Each step unions tokens.
function registry.merge_nickname_registry(registry_entries, pack_entries, user_entries, allow_mod, allow_overwrite)
  local merged = {}

  local function ensure_entry(signal_type, name)
    local key = signal_types.target_key(signal_type, name)
    if not merged[key] then
      merged[key] = {
        signal_type = signal_types.internal_signal_type(signal_type),
        name = name,
        tokens = {},
      }
    end
    return merged[key]
  end

  if allow_mod and registry_entries then
    for _, entry in ipairs(registry_entries) do
      if entry.op == "add" then
        local target = ensure_entry(entry.signal_type, entry.name)
        target.tokens = tokens.union_tokens(target.tokens, entry.tokens)
      elseif entry.op == "add_row" then
        local row = row_model.normalize_row(entry.row)
        if not row_model.is_disabled(row) then
          for _, target in ipairs(row_expand.expand_row(row, nil)) do
            local merged_target = ensure_entry(target.signal_type, target.name)
            merged_target.tokens = tokens.union_tokens(
              merged_target.tokens,
              tokens.token_list(target.nicknames)
            )
          end
        end
      end
    end

    if allow_overwrite then
      for _, entry in ipairs(registry_entries) do
        if entry.op == "remove" then
          local key = signal_types.target_key(entry.signal_type, entry.name)
          local target = merged[key]
          if target then
            target.tokens = tokens.remove_tokens(target.tokens, entry.tokens)
          end
        elseif entry.op == "clear" then
          local key = signal_types.target_key(entry.signal_type, entry.name)
          if merged[key] then
            merged[key].tokens = {}
          end
        end
      end
    end
  end

  for _, entry in pairs(pack_entries or {}) do
    local target = ensure_entry(entry.signal_type, entry.name)
    target.tokens = tokens.union_tokens(target.tokens, tokens.token_list(entry.nicknames))
  end

  for _, entry in pairs(user_entries or {}) do
    local target = ensure_entry(entry.signal_type, entry.name)
    target.tokens = tokens.union_tokens(target.tokens, tokens.token_list(entry.nicknames))
  end

  local result = {}
  for key, entry in pairs(merged) do
    if #entry.tokens > 0 then
      result[key] = {
        signal_type = entry.signal_type,
        name = entry.name,
        nicknames = tokens.join_tokens(entry.tokens),
      }
    end
  end

  return result
end

return registry
