function clientCallbacks.getVehicleProperties(_, model, plate)
   local coords = GetEntityCoords(vx.cache.ped)
   local x, y, z = table.unpack(coords)

   local vehicle = vx.createVehicle(model, vector3(x, y, z - 10.0), 0.0)
   if plate then
      SetVehicleNumberPlateText(vehicle, plate)
   end

   local properties = vx.getVehicleProperties(vehicle)
   DeleteEntity(vehicle)

   return properties
end
