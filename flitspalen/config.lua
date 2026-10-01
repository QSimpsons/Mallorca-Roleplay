Config = {}

-- Kilometer per uur die je boven de limiet mag zitten zonder flits.
-- De limiet op de paal blijft het maximum. Dit is alleen de meetmarge.
Config.Tolerantie = 5

-- Onder deze snelheid telt door rood niet (stilstaan op de streep).
Config.RoodMinSnelheid = 18

-- Ook flitsen als het licht geel is.
Config.FlitsOpGeel = false

-- Boete
Config.BoetePerKmh = 12          -- euro per km/h boven de limiet
Config.RoodlichtBoete = 380      -- extra of los, als je door rood rijdt
Config.MinimumBoete = 50
Config.MaximumBoete = 2500

-- Tijd tussen twee flitsen voor dezelfde speler (ms)
Config.CooldownMs = 10000

-- Hoe ver je koers mag afwijken als een paal maar één richting pakt (graden)
Config.RichtingTolerantie = 55

-- Paal in de wereld zetten als je in de buurt bent
Config.SpawnPalen = true
Config.PaalModel = 'prop_cctv_pole_04'
Config.PaalOpzij = 5.5

-- Alleen de rode flitspalen staan op de kaart: een rood bolletje met het camerapictogram erin.
-- Roodlichtcamera's hebben geen icoon.
Config.ToonBlips = true
Config.BlipKorteAfstand = true

-- Tekst als je een paal nadert, met het maximum van die plek
Config.ToonLimietTekst = true

-- Noodvoertuigen met sirene aan worden niet geflitst.
-- Jobs hieronder ook niet, zodra ESX of QBCore draait.
Config.NoodvoertuigMetSireneVrij = true
Config.VrijgesteldeJobs = {
    'police',
    'ambulance',
    'kmar'
}

-- Stoplichten op een kruispunt met een roodlichtcamera volgen deze cyclus,
-- zodat de flits gelijk loopt met het licht dat je ziet.
-- 0 = groen, daarna geel, de andere richting blijft rood. Dan wisselen ze.
Config.GroenMs = 14000
Config.GeelMs = 3000

Config.StoplichtModellen = {
    'prop_traffic_01a',
    'prop_traffic_01b',
    'prop_traffic_01d',
    'prop_traffic_02a',
    'prop_traffic_02b',
    'prop_traffic_03a',
    'prop_traffic_03b'
}

-- Markers op palen en kruispunten. Zet aan als je posities fijnafstellen.
Config.Debug = false

-- /flitslocatie print in F8 een regel die je hieronder kunt plakken.
Config.PlaatsCommando = true

