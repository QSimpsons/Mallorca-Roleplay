# Snelle

## Resources

`esrp_lib` is de Vertex-library. Die zet de API in de globals `vx` en `esrp_lib`.
`ocean_garage` is de garage en impound voor ESX Legacy 1.15.2. `owned_vehicles.pound` blijft de impound-locatie, `stored` en `parking` blijven van ESX.

Startvolgorde in `server.cfg`:

```
ensure ox_lib
ensure es_extended
ensure oxmysql
ensure esrp_lib
ensure ocean_garage
```

