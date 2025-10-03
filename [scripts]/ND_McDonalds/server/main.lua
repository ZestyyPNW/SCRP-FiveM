-- Useable Items for Meal Bags
exports.ox_inventory:registerHook('usingItem', function(playerId, itemName, slotId, metadata)
    if itemName == 'mcdonalds_bagsmall' then
        TriggerClientEvent('ND_McDonalds:CraftSmallBagItem', playerId)
        return true
    elseif itemName == 'mcdonalds_bagbig' then
        TriggerClientEvent('ND_McDonalds:CraftBigBagItem', playerId)
        return true
    elseif itemName == 'mcdonalds_baggoat' then
        TriggerClientEvent('ND_McDonalds:CraftGoatMenuItem', playerId)
        return true
    elseif itemName == 'mcdonalds_bagcoffe' then
        TriggerClientEvent('ND_McDonalds:CraftCoffeeMenuItem', playerId)
        return true
    end
    return false
end, {
    print = false,
    inventoryFilter = {
        'mcdonalds_bagsmall',
        'mcdonalds_bagbig',
        'mcdonalds_baggoat',
        'mcdonalds_bagcoffe'
    }
})

-- Small Bag Item Crafting
RegisterNetEvent('ND_McDonalds:SmallBagItem', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    exports.ox_inventory:RemoveItem(src, Config.SmallBagItem, 1)

    for k, v in pairs(Config.SmallBag) do
        exports.ox_inventory:AddItem(src, v, 1)
    end
end)

-- Big Bag Item Crafting
RegisterNetEvent('ND_McDonalds:BigBagItem', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    exports.ox_inventory:RemoveItem(src, Config.BigBagItem, 1)

    for k, v in pairs(Config.BigBag) do
        exports.ox_inventory:AddItem(src, v, 1)
    end
end)

-- Goat Menu Item Crafting
RegisterNetEvent('ND_McDonalds:GoatMenuItem', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    exports.ox_inventory:RemoveItem(src, Config.GoatBagItem, 1)

    for k, v in pairs(Config.GoatBag) do
        exports.ox_inventory:AddItem(src, v, 1)
    end
end)

-- Coffee Menu Item Crafting
RegisterNetEvent('ND_McDonalds:CoffeeMenuItem', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    exports.ox_inventory:RemoveItem(src, Config.CoffeeBagItem, 1)

    for k, v in pairs(Config.CoffeeBag) do
        exports.ox_inventory:AddItem(src, v, 1)
    end
end)

-- Random Toy Gift
RegisterNetEvent('ND_McDonalds:givetoy')
AddEventHandler('ND_McDonalds:givetoy', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local items = {"avatar_box", "hulk_box", "disney_box", "wwe_box", "horror_box", "malewwe_box", "nba_box", "tmnt_box", "office_box", "music_box"}
    local item = items[math.random(1, #items)]

    local success = exports.ox_inventory:AddItem(src, item, 1)
    if success then
        player.notify({
            title = 'McDonald\'s',
            description = 'You received a free toy!',
            type = 'success'
        })
    else
        player.notify({
            title = 'McDonald\'s',
            description = 'Your inventory is full',
            type = 'error'
        })
    end
end)

-- Item Check Callbacks
lib.callback.register('ND_McDonalds:itemcheck', function(source, item)
    local count = exports.ox_inventory:GetItemCount(source, item)
    return count > 0
end)

lib.callback.register('ND_McDonalds:get:smallpacket', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.BleederBurger)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.SmallColaItem)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.SmallPotato)
    return item1 > 0 and item2 > 0 and item3 > 0
end)

lib.callback.register('ND_McDonalds:get:bigpacket', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.BigKingBurger)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.BigColaItem)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.BigPotato)
    return item1 > 0 and item2 > 0 and item3 > 0
end)

lib.callback.register('ND_McDonalds:get:goatpacket', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.Wrap)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.Nuggets)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.Rings)
    local item4 = exports.ox_inventory:GetItemCount(source, Config.BigColaItem)
    return item1 > 0 and item2 > 0 and item3 > 0 and item4 > 0
end)

lib.callback.register('ND_McDonalds:get:coffeepacket', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.CoffeeItem)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.Macaroon)
    return item1 > 0 and item2 > 0
end)

lib.callback.register('ND_McDonalds:get:bigpotato', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.BigFrozenPotato)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.BigEmptyCardboard)
    return item1 > 0 and item2 > 0
end)

lib.callback.register('ND_McDonalds:get:smallpotato', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.SmallFrozenPotato)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.SmallEmptyCardboard)
    return item1 > 0 and item2 > 0
