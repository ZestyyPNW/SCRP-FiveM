-- Server-side inventory management
local Inventories = {}
local Items = {}
local DroppedItems = {}

-- Load items from JSON
CreateThread(function()
    local itemsJson = LoadResourceFile(GetCurrentResourceName(), 'items.json')
    if itemsJson then
        Items = json.decode(itemsJson)
        print(('[nd_inventory] Loaded %s items'):format(#Items))
    else
        print('[nd_inventory] ERROR: items.json not found!')
    end
end)

-- Get item data by name
local function GetItemData(itemName)
    for _, item in pairs(Items) do
        if item.name == itemName then
            return item
        end
    end
    return nil
end

-- Calculate total weight of inventory
local function CalculateWeight(items)
    local totalWeight = 0
    for _, item in pairs(items) do
        if item and item.weight and item.count then
            totalWeight = totalWeight + (item.weight * item.count)
        end
    end
    return totalWeight
end

-- Create a new inventory
function CreateInventory(id, type, slots, maxWeight, items)
    slots = slots or Config.MaxSlots
    maxWeight = maxWeight or Config.MaxWeight
    items = items or {}

    -- Initialize empty slots
    local inventory = {
        id = id,
        type = type,
        slots = slots,
        maxWeight = maxWeight,
        items = {},
        weight = 0
    }

    -- Fill inventory with empty slots
    for i = 1, slots do
        inventory.items[i] = items[i] or {slot = i}
    end

    inventory.weight = CalculateWeight(inventory.items)

    Inventories[id] = inventory
    return inventory
end

-- Get inventory by ID
function GetInventory(id)
    return Inventories[id]
end

-- Add item to inventory
function AddItem(inventoryId, itemName, count, metadata, targetSlot)
    local inventory = GetInventory(inventoryId)
    if not inventory then
        print(('[nd_inventory] ERROR: Inventory %s not found'):format(inventoryId))
        return false, 'inventory_not_found'
    end

    local itemData = GetItemData(itemName)
    if not itemData then
        print(('[nd_inventory] ERROR: Item %s not found'):format(itemName))
        return false, 'item_not_found'
    end

    count = math.floor(count or 1)
    metadata = metadata or {}

    local itemWeight = (itemData.weight or 0) * count
    if inventory.weight + itemWeight > inventory.maxWeight then
        return false, 'inventory_full_weight'
    end

    -- Determine starting slot (skip weapon slots for non-weapons)
    local startSlot = 1
    if inventory.type == 'player' then
        if itemData.weapon then
            startSlot = 1 -- Weapons start from slot 1
        else
            startSlot = 3 -- Non-weapons skip weapon slots
        end
    end

    -- Try to stack with existing items
    if itemData.stack then
        for i = startSlot, inventory.slots do
            local slot = inventory.items[i]
            if slot and slot.name == itemName then
                -- Check if metadata matches for stacking
                local metadataMatches = true
                if metadata and slot.metadata then
                    for k, v in pairs(metadata) do
                        if slot.metadata[k] ~= v then
                            metadataMatches = false
                            break
                        end
                    end
                end

                if metadataMatches then
                    slot.count = slot.count + count
                    inventory.weight = inventory.weight + itemWeight
                    return true, slot
                end
            end
        end
    end

    -- Find empty slot
    local emptySlot = targetSlot
    if not emptySlot or inventory.items[emptySlot].name then
        for i = startSlot, inventory.slots do
            -- Skip weapon slots for non-weapons
            if inventory.type == 'player' and i <= 2 and not itemData.weapon then
                goto continue
            end

            if not inventory.items[i].name then
                emptySlot = i
                break
            end
            ::continue::
        end
    end

    if not emptySlot then
        return false, 'inventory_full_slots'
    end

    -- Add item to slot
    inventory.items[emptySlot] = {
        slot = emptySlot,
        name = itemName,
        label = itemData.label,
        count = count,
        weight = itemData.weight,
        metadata = metadata,
        stack = itemData.stack,
        close = itemData.close,
        description = itemData.description,
        image = itemData.image or itemName
    }

    inventory.weight = inventory.weight + itemWeight

    return true, inventory.items[emptySlot]
end

-- Remove item from inventory
function RemoveItem(inventoryId, slot, count)
    local inventory = GetInventory(inventoryId)
    if not inventory then return false, 'inventory_not_found' end

    local item = inventory.items[slot]
    if not item or not item.name then
        return false, 'slot_empty'
    end

    count = count or item.count

    if count >= item.count then
        -- Remove entire stack
        local removedItem = item
        inventory.items[slot] = {slot = slot}
        inventory.weight = inventory.weight - (removedItem.weight * removedItem.count)
        return true, removedItem
    else
        -- Remove partial stack
        item.count = item.count - count
        inventory.weight = inventory.weight - (item.weight * count)
        return true, {
            name = item.name,
            count = count,
            weight = item.weight,
            metadata = item.metadata
        }
    end
end

-- Move item between slots
function MoveItem(fromInvId, fromSlot, toInvId, toSlot, count)
    local fromInv = GetInventory(fromInvId)
    local toInv = GetInventory(toInvId)

    if not fromInv or not toInv then
        return false, 'inventory_not_found'
    end

    local fromItem = fromInv.items[fromSlot]
    if not fromItem or not fromItem.name then
        return false, 'slot_empty'
    end

    count = count or fromItem.count
    local toItem = toInv.items[toSlot]

    -- Check if moving to same inventory and slot
    if fromInvId == toInvId and fromSlot == toSlot then
        return false, 'same_slot'
    end

    -- Check weapon slot restrictions
    if toInv.type == 'player' and toSlot <= 2 then
        local itemData = GetItemData(fromItem.name)
        if not itemData or not itemData.weapon then
            return false, 'weapon_slot_only'
        end
    end

    -- If target slot is empty, move item
    if not toItem.name then
        local success, removed = RemoveItem(fromInvId, fromSlot, count)
        if not success then return false, removed end

        local addSuccess, added = AddItem(toInvId, removed.name, removed.count, removed.metadata, toSlot)
        if not addSuccess then
            -- Revert removal
            AddItem(fromInvId, removed.name, removed.count, removed.metadata, fromSlot)
            return false, added
        end

        return true, {from = fromSlot, to = toSlot}
    end

    -- If target slot has same item, try stacking
    if toItem.name == fromItem.name and fromItem.stack then
        local metadataMatches = true
        if fromItem.metadata and toItem.metadata then
            for k, v in pairs(fromItem.metadata) do
                if toItem.metadata[k] ~= v then
                    metadataMatches = false
                    break
                end
            end
        end

        if metadataMatches then
            local success, removed = RemoveItem(fromInvId, fromSlot, count)
            if not success then return false, removed end

            toItem.count = toItem.count + removed.count
            toInv.weight = toInv.weight + (removed.weight * removed.count)
            return true, {from = fromSlot, to = toSlot, stacked = true}
        end
    end

    -- Swap items
    local tempItem = table.clone(fromItem)
    fromInv.items[fromSlot] = table.clone(toItem)
    fromInv.items[fromSlot].slot = fromSlot
    toInv.items[toSlot] = tempItem
    toInv.items[toSlot].slot = toSlot

    return true, {from = fromSlot, to = toSlot, swapped = true}
end

-- Save player inventory to database
function SavePlayerInventory(source)
    local player = NDCore.Functions.GetPlayer(source)
    if not player then return end

    local inventory = GetInventory('player:' .. source)
    if not inventory then return end

    local inventoryData = json.encode(inventory.items)

    MySQL.Async.execute('UPDATE characters SET inventory = @inventory WHERE character_id = @id', {
        ['@inventory'] = inventoryData,
        ['@id'] = player.character.id
    })
end

-- Load player inventory from database
function LoadPlayerInventory(source)
    local player = NDCore.Functions.GetPlayer(source)
    if not player then return end

    local result = MySQL.Sync.fetchAll('SELECT inventory FROM characters WHERE character_id = @id', {
        ['@id'] = player.character.id
    })

    local items = {}
    if result[1] and result[1].inventory then
        items = json.decode(result[1].inventory) or {}
    end

    local inventory = CreateInventory('player:' .. source, 'player', Config.MaxSlots, Config.MaxWeight, items)

    return inventory
end

-- Exports
exports('CreateInventory', CreateInventory)
exports('GetInventory', GetInventory)
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('MoveItem', MoveItem)
exports('GetItemData', GetItemData)

-- Event Handlers
RegisterNetEvent('nd_inventory:server:loadInventory', function()
    local src = source
    LoadPlayerInventory(src)
end)

RegisterNetEvent('nd_inventory:server:moveItem', function(fromInvId, fromSlot, toInvId, toSlot, count)
    local src = source
    local success, result = MoveItem(fromInvId, fromSlot, toInvId, toSlot, count)

    if success then
        -- Sync with client
        TriggerClientEvent('nd_inventory:client:refreshInventory', src, GetInventory(fromInvId))
        if fromInvId ~= toInvId then
            TriggerClientEvent('nd_inventory:client:refreshInventory', src, GetInventory(toInvId))
        end
    else
        TriggerClientEvent('nd_inventory:client:notify', src, 'error', result)
    end
end)

-- Player disconnect - save inventory
AddEventHandler('playerDropped', function()
    local src = source
    SavePlayerInventory(src)

    -- Remove inventory from memory
    Inventories['player:' .. src] = nil
end)

-- Periodic save
CreateThread(function()
    while true do
        Wait(300000) -- Save every 5 minutes
        for playerId, _ in pairs(Inventories) do
            if playerId:match('^player:') then
                local src = tonumber(playerId:match('%d+'))
                if src then
                    SavePlayerInventory(src)
                end
            end
        end
    end
end)

print('[nd_inventory] Server initialized')
