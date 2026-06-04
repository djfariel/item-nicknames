-- Sprite-button checkboxes: gray X when off, check mark when on.

local M = {}

M.tag = "item_nicknames_checkbox"

M.unchecked_sprite = "utility/close"
M.checked_sprite = "utility/check_mark"

M.style = "item_nicknames_checkbox"
M.style_large = "item_nicknames_checkbox_large"

function M.sprite_for(checked)
  return checked and M.checked_sprite or M.unchecked_sprite
end

function M.is_checked(element)
  return element and element.valid and element.toggled == true
end

function M.is_checkbox(element)
  return element and element.valid and element.tags and element.tags[M.tag] == true
end

function M.sync_sprite(element)
  if element and element.valid then
    element.sprite = M.sprite_for(element.toggled == true)
  end
end

---@param parent LuaGuiElement
---@param options table name, checked?, tooltip?, tags?, style?, enabled?
function M.add(parent, options)
  options = options or {}
  local checked = options.checked == true
  local tags = options.tags or {}
  tags[M.tag] = true

  local element = parent.add{
    type = "sprite-button",
    name = options.name,
    sprite = M.sprite_for(checked),
    tooltip = options.tooltip,
    tags = tags,
    auto_toggle = true,
    toggled = checked,
    style = options.style or M.style,
  }

  if options.enabled == false then
    element.enabled = false
  end

  return element
end

function M.after_click(element)
  if not M.is_checkbox(element) then
    return false
  end

  M.sync_sprite(element)
  return true
end

return M
