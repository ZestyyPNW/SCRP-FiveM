-- Admin/Test Commands

-- Give item command
RegisterCommand('giveitem', function(source, args)
    if source == 0 then return end -- Console only

    local itemName = args[1]
    local count = tonumber(args[2]) or 1

    if not itemName then
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', 'Usage: /giveitem [item] [count]')
        return
    end

    local inventoryId = 'player:' .. source
    local success, result = AddItem(inventoryId, itemName, count)

    if success then
        TriggerClientEvent('nd_inventory:client:notify', source, 'success', ('Added %dx %s'):format(count, itemName))
        TriggerClientEvent('nd_inventory:client:refreshInventory', source, GetInventory(inventoryId))
    else
        TriggerClientEvent('nd_inventory:client:notify', source, 'error', result)
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
