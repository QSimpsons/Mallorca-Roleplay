StaffDuty = {}

local sessions = {}

local function round(value)
	return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function cleanStreet(value)
	if type(value) ~= "string" then
		return ""
	end

	value = value:gsub("[%c]", ""):sub(1, 64)
	return value
end

local function validCoord(value)
	value = tonumber(value)
	return value and value > -12000 and value < 12000
end

function StaffDuty.isOnDuty(source)
	return sessions[source] ~= nil
end

local function clockOut(source)
	local session = sessions[source]
	if not session then
		return false
	end

	sessions[source] = nil

	if session.shiftId then
		pcall(function()
			MySQL.update.await(
				"UPDATE admin_duty_shifts SET clock_out = CURRENT_TIMESTAMP WHERE id = ? AND clock_out IS NULL",
				{ session.shiftId }
			)
		end)
	end

	return true
end

local function clockIn(source)
	if sessions[source] then
		return sessions[source]
	end

	local identifier = Helpers.getPlayerLicenseIdentifier(source) or ("player:%s"):format(source)
	local name = GetPlayerName(source) or "Staff"
	local shiftId = nil
	local ok, inserted = pcall(function()
		return MySQL.insert.await(
			"INSERT INTO admin_duty_shifts (identifier, name) VALUES (?, ?)",
			{ identifier, name:sub(1, 64) }
		)
	end)

	if ok then
		shiftId = inserted
	else
		print(("[esx-adminmenu] Duty clock-in was not saved: %s"):format(tostring(inserted)))
	end

	sessions[source] = {
		identifier = identifier,
		name = name,
		startedAt = os.time(),
		shiftId = shiftId,
		x = nil,
		y = nil,
		z = nil,
		heading = 0,
		street = "",
		inVehicle = false,
		updatedAt = 0,
	}

	return sessions[source]
end

local function snapshot(viewer, origin)
	local list = {}
	local ox, oy, oz = origin.x, origin.y, origin.z

	for src, session in pairs(sessions) do
		if GetPlayerName(src) then
			local distance = nil
			if ox and session.x and oy and session.y and oz and session.z then
				local dx, dy, dz = session.x - ox, session.y - oy, session.z - oz
				distance = math.floor(math.sqrt(dx * dx + dy * dy + dz * dz) + 0.5)
			end

			list[#list + 1] = {
				id = src,
				name = session.name,
				startedAt = session.startedAt,
				x = session.x,
				y = session.y,
				z = session.z,
				heading = session.heading,
				street = session.street,
				inVehicle = session.inVehicle == true,
				self = src == viewer,
				distance = distance,
			}
		else
			sessions[src] = nil
		end
	end

	table.sort(list, function(a, b)
		return (a.name or "") < (b.name or "")
	end)

	local mine = sessions[viewer]
	return {
		success = true,
		onDuty = mine ~= nil,
		startedAt = mine and mine.startedAt or nil,
		staff = list,
	}
end

function StaffDuty.updatePosition(source, data)
	local session = sessions[source]
	if not session or type(data) ~= "table" then
		return false
	end

	local now = GetGameTimer()
	if session.updatedAt > 0 and (now - session.updatedAt) < 750 then
		return false
	end

	if not validCoord(data.x) or not validCoord(data.y) or not validCoord(data.z) then
		return false
	end

	session.x = round(data.x)
	session.y = round(data.y)
	session.z = round(data.z)
	session.heading = round(data.heading)
	session.street = cleanStreet(data.street)
	session.inVehicle = data.inVehicle == true
	session.updatedAt = now
	session.name = GetPlayerName(source) or session.name
	return true
end

local function canView(source)
	return Helpers.hasFeaturePermission(source, "staffTracker") or Helpers.hasFeaturePermission(source, "staffDuty")
end

local function originFrom(data)
	local origin = {}
	if type(data) == "table" and validCoord(data.x) and validCoord(data.y) and validCoord(data.z) then
		origin.x, origin.y, origin.z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
	end
	return origin
end

Helpers.registerCallback("esx-adminmenu:server:getStaffDesk", function(source, data)
	if not canView(source) then
		return { success = false, err = "Insufficient Permissions." }
	end

	return snapshot(source, originFrom(data))
end)

Helpers.registerCallback("esx-adminmenu:server:toggleStaffDuty", function(source, data)
	if not Helpers.hasFeaturePermission(source, "staffDuty") then
		return { success = false, err = "Insufficient Permissions." }
	end

	local origin = originFrom(data)

	if StaffDuty.isOnDuty(source) then
		clockOut(source)
		Logs.record({
			namespace = "staff",
			action = "clockOut",
			actor = source,
			success = true,
		})
		return snapshot(source, origin)
	end

	local session = clockIn(source)
	if origin.x then
		session.x = round(origin.x)
		session.y = round(origin.y)
		session.z = round(origin.z)
		session.updatedAt = GetGameTimer()
	end
	Logs.record({
		namespace = "staff",
		action = "clockIn",
		actor = source,
		success = true,
	})
	return snapshot(source, origin)
end)

RegisterNetEvent("esx-adminmenu:server:updateStaffPosition", function(data)
	if not StaffDuty.isOnDuty(source) then
		return
	end

	StaffDuty.updatePosition(source, data)
end)

AddEventHandler("playerDropped", function()
	if clockOut(source) then
		Logs.record({
			namespace = "staff",
			action = "clockOut",
			actor = source,
			success = true,
			payload = { reason = "disconnect" },
		})
	end
end)

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

	for src in pairs(sessions) do
		clockOut(src)
	end
end)
