-- Item Data Callbacks (for client display)
lib.callback.register('ND_PizzaThis:GetItemData', function(source, itemName)
    local itemInfo = exports.ox_inventory:Items(itemName)
    if itemInfo then
        return {
            label = itemInfo.label,
            image = itemInfo.client and itemInfo.client.image or itemName..'.png',
            thirst = itemInfo.client and itemInfo.client.status and itemInfo.client.status.thirst or 0,
            hunger = itemInfo.client and itemInfo.client.status and itemInfo.client.status.hunger or 0,
        }
    end
    return nil
end)

lib.callback.register('ND_PizzaThis:GetItemsData', function(source, itemNames)
    local itemsData = {}
    for _, itemName in ipairs(itemNames) do
        local itemInfo = exports.ox_inventory:Items(itemName)
        if itemInfo then
            itemsData[itemName] = {
                label = itemInfo.label,
                image = itemInfo.client and itemInfo.client.image or itemName..'.png',
            }
        end
    end
    return itemsData
end)

lib.callback.register('ND_PizzaThis:GetJobGrades', function(source)
    -- Get job grades for boss menu detection
    local jobsJson = GetConvar('core:groups', '{}')
    local jobs = json.decode(jobsJson)
    if jobs and jobs.pizzathis and jobs.pizzathis.ranks then
        return jobs.pizzathis.ranks
    end
    return {}
end)

-- Resource start validation
AddEventHandler('onResourceStart', function(r)
    if GetCurrentResourceName() ~= r then return end

    for k, v in pairs(Crafting) do
        for i = 1, #v do
            for l, b in pairs(v[i]) do
                local itemInfo = exports.ox_inventory:Items(l)
                if not itemInfo then
                    print("^5Debug^7: ^6Crafting^7: ^2Missing Item from ox_inventory^7: '^6"..l.."^7'")
                end
                for j, c in pairs(b) do
                    local ingredientInfo = exports.ox_inventory:Items(j)
                    if not ingredientInfo then
                        print("^5Debug^7: ^6Crafting^7: ^2Missing Item from ox_inventory^7: '^6"..j.."^7'")
                    end
                end
            end
        end
    end

    for i = 1, #Config.DrinkItems.items do
        local itemInfo = exports.ox_inventory:Items(Config.DrinkItems.items[i].name)
        if not itemInfo then
            print("^5Debug^7: ^6Store^7: ^2Missing Item from ox_inventory^7: '^6"..Config.DrinkItems.items[i].name.."^7'")
        end
    end

    for i = 1, #Config.FoodItems.items do
        local itemInfo = exports.ox_inventory:Items(Config.FoodItems.items[i].name)
        if not itemInfo then
            print("^5Debug^7: ^6Store^7: ^2Missing Item from ox_inventory^7: '^6"..Config.FoodItems.items[i].name.."^7'")
        end
    end

    for i = 1, #Config.WineItems.items do
        local itemInfo = exports.ox_inventory:Items(Config.WineItems.items[i].name)
        if not itemInfo then
            print("^5Debug^7: ^6Store^7: ^2Missing Item from ox_inventory^7: '^6"..Config.WineItems.items[i].name.."^7'")
        end
    end

    for i = 1, #Config.FreezerItems.items do
        local itemInfo = exports.ox_inventory:Items(Config.FreezerItems.items[i].name)
        if not itemInfo then
            print("^5Debug^7: ^6Store^7: ^2Missing Item from ox_inventory^7: '^6"..Config.FreezerItems.items[i].name.."^7'")
        end
    end

    local jobsJson = GetConvar('core:groups', '{}')
    local jobs = json.decode(jobsJson)
    if not jobs or not jobs.pizzathis then
        print("Error: Job role not found - 'pizzathis'")
    end
end)

-- Pizza Box Opening (converts box to slices)
RegisterServerEvent('ND_PizzaThis:OpenBox', function(source, item)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local slices = nil
    if item == "capricciosabox" then slices = "capricciosa"
    elseif item == "diavolabox" then slices = "diavola"
    elseif item == "marinarabox" then slices = "marinara"
    elseif item == "margheritabox" then slices = "margherita"
    elseif item == "prosciuttiobox" then slices = "prosciuttio"
    elseif item == "vegetarianabox" then slices = "vegetariana" end

    if slices then
        -- Remove the box
        if exports.ox_inventory:RemoveItem(src, item, 1) then
            Wait(600)
            -- Give 6 slices
            exports.ox_inventory:AddItem(src, slices, 6)
        end
    end
end)

