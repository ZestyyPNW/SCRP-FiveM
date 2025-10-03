-- Admin/Test Commands

-- Load inventory manually
RegisterCommand('loadinv', function(source, args)
    if source == 0 then return end

    print(('[nd_inventory] Manual load command for player %s'):format(source))
    local inventory = LoadPlayerInventory(source)

    if inventory then
        TriggerClientEvent('nd_inventory:client:refreshInventory', source, inventory)
        TriggerClientEvent('nd_inventory:client:notify', source, 'success', 'Inventory loaded')
        print(('[nd_inventory] Inventory loaded successfully'):format())
    else
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Failed to load inventory')
        print(('[nd_inventory] Failed to load inventory'):format())
    end
end, false)

-- Give item to another player
RegisterCommand('giveitemto', function(source, args)
    if source == 0 then
        print('[nd_inventory] This command can only be used in-game')
        return
    end

    local targetId = tonumber(args[1])
    local itemName = args[2]
    local count = tonumber(args[3]) or 1

    if not targetId or not itemName then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Usage: /giveitemto [playerid] [item] [count]')
        return
    end

    -- Check if target player exists
    local targetPlayer = GetPlayerName(targetId)
    if not targetPlayer then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Player not found')
        return
    end

    local inventoryId = 'player:' .. targetId
    local inventory = GetInventory(inventoryId)

    if not inventory then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Target player inventory not loaded')
        return
    end

    local success, result = AddItem(inventoryId, itemName, count)

    if success then
        TriggerClientEvent('nd_inventory:client:notify', source, 'success', ('Gave %dx %s to %s'):format(count, itemName, targetPlayer))
        TriggerClientEvent('nd_inventory:client:notify', targetId, 'success', ('Received %dx %s'):format(count, itemName))
        TriggerClientEvent('nd_inventory:client:refreshInventory', targetId, GetInventory(inventoryId))
        print(('[nd_inventory] Player %s gave %dx %s to player %s'):format(source, count, itemName, targetId))
    else
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', result)
    end
end, false)

-- Give item command (gives to yourself)
RegisterCommand('giveitem', function(source, args)
    if source == 0 then
        print('[nd_inventory] This command can only be used in-game')
        return
    end

    local itemName = args[1]
    local count = tonumber(args[2]) or 1

    if not itemName then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Usage: /giveitem [item] [count]')
        print('[nd_inventory] Usage: /giveitem [item] [count]')
        return
    end

    local inventoryId = 'player:' .. source
    local inventory = GetInventory(inventoryId)

    if not inventory then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Your inventory is not loaded yet. Try /loadinv first')
        print(('[nd_inventory] Inventory not found for player %s'):format(source))
        return
    end

    local success, result = AddItem(inventoryId, itemName, count)

    if success then
        TriggerClientEvent('nd_inventory:client:notify', source, 'success', ('Added %dx %s to your inventory'):format(count, itemName))
        TriggerClientEvent('nd_inventory:client:refreshInventory', source, GetInventory(inventoryId))
        print(('[nd_inventory] Gave %dx %s to player %s'):format(count, itemName, source))
    else
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', result)
        print(('[nd_inventory] Failed to give item: %s'):format(result))
    end
end, false)

-- Clear inventory command
RegisterCommand('clearinv', function(source, args)
    if source == 0 then return end

    local inventoryId = 'player:' .. source
    local inventory = GetInventory(inventoryId)

    if inventory then
        for i = 1, inventory.slots do
            inventory.items[i] = {slot = i}
        end
        inventory.weight = 0

        TriggerClientEvent('nd_inventory:client:refreshInventory', source, inventory)
        TriggerClientEvent('nd_inventory:client:notify', source, 'success', 'Inventory cleared')
    end
end, false)

print('[nd_inventory] Commands registered')
