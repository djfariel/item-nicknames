-- GUI element tags for editor row children.

local M = {}

function M.row_child_tags(row_id, row_uid)
  return {
    item_nicknames_row_id = row_id,
    item_nicknames_row_uid = row_uid,
  }
end

return M
