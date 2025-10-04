ps.warn('lj inventory is archived and outdated, please use ps-inventory')

function ps.removeItem(identifier, item, amount, slot, reason)
    local Player = ps.getPlayer(identifier)
     if not identifier or not item then return end
    if not amount then amount = 1 end
    if not slot then slot = false end
    if not reason then reason = 'ps_lib Remove Item' end
    return Player.Functions.RemoveItem(item, amount, slot, reason)
end

function ps.addItem(identifier, item, amount, meta, slot, reason)
    local Player = ps.getPlayer(identifier)
    if not identifier or not item then return end
    if not amount then amount = 1 end
    if not slot then slot = false end
    if not reason then reason = 'ps_lib Add Item' end
    return Player.Functions.AddItem(item, amount, slot, meta, reason)
end

function ps.openStash(source, identifier, data)
    if not data.label then data.label = identifier end
    if not data.maxweight then data.maxweight = 100000 end
    if not data.slots then data.slots = 50 end
    TriggerClientEvent('lj-inventory:client:openInventoryBackWards', source, identifier, data)
end

function ps.hasItem(identifier, item, amount)
    if not identifier or not item then return end
    if not amount then amount = 1 end
    local Player = ps.getPlayer(identifier)
    return Player.Functions.GetItemByName(item).amount >= amount
end

function ps.getFreeWeight(identifier)
    if not identifier then return end
    local Player = ps.getPlayer(identifier)
    return Player.Functions.GetFreeWeight()
end

function ps.openInventoryById(source, playerid)
    if not playerid then playerid = false end
    TriggerServerEvent('lj-inventory:server:SearchPlayer', source)
end

function ps.clearInventory(source, identifier)
    if not identifier then return end
    local Player = ps.getPlayer(identifier)
    if Player then
        Player.Functions.ClearInventory()
        TriggerClientEvent('lj-inventory:client:closeInventory', source)
    else
        ps.warn('Player not found for clearing inventory: ' .. identifier)
    end
end

function ps.clearStash(source, identifier)
    if not identifier then return end
    local stash = MySQL.query.await('SELECT * FROM stashitems WHERE stash = ?', {identifier})
    if stash and #stash > 0 then
        MySQL.update.await('UPDATE stashitems SET items = ? WHERE stash = ?', {json.encode({}), identifier})
        TriggerClientEvent('lj-inventory:client:closeInventory', source)
    else
        ps.warn('No stash found for clearing: ' .. identifier)
    end
end

function ps.getItemCount(source, item)
    local Player = ps.getPlayer(source)
    if not Player or not item then return false end
    local itemData = Player.Functions.GetItemByName(item)
    if itemData then
        return itemData.amount
    else
        return 0
    end
end

function ps.getItemByName(source, item)
    local Player = ps.getPlayer(source)
    if not Player or not item then return false end
    local itemData = Player.Functions.GetItemByName(item)
    if itemData then
        return itemData
    else
        return nil
    end
end

function ps.getItemsByNames(source, items)
    local Player = ps.getPlayer(source)
    if not Player or not items or #items == 0 then return {} end
    local itemData = {}
    for _, item in ipairs(items) do
        local itemInfo = Player.Functions.GetItemByName(item)
        if itemInfo then
            itemData[item] = itemInfo
        end
    end
    return itemData
end

function ps.createShop(source, shopData)
    TriggerClientEvent('ps_lib:client:createShop', source, shopData)
end

function ps.verifyRecipe(source, recipe)
    local need, have = 0, 0
    if not recipe or not recipe.ingredients then return false end
    for item, amount in pairs (recipe) do 
        if ps.getItemCount(source, item) >= amount then
            have = have + 1
        end
        need = need + 1
    end
    return have == need
end

function ps.craftItem(source, recipe)
    local src = source
    if not recipe or not recipe.take then return false end
    local itemChecks = ps.verifyRecipe(src, recipe.take)

    if not itemChecks then return false end

    for item, amount in pairs(recipe.take) do
        if not ps.removeItem(src, item, amount) then
            ps.warn('Failed to remove item during crafting: ' .. item)
            return false
        end
    end

    for item, amount in pairs(recipe.give) do
        ps.addItem(src, item, amount)
    end
    
    return true
end