local function requestVehicleModel(model)
   local hash = type(model) == "number" and model or joaat(model)

   if HasModelLoaded(hash) then
      return hash
   end

   RequestModel(hash)

   local expires = GetGameTimer() + 5000
   while not HasModelLoaded(hash) do
      if GetGameTimer() > expires then
         return nil
      end

      Wait(0)
   end

   return hash
end

function clientCallbacks.getVehicleProperties(first, second, third)
   -- Bridge may pass (model, plate) or (extra, model, plate).
   local model = third and second or first
   local plate = third or second
   local hash = requestVehicleModel(model)

   if not hash then
      return nil
   end

   local coords = GetEntityCoords(vx.cache.ped)
   local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z - 10.0, 0.0, false, false)
   local expires = GetGameTimer() + 3000

   while not DoesEntityExist(vehicle) and GetGameTimer() < expires do
      Wait(0)
   end

   if not DoesEntityExist(vehicle) then
      SetModelAsNoLongerNeeded(hash)
      return nil
   end

   if plate then
      SetVehicleNumberPlateText(vehicle, plate)
   end

   local properties = vx.getVehicleProperties(vehicle)
   DeleteEntity(vehicle)
   SetModelAsNoLongerNeeded(hash)

   return properties
end
