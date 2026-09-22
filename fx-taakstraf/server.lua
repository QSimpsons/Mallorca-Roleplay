local ActiveTasks = {}


local lastDoneTask  = {}
local DONETASK_COOLDOWN = 4000 


local areaViolations  = {}
local MAX_AREA_VIOLATIONS = 5


local ESX = exports["es_extended"]:getSharedObject()

local function hasTaskPerms(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    local group = xPlayer.getGroup()

    -- allowed groups
    local allowed = {
        ["mod"] = true,
        ["admin"] = true,
        ["owner"] = true
    }

    return allowed[group] == true
end


local function getLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then return id end
    end
    return nil
end


local function sendLog(title, description, color)
    local webhook = Config.Webhook
    if not webhook or webhook == "" then return end

    PerformHttpRequest(
        webhook,
        function(status) end,
        "POST",
        json.encode({
            embeds = {{
                title       = title,
                description = description,
                color       = color or 3447003,
                footer      = { text = "Mallorca Taakstraf • " .. os.date("%d-%m-%Y %H:%M:%S") }
            }}
        }),
        { ["Content-Type"] = "application/json" }
    )
end



RegisterCommand("taakstraf", function(source, args)
    if source == 0 then return end
    if not hasTaskPerms(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Geen permissie.', type = 'error' })
        return
    end

    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = table.concat(args, " ", 3)

    if not target or not GetPlayerName(target) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Ongeldig speler ID.', type = 'error' })
        return
    end
    if not amount or amount < 1 then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Hoeveelheid moet hoger dan 0 zijn.', type = 'error' })
        return
    end
    if not reason or reason == "" then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Geef een reden op.', type = 'error' })
        return
    end

    if ActiveTasks[target] then
        ActiveTasks[target].left   = ActiveTasks[target].left + amount
        ActiveTasks[target].reason = reason
        ActiveTasks[target].by     = GetPlayerName(source)

        local license = getLicense(target)
        if license then
            exports.oxmysql:update(
                "UPDATE taakstraf_disconnect_logs SET tasks_left = ?, reason = ?, given_by = ? WHERE license = ? AND active = 1",
                { ActiveTasks[target].left, reason, GetPlayerName(source), license }
            )
        end

        TriggerClientEvent("fx-taakstraf:update", target, ActiveTasks[target].left)
        TriggerClientEvent('ox_lib:notify', source, {
            title       = 'Taakstraf bijgewerkt',
            description = ('%s heeft nu %s taken over.'):format(GetPlayerName(target), ActiveTasks[target].left),
            type        = 'success'
        })
        sendLog("Taakstraf Uitgebreid",
            ("**Staff:** %s\n**Speler:** %s (ID: %s)\n**Extra taken:** %s\n**Totaal:** %s\n**Reden:** %s")
                :format(GetPlayerName(source), GetPlayerName(target), target, amount, ActiveTasks[target].left, reason),
            16744272)
        return
    end


    ActiveTasks[target]   = { left = amount, reason = reason, by = GetPlayerName(source) }
    areaViolations[target] = 0

    local license = getLicense(target)
    if license then
        exports.oxmysql:insert(
            "INSERT INTO taakstraf_disconnect_logs (player_name, license, tasks_left, reason, given_by, disconnect_reason, active) VALUES (?, ?, ?, ?, ?, ?, 1)",
            { GetPlayerName(target), license, amount, reason, GetPlayerName(source), "Online opgelegd" }
        )
    end

    TriggerClientEvent("fx-taakstraf:start", target, ActiveTasks[target])
    TriggerClientEvent('ox_lib:notify', source, {
        title       = 'Taakstraf opgelegd',
        description = ('%s heeft %s taken gekregen.'):format(GetPlayerName(target), amount),
        type        = 'success'
    })
    sendLog("Taakstraf Opgelegd",
        ("**Staff:** %s\n**Speler:** %s (ID: %s)\n**Taken:** %s\n**Reden:** %s")
            :format(GetPlayerName(source), GetPlayerName(target), target, amount, reason),
        3066993)
end)


RegisterCommand("stoptaakstraf", function(source, args)
    if source == 0 then return end
    if not hasTaskPerms(source) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Geen permissie.', type = 'error' })
        return
    end

    local target = tonumber(args[1])
    if not target or not GetPlayerName(target) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Ongeldig speler ID.', type = 'error' })
        return
    end
    if not ActiveTasks[target] then
        TriggerClientEvent('ox_lib:notify', source, { title = 'Taakstraf', description = 'Deze speler heeft geen actieve taakstraf.', type = 'error' })
        return
    end

    local takenOver = ActiveTasks[target].left
    local reden     = ActiveTasks[target].reason
    local license   = getLicense(target)

    ActiveTasks[target]    = nil
    areaViolations[target] = nil
    lastDoneTask[target]   = nil

    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
            { license }
        )
    end

    TriggerClientEvent("fx-taakstraf:stop", target)
    TriggerClientEvent('ox_lib:notify', source, {
        title       = 'Taakstraf gestopt',
        description = ('Taakstraf van %s is verwijderd.'):format(GetPlayerName(target)),
        type        = 'success'
    })
    sendLog("Taakstraf Gestopt",
        ("**Staff:** %s\n**Speler:** %s (ID: %s)\n**Taken over:** %s\n**Originele reden:** %s")
            :format(GetPlayerName(source), GetPlayerName(target), target, takenOver, reden),
        15158332)
end)


-- ─── TEBEX / CONSOLE COMMAND ─────────────────────────────────────────────────
-- Deze variant mag WEL vanaf de server console (Tebex) worden uitgevoerd.
-- Gebruik in Tebex: stoptaakstrafwebshop {steamid}
RegisterCommand("stoptaakstrafwebshop", function(source, args)
    if source ~= 0 then return end -- alleen console/Tebex mag dit command gebruiken

    local target = tonumber(args[1])
    if not target or not GetPlayerName(target) then
        print(("[fx-taakstraf] stoptaakstrafwebshop: ongeldig playerId '%s'"):format(tostring(args[1])))
        return
    end
    if not ActiveTasks[target] then
        print(("[fx-taakstraf] stoptaakstrafwebshop: speler %s heeft geen actieve taakstraf."):format(target))
        return
    end

    local takenOver = ActiveTasks[target].left
    local reden     = ActiveTasks[target].reason
    local license   = getLicense(target)

    ActiveTasks[target]    = nil
    areaViolations[target] = nil
    lastDoneTask[target]   = nil

    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
            { license }
        )
    end

    TriggerClientEvent("fx-taakstraf:stop", target)
    TriggerClientEvent('ox_lib:notify', target, {
        title       = 'Taakstraf gestopt',
        description = 'Je taakstraf is afgekocht via de webshop.',
        type        = 'success'
    })
    sendLog("Taakstraf Afgekocht (Webshop)",
        ("**Speler:** %s (ID: %s)\n**Taken over:** %s\n**Originele reden:** %s")
            :format(GetPlayerName(target), target, takenOver, reden),
        15158332)
end, false)



