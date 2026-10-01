Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Eclipse Garage · ESX Legacy
-- Parkeer je voertuig, roep het op, of haal het uit de impound.
-- ═══════════════════════════════════════════════════════════════

Config.Debug = false

-- Elke garage van hetzelfde type kan elk geparkeerd voertuig geven.
-- false = een auto die in Legion staat, haal je alleen daar op.
Config.ShareGarages = true

-- Voertuig dat buiten staat (of weg is) kun je bij de impound terughalen.
Config.RecoverOutVehicles = true

-- Job-voertuigen (owned_vehicles.job gevuld) in de gewone garage tonen.
Config.IncludeJobVehicles = false

-- In het voertuig zetten zodra het gespawned is.
Config.WarpIntoVehicle = true

Config.MarkerDistance = 28.0
Config.InteractDistance = 2.5
Config.StoreDistance = 8.0
Config.ServerDistance = 14.0
Config.CommandDistance = 22.0
Config.BlipShortRange = false

-- Sleutels: 'auto' probeert bekende scripts, 'none' slaat het over.
-- auto herkent qs-vehiclekeys, wasabi_carlock, mk_vehiclekeys, vehicles_keys, cd_garage.
Config.Keys = {
    system = 'auto'
}

-- Brandstof: ox_fuel en LegacyFuel worden automatisch gezet als ze draaien.
Config.Fuel = {
    default = 100.0
}

-- Ophalen, terugzetten en oproepen is gratis.
Config.Prices = {
    impound = 0,
    recover = 0,
    call = 0
}

-- Impound-betalingen gaan naar deze maatschappijrekening (leeg = nergens heen).
Config.ImpoundSociety = 'society_takel'

-- Jobs die /inbeslagnemen mogen gebruiken. Leeg tabel-item = niemand via job.
Config.ImpoundJobs = {
    police = true,
    kmar = true,
    mechanic = true,
    takel = true,
    anwb = true,
    wegenwacht = true
}

-- Extra ACE, bijvoorbeeld in server.cfg: add_ace group.admin eclipse.impound allow
Config.ImpoundAce = 'eclipse.impound'

Config.Commands = {
    garage = 'garage',
    impound = 'impound',
    call = 'oproep',
    staffImpound = 'inbeslagnemen'
}

-- /oproep en de toets hieronder. Alleen types die hier op true staan.
Config.Call = {
    enabled = true,
    key = 'F7',
    price = 0,
    cooldown = 20,
    maxDistance = 35.0,
    types = {
        car = true,
        boat = false,
        aircraft = false
    }
}

Config.Text = {
    openGarage = 'Druk op ~INPUT_CONTEXT~ om de garage te openen',
    store = 'Druk op ~INPUT_CONTEXT~ om je voertuig te parkeren',
    openImpound = 'Druk op ~INPUT_CONTEXT~ om de impound te openen',
    storing = 'Voertuig wordt in de garage gezet...',
    parked = 'Voertuig geparkeerd.',
    storedNew = 'Voertuig op jouw naam gezet en geparkeerd.',
    spawned = 'Je voertuig staat klaar.',
    called = 'Je voertuig is bij je neergezet.',
    recovered = 'Voertuig opgehaald uit de impound.',
    noMoney = 'Je hebt niet genoeg geld bij je of op de bank.',
    notOwner = 'Dit voertuig is niet van jou.',
    alreadyOut = 'Dit voertuig staat al buiten. Haal het op bij de impound.',
    impounded = 'Dit voertuig staat in de impound.',
    notHere = 'Je staat niet bij een garage. Gebruik /oproep om een voertuig bij je te roepen.',
    notImpound = 'Je staat niet bij een impound.',
    spawnBlocked = 'De uitrijplaats is geblokkeerd. Rij de andere wagen weg.',
    modelFail = 'Dit voertuig kon niet geladen worden.',
    cooldown = 'Wacht even voor je opnieuw een voertuig oproept.',
    tooFast = 'Even geduld.',
    notStored = 'Dit voertuig staat niet in de garage.',
    wrongType = 'Dit voertuig hoort niet bij deze garage.',
    otherGarage = 'Dit voertuig staat in een andere garage.',
    notDriver = 'Je moet op de bestuurdersstoel zitten.',
    noVehicle = 'Geen voertuig in de buurt.',
    staffDenied = 'Je mag geen voertuigen in beslag nemen.',
    staffDone = 'Voertuig in beslag genomen.',
    staffNpc = 'Voertuig weggesleept.',
    ownerImpounded = 'Je voertuig %s is in beslag genomen.',
    dbDown = 'De garage is nog niet klaar. Probeer het zo opnieuw.',
    inVehicleCall = 'Stap eerst uit je voertuig.',
    busy = 'Dit voertuig wordt al verwerkt.',
    callOff = 'Oproepen staat uit.',
    nothing = 'Je hebt hier geen voertuigen.',
    plateMismatch = 'Het kenteken komt niet overeen met dit voertuig.'
}