--[[
    Flitspalen
    ----------
    Elke paal heeft zijn eigen maximum (limiet, in km/h).
    coords      = midden van de weg / het meetpunt
    richting    = kant die het verkeer óp rijdt (0 = noord, 90 = west)
    straal      = hoe breed de meting pakt
    beideRichtingen = true pakt beide kanten. false alleen `richting`.

    Posities liggen bij bekende plekken op de weg. Klopt een paal niet,
    ga er staan en gebruik /flitslocatie.
]]
Config.Flitspalen = {
    -- Stad, 50 km/h
    { naam = 'Legion Square', coords = vector3(215.76, -810.12, 30.73), richting = 340.0, limiet = 50, straal = 18.0 },
    { naam = 'Strawberry', coords = vector3(25.74, -1346.58, 29.50), richting = 270.0, limiet = 50, straal = 18.0 },
    { naam = 'Davis', coords = vector3(-48.52, -1757.51, 29.42), richting = 50.0, limiet = 50, straal = 18.0 },
    { naam = 'Little Seoul', coords = vector3(-707.50, -914.26, 19.22), richting = 0.0, limiet = 50, straal = 18.0 },
    { naam = 'Textile City', coords = vector3(425.13, -806.22, 29.49), richting = 90.0, limiet = 50, straal = 16.0 },
    { naam = 'Alta Street', coords = vector3(275.43, -345.53, 45.17), richting = 160.0, limiet = 50, straal = 16.0 },
    { naam = 'Mission Row', coords = vector3(412.20, -1024.60, 29.25), richting = 0.0, limiet = 50, straal = 16.0 },
    { naam = 'Mirror Park', coords = vector3(1163.37, -323.80, 69.21), richting = 100.0, limiet = 50, straal = 16.0 },
    { naam = 'Vinewood', coords = vector3(373.88, 325.90, 103.57), richting = 260.0, limiet = 50, straal = 16.0 },
    { naam = 'Rockford Hills', coords = vector3(-1487.55, -379.11, 40.16), richting = 140.0, limiet = 50, straal = 16.0 },
    { naam = 'Vespucci', coords = vector3(-1222.92, -906.98, 12.33), richting = 30.0, limiet = 50, straal = 16.0 },
    { naam = 'Murrieta Heights', coords = vector3(1135.81, -982.28, 46.42), richting = 280.0, limiet = 50, straal = 16.0 },
    { naam = 'La Mesa', coords = vector3(731.45, -1088.82, 22.17), richting = 0.0, limiet = 50, straal = 18.0 },
    { naam = 'Del Perro', coords = vector3(-1388.36, -586.92, 30.22), richting = 30.0, limiet = 50, straal = 18.0 },

    -- Woonwijk, 30 km/h
    { naam = 'Grove Street', coords = vector3(104.50, -1939.40, 20.80), richting = 50.0, limiet = 30, straal = 18.0 },

    -- Buitenwegen en dorpen, 80 km/h
    { naam = 'Luchthaven', coords = vector3(-1037.51, -2737.81, 20.17), richting = 330.0, limiet = 80, straal = 22.0 },
    { naam = 'Route 68 Harmony', coords = vector3(547.43, 2671.71, 42.16), richting = 100.0, limiet = 80, straal = 22.0 },
    { naam = 'Route 68 oost', coords = vector3(1166.02, 2708.93, 38.16), richting = 180.0, limiet = 80, straal = 22.0 },
    { naam = 'Sandy Shores', coords = vector3(1961.46, 3740.67, 32.34), richting = 300.0, limiet = 80, straal = 20.0 },
    { naam = 'Sandy Shores noord', coords = vector3(1392.56, 3604.68, 34.98), richting = 200.0, limiet = 80, straal = 20.0 },
    { naam = 'Grapeseed', coords = vector3(1698.39, 4924.40, 42.06), richting = 55.0, limiet = 80, straal = 18.0 },
    { naam = 'Banham Canyon', coords = vector3(-1820.52, 792.52, 138.12), richting = 130.0, limiet = 80, straal = 18.0 },
    { naam = 'Paleto Bay', coords = vector3(-112.22, 6469.29, 31.63), richting = 225.0, limiet = 50, straal = 16.0 },
    { naam = 'Paleto Boulevard', coords = vector3(-448.10, 6012.40, 31.72), richting = 315.0, limiet = 50, straal = 16.0 },

    -- Snelweg, 100–120 km/h
    { naam = 'Great Ocean Highway', coords = vector3(-2968.24, 390.91, 15.04), richting = 90.0, limiet = 120, straal = 24.0 },
    { naam = 'Great Ocean Highway west', coords = vector3(-3038.94, 585.95, 7.91), richting = 20.0, limiet = 120, straal = 24.0 },
    { naam = 'Great Ocean Highway Chumash', coords = vector3(-3241.93, 1001.46, 12.83), richting = 270.0, limiet = 120, straal = 24.0 },
    { naam = 'Great Ocean Highway noord', coords = vector3(-2194.20, 4286.40, 49.18), richting = 240.0, limiet = 120, straal = 24.0 },
    { naam = 'Palomino Freeway', coords = vector3(2557.46, 382.28, 108.62), richting = 0.0, limiet = 120, straal = 22.0 },
    { naam = 'Senora Freeway', coords = vector3(2678.92, 3280.67, 55.24), richting = 330.0, limiet = 100, straal = 22.0 },
    { naam = 'Senora richting Paleto', coords = vector3(1729.22, 6414.13, 35.04), richting = 240.0, limiet = 100, straal = 22.0 },
}

