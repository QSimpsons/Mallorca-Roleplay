# Installatie

1. Kopieer `eclipse-overheid-voertuigen` naar `resources/`.
2. Voeg toe aan `server.cfg`:

```cfg
ensure eclipse-overheid-voertuigen
```

3. Voeg in `config.lua` onder `Config.Models` jullie voertuigen toe:

```lua
polargento1 = true,
mijnpdauto = true,
```

4. `ensure eclipse-overheid-voertuigen`
