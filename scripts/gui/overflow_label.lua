-- Overflow warning label (red) for editor help panels.

local constants = require("scripts.constants")
local overflow = require("scripts.overflow")

local M = {}

local OVERFLOW_COLOR = {255, 120, 120}

function M.add(parent, options)
  options = options or {}
  local message = options.message or overflow.overflow_message()
  if not message then
    return nil
  end

  local warning = parent.add({
    type = "label",
    name = options.name or constants.names.overflow_warning,
    caption = message,
  })
  warning.style.single_line = false
  warning.style.font_color = OVERFLOW_COLOR
  return warning
end

return M