-- Blip: sprite 357 = garage, 68 = impound, 356 = boot, 359 = vliegtuig.
-- Kleuren: 29 = donkerblauw, 1 = rood, 3 = blauw, 46 = geel.
Config.Blips = {
    car = { sprite = 357, color = 29, scale = 0.75 },
    boat = { sprite = 356, color = 3, scale = 0.75 },
    aircraft = { sprite = 359, color = 46, scale = 0.8 },
    impound = { sprite = 68, color = 1, scale = 0.8 }
}

Config.Markers = {
    car = { type = 36, r = 20, g = 58, b = 140 },
    boat = { type = 35, r = 80, g = 170, b = 255 },
    aircraft = { type = 34, r = 255, g = 196, b = 64 },
    impound = { type = 36, r = 255, g = 70, b = 70 }
}

-- Verplaats coördinaten vrij: coords = marker, spawns = plekken waar de auto komt.
Config.Garages = {
    {
        id = 'legion',
        label = 'Garage Legion Square',
        type = 'car',
        coords = vector3(215.80, -810.06, 30.73),
        spawns = {
            vector4(222.17, -804.27, 30.16, 248.0),
            vector4(223.55, -799.10, 30.16, 248.0),
            vector4(224.72, -794.35, 30.16, 248.0),
            vector4(226.10, -789.20, 30.16, 248.0)
        }
    },
    {
        id = 'pillbox',
        label = 'Garage Pillbox Hill',
        type = 'car',
        coords = vector3(273.67, -343.84, 44.92),
        spawns = {
            vector4(270.75, -340.51, 44.92, 342.0),
            vector4(277.55, -336.90, 44.92, 342.0),
            vector4(284.55, -333.20, 44.92, 342.0)
        }
    },
    {
        id = 'alta',
        label = 'Garage Alta',
        type = 'car',
        coords = vector3(-340.58, -876.12, 31.07),
        spawns = {
            vector4(-357.12, -883.55, 31.07, 90.0),
            vector4(-349.40, -883.20, 31.07, 90.0),
            vector4(-339.80, -883.40, 31.07, 90.0)
        }
    },
    {
        id = 'mirror',
        label = 'Garage Mirror Park',
        type = 'car',
        coords = vector3(1036.28, -763.27, 57.99),
        spawns = {
            vector4(1023.20, -764.27, 57.96, 319.0),
            vector4(1027.55, -771.80, 57.96, 319.0),
            vector4(1031.10, -779.20, 57.96, 319.0)
        }
    },
    {
        id = 'sandy',
        label = 'Garage Sandy Shores',
        type = 'car',
        coords = vector3(1737.59, 3710.20, 34.14),
        spawns = {
            vector4(1728.55, 3715.40, 34.15, 20.0),
            vector4(1722.90, 3713.20, 34.20, 20.0),
            vector4(1737.84, 3719.28, 34.04, 21.0)
        }
    },
    {
        id = 'paleto',
        label = 'Garage Paleto Bay',
        type = 'car',
        coords = vector3(105.36, 6613.59, 32.40),
        spawns = {
            vector4(117.50, 6599.40, 32.01, 270.0),
            vector4(122.10, 6594.80, 32.01, 270.0),
            vector4(126.70, 6590.10, 32.01, 270.0)
        }
    },
    {
        id = 'boten',
        label = 'Garage La Puerta — boten',
        type = 'boat',
        coords = vector3(-795.15, -1510.79, 1.60),
        spawns = {
            vector4(-798.66, -1507.73, -0.40, 110.0),
            vector4(-804.20, -1498.50, -0.40, 110.0)
        }
    },
    {
        id = 'lsia',
        label = 'Hangar LSIA',
        type = 'aircraft',
        coords = vector3(-1639.50, -3104.30, 13.94),
        spawns = {
            vector4(-1653.20, -3145.10, 13.99, 330.0),
            vector4(-1668.40, -3135.60, 13.99, 330.0)
        }
    }
}

