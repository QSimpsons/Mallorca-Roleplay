# Snelle

## Resources

`esrp_lib` is de Vertex-library. Die zet de API in de globals `vx` en `esrp_lib`.
`ocean_garage` is de garage en impound en praat alleen via die API.

Startvolgorde in `server.cfg`:

```
ensure ox_lib
ensure es_extended
ensure oxmysql
ensure esrp_lib
ensure ocean_garage
```