-- Crafting System
RegisterServerEvent('ND_PizzaThis:Crafting:GetItem', function(ItemMake, craftable)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local amount = 1
    if craftable then
        if craftable["amount"] then amount = craftable["amount"] end
        -- Remove required ingredients
        for k, v in pairs(craftable[ItemMake]) do
            if not exports.ox_inventory:RemoveItem(src, tostring(k), v) then
                -- Failed to remove item - possible dupe attempt
                TriggerEvent("ND_PizzaThis:server:DupeWarn", tostring(k), src)
                return
            end
        end
    end

    -- Give crafted item
    exports.ox_inventory:AddItem(src, ItemMake, amount)
end)

-- Toggle Item (for adding/removing items)
RegisterNetEvent('ND_PizzaThis:server:toggleItem', function(give, item, amount, newsrc)
    local src = newsrc or source
    local amount = amount or 1
    local player = NDCore.getPlayer(src)
    if not player then return end

    if not give then
        -- Remove item
        local hasItem = exports.ox_inventory:GetItemCount(src, item) >= amount
        if hasItem then
            if not exports.ox_inventory:RemoveItem(src, item, amount) then
                TriggerEvent("ND_PizzaThis:server:DupeWarn", item, src)
            end
        else
            TriggerEvent("ND_PizzaThis:server:DupeWarn", item, src)
        end
    elseif give then
        -- Add item
        exports.ox_inventory:AddItem(src, item, amount)
    end
end)

-- Dupe Warning
RegisterNetEvent("ND_PizzaThis:server:DupeWarn", function(item, newsrc)
    local src = newsrc or source
    local player = NDCore.getPlayer(src)
    if not player then return end

    local charinfo = player.getName()
    print("^5DupeWarn: ^1"..charinfo.."^7(^1"..tostring(src).."^7) ^2Tried to remove item ^7('^3"..item.."^7')^2 but it wasn't there^7")

    if not Config.Debug then
        DropPlayer(src, "Kicked for attempting to duplicate items")
        print("^5DupeWarn: ^1"..charinfo.."^7(^1"..tostring(src).."^7) ^2Dropped from server for item duplicating^7")
    end
end)

-- Shop Inventories
RegisterNetEvent('ND_PizzaThis:server:OpenShop', function(shopData)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    if player.job.name ~= "pizzathis" then return end

    -- Convert shop data to ox_inventory format
    local items = {}
    for k, v in pairs(shopData.items) do
        items[v.name] = {
            name = v.name,
            price = v.price or 0,
            count = v.amount or 50,
            currency = 'money'
        }
    end

    exports.ox_inventory:RegisterShop('pizzathis_'..shopData.label, {
        name = shopData.label,
        inventory = items,
        locations = {},
        groups = { pizzathis = 0 }
    })

    exports.ox_inventory:OpenInventory(src, 'shop', { type = 'pizzathis_'..shopData.label })
end)

-- Useable Items for Pizza Boxes
exports.ox_inventory:registerHook('usingItem', function(playerId, itemName, slotId, metadata)
    if itemName == 'capricciosabox' or itemName == 'diavolabox' or
       itemName == 'marinarabox' or itemName == 'margheritabox' or
       itemName == 'prosciuttiobox' or itemName == 'vegetarianabox' then
        TriggerEvent('ND_PizzaThis:OpenBox', playerId, itemName)
        return true
    end
    return false
end, {
    print = false,
    inventoryFilter = {
        'capricciosabox',
        'diavolabox',
        'marinarabox',
        'margheritabox',
        'prosciuttiobox',
        'vegetarianabox'
    }
})

-- Consumable Items
local alcoholItems = {'ambeer', 'dusche', 'logger', 'pisswasser', 'pisswasser2', 'pisswasser3',
                      'amarone', 'barbera', 'dolceto', 'housered', 'housewhite', 'rosso'}
local drinkItems = {'sprunk', 'sprunklight', 'ecola', 'ecolalight'}

for _, item in ipairs(alcoholItems) do
    exports.ox_inventory:registerHook('usingItem', function(playerId, itemName)
        TriggerClientEvent('ND_PizzaThis:client:DrinkAlcohol', playerId, itemName)
        return false -- Don't remove item yet, client will handle it
    end, {
        print = false,
        itemFilter = {item}
    })
end

for _, item in ipairs(drinkItems) do
    exports.ox_inventory:registerHook('usingItem', function(playerId, itemName)
        TriggerClientEvent('ND_PizzaThis:client:Drink', playerId, itemName)
        return false -- Don't remove item yet, client will handle it
    end, {
        print = false,
        itemFilter = {item}
    })
end

-- Duty System
RegisterNetEvent('ND_PizzaThis:server:setDuty', function(duty)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    -- Update player duty status
    -- Note: This is just for tracking, ND_Core handles the actual job duty
    TriggerClientEvent('ND_PizzaThis:toggleDuty', src, duty)
end)