Config.Impounds = {
    {
        id = 'impound_davis',
        label = 'Impound Davis',
        type = 'car',
        coords = vector3(409.14, -1622.88, 29.29),
        spawns = {
            vector4(401.28, -1632.77, 29.29, 230.0),
            vector4(396.55, -1644.13, 29.29, 320.0),
            vector4(408.90, -1646.40, 29.29, 230.0)
        }
    },
    {
        id = 'impound_sandy',
        label = 'Impound Sandy Shores',
        type = 'car',
        coords = vector3(1412.92, 3619.55, 34.90),
        spawns = {
            vector4(1422.40, 3624.80, 34.87, 200.0),
            vector4(1416.20, 3622.10, 34.87, 200.0)
        }
    },
    {
        id = 'impound_boten',
        label = 'Impound haven',
        type = 'boat',
        coords = vector3(-772.40, -1430.55, 1.60),
        spawns = {
            vector4(-780.20, -1425.40, -0.30, 140.0)
        }
    },
    {
        id = 'impound_lsia',
        label = 'Impound LSIA',
        type = 'aircraft',
        coords = vector3(-1293.10, -3378.40, 13.94),
        spawns = {
            vector4(-1271.50, -3380.20, 13.94, 330.0)
        }
    }
}

function Config.NormalizePlate(plate)
    plate = tostring(plate or ''):upper()
    plate = plate:gsub('%s+', '')
    return plate
end

function Config.SameType(garageType, dbType)
    garageType = string.lower(tostring(garageType or 'car'))
    dbType = string.lower(tostring(dbType or 'car'))
    if dbType == '' then
        dbType = 'car'
    end
    if garageType == 'car' then
        return dbType == 'car' or dbType == 'automobile' or dbType == 'bike' or dbType == 'motorcycle'
    end
    if garageType == 'boat' then
        return dbType == 'boat'
    end
    if garageType == 'aircraft' then
        return dbType == 'aircraft' or dbType == 'plane' or dbType == 'heli' or dbType == 'helicopter'
    end
    return garageType == dbType
end

function Config.CallAllowed(dbType)
    local types = Config.Call and Config.Call.types or {}
    for name, enabled in pairs(types) do
        if enabled and Config.SameType(name, dbType) then
            return true
        end
    end
    return false
end

function Config.IsPersonalVehicle(job)
    if job == nil then
        return true
    end
    if type(job) ~= 'string' then
        return false
    end
    job = job:lower()
    return job == '' or job == 'civ' or job == 'civilian' or job == 'unemployed'
end

function Config.FindGarage(id)
    if not id then
        return nil
    end
    for i = 1, #Config.Garages do
        if Config.Garages[i].id == id then
            return Config.Garages[i]
        end
    end
    return nil
end

function Config.FindImpound(id)
    if not id then
        return nil
    end
    for i = 1, #Config.Impounds do
        if Config.Impounds[i].id == id then
            return Config.Impounds[i]
        end
    end
    return nil
end
