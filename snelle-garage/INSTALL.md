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
E bij blauwe marker     = menu, daarna Uithalen
E bij rode marker       = gekochte auto parkeren (ook van de cardealer)
E bij een impound       = ophalen
/garage                 = dichtstbijzijnde garage
/impound of /inbeslag   = dichtstbijzijnde impound
/oproep of F7           = geparkeerde auto bij je neerzetten
/inbeslagnemen [reden]  = politie / takel / ANWB / monteur

Zet `ocean_garage` uit. De locaties staan in locations.lua.
Prijzen en jobs staan in config.lua.
Zonder oxmysql start de garage niet.
Zonder ox_target blijven de markers werken.
