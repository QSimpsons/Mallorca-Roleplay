StaffClient = {
	onDuty = false,
}

local blips = {}

local function dutyConfig()
	return Config.StaffDuty or {}
end

local function clearBlips()
	for id, blip in pairs(blips) do
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
		blips[id] = nil
	end
end

local function viewerCoords()
	local coords = GetEntityCoords(PlayerPedId())
	return { x = coords.x, y = coords.y, z = coords.z }
end

function StaffClient.reportPosition()
	if not StaffClient.onDuty then
		return
	end

	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)

	TriggerServerEvent("esx-adminmenu:server:updateStaffPosition", {
		x = coords.x,
		y = coords.y,
		z = coords.z,
		heading = GetEntityHeading(ped),
		street = GetStreetNameFromHashKey(streetHash),
		inVehicle = IsPedInAnyVehicle(ped, false),
	})
end

local function upsertBlips(staff)
	local seen = {}
	local blipConfig = dutyConfig().Blip or {}

	for i = 1, #staff do
		local member = staff[i]
		if member and not member.self and member.x and member.y then
			local id = member.id
			seen[id] = true
			local blip = blips[id]

			if not blip or not DoesBlipExist(blip) then
				blip = AddBlipForCoord(member.x + 0.0, member.y + 0.0, (member.z or 0.0) + 0.0)
				SetBlipSprite(blip, blipConfig.sprite or 1)
				SetBlipColour(blip, blipConfig.colour or 3)
				SetBlipScale(blip, blipConfig.scale or 0.9)
				SetBlipAsShortRange(blip, false)
				ShowHeadingIndicatorOnBlip(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(("Staff | %s"):format(member.name or "Staff"))
				EndTextCommandSetBlipName(blip)
				blips[id] = blip
			else
				SetBlipCoords(blip, member.x + 0.0, member.y + 0.0, (member.z or 0.0) + 0.0)
			end

			if member.heading then
				SetBlipRotation(blip, math.floor(member.heading + 0.5))
			end
		end
	end

	for id, blip in pairs(blips) do
		if not seen[id] then
			if DoesBlipExist(blip) then
				RemoveBlip(blip)
			end
			blips[id] = nil
		end
	end
end

function StaffClient.refresh(cb)
	xLib.callback("esx-adminmenu:server:getStaffDesk", false, function(res)
		if res and res.success then
			StaffClient.onDuty = res.onDuty == true
			upsertBlips(res.staff or {})
		elseif res and res.err then
			StaffClient.onDuty = false
			clearBlips()
		end

		if cb then
			cb(res)
		end
	end, viewerCoords())
end

CreateThread(function()
	local allowed = nil

	while true do
		local waitMs = dutyConfig().UpdateMs or 2000

		if allowed == false then
			Wait(60000)
			allowed = nil
		else
			if StaffClient.onDuty then
				StaffClient.reportPosition()
			end

			local done = false
			StaffClient.refresh(function(res)
				allowed = res and res.success == true
				done = true
			end)

			local timeout = GetGameTimer() + 5000
			while not done and GetGameTimer() < timeout do
				Wait(50)
			end

			Wait(waitMs)
		end
	end
end)
