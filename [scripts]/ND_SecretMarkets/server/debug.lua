-- Debug commands for quest testing

RegisterCommand('giveevidencebags', function(source, args)
    local src = source
    local amount = tonumber(args[1]) or 3

    local success = pcall(function()
        exports.ox_inventory:AddItem(src, 'evidence_bag', amount)
    end)

    if not success then
        print('[ND_SecretMarkets] Failed to add evidence bags - ox_inventory not ready')
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = 'Added ' .. amount .. ' evidence bags to inventory'
    })
end, false)

RegisterCommand('questdebug', function(source, args)
    local src = source

    print('=== Active Quests Debug ===')
    print('Server player quests:', json.encode(playerQuests[src] or {}, {indent = true}))

    TriggerClientEvent('ND_SecretMarkets:debugQuests', src)
end, false)

-- Client debug event
RegisterNetEvent('ND_SecretMarkets:debugQuests')
AddEventHandler('ND_SecretMarkets:debugQuests', function()
    print('=== Client Active Quests ===')
    print(json.encode(activeQuests, {indent = true}))
end)