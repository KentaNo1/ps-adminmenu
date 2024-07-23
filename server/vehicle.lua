-- Admin Car
RegisterNetEvent('ps-adminmenu:server:SaveCar', function(vehicle)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local plate = vehicle.plate
    local result = MySQL.query.await('SELECT `plate` FROM `owned_vehicles` WHERE plate = ?', { plate })

    if result[1] == nil then
        MySQL.prepare(
        'INSERT INTO `owned_vehicles` (`owner`, `vehicle`, `plate`, `stored`) VALUES (?, ?, ?, ?)',
            {
                Player.identifier,
                json.encode(vehicle),
                plate,
                0
            })
        TriggerClientEvent('esx:showNotification', src, _U("veh_owner"), 'success', 5000)
    else
        TriggerClientEvent('esx:showNotification', src, _U("u_veh_owner"), 'error', 3000)
    end
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:givecar", function(data, selectedData)
    local src = source

    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then
        TriggerClientEvent('esx:showNotification', src, _U("no_perms"), "error", 5000)
        return
    end

    local plate = selectedData['Plate (Optional)'].value or ('KENTA'..math.random(100, 999))
    local vehmodel = selectedData['Vehicle'].value
    local vehicleData = lib.callback.await("ps-adminmenu:client:getvehData", src, vehmodel, plate)

    if not vehicleData then
        return
    end

    local tsrc = selectedData['Player'].value
    local garage = selectedData['Garage (Optional)'] and selectedData['Garage (Optional)'].value or Config.DefaultGarage
    local Player = ESX.GetPlayerFromId(tsrc)

    if garage and #garage < 1 then
        garage = Config.DefaultGarage
    end

    if plate:len() > 8 then
        TriggerClientEvent('esx:showNotification', src, _U("plate_max"), "error", 5000)
        return
    end

    if not Player then
        TriggerClientEvent('esx:showNotification', src, _U("not_online"), "error", 5000)
        return
    end

    if CheckAlreadyPlate(plate) then
        TriggerClientEvent('esx:showNotification', src, _U("already_plate", plate:upper()), "error", 5000)
        return
    end

    MySQL.prepare('INSERT INTO `owned_vehicles` (`owner`, `vehicle`, `garage`, `plate`, `stored`) VALUES (?, ?, ?, ?, ?)',
        {
            Player.identifier,
            json.encode(vehicleData),
            garage,
            plate,
            1
        })

        TriggerClientEvent('esx:showNotification', src, _U("givecar.success.source", vehmodel, Player.getName()), "success", 5000)
        TriggerClientEvent('esx:showNotification', Player.source, _U("givecar.success.target", plate:upper(), garage), "success", 5000)
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:SetVehicleState", function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then
        TriggerClientEvent('esx:showNotification', src, _U("no_perms"), "error", 5000)
        return
    end

    local plate = string.upper(selectedData['Plate'].value)
    local state = tonumber(selectedData['State'].value)

    if plate:len() > 8 then
        TriggerClientEvent('esx:showNotification', src, _U("plate_max"), "error", 5000)
        return
    end

    if not CheckAlreadyPlate(plate) then
        TriggerClientEvent('esx:showNotification', src, _U("plate_doesnt_exist"), "error", 5000)
        return
    end

    MySQL.update('UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?', {state, plate})

    TriggerClientEvent('esx:showNotification', src, _U("state_changed"), "success", 5000)
end)

RegisterNetEvent("ps-adminmenu:server:DeleteObj", function(netId)
    local obj = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(obj)
end)

-- Change Plate
RegisterNetEvent('ps-adminmenu:server:ChangePlate', function(newPlate, currentPlate)
    local newPlate = newPlate:upper()

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:UpdateVehicle(currentPlate, newPlate)
    end

    MySQL.update('UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ?', { newPlate, currentPlate })
    --MySQL.update('UPDATE trunkitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    --MySQL.update('UPDATE gloveboxitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
end)

lib.callback.register('ps-adminmenu:server:GetVehicleByPlate', function(_, plate)
    local result = MySQL.query.await('SELECT `vehicle` FROM `owned_vehicles` WHERE `plate` = ?', { plate })
    local veh = result[1] and json.decode(result[1].vehicle) or {}
    return veh
end)

lib.callback.register('ps-adminmenu:callback:GetVehicles', function()
    local result = MySQL.query.await('SELECT * FROM `vehicles`')
    return result
end)

-- Fix Vehicle for player
RegisterNetEvent('ps-adminmenu:server:FixVehFor', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local src = source
    local playerId = selectedData['Player'].value
    local Player = ESX.GetPlayerFromId(tonumber(playerId))
    local name = Player.getName()
    if Player then
        TriggerClientEvent('ps-adminmenu:client:fixEverything', Player.source)
        TriggerClientEvent('esx:showNotification', src, _U("veh_fixed", name), 'success', 7500)
    else
        TriggerClientEvent('esx:showNotification', src, _U("not_online"), "error")
    end
end)

-- Delete vehicles
RegisterNetEvent('ps-adminmenu:server:DeleteRadiusVehicles', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local src = source
    if not selectedData['Radius'] then return TriggerClientEvent('esx:showNotification', src, "Nem írtál be számot", "error") end
    local c1 = GetEntityCoords(GetPlayerPed(src))
    local v = GetAllVehicles()
    local c2 = tonumber(selectedData['Radius'].value)
    local d = 0
    for i=1, #v do
        if #(GetEntityCoords(v[i]) - c1) < c2 then
            DeleteEntity(v[i])
            d += 1
        end
    end
    TriggerClientEvent('esx:showNotification', src,  _U( "veh_deleted", d), 'success', 7500)
end)

-- Delete peds
RegisterNetEvent('ps-adminmenu:server:DeleteRadiusPeds', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local src = source
    if not selectedData['Radius'] then return TriggerClientEvent('esx:showNotification', src, "Nem írtál be számot", "error") end
    local c1 = GetEntityCoords(GetPlayerPed(src))
    local v = GetAllPeds()
    local c2 = tonumber(selectedData['Radius'].value)
    local d = 0
    for i=1, #v do
        if #(GetEntityCoords(v[i]) - c1) < c2 then
            DeleteEntity(v[i])
            d += 1
        end
    end
    TriggerClientEvent('esx:showNotification', src,  _U( "ped_deleted", d), 'success', 7500)
end)

-- Delete objects
RegisterNetEvent('ps-adminmenu:server:DeleteRadiusObjects', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local src = source
    if not selectedData['Radius'] then return TriggerClientEvent('esx:showNotification', src, "Nem írtál be számot", "error") end
    local c1 = GetEntityCoords(GetPlayerPed(src))
    local v = GetAllObjects()
    local c2 = tonumber(selectedData['Radius'].value)
    local d = 0
    for i=1, #v do
        if #(GetEntityCoords(v[i]) - c1) < c2 then
            DeleteEntity(v[i])
            d += 1
        end
    end
    TriggerClientEvent('esx:showNotification', src,  _U( "object_deleted", d), 'success', 7500)
end)

-- Delete all objects
RegisterNetEvent('ps-adminmenu:server:DeleteAllObjects', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local src = source
    local v = GetAllObjects()
    local d = 0
    for i=1, #v do
        DeleteEntity(v[i])
        d += 1
    end
    TriggerClientEvent('esx:showNotification', src,  _U( "object_deleted", d), 'success', 7500)
    TriggerClientEvent('ps-adminmenu:client:DeleteAllObjects', -1)
end)