RegisterNetEvent("fx-taakstraf:doneTask", function()
    local src = source

    if not ActiveTasks[src] then
        sendLog("Valse doneTask",
            ("**Speler:** %s (ID: %s)\n**Reden:** doneTask gestuurd zonder actieve taakstraf.")
                :format(GetPlayerName(src), src),
            15158332)
        return
    end

    local now = GetGameTimer()
    if lastDoneTask[src] and (now - lastDoneTask[src]) < DONETASK_COOLDOWN then
        sendLog("🚨 Anti-Trigger: doneTask te snel",
            ("**Speler:** %s (ID: %s)\n**Tijd tussen events:** %sms (minimum: %sms)\n**Taken resterend:** %s")
                :format(GetPlayerName(src), src, now - lastDoneTask[src], DONETASK_COOLDOWN, ActiveTasks[src].left),
            15158332)
        return
    end
    lastDoneTask[src] = now

    local ped = GetPlayerPed(src)
    if ped and DoesEntityExist(ped) then
        local coords     = GetEntityCoords(ped)
        local startCoords = vector3(Config.StartTeleport.x, Config.StartTeleport.y, Config.StartTeleport.z)
        local dist       = #(coords - startCoords)

        if dist > 150.0 then
            areaViolations[src] = (areaViolations[src] or 0) + 1
            sendLog("Speler buiten zone bij doneTask",
                ("**Speler:** %s (ID: %s)\n**Afstand van zone:** %.1f meter\n**Overtredingen:** %s/%s")
                    :format(GetPlayerName(src), src, dist, areaViolations[src], MAX_AREA_VIOLATIONS),
                16744272)

            if areaViolations[src] >= MAX_AREA_VIOLATIONS then
                return
            end

            TriggerClientEvent("fx-taakstraf:forceTP", src)
            return
        end
    end

    ActiveTasks[src].left = ActiveTasks[src].left - 1

    local license = getLicense(src)
    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET tasks_left = ? WHERE license = ? AND active = 1",
            { ActiveTasks[src].left, license }
        )
    end

    TriggerClientEvent("fx-taakstraf:update", src, ActiveTasks[src].left)

    if ActiveTasks[src].left <= 0 then
        local reden = ActiveTasks[src].reason
        ActiveTasks[src]    = nil
        areaViolations[src] = nil
        lastDoneTask[src]   = nil

        if license then
            exports.oxmysql:update(
                "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
                { license }
            )
        end

        TriggerClientEvent("fx-taakstraf:finish", src)
        sendLog("Taakstraf Voltooid",
            ("**Speler:** %s (ID: %s)\n**Reden van straf:** %s"):format(GetPlayerName(src), src, reden),
            5763719)
    end
