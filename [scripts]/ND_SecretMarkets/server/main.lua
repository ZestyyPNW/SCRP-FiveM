local ox_inventory = exports.ox_inventory
local NDCore = exports["ND_Core"]

local Config = require 'config.settings'
local Markets = require 'config.markets'
local Items = require 'config.items'

local playerHeat = {}
local playerReputation = {}
local dealerStock = {}
local lastRestock = {}

local function initializeStock()
    for dealerId, dealer in pairs(Markets.Dealers) do
        dealerStock[dealerId] = {}
        lastRestock[dealerId] = os.time()

        local marketItems = Items.MarketInventories[dealer.market_type]
        if marketItems and marketItems.buy then
            for itemName, itemData in pairs(marketItems.buy) do
                local stock = math.random(itemData.stock.min, itemData.stock.max)
                dealerStock[dealerId][itemName] = {
                    stock = stock,
                    price = math.random(itemData.price.min, itemData.price.max)
                }
            end
        end
    end

    if Config.Debug then
        print('[ND_SecretMarkets] Stock initialized for all dealers')
    end
end

local function restockDealer(dealerId)
    local dealer = Markets.Dealers[dealerId]
    if not dealer then return end

    dealerStock[dealerId] = {}

    local marketItems = Items.MarketInventories[dealer.market_type]
    if marketItems and marketItems.buy then
        for itemName, itemData in pairs(marketItems.buy) do
            local baseStock = math.random(itemData.stock.min, itemData.stock.max)
            local variation = math.random(-Config.StockVariation * 100, Config.StockVariation * 100) / 100
            local finalStock = math.max(1, math.floor(baseStock * (1 + variation)))

            dealerStock[dealerId][itemName] = {
                stock = finalStock,
                price = math.random(itemData.price.min, itemData.price.max)
            }
        end
    end

    lastRestock[dealerId] = os.time()

    if Config.Debug then
        print(('[ND_SecretMarkets] Restocked dealer: %s'):format(dealerId))
    end
end

local function checkRestocks()
    local currentTime = os.time()

    for dealerId in pairs(Markets.Dealers) do
        if not lastRestock[dealerId] or (currentTime - lastRestock[dealerId]) >= (Config.RestockInterval * 60) then
            restockDealer(dealerId)
        end
    end
end

local function getPlayerHeat(playerId)
    return playerHeat[playerId] or 0
end

local function addPlayerHeat(playerId, amount)
    playerHeat[playerId] = (playerHeat[playerId] or 0) + amount

    if playerHeat[playerId] > Config.MaxHeatLevel then
        playerHeat[playerId] = Config.MaxHeatLevel
    end

    TriggerClientEvent('ND_SecretMarkets:updateHeat', playerId, playerHeat[playerId])

    if playerHeat[playerId] >= Config.PoliceAlertThreshold then
        TriggerEvent('ND_SecretMarkets:policeAlert', playerId)
    end
end

local function getPlayerReputation(playerId, marketType)
    if not playerReputation[playerId] then
        playerReputation[playerId] = {}
    end

    return playerReputation[playerId][marketType] or 0
end

local function addPlayerReputation(playerId, marketType, amount)
    if not playerReputation[playerId] then
        playerReputation[playerId] = {}
    end

    playerReputation[playerId][marketType] = (playerReputation[playerId][marketType] or 0) + amount

    if playerReputation[playerId][marketType] > 100 then
        playerReputation[playerId][marketType] = 100
    end

    TriggerClientEvent('ND_SecretMarkets:updateReputation', playerId, playerReputation[playerId])
end

local function getReputationDiscount(playerId, marketType)
    local rep = getPlayerReputation(playerId, marketType)

    for _, level in pairs(Config.ReputationLevels) do
        if rep >= level.min and rep <= level.max then
            return level.discount
        end
    end

    return 0
end

RegisterNetEvent('ND_SecretMarkets:playerLoaded')
AddEventHandler('ND_SecretMarkets:playerLoaded', function()
    local src = source

    if not playerHeat[src] then
        playerHeat[src] = 0
    end

    if not playerReputation[src] then
        playerReputation[src] = {}
    end

    TriggerClientEvent('ND_SecretMarkets:updateHeat', src, playerHeat[src])
    TriggerClientEvent('ND_SecretMarkets:updateReputation', src, playerReputation[src])
end)

