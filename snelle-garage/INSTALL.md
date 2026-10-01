Eclipse Garage — installatie
===========================

1. Map `snelle-garage` in je resources-folder.
2. Voer `sql/install.sql` uit op de ESX-database.
3. In server.cfg, na oxmysql en es_extended:

   ensure oxmysql
   ensure es_extended
   ensure snelle-garage

4. Herstart de server, of: restart snelle-garage

In-game
-------
E bij een garage          = menu, of een gekocht voertuig parkeren
E bij een impound         = betalen en ophalen
/garage                   = dichtstbijzijnde garage
/impound of /inbeslag     = dichtstbijzijnde impound
/oproep of F7             = geparkeerde auto bij je neerzetten
/inbeslagnemen [reden]    = politie / takel / ANWB / monteur

Locaties en prijzen staan in config.lua.
Zonder oxmysql start de garage niet.
Zonder ox_target blijven de markers werken.
