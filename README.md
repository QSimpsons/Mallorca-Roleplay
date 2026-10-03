# Snelle

## Resources

`esrp_lib` is de Vertex-library. Die zet de API in de globals `vx` en `esrp_lib` in elke resource die `@esrp_lib/init.lua` of `@vx_lib/init.lua` include't.
`vx_lib` is de schakel voor resources zoals `esrp_cardealer`: `@vx_lib/init.lua` laadt `esrp_lib` in die resource. Zonder die include blijft `vx` nil.
`esrp_lib` geeft de naam `vx_lib` ook zelf door. Een gestarte oude `vx_lib` wint van die doorverwijzing, dus vervang een oude `vx_lib` map door deze.
`ocean_garage` is de garage en impound voor ESX Legacy 1.15.2. `owned_vehicles.pound` blijft de impound-locatie, `stored` en `parking` blijven van ESX.

Startvolgorde in `server.cfg`:

```
ensure ox_lib
ensure es_extended
ensure oxmysql
ensure esrp_lib
ensure vx_lib
ensure ocean_garage
ensure esrp_cardealer
```

