Config = {}

-- Merk op het doek (step-and-repeat)
Config.Brand = {
    title = 'ECLIPSE',
    subtitle = 'ROLEPLAY',
    -- Diepblauw, vergelijkbaar met een classic event-doek
    background = '#0b2f7a',
    accent = '#3b82f6',
    textColor = '#ffffff',
    -- Logo in html/img/ — laat leeg voor alleen tekst
    logo = 'img/logo.jpg'
}

-- Formaat van één doek (meter)
Config.Breedte = 4.2
Config.Hoogte = 2.35
-- Ruimte tussen doek en grond (onderkant van de stof). Laag houden zodat
-- het wanddoek aansluit op het vloerdoek.
Config.GrondOffset = 0.02
-- Hoe ver het frame uitsteekt t.o.v. het doek
Config.FrameDikte = 0.06

-- Vloerdoek: zelfde print ligt vóór het frame op de grond (seamless backdrop)
Config.VloerDoek = true
-- Hoe diep het vloerdoek naar voren loopt (meter)
Config.VloerDiepte = 2.8
-- Licht boven de grond zodat z-fighting met het asfalt/tegelwerk meevalt
Config.VloerHoogte = 0.018

-- Render-afstand: doek tekenen als je dichterbij bent
Config.RenderAfstand = 80.0
-- Spawn/stream afstand voor de metalen poten
Config.StreamAfstand = 120.0

-- Textuurresolutie van het DUI-doek (hoger = scherper, zwaarder)
Config.DuiBreedte = 1024
Config.DuiHoogte = 576

-- Commando's (staff)
Config.CommandoPlaatsen = 'doek'
Config.CommandoVerwijderen = 'doekverwijder'
Config.CommandoLijst = 'doeklijst'

-- Wie mag plaatsen / verwijderen
-- ACE: add_ace group.admin fotodoek.manage allow
Config.AcePermission = 'fotodoek.manage'
-- ESX groups (leeg = alleen ACE). Werkt als es_extended draait.
Config.EsxGroups = { 'admin', 'superadmin' }

-- Debug markers (meetpunt)
Config.Debug = false

--[[
    Vaste doeken in de wereld
    -------------------------
    coords  = midden-onderkant van het doek (op de grond staan en heading kiezen)
    heading = kant waarvóór je staat om op de foto te gaan (0 = noord)
    label   = optionele naam in /doeklijst

    Tip: ga op de plek staan, kijk de goede kant op, typ /doek
    De regel die in F8 verschijnt kun je hier plakken.
]]
Config.Doeken = {
    -- Voorbeeld bij Legion Square (pas coords aan of gebruik /doek)
    -- { label = 'Legion event', coords = vector3(195.50, -933.20, 30.69), heading = 140.0 },
}

-- Tijdelijke doeken (via /doek) bewaren over resource-restart
Config.OpslaanDynamisch = true
