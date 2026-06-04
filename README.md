# Item Nicknames

Factorio 2.0 mod that appends invisible nickname/search terms to prototype names.

Ship `thumbnail.png` in the mod root next to `info.json` so the in-game mod browser and Mod Portal show the mod icon (no `info.json` field; Factorio loads `thumbnail.png` automatically).

## Format (IN1)

Custom Nicknames, nickname pack settings, and programmatic `add_from_text` all use an **IN1** string: a version prefix plus base64-encoded JSON.

```
IN1.W3sibiI6ImVsZWN0cm9uaWMtY2lyY3VpdCIsInkiOiJpbnIiLCJ3IjoiZ3JlZW4gY2hpcCJ9XQ==
```

### Decoded payload (before encoding)

The string above decodes to a JSON **array of row objects**. Each object uses single-character keys:

| Key | Meaning |
|-----|---------|
| `n` | Prototype name |
| `y` | Type flags (see below) |
| `w` | Nicknames (search terms) |
| `d` | Disabled when `true` (optional) |
| `h` | Helpers (optional; `b` = also apply to fluid barrel item) |

Example decoded body (what you edit before export):

```json
[
  {"n":"fast-inserter","y":"inr","w":"blue claw"},
  {"n":"water","y":"f","h":"b","w":"H2O"},
  {"n":"automation-science-pack","y":"x","w":"red flask"}
]
```

On disk or in Mod settings, that array is minified, base64-encoded, and prefixed with `IN1.`. The editor Export button produces the encoded form; Import accepts only IN1.

### Type flags (`y`)

| Char | Applies to |
|------|------------|
| `i` | Item |
| `n` | Entity |
| `r` | Recipe |
| `f` | Fluid |
| `p` | Equipment |
| `l` | Tile |
| `o` | Space location (includes planets) |
| `v` | Virtual signal |
| `a` | Asteroid chunk |
| `x` | Technology (tech-only rows; not combinable in the matrix) |

The mod converts each expanded target into a `localised_name` like:

```lua
{"", original_name, "[font=item-nicknames-invisible] ", nick_chunk_1, nick_chunk_2, "[/font]"}
```

Nickname text is deduped and split into segments under 200 characters to satisfy Factorio's localised-string limits. Each target supports roughly 3,200 characters of deduped nickname text across all contributing sources.

## Startup settings

- **Custom Nicknames** (`item-nicknames-definitions`): your personal nickname rows (empty by default). These are merged last and are never removed by mod subtractive API calls.
- **Allow mod nicknames** (`item-nicknames-allow-mod-nicknames`, default on): when disabled, programmatic mod API contributions are ignored. Nickname pack startup settings still apply.
- **Allow mod nickname overwrites** (`item-nicknames-allow-mod-overwrite`, default on): when disabled, mod subtractive API calls (`remove`, `clear`) are ignored. Additive mod contributions still apply.

## Runtime editing

The shortcut toolbar button opens a row editor for a per-player draft copy of your definitions. Each row has:

- Enabled checkbox
- Target button (opens tabbed prototype catalog with icons)
- Type matrix (toggle which prototype surfaces receive the nicknames)
- Optional barrel helper for fluid rows
- Nickname field

Technology targets use separate tech-only rows from the Research catalog tab.

Factorio finalizes prototypes before a save is loaded, so runtime edits cannot immediately change names or built-in search. Export the enabled rows, copy the IN1 string into the startup setting, and restart Factorio to apply it. Editor draft changes persist in the save, but only startup setting changes affect in-game names after restart.

Disabled rows stay in the draft with `"d":true` and are still exported, but their nicknames are not applied.

## Nickname packs

Other mods can ship nickname packs. Use the editor's **Nickname packs** button to list installed packs, preview their rows, edit a copy, or view the shipped default string.

## Mod author guide

There are three ways to contribute nicknames. Pick based on whether users should edit your text and whether you need a fixed programmatic contribution.

| | **Nickname pack** | **Programmatic API** | **Custom Nicknames** (player) |
|---|---|---|---|
| **Who uses it** | Pack mod authors | Any mod author | Players |
| **Registration** | `pack-settings.register` in `settings.lua` | `nickname-api` in `data.lua` | Mod settings UI |
| **User-editable** | Yes (startup setting) | No | Yes |
| **Shown in Nickname packs editor** | Yes | No | N/A (main editor) |
| **Respects Allow mod nicknames** | No (always merged) | Yes | N/A |
| **Subtractive API can remove** | No | Yes (if Allow overwrites on) | No (always protected) |
| **Requires restart to apply** | Yes | Yes (prototype stage) | Yes |

### Nickname pack (user-editable IN1)

Use when you want to ship a default nickname list and let users override or disable it (e.g. a mod author tagging all their items with `"crucible"`).

**Important:** packs must register through `pack-settings.register`. Item Nicknames only discovers settings whose names start with `item-nicknames-pack-`. A custom setting name like `planet-crucible-nicknames` will **not** be picked up.

In `settings.lua` only:

```lua
if mods["item-nicknames"] then
  require("__item-nicknames__/pack-settings").register("planet-crucible", {
    default = require("pack-definitions"),  -- return "IN1...."
    order = "pack-planet-crucible",
  })
end
```

This creates startup setting `item-nicknames-pack-planet-crucible`. Localize it for players in your mod's locale:

```cfg
[mod-setting-name]
item-nicknames-pack-planet-crucible=Planet Crucible nicknames
```

No `data.lua` or `control.lua` is required. Item Nicknames auto-discovers the setting in `data-final-fixes` and applies the effective startup value (user override, or default if unset). Clearing the setting disables the pack. The shipped default remains available in the pack editor via the immutable prototype default.

### Programmatic contributions (fixed, not user-editable)

Use when nicknames should always apply and you do not need a Mod settings text field. Call from your mod's `data.lua` or `data-updates.lua`, not from `data-final-fixes.lua`:

```lua
if mods["item-nicknames"] then
  local api = require("__item-nicknames__/nickname-api")

  api.add("item", "my-belt", "green tier 4", {source = "my-mod"})
  api.remove("item", "transport-belt", "green", {source = "my-mod"})
  api.clear("item", "transport-belt", {source = "my-mod"})
  api.add_from_text("IN1....", {source = "my-mod"})
end
```

- Ignored when **Allow mod nicknames** is off.
- `remove` / `clear` only apply when **Allow mod nickname overwrites** is on.
- Not listed in the Nickname packs editor.
- Users can still add their own nicknames for the same targets via Custom Nicknames (additive merge).

### Merge order during prototype loading

1. Mod additive contributions from the programmatic API (only if **Allow mod nicknames** is enabled)
2. Mod subtractive contributions (only if **Allow mod nickname overwrites** is enabled)
3. Nickname pack startup settings (always additive)
4. Custom Nicknames from the player (always additive, always protected)

## Public API files

- `pack-settings.lua` — register a nickname pack startup setting (`item-nicknames-pack-<id>`)
- `nickname-api.lua` — programmatic add/remove/clear/add_from_text in the data stage

Factorio loads startup settings before the prototype stage, so pack and Custom Nicknames values are readable in `data-final-fixes`. Prototypes cannot be modified at runtime.
