local M = {}

M.tag = "editable_label"

local suffix = {
  label = "_label",
  field = "_field",
  edit = "_edit",
}

local function child_name(base, part)
  return base .. suffix[part]
end

function M.is_flow(element)
  return element and element.valid and element.tags and element.tags[M.tag] == true
end

function M.is_edit_button(element)
  return element and element.valid and element.tags and element.tags.editable_label_part == "edit"
end

function M.is_field(element)
  return element and element.valid and element.tags and element.tags.editable_label_part == "field"
end

function M.root_from_element(element)
  if not (element and element.valid) then
    return nil
  end

  if M.is_flow(element) then
    return element
  end

  local parent = element.parent
  if parent and M.is_flow(parent) then
    return parent
  end

  return nil
end

function M.row_frame_from(element)
  local root = M.root_from_element(element)
  return root and root.parent
end

function M.parts(root)
  if not M.is_flow(root) then
    return nil
  end

  local base = root.name
  return {
    root = root,
    label = root[child_name(base, "label")],
    field = root[child_name(base, "field")],
    edit = root[child_name(base, "edit")],
  }
end

local function display_caption(text, default_caption)
  if text and text ~= "" then
    return text
  end

  return default_caption
end

local function update_label_tooltip(parts, text)
  if not parts then
    return
  end

  if text and text ~= "" then
    parts.label.tooltip = text
    return
  end

  parts.label.tooltip = parts.root.tags.editable_label_tooltip or ""
end

function M.read_value(root)
  local parts = M.parts(root)
  if not parts then
    return ""
  end

  if parts.field.visible then
    return parts.field.text or ""
  end

  return parts.root.tags.editable_label_text or ""
end

function M.set_value(root, text)
  local parts = M.parts(root)
  if not parts then
    return
  end

  text = text or ""
  local tags = parts.root.tags
  tags.editable_label_text = text
  parts.root.tags = tags
  parts.label.caption = display_caption(text, tags.editable_label_default)
  parts.field.text = text
  update_label_tooltip(parts, text)
end

function M.set_enabled(root, enabled)
  local parts = M.parts(root)
  if not parts then
    return
  end

  parts.label.enabled = enabled
  parts.field.enabled = enabled
  parts.edit.enabled = enabled

  if not enabled and parts.field.visible then
    M.cancel(root, nil)
  end
end

function M.begin_edit(player, root)
  local parts = M.parts(root)
  if not (parts and parts.edit.enabled) then
    return
  end

  local text = parts.root.tags.editable_label_text or ""
  parts.field.text = text
  parts.label.visible = false
  parts.field.visible = true
  parts.field.focus()
  parts.edit.tooltip = {"gui-edit-label.save-label"}

  if player and not player.opened then
    player.opened = parts.field
  end
end

function M.confirm(root, player)
  local parts = M.parts(root)
  if not parts then
    return ""
  end

  local text = parts.field.text or ""
  M.set_value(root, text)
  parts.label.visible = true
  parts.field.visible = false
  parts.edit.tooltip = {"gui-edit-label.edit-label"}

  if player and player.opened == parts.field then
    player.opened = nil
  end

  return text
end

function M.cancel(root, player)
  local parts = M.parts(root)
  if not parts then
    return
  end

  local text = parts.root.tags.editable_label_text or ""
  parts.field.text = text
  parts.label.visible = true
  parts.field.visible = false
  parts.edit.tooltip = {"gui-edit-label.edit-label"}

  if player and player.opened == parts.field then
    player.opened = nil
  end
end

---@param parent LuaGuiElement
---@param options table name, text?, default_caption?, width?, tooltip?, tags?, index?
function M.add(parent, options)
  options = options or {}
  local base = options.name
  local default_caption = options.default_caption or {"item-nicknames.nickname-empty"}
  local tags = options.tags or {}
  tags[M.tag] = true
  tags.editable_label_text = options.text or ""
  tags.editable_label_default = default_caption
  tags.editable_label_tooltip = options.tooltip

  local flow_props = {
    type = "flow",
    name = base,
    direction = "horizontal",
    style = "item_nicknames_editable_label_flow",
    tags = tags,
  }

  local flow
  if options.index then
    flow = parent.add(flow_props, options.index)
  else
    flow = parent.add(flow_props)
  end

  if options.width then
    flow.style.width = options.width
  end

  local part_tags = function(part)
    local child = {}
    for key, value in pairs(tags) do
      if key ~= M.tag and key ~= "editable_label_text" and key ~= "editable_label_default" then
        child[key] = value
      end
    end
    child.editable_label_part = part
    return child
  end

  local label = flow.add({
    type = "label",
    name = child_name(base, "label"),
    caption = display_caption(options.text or "", default_caption),
    tooltip = options.tooltip,
    tags = part_tags("label"),
    style = "item_nicknames_editable_label_display",
  })
  label.style.horizontally_stretchable = true
  label.style.horizontally_squashable = true
  update_label_tooltip(M.parts(flow), options.text or "")

  flow.add({
    type = "textfield",
    name = child_name(base, "field"),
    visible = false,
    lose_focus_on_confirm = true,
    text = options.text or "",
    tooltip = options.tooltip,
    tags = part_tags("field"),
  })

  flow.add({
    type = "sprite-button",
    name = child_name(base, "edit"),
    style = "mini_button_aligned_to_text_vertically_when_centered",
    sprite = "utility/rename_icon",
    tooltip = {"gui-edit-label.edit-label"},
    tags = part_tags("edit"),
  })

  return flow
end

function M.handle_click(player, element, on_committed)
  if not M.is_edit_button(element) then
    return false
  end

  local root = element.parent
  local parts = M.parts(root)
  if not parts then
    return false
  end

  if parts.label.visible then
    M.begin_edit(player, root)
  else
    local text = M.confirm(root, player)
    if on_committed then
      on_committed(player, element, text)
    end
  end

  return true
end

function M.try_handle_confirmed(player, element, on_committed)
  if not M.is_field(element) then
    return false
  end

  local text = M.confirm(element.parent, player)
  if on_committed then
    on_committed(player, element, text)
  end

  return true
end

function M.try_handle_closed(player, element)
  if not M.is_field(element) then
    return false
  end

  M.cancel(element.parent, player)
  return true
end

return M
