-- Clear Inventory
RegisterNetEvent('ps-adminmenu:server:ClearInventory', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local Player = ESX.GetPlayerFromId(player)

    if not Player then
        return TriggerClientEvent('esx:showNotification', src, _U("not_online"), 'error', 7500)
    end

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(player)
        TriggerClientEvent('esx:showNotification', src,
        _U("invcleared", Player.getName()),
        'success', 7500)
    else
        --exports[Config.Inventory]:ClearInventory(player, nil)
    end

    TriggerClientEvent('esx:showNotification', src,
        _U("invcleared", Player.getName()),
        'success', 7500)
end)

-- Clear Inventory Offline
RegisterNetEvent('ps-adminmenu:server:ClearInventoryOffline', function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local citizenId = selectedData["Citizen ID"].value
    local Player = ESX.GetPlayerFromId(citizenId)

    if Player then
        if Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:ClearInventory(Player.source)
        else
            --exports[Config.Inventory]:ClearInventory(Player.PlayerData.source, nil)
        end
        TriggerClientEvent('esx:showNotification', src,
            _U("invcleared", Player.getName()),
            'success', 7500)
    else
        MySQL.query("SELECT 1 FROM `users` WHERE `citizenid` = ?", {citizenId},
            function(result)
                if result and result[1] then
                    MySQL.update("UPDATE users SET inventory = '{}' WHERE citizenid = ?", {citizenId})
                    TriggerClientEvent('esx:showNotification', src, "Player's inventory cleared", 'success', 7500)
                else
                    TriggerClientEvent('esx:showNotification', src, _U("player_not_found"), 'error', 7500)
                end
            end)
    end
end)

-- Open Inv [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenInv', function(data)
    TriggerClientEvent("ps-adminmenu:client:CloseUI", source)
    exports.ox_inventory:forceOpenInventory(source, 'player', data)
end)

-- Open Stash [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenStash', function(data)
    TriggerClientEvent("ps-adminmenu:client:CloseUI", source)
    exports.ox_inventory:forceOpenInventory(source, 'stash', tostring(data))
end)

-- Open Trunk [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenTrunk', function(data)
    TriggerClientEvent("ps-adminmenu:client:CloseUI", source)
    exports.ox_inventory:forceOpenInventory(source, 'trunk', tostring(data))
end)

-- Add Item
RegisterNetEvent('ps-adminmenu:server:AddItem', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local name = selectedData["Name"].value
    local label = selectedData["Label"].value
    local weight = selectedData["Weight"].value

    MySQL.insert('INSERT INTO `items` (`name`, `label`, `weight`) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)', {name, label, weight})
end)

-- Delete Item
RegisterNetEvent('ps-adminmenu:server:DeleteItem', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    if not selectedData["Item"] then return end

    local item = selectedData["Item"].value

    MySQL.update('DELETE FROM `items` WHERE `name` = ?', {item})
end)

-- Give Item
RegisterNetEvent('ps-adminmenu:server:GiveItem', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    if not selectedData["Player"] or not selectedData["Item"] or not selectedData["Amount"] then return end

    local target = selectedData["Player"].value
    local item = selectedData["Item"].value
    local amount = selectedData["Amount"].value
    local Player = ESX.GetPlayerFromId(target)

    if not Player then
        return TriggerClientEvent('esx:showNotification', source, _U("not_online"), 'error', 7500)
    end

    Player.addInventoryItem(item or "money", amount or 1)
    TriggerClientEvent('esx:showNotification', source,
        _U("give_item", tonumber(amount) .. " " .. item,
            Player.getName()), "success", 7500)
end)

-- Give Item to All
RegisterNetEvent('ps-adminmenu:server:GiveItemAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local item = selectedData["Item"].value or 'money'
    local amount = selectedData["Amount"].value or 1

    local players = ESX.GetExtendedPlayers()

    for _, id in pairs(players) do
        id.addInventoryItem(item, amount)
    end
    TriggerClientEvent('esx:showNotification', source, _U("give_item_all", amount .. " " .. item), "success", 7500)
end)
