local function getPlayerFromDialog()
	local input = lib.inputDialog("Vul de speler in, Kan ID of Identifier zijn", {
		{
			label = "Speler ID/Identifier",
			type = "input"
		},
		{
			label = "Ik aanvaard dat alles wat ik in dit menu doe word gelogged naar de beheerders van deze stad",
			type = "checkbox",
			checked = true
		}
	}, { allowCancel = true })

	if not input then return end

	if input[2] == false then
		vx.notify({
			message = "Je ging niet akkoord met de voorwaarden",
			type = "error"
		})
		return
	end

	return serverCallbackProxy.getPlayerFromInput(input)
end

---@param title string
---@param description string
---@param callback any
local function showConfirmationMenu(title, description, callback)
	local menu = vx.registerContextMenu({
		id = "vx_property_purchase_confirmation",
		title = title,
		options = {
			{
				title = "Ja",
				description = description,
				onSelect = callback
			},
			{
				title = "Nee",
				onSelect = function() end
			}
		}
	})

	vx.openContextMenu(menu)
end

RegisterNetEvent('vx_staffassist:openmenu')
AddEventHandler('vx_staffassist:openmenu', function(source, group)
	lib.registerContext({
		id = "vx_staffassist_menu",
		title = "Staff Assist",
		options = {
			{
				title = "Beheer speler",
				arrow = true,
				icon = "fa-solid fa-user",
				onSelect = (function()
					local player = getPlayerFromDialog()
					if player ~= nil then OpenPlayerMenu(player) end
				end)
			},
			{
				title = "Haal speler van de blacklist",
				arrow = true,
				icon = "fa-solid fa-list",
				onSelect = (function()
					OpenWhitelistMenu()
				end)
			},
			{
				title = "Open prullenmand",
				arrow = true,
				icon = "fa-solid fa-trash",
				onSelect = (function()
					local trashStashId = serverCallbackProxy.OpenTrashCan()
					if trashStashId == nil then return end
					exports.ox_inventory:openInventory('stash', trashStashId)
				end)
			}
		},

	})

	lib.showContext("vx_staffassist_menu")
end)

---@param player SrpPlayer
function OpenPlayerMenu(player)
	local comserveResource = serverCallbackProxy.doesComserveResourceExist()

	local options = ({
		{
			title = "Open inventory",
			arrow = true,
			disabled = false,
			onSelect = function()
				serverCallbackProxy.OpenPlayerInventory(player)
			end
		},
		{
			title = "Open garage",
			arrow = true,
			disabled = false,
			onSelect = function()
				OpenVehicleMenu(player)
			end
		},
		{
			title = "Open appartementen",
			arrow = true,
			disabled = false,
			onSelect = function()
				OpenAppartmentsMenu(player)
			end
		},
		{
			title = "Open loodsen",
			arrow = true,
			disabled = false,
			onSelect = function()
				OpenLoodsenMenu(player)
			end
		},
		{
			title = "Zet op blacklist",
			arrow = true,
			onSelect = function()
				OpenBlacklistMenu(player)
			end
		},
		{
			title = "Verwijder account",
			arrow = true,
			onSelect = function()
				showConfirmationMenu(
					"Account Verwijderen",
					"Weet je zeker dat je dit account wilt verwijderen (Dit kan niet terug worden veranderd!)",
					function()
						serverCallbackProxy.WipePlayerData(player)
					end)
			end
		},
		{
			title = "Transfer account",
			arrow = true,
			disabled = not player.isOnline,
			onSelect = function()
				local dialog = lib.inputDialog("Identifier van de speler zijn oude account",
					{
						{
							label = "Oude speler zijn identifier",
							type = "input"
						}
					})

				if not dialog or dialog[1] == nil then
					return
				end

				showConfirmationMenu(
					"Account overzetten",
					"Deze actie kan niet terug worden gedraaid, zodra je akkoord gaat word (bijna) alle data van de speler overgezet!",
					function()
						serverCallbackProxy.TransferAccount(player, tostring(dialog[1]))
					end)
			end
		}
	})

    options[#options+1] = {
        title = "Stuur speler op taken",
        arrow = true,
        disabled = not player.isOnline,
        onSelect = function()
            OpenComserveMenu(player)
        end
    }

	lib.registerContext({
		id = "vx_staffassist_menu_manage:" .. player.identifier,
		title = "Assisting " .. player.name,
		options = options

	})

	lib.showContext("vx_staffassist_menu_manage:" .. player.identifier)
end

