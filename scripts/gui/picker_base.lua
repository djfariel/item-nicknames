-- Shared modal picker lifecycle (open context + destroy + reopen editor).

local dialogs = require("scripts.gui.dialogs")

local M = {}

function M.new(frame_name)
  local open_context = {}
  local api = {}

  api.frame_name = frame_name

  function api.context(player)
    return open_context[player.index]
  end

  function api.set_context(player, context)
    open_context[player.index] = context
  end

  function api.clear_context(player)
    open_context[player.index] = nil
  end

  function api.close(player)
    local frame = player.gui.screen[frame_name]
    if frame and frame.valid then
      frame.destroy()
    end

    api.clear_context(player)
  end

  function api.destroy(player)
    api.close(player)
    dialogs.reopen_editor(player)
  end

  function api.is_open(player)
    local frame = player.gui.screen[frame_name]
    return frame and frame.valid
  end

  return api
end

return M
