# Snelle

## Resources

- `ox_lib` — shared library and NUI. `web/build` is included so the resource can start. Start it before resources that use `@ox_lib/init.lua`.
- `illenium-appearance` — character appearance. Start it after `ox_lib` and `es_extended`.
- `sd-phone/bridge/client/target.lua` — replace the same file in an existing sd-phone install. Player eye options use `addGlobalPed` when ox_target has no `addGlobalPlayer` export.
- `esx_addoninventory` — registers `addon_inventory` rows as ox_inventory stashes when `OxInventory` is enabled. A missing `RegisterStash` export is logged and retried when `ox_inventory` starts, instead of aborting the resource. Start `ox_inventory` before this resource.
- `esx_adminmenu` — admin dashboard and quick menu. Staff can clock in, follow on-duty staff live, and flip, repair, refuel, or unlock the nearest vehicle.

