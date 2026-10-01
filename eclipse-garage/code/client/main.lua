local spawnedVehicles = {}
local isGarageOpen = false
local isPlayerInVehicle = false

---@param garage Garage
local function spawnVehicle(garage, vehicle)
	local spawnPointIndex = math.random(1, #garage.spawnPoints)
	local spawnPoint = garage.spawnPoints[spawnPointIndex]

	local props = json.decode(vehicle.vehicle)
	local model = props.model

	lib.requestModel(model)

	-- local ownedVehicleNetworkId = esrp_lib.callback.await("vx_garage:spawnVehicle", false, model, spawnPoint)
	-- local ownedVehicle = NetworkGetEntityFromNetworkId(ownedVehicleNetworkId)
	local ownedVehicle = CreateVehicle(model, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
	while not DoesEntityExist(ownedVehicle) do
		Citizen.Wait(1)
	end

	SetVehicleHasBeenOwnedByPlayer(ownedVehicle, true)

	functions.setVehicleProperties(ownedVehicle, props)

	table.insert(spawnedVehicles, {
		vehicle = ownedVehicle,
		plate = vehicle.plate
	})

	local ped = PlayerPedId()
	esrp_lib.callback.await("vx_garage:vehicleSpawned", false, VehToNet(ownedVehicle))

	functions.createCam()
	SetVehicleHasBeenOwnedByPlayer(ownedVehicle, true)
	TaskWarpPedIntoVehicle(ped, ownedVehicle, -1)
end

local function addToFavorite(vehicle)
	esrp_lib.callback.await("vx_garage:setFavorite", false, vehicle.plate, 1)
end

local function removeFromFavorite(vehicle)
	esrp_lib.callback.await("vx_garage:setFavorite", false, vehicle.plate, 0)
end

local currentGarage = nil
local currentVehicles = {}

---@param garage Garage
local function openGarage(garage)
    currentGarage = garage
    local vehicles = esrp_lib.callback.await("vx_garage:getOwnedVehicles", false, garage.type)
    local existingVehicles = esrp_lib.callback.await("vx_garage:getExistingVehicles", false)
    currentVehicles = vehicles

    local uiVehicles = {}

    local function isExistingVehicle(plate)
        for _, existingVehicle in pairs(existingVehicles) do
            if existingVehicle.plate == plate then
                return true
            end
        end
        return false
    end

    for _, vehicle in pairs(vehicles) do
        local props = json.decode(vehicle.vehicle)
        local model = props.model
        local vehicleName = vehicle.name or GetDisplayNameFromVehicleModel(model) or locale("unknown")
        
        local inGarage = false
        local location = "Kwijt"

        if vehicle.pound == 1 or vehicle.pound == true then
            location = "In Beslag"
            inGarage = false
        elseif isExistingVehicle(vehicle.plate) then
            location = "Buiten"
            inGarage = false
        else
            location = garage.name
            inGarage = true
        end

        table.insert(uiVehicles, {
            id = vehicle.plate,
            name = vehicleName,
            plate = vehicle.plate,
            location = location,
            inGarage = inGarage,
            fuel = 100,
            damage = 0,
            pound = vehicle.pound,
            favorite = vehicle.favorite == 1
        })
    end

    SendNUIMessage({
        action = "showMenu",
        data = {
            show = true,
            vehicle = uiVehicles
        }
    })
    SetNuiFocus(true, true)
    isGarageOpen = true
end

RegisterNUICallback("hide", function(data, cb)
    SetNuiFocus(false, false)
    isGarageOpen = false
    SendNUIMessage({
        action = "showMenu",
        data = {
            show = false
        }
    })
    cb("ok")
end)

RegisterNUICallback("spawnVehicle", function(data, cb)
    local vehicle = nil
    for _, v in pairs(currentVehicles) do
        if v.plate == data.plate then
            vehicle = v
            break
        end
    end

    if vehicle then
        if vehicle.pound == 1 or vehicle.pound == true then
             esrp_lib.notify({type = "error", message = locale("vehicle_impounded")})
        else
            spawnVehicle(currentGarage, vehicle)
            SetNuiFocus(false, false)
            isGarageOpen = false
            SendNUIMessage({
                action = "showMenu",
                data = {
                    show = false
                }
            })
        end
    end
    cb("ok")
end)

RegisterNUICallback("renameVehicle", function(data, cb)
    if data.plate and data.name then
        esrp_lib.callback.await("vx_garage:setVehicleName", false, data.plate, data.name)
        openGarage(currentGarage)
    end
    cb("ok")
end)

RegisterNUICallback("returnVehicle", function(data, cb)
    local vehicle = nil
    for _, v in pairs(currentVehicles) do
        if v.plate == data.plate then
            vehicle = v
            break
        end
    end

    if vehicle then
         local result = esrp_lib.callback.await("vx_garage:returnFromImpound", false, vehicle.plate)
         if result then
            esrp_lib.notify({type = "success", message = locale("returned_vehicle")})
			SetNuiFocus(false, false)
			isGarageOpen = false
			SendNUIMessage({
				action = "showMenu",
				data = {
					show = false
				}
			})
         else
            esrp_lib.notify({type = "error", message = locale("something_went_wrong")})
         end
    end
    cb("ok")
end)


RegisterNUICallback("transferVehicle", function(data, cb)
    esrp_lib.notify({type = "error", message = "Transfer functie nog niet beschikbaar."})
    cb("ok")
end)

RegisterNUICallback("toggleFavorite", function(data, cb)
    if data.plate then
        local favoriteStatus = data.favorite and 1 or 0
        esrp_lib.callback.await("vx_garage:setFavorite", false, data.plate, favoriteStatus)
        openGarage(currentGarage) -- Refresh UI to sync state completely
    end
    cb("ok")
end)

---@param garage Garage
local function createBlip(garage)
	if not garage.blip then
		return
	end

	esrp_lib.addBlipForCoords({
		coords = garage.spawnMarker,
		sprite = garage.blip.id,
		color = garage.blip.color,
		scale = garage.blip.scale,
		text = garage.blip.text,
		shortRange = true
	})
end

---@param garage Garage
local function createSpawnMarker(garage)
	local x, y, z = table.unpack(garage.spawnMarker)
	local marker = lib.marker.new({
		coords = { x = x, y = y, z = z - 0.1 },
		type = "ChevronUpx1",
		color = { r = 0, g = 255, b = 0, a = 200 },
		width = 0.4,
		height = 0.4,
		rotate = true
	})

	local point = lib.points.new({
		coords = vector3(x, y, z),
		distance = 20.0,
	})

	local hasTextUI = false
	function point:nearby()
		marker:draw()

		if self.currentDistance < 1.0 then
			if not hasTextUI and not isGarageOpen then
				esrp_lib.showTextUi(locale("press_to_open_garage"))
				hasTextUI = true
			end

			if IsControlJustPressed(0, 38) then
				openGarage(garage)
			end
		else
			if hasTextUI then
				esrp_lib.hideTextUi()
				hasTextUI = false
			end
		end
	end
end

---@param garage Garage
local function createStoreMarker(garage)
	local x, y, z = table.unpack(garage.storeMarker)
	local marker = lib.marker.new({
		coords = { x = x, y = y, z = z - 0.1 },
		type = "ChevronUpx1",
		color = { r = 255, g = 0, b = 0, a = 255 },
		width = 0.5,
		height = 0.5,
		rotate = true
	})

	local point = lib.points.new({
		coords = vector3(x, y, z),
		distance = 20.0,
	})

	local hasTextUI = false
	function point:nearby()
		if not isPlayerInVehicle then
			return
		end

		marker:draw()

		if self.currentDistance < 2.5 then
			if not hasTextUI then
				esrp_lib.showTextUi(locale("press_to_return_vehicle"))
				hasTextUI = true
			end

			if IsControlJustPressed(0, 38) then
				local ped = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(ped, false)
				local driver = GetPedInVehicleSeat(vehicle, -1)

				if driver and driver == ped then
					local plate = GetVehicleNumberPlateText(vehicle)
					local props = esrp_lib.getVehicleProperties(vehicle)
					local success = esrp_lib.callback.await("vx_garage:storeVehicle", false, garage, props, plate)
					if not success then
						esrp_lib.notify({
							type = "error",
							title = locale("error"),
							message = locale("not_your_vehicle")
						})

						return
					end

					isPlayerInVehicle = false
					-- TaskLeaveVehicle(ped, vehicle, 0)
					esrp_lib.hideTextUi()

					-- Wait(1000)
					DeleteEntity(vehicle)

					esrp_lib.callback("vx_garage:storedVehicle", false, function() end, plate)
				else
					esrp_lib.notify({
						type = "error",
						title = locale("error"),
						message = locale("must_be_in_driver_seat")
					})
				end
			end
		else
			if hasTextUI then
				esrp_lib.hideTextUi()
				hasTextUI = false
			end
		end
	end
end

local garages = { Config.carGarages, Config.boatGarages, Config.airplaneGarages }

Citizen.CreateThread(function()
	for _, garageType in pairs(garages) do
		for _, garage in pairs(garageType) do
			createStoreMarker(garage)
			createSpawnMarker(garage)
			createBlip(garage)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local ped         = PlayerPedId()
		isPlayerInVehicle = IsPedInAnyVehicle(ped, false)

		Citizen.Wait(1000)
	end
end)