end)



RegisterNetEvent("fx-taakstraf:shopRemoveTask", function()
    local src = source

    if not ActiveTasks[src] then return end


    local now = GetGameTimer()
    if lastDoneTask[src] and (now - lastDoneTask[src]) < 200 then
        sendLog("Anti-Trigger: shopRemoveTask te snel",
            ("**Speler:** %s (ID: %s)\n**Tijd tussen events:** %sms")
                :format(GetPlayerName(src), src, now - lastDoneTask[src]),
            15158332)
        return
    end
    lastDoneTask[src] = now

    ActiveTasks[src].left = ActiveTasks[src].left - 1

    local license = getLicense(src)
    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET tasks_left = ? WHERE license = ? AND active = 1",
            { ActiveTasks[src].left, license }
        )
    end

    TriggerClientEvent("fx-taakstraf:update", src, ActiveTasks[src].left)

    if ActiveTasks[src].left <= 0 then
        local reden = ActiveTasks[src].reason
        ActiveTasks[src]    = nil
        areaViolations[src] = nil
        lastDoneTask[src]   = nil

        if license then
            exports.oxmysql:update(
                "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
                { license }
            )
        end

        TriggerClientEvent("fx-taakstraf:finish", src)
        sendLog("Taakstraf Voltooid (Weggekocht)",
            ("**Speler:** %s (ID: %s)\n**Reden van straf:** %s"):format(GetPlayerName(src), src, reden),
            5763719)
    end
end)



AddEventHandler("playerDropped", function(reason)
    local src = source
    if not ActiveTasks[src] then return end

    local data    = ActiveTasks[src]
    local license = getLicense(src)

    if license then
        exports.oxmysql:insert(
            "INSERT INTO taakstraf_disconnect_logs (player_name, license, tasks_left, reason, given_by, disconnect_reason, active) VALUES (?, ?, ?, ?, ?, ?, 1)",
            { GetPlayerName(src), license, data.left, data.reason, data.by, reason or "Onbekend" }
        )
    end

    lastDoneTask[src]   = nil
    areaViolations[src] = nil

    sendLog("Speler Disconnected met Taakstraf",
        ("**Speler:** %s (ID: %s)\n**Taken resterend:** %s\n**Reden disconnect:** %s\n**Originele reden straf:** %s")
            :format(GetPlayerName(src), src, data.left, reason or "Onbekend", data.reason),
        16744272)
end)



AddEventHandler("playerJoining", function()
    local src     = source
    local license = getLicense(src)
    if not license then return end

    exports.oxmysql:execute(
        "SELECT * FROM taakstraf_disconnect_logs WHERE license = ? AND active = 1 ORDER BY id DESC LIMIT 1",
        { license },
        function(result)
            if not result or not result[1] then return end
            local row = result[1]

            ActiveTasks[src]   = { left = row.tasks_left, reason = row.reason, by = row.given_by }
            areaViolations[src] = 0

            SetTimeout(5000, function()
                if GetPlayerName(src) then
                    TriggerClientEvent("fx-taakstraf:start", src, ActiveTasks[src])
                    sendLog("Speler gerelogged met Taakstraf",
                        ("**Speler:** %s (ID: %s)\n**Taken resterend:** %s\n**Originele reden:** %s")
                            :format(GetPlayerName(src), src, row.tasks_left, row.reason),
                        3447003)
                end
            end)
        end
    )
end)


