if ESX.GetConfig().OxInventory then
	local warnedMissingExport = false

	local function registerAddonStashes()
		if GetResourceState('ox_inventory') ~= 'started' then
			return false
		end

		local ok, stashes = pcall(MySQL.query.await, 'SELECT * FROM addon_inventory')

		if not ok then
			print(('[esx_addoninventory] addon_inventory query failed: %s'):format(stashes))
			return false
		end

		if type(stashes) ~= 'table' then
			print('[esx_addoninventory] addon_inventory query returned no rows')
			return false
		end

		for i = 1, #stashes do
			local stash = stashes[i]

			if type(stash) == 'table' and type(stash.name) == 'string' then
				local jobStash = stash.name:find('society', 1, true) and string.sub(stash.name, 9)
				local success, err = pcall(function()
					exports.ox_inventory:RegisterStash(stash.name, stash.label, 100, 200000, stash.shared == 0 and true or false, jobStash)
				end)

				if not success then
					local message = tostring(err)

					if message:find('No such export', 1, true) then
						if not warnedMissingExport then
							warnedMissingExport = true
							print('^3[esx_addoninventory]^7 ox_inventory heeft geen export RegisterStash. De resource is niet klaar of is gestopt door een eerdere fout (vaak ox_lib). Startvolgorde: oxmysql, ox_lib, es_extended, ox_inventory, esx_addoninventory. Zet ook: setr inventory:framework "esx"')
						end

						return false
					end

					print(('[esx_addoninventory] RegisterStash failed for %s: %s'):format(stash.name, message))
				end
			end
		end

		warnedMissingExport = false
		return true
	end

	AddEventHandler('onServerResourceStart', function(resourceName)
		if resourceName ~= 'ox_inventory' and resourceName ~= GetCurrentResourceName() then
			return
		end

		if GetResourceState('ox_inventory') == 'started' then
			registerAddonStashes()
			return
		end

		CreateThread(function()
			local timeout = GetGameTimer() + 15000

			while GetResourceState('ox_inventory') ~= 'started' and GetGameTimer() < timeout do
				Wait(200)
			end

			if GetResourceState('ox_inventory') ~= 'started' then
				if not warnedMissingExport then
					warnedMissingExport = true
					print('^3[esx_addoninventory]^7 ox_inventory is niet gestart, dus RegisterStash is overgeslagen. Startvolgorde: oxmysql, ox_lib, es_extended, ox_inventory, esx_addoninventory.')
				end

				return
			end

			registerAddonStashes()
		end)
	end)

	return
end

Items = {}
local InventoriesIndex, Inventories, SharedInventories = {}, {}, {}

MySQL.ready(function()
	local items = MySQL.query.await('SELECT * FROM items')

	for i=1, #items, 1 do
		Items[items[i].name] = items[i].label
	end

	local result = MySQL.query.await('SELECT * FROM addon_inventory')

	for i=1, #result, 1 do
		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.query.await('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name', {
			['@inventory_name'] = name
		})

		if shared == 0 then

			table.insert(InventoriesIndex, name)

			Inventories[name] = {}
			local items       = {}

			for j=1, #result2, 1 do
				local itemName  = result2[j].name
				local itemCount = result2[j].count
				local itemOwner = result2[j].owner

				if items[itemOwner] == nil then
					items[itemOwner] = {}
				end

				table.insert(items[itemOwner], {
					name  = itemName,
					count = itemCount,
					label = Items[itemName]
				})
			end

			for k,v in pairs(items) do
				local addonInventory = CreateAddonInventory(name, k, v)
				table.insert(Inventories[name], addonInventory)
			end

		else
			local items = {}

			for j=1, #result2, 1 do
				table.insert(items, {
					name  = result2[j].name,
					count = result2[j].count,
					label = Items[result2[j].name]
				})
			end

			local addonInventory    = CreateAddonInventory(name, nil, items)
			SharedInventories[name] = addonInventory
			GlobalState.SharedInventories = SharedInventories
		end
	end
end)

function GetInventory(name, owner)
	for i=1, #Inventories[name], 1 do
		if Inventories[name][i].owner == owner then
			return Inventories[name][i]
		end
	end
end

function GetSharedInventory(name)
	return SharedInventories[name]
end

function AddSharedInventory(society)
    if type(society) ~= 'table' or not society?.name or not society?.label then return end
    -- society (array) containing name (string) and label (string)

    -- addon inventory:
    MySQL.Async.execute('INSERT INTO addon_inventory (name, label, shared) VALUES (@name, @label, @shared)', {
        ['name'] = society.name,
        ['label'] = society.label,
        ['shared'] = 1
    })

    SharedInventories[society.name] = CreateAddonInventory(society.name, nil, {})
end

AddEventHandler('esx_addoninventory:getInventory', function(name, owner, cb)
	cb(GetInventory(name, owner))
end)

AddEventHandler('esx_addoninventory:getSharedInventory', function(name, cb)
	cb(GetSharedInventory(name))
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	local addonInventories = {}

	for i=1, #InventoriesIndex, 1 do
		local name      = InventoriesIndex[i]
		local inventory = GetInventory(name, xPlayer.identifier)

		if inventory == nil then
			inventory = CreateAddonInventory(name, xPlayer.identifier, {})
			table.insert(Inventories[name], inventory)
		end

		table.insert(addonInventories, inventory)
	end

	xPlayer.set('addonInventories', addonInventories)
end)