--[[
    Roodlichtcamera's
    -----------------
    centrum = midden van het kruispunt
    limiet  = maximum op dat kruispunt (te hard wordt ook geflitst)
    straal  = wanneer je "door het kruispunt" rijdt
    offset  = verschuift de cyclus, zodat niet elk licht tegelijk verspringt

    Het script zet de stoplichten op dit kruispunt zelf op groen/geel/rood.
    Alleen dan is zeker welk licht voor jouw rijrichting geldt.
    Zonder stoplicht in de buurt volgt er geen roodlichtflits.
]]
Config.Roodlicht = {
    { naam = 'Kruispunt Legion', centrum = vector3(160.0, -1028.0, 29.35), limiet = 50, straal = 15.0, zoekstraal = 42.0, offset = 0 },
    { naam = 'Kruispunt Mission Row', centrum = vector3(400.0, -1032.0, 29.30), limiet = 50, straal = 15.0, zoekstraal = 42.0, offset = 4000 },
    { naam = 'Kruispunt Textile City', centrum = vector3(380.0, -830.0, 29.30), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 8000 },
    { naam = 'Kruispunt Strawberry', centrum = vector3(55.0, -1375.0, 29.30), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 2000 },
    { naam = 'Kruispunt Davis', centrum = vector3(-70.0, -1765.0, 29.30), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 11000 },
    { naam = 'Kruispunt Little Seoul', centrum = vector3(-680.0, -940.0, 19.20), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 6000 },
    { naam = 'Kruispunt Alta Street', centrum = vector3(250.0, -370.0, 44.80), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 9000 },
    { naam = 'Kruispunt Pillbox', centrum = vector3(260.0, -590.0, 43.20), limiet = 50, straal = 14.0, zoekstraal = 45.0, offset = 3000 },
    { naam = 'Kruispunt Mirror Park', centrum = vector3(1145.0, -360.0, 67.20), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 7000 },
    { naam = 'Kruispunt Vinewood', centrum = vector3(340.0, 300.0, 103.50), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 1500 },
    { naam = 'Kruispunt Rockford Hills', centrum = vector3(-1460.0, -400.0, 36.50), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 10000 },
    { naam = 'Kruispunt Vespucci', centrum = vector3(-1200.0, -890.0, 13.00), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 5000 },
    { naam = 'Kruispunt La Mesa', centrum = vector3(760.0, -1065.0, 22.20), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 12000 },
    { naam = 'Kruispunt Del Perro', centrum = vector3(-1360.0, -560.0, 30.20), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 2500 },
    { naam = 'Kruispunt Luchthaven', centrum = vector3(-1055.0, -2710.0, 20.10), limiet = 80, straal = 16.0, zoekstraal = 45.0, offset = 4500 },
    { naam = 'Kruispunt Paleto', centrum = vector3(-90.0, 6445.0, 31.40), limiet = 50, straal = 14.0, zoekstraal = 40.0, offset = 5500 },
    { naam = 'Kruispunt Sandy Shores', centrum = vector3(1930.0, 3720.0, 32.30), limiet = 80, straal = 16.0, zoekstraal = 45.0, offset = 8500 },
    { naam = 'Kruispunt Grapeseed', centrum = vector3(1685.0, 4905.0, 42.00), limiet = 80, straal = 16.0, zoekstraal = 45.0, offset = 15000 },
}

function Config.BerekenBoete(teHard, doorRood)
    local bedrag = 0

    if teHard and teHard > 0 then
        bedrag = teHard * Config.BoetePerKmh
    end

    if doorRood then
        bedrag = bedrag + Config.RoodlichtBoete
    end

    if bedrag <= 0 then
        return 0
    end

    if bedrag < Config.MinimumBoete then
        bedrag = Config.MinimumBoete
    end

    if bedrag > Config.MaximumBoete then
        bedrag = Config.MaximumBoete
    end

    return math.floor(bedrag)
end