end)

lib.callback.register('ND_McDonalds:get:rings', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.FrozenRings)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.SmallEmptyCardboard)
    return item1 > 0 and item2 > 0
end)

lib.callback.register('ND_McDonalds:get:nuggets', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.FrozenNuggets)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.BigEmptyCardboard)
    return item1 > 0 and item2 > 0
end)

lib.callback.register('ND_McDonalds:get:bleederburger', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.Bread)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.Meat)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.Sauce)
    local item4 = exports.ox_inventory:GetItemCount(source, Config.VegetableCurly)
    return item1 > 0 and item2 > 0 and item3 > 0 and item4 > 0
end)

lib.callback.register('ND_McDonalds:get:bigkingburger', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.Bread)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.Meat)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.Sauce)
    local item4 = exports.ox_inventory:GetItemCount(source, Config.Cheddar)
    local item5 = exports.ox_inventory:GetItemCount(source, Config.Tomato)
    local item6 = exports.ox_inventory:GetItemCount(source, Config.VegetableCurly)
    return item1 > 0 and item2 > 0 and item3 > 0 and item4 > 0 and item5 > 0 and item6 > 0
end)

lib.callback.register('ND_McDonalds:get:wrap', function(source)
    local item1 = exports.ox_inventory:GetItemCount(source, Config.Lavash)
    local item2 = exports.ox_inventory:GetItemCount(source, Config.Meat)
    local item3 = exports.ox_inventory:GetItemCount(source, Config.Sauce)
    local item4 = exports.ox_inventory:GetItemCount(source, Config.Cheddar)
    local item5 = exports.ox_inventory:GetItemCount(source, Config.Tomato)
    local item6 = exports.ox_inventory:GetItemCount(source, Config.VegetableCurly)
    return item1 > 0 and item2 > 0 and item3 > 0 and item4 > 0 and item5 > 0 and item6 > 0
end)

-- Package Creation Events
RegisterNetEvent('ND_McDonalds:add:smallpacket', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    for k, v in pairs(Config.SmallBag) do
        exports.ox_inventory:RemoveItem(src, v, 1)
    end
    exports.ox_inventory:AddItem(src, Config.SmallBagItem, 1)
end)

RegisterNetEvent('ND_McDonalds:add:bigpacket', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    for k, v in pairs(Config.BigBag) do
        exports.ox_inventory:RemoveItem(src, v, 1)
    end
    exports.ox_inventory:AddItem(src, Config.BigBagItem, 1)
end)

RegisterNetEvent('ND_McDonalds:add:goatpacket', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    for k, v in pairs(Config.GoatBag) do
        exports.ox_inventory:RemoveItem(src, v, 1)
    end
    exports.ox_inventory:AddItem(src, Config.GoatBagItem, 1)
end)

RegisterNetEvent('ND_McDonalds:add:coffeepacket', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    for k, v in pairs(Config.CoffeeBag) do
        exports.ox_inventory:RemoveItem(src, v, 1)
    end
    exports.ox_inventory:AddItem(src, Config.CoffeeBagItem, 1)
end)

-- Drink Station Events
RegisterNetEvent('ND_McDonalds:server:bigcola', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.BigEmptyGlass, 1)
    exports.ox_inventory:AddItem(src, Config.BigColaItem, 1)
end)

RegisterNetEvent('ND_McDonalds:server:smallcola', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.SmallEmptyGlass, 1)
    exports.ox_inventory:AddItem(src, Config.SmallColaItem, 1)
end)

RegisterNetEvent('ND_McDonalds:server:coffee', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.CoffeeEmptyGlass, 1)
    exports.ox_inventory:AddItem(src, Config.CoffeeItem, 1)
end)

-- Fries Station Events
RegisterNetEvent('ND_McDonalds:server:bigpotato', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.BigFrozenPotato, 1)
    exports.ox_inventory:RemoveItem(src, Config.BigEmptyCardboard, 1)
    exports.ox_inventory:AddItem(src, Config.BigPotato, 1)
end)

RegisterNetEvent('ND_McDonalds:server:smallpotato', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.SmallFrozenPotato, 1)
    exports.ox_inventory:RemoveItem(src, Config.SmallEmptyCardboard, 1)
    exports.ox_inventory:AddItem(src, Config.SmallPotato, 1)
end)

RegisterNetEvent('ND_McDonalds:server:rings', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.FrozenRings, 1)
    exports.ox_inventory:RemoveItem(src, Config.SmallEmptyCardboard, 1)
    exports.ox_inventory:AddItem(src, Config.Rings, 1)
