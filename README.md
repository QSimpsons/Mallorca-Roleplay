# Snelle

## Resources

- `ox_lib` — shared library and NUI. `web/build` is included so the resource can start. Start it before resources that use `@ox_lib/init.lua`.
- `illenium-appearance` — character appearance. Start it after `ox_lib` and `es_extended`.
- `sd-phone/bridge/client/target.lua` — replace the same file in an existing sd-phone install. Player eye options use `addGlobalPed` when ox_target has no `addGlobalPlayer` export.

