ESX.RegisterCommand('ps-adminmenu', {'mod', 'admin', 'superadmin'}, function(xPlayer, _, _)
    TriggerClientEvent('ps-adminmenu:client:OpenUI', xPlayer.source)
end, false, {help = 'Open the admin menu'})