-- ─── EXPORTS ──────────────────────────────────────────────────────────────────

exports('AddTaakstraf', function(target, amount, reason, staffName)
    if not target or not GetPlayerName(target) then return false end
    if not amount or amount < 1 then return false end
    staffName = staffName or "Systeem"
    reason    = reason    or "Geen reden opgegeven"

    if ActiveTasks[target] then
        ActiveTasks[target].left = ActiveTasks[target].left + amount
        TriggerClientEvent("fx-taakstraf:update", target, ActiveTasks[target].left)
    else
        ActiveTasks[target]   = { left = amount, reason = reason, by = staffName }
        areaViolations[target] = 0
        local license = getLicense(target)
        if license then
            exports.oxmysql:insert(
                "INSERT INTO taakstraf_disconnect_logs (player_name, license, tasks_left, reason, given_by, disconnect_reason, active) VALUES (?, ?, ?, ?, ?, ?, 1)",
                { GetPlayerName(target), license, amount, reason, staffName, "Via export opgelegd" }
            )
        end
        TriggerClientEvent("fx-taakstraf:start", target, ActiveTasks[target])
    end

    sendLog("Taakstraf Opgelegd (Export)",
        ("**Staff/Systeem:** %s\n**Speler:** %s (ID: %s)\n**Taken:** %s\n**Reden:** %s")
            :format(staffName, GetPlayerName(target), target, amount, reason),
        3066993)
    return true
end)


exports('RemoveTaakstraf', function(target, staffName)
    if not target or not ActiveTasks[target] then return false end
    staffName = staffName or "Systeem"

    local takenOver = ActiveTasks[target].left
    local reden     = ActiveTasks[target].reason
    local license   = getLicense(target)

    ActiveTasks[target]    = nil
    areaViolations[target] = nil
    lastDoneTask[target]   = nil

    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
            { license }
        )
    end

    TriggerClientEvent("fx-taakstraf:stop", target)
    sendLog("Taakstraf Verwijderd (Export)",
        ("**Staff/Systeem:** %s\n**Speler:** %s (ID: %s)\n**Taken over:** %s\n**Originele reden:** %s")
            :format(staffName, GetPlayerName(target), target, takenOver, reden),
        15158332)
    return true
end)


exports('GetTaakstrafInfo', function(target)
    if not target or not ActiveTasks[target] then return nil end
    return { left = ActiveTasks[target].left, reason = ActiveTasks[target].reason, by = ActiveTasks[target].by }
end)

exports('RemoveTaakstrafAmount', function(target, amount)
    if not target or not ActiveTasks[target] then return false end
    if not amount or amount < 1 then return false end
 
    ActiveTasks[target].left = math.max(0, ActiveTasks[target].left - amount)
 
    local license = getLicense(target)
    if license then
        exports.oxmysql:update(
            "UPDATE taakstraf_disconnect_logs SET tasks_left = ? WHERE license = ? AND active = 1",
            { ActiveTasks[target].left, license }
        )
    end
 
    TriggerClientEvent("fx-taakstraf:update", target, ActiveTasks[target].left)
 
    sendLog("Taakstraffen Weggekocht",
        ("**Speler:** %s (ID: %s)\n**Weggekocht:** %s taken\n**Resterend:** %s")
            :format(GetPlayerName(target), target, amount, ActiveTasks[target].left),
        3447003)
 
    if ActiveTasks[target].left <= 0 then
        local reden = ActiveTasks[target].reason
        local lic   = license
 
        ActiveTasks[target]    = nil
        areaViolations[target] = nil
        lastDoneTask[target]   = nil
 
        if lic then
            exports.oxmysql:update(
                "UPDATE taakstraf_disconnect_logs SET active = 0 WHERE license = ? AND active = 1",
                { lic }
            )
        end
 
        TriggerClientEvent("fx-taakstraf:finish", target)
        sendLog("Taakstraf Voltooid (Weggekocht)",
            ("**Speler:** %s (ID: %s)\n**Reden van straf:** %s"):format(GetPlayerName(target), target, reden),
            5763719)
    end
 
    return true
end)