end)

RegisterNetEvent('ND_McDonalds:server:nuggets', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.FrozenNuggets, 1)
    exports.ox_inventory:RemoveItem(src, Config.BigEmptyCardboard, 1)
    exports.ox_inventory:AddItem(src, Config.Nuggets, 1)
end)

-- Meat Station Event
RegisterNetEvent('ND_McDonalds:server:meat', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.FrozenMeat, 1)
    exports.ox_inventory:AddItem(src, Config.Meat, 1)
end)

-- Burger Station Events
RegisterNetEvent('ND_McDonalds:server:bleederburger', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Bread, 1)
    exports.ox_inventory:RemoveItem(src, Config.Meat, 1)
    exports.ox_inventory:RemoveItem(src, Config.Sauce, 1)
    exports.ox_inventory:RemoveItem(src, Config.VegetableCurly, 1)
    exports.ox_inventory:AddItem(src, Config.BleederBurger, 1)
end)

RegisterNetEvent('ND_McDonalds:server:bigkingburger', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Bread, 1)
    exports.ox_inventory:RemoveItem(src, Config.Meat, 1)
    exports.ox_inventory:RemoveItem(src, Config.Sauce, 1)
    exports.ox_inventory:RemoveItem(src, Config.VegetableCurly, 1)
    exports.ox_inventory:RemoveItem(src, Config.Cheddar, 1)
    exports.ox_inventory:RemoveItem(src, Config.Tomato, 1)
    exports.ox_inventory:AddItem(src, Config.BigKingBurger, 1)
end)

RegisterNetEvent('ND_McDonalds:server:wrap', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Lavash, 1)
    exports.ox_inventory:RemoveItem(src, Config.Meat, 1)
    exports.ox_inventory:RemoveItem(src, Config.Sauce, 1)
    exports.ox_inventory:RemoveItem(src, Config.VegetableCurly, 1)
    exports.ox_inventory:RemoveItem(src, Config.Cheddar, 1)
    exports.ox_inventory:RemoveItem(src, Config.Tomato, 1)
    exports.ox_inventory:AddItem(src, Config.Wrap, 1)
end)

-- Ice Cream Station Events
RegisterNetEvent('ND_McDonalds:server:chocolateicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.ChocolateIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:vanillaicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.VanillaIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:thesmurfsicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.ThesmurfsIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:strawberryicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.StrawberryIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:matchaicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.MatchaIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:ubeicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.UbeIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:smurfetteicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.SmurfetteIceCream, 1)
end)

RegisterNetEvent('ND_McDonalds:server:unicornicecream', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Cone, 1)
    exports.ox_inventory:AddItem(src, Config.UnicornIceCream, 1)
end)

-- Macaroon Purchase Event
RegisterNetEvent('ND_McDonalds:server:macaroon', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local price = 500
    if player.cash >= price then
        player.removeMoney("cash", price, "Bought macaroon")
        exports.ox_inventory:AddItem(src, Config.Macaroon, 1)
    else
        player.notify({
            title = 'McDonald\'s',
            description = 'You don\'t have enough cash',
            type = 'error'
        })
    end
end)

-- Delivery Sell Events
RegisterNetEvent('ND_McDonalds:server:smallpacketsell')
AddEventHandler('ND_McDonalds:server:smallpacketsell', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local count = exports.ox_inventory:GetItemCount(src, Config.SmallBagItem)

    if count > 0 then
        exports.ox_inventory:RemoveItem(src, Config.SmallBagItem, 1)
        player.addMoney('cash', Config.SmallBagSellPrice, 'McDonald\'s delivery')

        player.notify({
            title = 'McDonald\'s',
            description = 'Delivery completed! Earned $' .. Config.SmallBagSellPrice,
            type = 'success',
            duration = 5000
        })
    end
end)

RegisterNetEvent('ND_McDonalds:server:bigpacketsell')
AddEventHandler('ND_McDonalds:server:bigpacketsell', function()
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local count = exports.ox_inventory:GetItemCount(src, Config.BigBagItem)

    if count > 0 then
        exports.ox_inventory:RemoveItem(src, Config.BigBagItem, 1)
        player.addMoney('cash', Config.BigBagSellPrice, 'McDonald\'s delivery')

        player.notify({
            title = 'McDonald\'s',
            description = 'Delivery completed! Earned $' .. Config.BigBagSellPrice,
            type = 'success',
            duration = 5000
        })
    end
end)

print("^2[ND_McDonalds]^7 Server started successfully")
