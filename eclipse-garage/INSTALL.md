Eclipse Garage — installatie
===========================

1. Map `eclipse-garage` in je resources-folder.
2. Voer `sql/install.sql` uit op de ESX-database.
3. In server.cfg, na oxmysql en es_extended:

   ensure oxmysql
   ensure es_extended
   ensure eclipse-garage

4. Herstart de server, of: restart eclipse-garage

In-game
-------
E bij een garage          = menu, of parkeren als je bestuurder bent
Een gekochte auto die nog niet in de garage staat, wordt bij het parkeren
op jouw naam gezet. Daarna staat hij in het menu.
E bij een impound         = betalen en ophalen
/garage                   = dichtstbijzijnde garage
/impound of /inbeslag     = dichtstbijzijnde impound
/oproep of F7             = geparkeerde auto bij je neerzetten
/inbeslagnemen [reden]    = politie / takel / ANWB / monteur

Locaties en prijzen staan in config.lua.
Zonder oxmysql start de garage niet.
Zonder ox_target blijven de markers werken.