RegisterNetEvent('ND_SecretMarkets:requestBuyMenu')
AddEventHandler('ND_SecretMarkets:requestBuyMenu', function(dealerId)
    local src = source
    local dealer = Markets.Dealers[dealerId]

    if not dealer then return end

    local shopItems = {}
    local marketItems = Items.MarketInventories[dealer.market_type]

    if marketItems and marketItems.buy and dealerStock[dealerId] then
        for itemName, itemData in pairs(marketItems.buy) do
            if dealerStock[dealerId][itemName] and dealerStock[dealerId][itemName].stock > 0 then
                table.insert(shopItems, {
                    name = itemName,
                    price = dealerStock[dealerId][itemName].price,
                    count = dealerStock[dealerId][itemName].stock
                })
            end
        end
    end

    if #shopItems > 0 then
        exports.ox_inventory:RegisterShop(dealerId, {
            name = dealer.name,
            inventory = shopItems,
            onBuy = function(playerId, item, quantity, price)
                local totalPrice = price * quantity
                local player = NDCore:getPlayer(playerId)

                if not player then return false end

                local cash = player.getData("cash")
                if cash < totalPrice then
                    return false
                end

                -- Update stock
                if dealerStock[dealerId][item.name] then
                    dealerStock[dealerId][item.name].stock = dealerStock[dealerId][item.name].stock - quantity
                end

                -- Add heat
                addPlayerHeat(playerId, dealer.heat_generation * quantity)

                -- Deduct money
                player.deductMoney("cash", totalPrice)

                if Config.Debug then
                    print(('[ND_SecretMarkets] Player %d bought %dx %s from %s'):format(playerId, quantity, item.name, dealerId))
                end

                return true
            end
        })

        TriggerClientEvent('ND_SecretMarkets:openShop', src, dealerId)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'No items available for your reputation level'
        })
    end
end)

RegisterNetEvent('ND_SecretMarkets:requestSellMenu')
AddEventHandler('ND_SecretMarkets:requestSellMenu', function(dealerId)
    local src = source
    local dealer = Markets.Dealers[dealerId]

    if not dealer then return end

    local playerRep = getPlayerReputation(src, dealer.market_type)
    if playerRep < dealer.reputation_required then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Insufficient reputation'
        })
        return
    end

    local playerItems = {}
    local marketItems = Items.MarketInventories[dealer.market_type]

    if marketItems and marketItems.sell then
        for itemName, itemData in pairs(marketItems.sell) do
            local count = ox_inventory:Search(src, 'count', itemName)
            if count and count > 0 then
                playerItems[itemName] = {
                    label = ox_inventory:Items(itemName)?.label or itemName,
                    price = math.random(itemData.price.min, itemData.price.max),
                    count = count
                }
            end
        end
    end

    TriggerClientEvent('ND_SecretMarkets:showSellMenu', src, dealerId, playerItems)
end)


RegisterNetEvent('ND_SecretMarkets:sellItem')
AddEventHandler('ND_SecretMarkets:sellItem', function(dealerId, itemName, quantity)
    local src = source
    local dealer = Markets.Dealers[dealerId]

    if not dealer then return end

    local marketItems = Items.MarketInventories[dealer.market_type]

    if not marketItems or not marketItems.sell or not marketItems.sell[itemName] then
        return
    end

    local itemData = marketItems.sell[itemName]
    local playerCount = ox_inventory:Search(src, 'count', itemName)

    if not playerCount or playerCount < quantity then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You don\'t have enough of this item'
        })
        return
    end

    local discount = getReputationDiscount(src, dealer.market_type)
    local basePrice = math.random(itemData.price.min, itemData.price.max)
    local totalPrice = math.floor(basePrice * quantity * (1 + discount))

    local success = ox_inventory:RemoveItem(src, itemName, quantity)
    if success then
        local player = NDCore:getPlayer(src)
        if player then
            player.addMoney("cash", totalPrice)

            addPlayerHeat(src, math.floor(dealer.heat_generation * quantity * 0.5))
            addPlayerReputation(src, dealer.market_type, math.ceil(quantity / 3))

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = ('Sold %dx %s for $%d'):format(quantity, ox_inventory:Items(itemName)?.label or itemName, totalPrice)
            })

            if Config.Debug then
                print(('[ND_SecretMarkets] Player %d sold %dx %s to %s'):format(src, quantity, itemName, dealerId))
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Could not remove item from inventory'
        })
    end
end)

CreateThread(function()
    while true do
        for playerId, heat in pairs(playerHeat) do
            if heat > 0 then
                playerHeat[playerId] = math.max(0, heat - Config.HeatDecayRate)
                TriggerClientEvent('ND_SecretMarkets:updateHeat', playerId, playerHeat[playerId])
            end
        end

        checkRestocks()
        Wait(60000)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        initializeStock()
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerHeat[src] = nil
    playerReputation[src] = nil
end)