---@param user SrpPlayer
function OpenVehicleMenu(user)
	local vehicles = serverCallbackProxy.GetVehiclesFromPlayerIdentifier(user)

	---@type ContextMenuItem
	local data = {
		{
			title = "Ga terug",
			arrow = true,
			onSelect = (function() OpenPlayerMenu(user) end)
		}
	}

	if vehicles ~= nil then
		for _, v in pairs(vehicles) do
			local type = v.type == "car" and "fa-car"
					or v.type == "airplane" and "fa-plane"
					or v.type == "boat" and "fa-ship"
					or v.type == "helicopter" and "fa-helicopter" or "fa-car"

			lib.registerContext({
				title = string.format("Voertuig %s (%s)", v.name, v.plate),
				id = "vx_staffassist_voertuig:selectType:" .. v.plate,
				options = {
					{
						title = "Ga terug",
						arrow = true,
						onSelect = (function() OpenVehicleMenu(user) end)
					},
					{
						title = "Open kofferbak",
						icon = "fa-solid fa-box",
						disabled = not v.hasTrunk,
						onSelect = function() serverCallbackProxy.OpenVehicleInventory(user, v.plate, "trunk") end
					},
					{
						title = "Open dashboard",
						icon = "fa-solid fa-box",
						disabled = not v.hasGlovebox,
						onSelect = function() serverCallbackProxy.OpenVehicleInventory(user, v.plate, "glove") end
					},
					{
						title = "Verander naam",
						icon = "fa-solid fa-pencil",
						onSelect = function()
							local dialog = lib.inputDialog("Verander naam", {
								{
									label = "Naam",
									type = "input"
								}
							})

							if dialog and dialog[1] ~= nil then
								serverCallbackProxy.RenameVehicleInGarage(user, v.plate, dialog[1])
							end
						end
					},
					{
						title = "Verander Kenteken",
						icon = "fa-solid fa-pencil",
						onSelect = function()
							local dialog = lib.inputDialog("Verander Kenteken", {
								{
									label = "Kenteken",
									type = "input"
								}
							})

							if dialog and dialog[1] ~= nil then
								serverCallbackProxy.RenamePlateInGarage(user, v.plate, dialog[1])
							end
						end
					},
					{
						title = "Verwijder voertuig",
						icon = "fa-solid fa-trash",
						onSelect = function()
							showConfirmationMenu("Voertuig verwijderen",
								"Weet je het heel zeker dat je dit voertuig wilt verwijderen? (Deze actie kan niet worden teruggedraaid)",
								function()
									serverCallbackProxy.RemoveVehicleFromGarage(user, v.plate)
								end)
						end
					},
				}
			})

			table.insert(data, {
				title = v.name == "Voertuig" and GetDisplayNameFromVehicleModel(v.hash) or v.name,
				arrow = true,
				icon = "fa-solid " .. type,
				description = "Kenteken " .. v.plate,
				menu = "vx_staffassist_voertuig:selectType:" .. v.plate
			})
		end
	else
		table.insert(data, {
			title = "Geen voertuigen gevonden",
			disabled = true
		})
	end

	lib.registerContext({
		id = "vx_staffassist_voertuig:" .. user.identifier,
		title = "Voertuigen",
		options = data
	})

	lib.showContext("vx_staffassist_voertuig:" .. user.identifier)
end

---@param user SrpPlayer
function OpenAppartmentsMenu(user)
	local properties = serverCallbackProxy.GetPropertiesFromPlayerIdentifier(user)

	---@type ContextMenuItem
	local data = {
		{
			title = "Ga terug",
			arrow = true,
			onSelect = (function() OpenPlayerMenu(user) end)
		}
	}

	if properties ~= nil then
		for _, p in pairs(properties) do
			table.insert(data, {
				title = p.name,
				icon = "fa-solid fa-house",
				arrow = true,
				onSelect = function() serverCallbackProxy.OpenPropertyInventory(user, p.id) end
			})
		end
	else
		table.insert(data, {
			title = "Geen appartmenten gevonden",
			disabled = true
		})
	end

	lib.registerContext({
		id = "vx_staffassist_property:" .. user.identifier,
		title = "Appartmenten",
		options = data
	})

	lib.showContext("vx_staffassist_property:" .. user.identifier)
end

---@param user SrpPlayer
function OpenLoodsenMenu(user)
	local properties = serverCallbackProxy.GetLoodsenFromPlayerIdentifier(user)

	---@type ContextMenuItem
	local data = {
		{
			title = "Ga terug",
			arrow = true,
			onSelect = (function() OpenPlayerMenu(user) end)
		}
	}

	if properties ~= nil then
		for _, p in pairs(properties) do
			table.insert(data, {
				title = p.property,
				icon = "fa-solid fa-warehouse",
				arrow = true,
				onSelect = function() serverCallbackProxy.OpenLoodsInventory(user, p.id) end
			})
		end
	else
		table.insert(data, {
			title = "Geen loodsen gevonden",
			disabled = true
		})
	end

	lib.registerContext({
		id = "vx_staffassist_loods:" .. user.identifier,
		title = "Loodsen",
		options = data
	})

	lib.showContext("vx_staffassist_loods:" .. user.identifier)
end

---@param user SrpPlayer
function OpenComserveMenu(user)
	local data = {
		{
			title = "Ga terug",
			arrow = true,
			onSelect = (function() OpenPlayerMenu(user) end)
		}
	}

	for _, serv in pairs(Config.ComserveJobs) do
		table.insert(data, {
			title = serv.reason,
			description = "Stuur speler op " .. serv.count .. " taken",
			onSelect = function() serverCallbackProxy.ComservePlayer(user, serv) end
		})
	end

	lib.registerContext({
		id = "vx_staffassist_comserv",
		title = "Taken",
		options = data
	})

	lib.showContext("vx_staffassist_comserv")
end

---@param user SrpPlayer
function OpenBlacklistMenu(user)
	local dialog = lib.inputDialog("Op de blacklist!",
		{
			{ label = "Reden:",       type = "input",   default = "Maak een ticket voor meer uitleg" },
			{ label = "Zeker weten?", type = "checkbox" }
		})

	if not dialog then
		return
	end

	serverCallbackProxy.BlacklistPlayer(user, dialog[1])
end

function OpenWhitelistMenu()
	local dialog = lib.inputDialog("Haal speler van de blacklist af", {
		{ label = "Blacklist ID", type = "input" },
		{ label = "Zeker weten?", type = "checkbox" }
	})
	if not dialog then return end
	serverCallbackProxy.WhitelistPlayer(dialog[1])
end
