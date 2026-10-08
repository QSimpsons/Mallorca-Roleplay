Config = {}

Config.Framework = 'esx'
Config.JobName = 'mechanic'
Config.AllowedJobs = {
    mechanic = true,
    wegenwacht = true,
    anwb = true,
    mecano = true,
    monteur = true
}
Config.MinGrade = 1
Config.MaxGrade = 6
Config.ManagerGrade = 6
Config.JobGrades = {
    [1] = 'Leerling autotechnicus',
    [2] = '3e Autotechnicus',
    [3] = '2e Autotechnicus',
    [4] = '1e Autotechnicus',
    [5] = 'Teamleider',
    [6] = 'Manager'
}
Config.Society = 'society_mechanic'
Config.RequireJob = true
Config.RequireDuty = false

function Config.IsAllowedJob(name)
    if not name or name == '' then
        return false
    end
    name = string.lower(tostring(name))
    if Config.AllowedJobs and Config.AllowedJobs[name] then
        return true
    end
    if Config.JobName and name == string.lower(Config.JobName) then
        return true
    end
    return name:find('mechanic', 1, true) ~= nil
        or name:find('wegenwacht', 1, true) ~= nil
        or name:find('anwb', 1, true) ~= nil
end

function Config.IsAllowedGrade(grade)
    grade = tonumber(grade)
    if grade == nil then
        return false
    end
    local minG = Config.MinGrade or 1
    local maxG = Config.MaxGrade or 6
    if grade >= minG and grade <= maxG then
        return true
    end
    -- ESX telt soms 0–5 i.p.v. 1–6
    if minG == 1 and grade == 0 then
        return true
    end
    if maxG == 6 and grade == 5 then
        return true
    end
    return false
end

Config.Keys = {
    menu = 'F1',
    toggle = 'O'
}

Config.Command = 'takel'
Config.CallCommand = 'takelhulp'

Config.UseTarget = true
Config.TargetDistance = 12.0

Config.PlaceVehicles = false
Config.AllowCurrentVehicle = false

Config.InteractDistance = 2.6
Config.TowSearchDistance = 12.0
Config.ImpoundDistance = 8.0
Config.BillDistance = 4.0

Config.Prices = {
    impound = 1500,
    minBill = 100,
    maxBill = 25000,
    callReward = 850,
    npcCallReward = 1200
}

Config.AllowAllVehicles = true
Config.AllowedClasses = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true,
    [5] = true, [6] = true, [7] = true, [8] = true, [9] = true,
    [10] = true, [11] = true, [12] = true, [13] = true, [14] = true,
    [15] = true, [16] = true, [17] = true, [18] = true, [19] = true,
    [20] = true, [21] = true
}

-- Alleen deze twee addons. Geen GTA flatbed/towtruck.
Config.TowVehicles = {
    [`fmltow`] = {
        label = 'FML Tow',
        bone = 'bodyshell',
        offset = vector3(0.0, -2.05, 1.02),
        rotation = vector3(0.0, 0.0, 0.0),
        slide = 6.2,
        dropY = -9.5
    },
    [`dlbrickade`] = {
        label = 'DL Brickade',
        bone = 'bodyshell',
        offset = vector3(0.0, -4.20, 1.28),
        rotation = vector3(0.0, 0.0, 0.0),
        slide = 7.4,
        dropY = -12.0
    }
}

Config.Depot = {
    label = 'Mallorca Takel',
    coords = vector3(491.19, -1314.78, 29.26),
    heading = 34.0,
    blip = { sprite = 68, color = 47, scale = 0.9 },
    spawn = vector4(479.48, -1326.41, 29.21, 5.0),
    store = vector3(479.48, -1326.41, 29.21)
}

Config.Impound = {
    label = 'Inbeslagname',
    coords = vector3(401.68, -1631.80, 29.29),
    heading = 230.0,
    blip = { sprite = 677, color = 1, scale = 0.75 },
    spawn = vector4(391.74, -1618.02, 29.29, 230.0),
    retrieve = vector3(409.24, -1623.08, 29.29)
}

Config.GarageVehicles = {
    { model = 'fmltow', label = 'FML Tow', minGrade = 1 },
    { model = 'dlbrickade', label = 'DL Brickade', minGrade = 1 }
}

Config.ParkedVehicles = {
    { model = 'fmltow', label = 'FML Tow', plate = 'FMLTOW', coords = vector4(476.68, -1317.52, 29.21, 305.0) },
    { model = 'dlbrickade', label = 'DL Brickade', plate = 'BRICK1', coords = vector4(487.55, -1332.40, 29.21, 300.0) }
}

Config.NpcCalls = {
    enabled = true,
    intervalMs = 180000,
    minOnDuty = 1,
    spots = {
        vector3(215.86, -810.12, 30.73),
        vector3(-303.41, -933.12, 31.08),
        vector3(1178.41, 2653.98, 37.81),
        vector3(-1603.21, -831.45, 10.07),
        vector3(1963.44, 3752.11, 32.21),
        vector3(-51.12, -1114.55, 26.44)
    },
    models = { 'sultan', 'banshee', 'asea', 'premier', 'oracle', 'buffalo' }
}

Config.Markers = {
    type = 1,
    scale = vector3(1.6, 1.6, 0.6),
    color = { r = 232, g = 93, b = 4, a = 140 }
}

Config.Locale = {
    duty_on = 'Je bent nu in dienst bij Mallorca Takel.',
    duty_off = 'Je bent uit dienst.',
    not_employee = 'Dit is voor Wegenwacht mechanic rang 1 t/m 6.',
    need_duty = 'Ga eerst in dienst bij het depot.',
    no_truck = 'Stap in de fmltow of dlbrickade.',
    no_target = 'Geen voertuig achter de bak gevonden.',
    class_blocked = 'Dit voertuig mag niet getakeld worden.',
    attaching = 'Bezig met takelen…',
    attached = 'Voertuig ligt op de bak.',
    detached = 'Voertuig is afgezet.',
    already_towing = 'Er ligt al een voertuig op de bak.',
    not_towing = 'De bak is leeg.',
    impounded = 'Voertuig inbeslaggenomen.',
    need_attached = 'Takel eerst een voertuig en rijd naar de inbeslagname.',
    billed = 'Factuur verstuurd.',
    bill_received = 'Je hebt een takelfactuur ontvangen.',
    paid = 'Betaald. Je voertuig staat klaar.',
    cannot_pay = 'Niet genoeg contant geld.',
    call_sent = 'Takeldienst is gewaarschuwd.',
    call_taken = 'Oproep aangenomen. GPS gezet.',
    call_new = 'Nieuwe takeloproep binnengekomen.',
    truck_out = 'Takelwagen uitgehaald.',
    truck_in = 'Takelwagen weggezet.',
    spawn_blocked = 'Spawnplek is geblokkeerd.',
    released = 'Voertuig vrijgegeven.',
    no_vehicle = 'Geen voertuig gevonden.',
    occupied = 'Laat inzittenden eerst uitstappen.',
    too_far_truck = 'Zet de auto dichter achter de bak.',
    truck_taken = 'Je pakt de takelwagen.',
    busy = 'Nog even wachten — er wordt getakeld.',
    eye_tow = 'Voertuig takelen',
    eye_detach = 'Loskoppelen',
    eye_call = 'Takelhulp vragen',
    eye_take_truck = 'Takelwagen pakken',
    eye_tablet = 'Takel tablet',
    eye_impound = 'Inbeslag nemen'
}
