functions = {}

function functions.getVehicleByPlate(plate)
    local result = MySQL.query.await("SELECT * FROM owned_vehicles WHERE `plate` = @plate", {
        ["@plate"] = plate
    })
    local vehicle = result[1]
    return vehicle
end
