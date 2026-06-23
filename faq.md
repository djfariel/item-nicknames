# Frequently asked questions

## Do nicknames change what I see on screen?

Usually no. Nicknames are added in a zero-size font after the real name. Tooltips and UIs still show the normal localized name. Search and filter fields are where nicknames matter.

## Why do I have to restart after exporting?

Factorio builds prototype names when the game loads. The editor saves a per-save draft, but nicknames only affect in-game search after you paste the IN1 string into a startup setting and restart.

## What is an IN1 string?

A compact export format from the editor (a short prefix plus encoded data). You do not need to edit it by hand; use **Export** in the editor and **Import** if you want to paste a backup or share a list. IN stands for "Item Nicknames" and 1 is the string version, in case it needs to be changed in the future.

## Can I use the editor without touching Mod settings?

You can edit and save a draft in your save, but aliases will not apply to search until you copy the exported string into **Custom Nicknames** (or a pack setting) and restart.

## What happens to unchecked rows?

They stay in the export with a disabled flag. They are not applied in-game until you enable them and restart with an updated string.

## Do nicknames from different sources stack?

Yes. Mod API contributions, nickname packs, and Custom Nicknames all add tokens on the same target. Later steps in the merge order add more text; they do not remove your Custom Nicknames.

## How do I turn the mod off for myself?

Clear **Custom Nicknames** in startup settings, disable any pack settings you use, and restart. You can also remove the mod from your mod list.

## How do I block other mods from adding nicknames?

Turn off **Allow mod nicknames** and **Allow mod nickname overwrites** in startup settings, then restart. Nickname packs from optional content mods still apply when their setting has text.

## Does this work in multiplayer?

Startup settings apply to the save. Players share the same applied nicknames after a restart. The in-save editor draft is per player.

## Is Space Age required?

No. The core mod works with base game content. Individual rows for prototypes that do not exist in your mod set simply have no effect.

## Something I nicknamed does not show up in search

Check that the row is enabled, has nicknames and type flags, and that you restarted after updating the startup setting. Confirm the prototype exists in your mod list (other mods may add or rename prototypes).

## I get an error when importing a string

Only IN1 strings exported from this mod (or another mod using the same format) are accepted. Paste the full string including the `IN1.` prefix.
