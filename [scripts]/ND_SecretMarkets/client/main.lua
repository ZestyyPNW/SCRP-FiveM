local ox_lib = exports.ox_lib
local ox_target = exports.ox_target
local NDCore = exports["ND_Core"]

local Config = require 'config.settings'
local Markets = require 'config.markets'
local Items = require 'config.items'
local Quests = require 'config.quests'

local spawnedNPCs = {}
local activeBlips = {}
local playerHeat = 0
local playerReputation = {}
local shutdownFlag = false

RegisterNetEvent('ND_SecretMarkets:updateHeat')
AddEventHandler('ND_SecretMarkets:updateHeat', function(newHeat)
    playerHeat = newHeat
end)

RegisterNetEvent('ND_SecretMarkets:updateReputation')
AddEventHandler('ND_SecretMarkets:updateReputation', function(reputation)
    playerReputation = reputation
end)

local function getCurrentTime()
    local hour = GetClockHours()
    return hour
end

local function getCurrentDay()
    return GetClockDayOfWeek()
end

local function isMarketAvailable(dealer)
    local currentDay = getCurrentDay()
    local currentHour = getCurrentTime()

    local dayAvailable = false
    for _, day in ipairs(dealer.availability.days) do
        if day == currentDay then
            dayAvailable = true
            break
        end
    end

    if not dayAvailable then
        return false
    end

    local startHour = dealer.availability.hours.start
    local endHour = dealer.availability.hours.finish

    if startHour > endHour then
        return currentHour >= startHour or currentHour <= endHour
    else
        return currentHour >= startHour and currentHour <= endHour
    end
end

local function createBlip(dealer, dealerId)
    if not dealer.blip.enabled then
        return
    end

    local blip = AddBlipForCoord(dealer.coords.x, dealer.coords.y, dealer.coords.z)
    SetBlipSprite(blip, dealer.blip.sprite)
    SetBlipColour(blip, dealer.blip.color)
    SetBlipScale(blip, dealer.blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(dealer.blip.label)
    EndTextCommandSetBlipName(blip)

    activeBlips[dealerId] = blip
end

local function removeBlip(dealerId)
    if activeBlips[dealerId] then
        RemoveBlip(activeBlips[dealerId])
        activeBlips[dealerId] = nil
    end
end

local function spawnNPC(dealer, dealerId)
    -- Clean up any existing ped first
    if spawnedNPCs[dealerId] then
        if DoesEntityExist(spawnedNPCs[dealerId].ped) then
            print(('[ND_SecretMarkets] NPC already exists for dealer %s, skipping spawn'):format(dealerId))
            return
        else
            -- Clean up stale reference
            spawnedNPCs[dealerId] = nil
        end
    end

    print(('[ND_SecretMarkets] Attempting to spawn dealer %s with model: %s'):format(dealerId, dealer.model))

    local model = dealer.model
    local hash = GetHashKey(model)

    print(('[ND_SecretMarkets] Model hash: %s'):format(hash))

    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print(('[ND_SecretMarkets] Invalid ped model: %s for dealer %s'):format(model, dealerId))
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    print(('[ND_SecretMarkets] Model loaded, creating ped...'):format())

    -- Create ped with explicit model string instead of hash (removed -1.0 from z)
    local ped = CreatePed(26, model, dealer.coords.x, dealer.coords.y, dealer.coords.z, dealer.coords.w, false, false)

    -- Wait a frame for the ped to be created
    Wait(0)

    if not DoesEntityExist(ped) then
        print(('[ND_SecretMarkets] Failed to create ped for dealer %s'):format(dealerId))
        SetModelAsNoLongerNeeded(hash)
        return
    end

    local actualModel = GetEntityModel(ped)
    print(('[ND_SecretMarkets] Ped created! Expected model hash: %s, Actual model hash: %s'):format(hash, actualModel))

    -- Set all properties after creation
    SetEntityHeading(ped, dealer.coords.w)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRandomComponentVariation(ped, 0)
    SetPedDefaultComponentVariation(ped)
    SetModelAsNoLongerNeeded(hash)

    spawnedNPCs[dealerId] = {
        ped = ped,
        coords = dealer.coords,
        dealer = dealer
    }

    if Config.UseTarget then
        local targetOptions = {}

        if dealer.interactions.buy then
            table.insert(targetOptions, {
                name = 'buy_' .. dealerId,
                icon = 'fas fa-shopping-cart',
                label = 'Buy Items',
                onSelect = function()
                    TriggerEvent('ND_SecretMarkets:openBuyMenu', dealerId)
                end
            })
        end

        if dealer.interactions.sell then
            table.insert(targetOptions, {
                name = 'sell_' .. dealerId,
                icon = 'fas fa-hand-holding-usd',
                label = 'Sell Items',
                onSelect = function()
                    TriggerEvent('ND_SecretMarkets:openSellMenu', dealerId)
                end
            })
        end

        -- Add quest option
        table.insert(targetOptions, {
            name = 'quests_' .. dealerId,
            icon = 'fas fa-clipboard-list',
            label = 'Jobs',
            onSelect = function()
                TriggerEvent('ND_SecretMarkets:openQuestMenu', dealerId)
            end
        })

        -- Add turn in quest option
        table.insert(targetOptions, {
            name = 'turnin_' .. dealerId,
            icon = 'fas fa-check-circle',
            label = 'Turn In Quest',
            onSelect = function()
                TriggerEvent('ND_SecretMarkets:openTurnInMenu', dealerId)
            end
        })

        ox_target:addLocalEntity(ped, targetOptions)
    end

    createBlip(dealer, dealerId)

    if Config.Debug then
        print(('[ND_SecretMarkets] Spawned NPC: %s at %s'):format(dealer.name, dealer.coords))
    end
end

local function despawnNPC(dealerId)
    if spawnedNPCs[dealerId] then
        if Config.UseTarget and GetResourceState('ox_target') == 'started' then
            pcall(function()
                ox_target:removeLocalEntity(spawnedNPCs[dealerId].ped)
            end)
        end

        if DoesEntityExist(spawnedNPCs[dealerId].ped) then
            DeletePed(spawnedNPCs[dealerId].ped)
        end

        spawnedNPCs[dealerId] = nil
        removeBlip(dealerId)

        if Config.Debug then
            print(('[ND_SecretMarkets] Despawned NPC: %s'):format(dealerId))
        end
    end
end

local function checkMarketAvailability()
    for dealerId, dealer in pairs(Markets.Dealers) do
        local isAvailable = isMarketAvailable(dealer)
        local isSpawned = spawnedNPCs[dealerId] ~= nil

        if isAvailable and not isSpawned then
            spawnNPC(dealer, dealerId)
        elseif not isAvailable and isSpawned then
            despawnNPC(dealerId)
        end
    end
end

RegisterNetEvent('ND_SecretMarkets:openBuyMenu')
AddEventHandler('ND_SecretMarkets:openBuyMenu', function(dealerId)
    local dealer = Markets.Dealers[dealerId]
    if not dealer then return end

    TriggerServerEvent('ND_SecretMarkets:requestBuyMenu', dealerId)
end)

RegisterNetEvent('ND_SecretMarkets:openShop')
AddEventHandler('ND_SecretMarkets:openShop', function(dealerId)
    exports.ox_inventory:openInventory('shop', {type = dealerId})
end)

RegisterNetEvent('ND_SecretMarkets:openSellMenu')
AddEventHandler('ND_SecretMarkets:openSellMenu', function(dealerId)
    local dealer = Markets.Dealers[dealerId]
    if not dealer then return end

    local playerRep = playerReputation[dealer.market_type] or 0
    if playerRep < dealer.reputation_required then
        ox_lib:notify({
            type = 'error',
            description = 'You need more reputation to trade with this dealer'
        })
        return
    end

    TriggerServerEvent('ND_SecretMarkets:requestSellMenu', dealerId)
end)


RegisterNetEvent('ND_SecretMarkets:showSellMenu')
AddEventHandler('ND_SecretMarkets:showSellMenu', function(dealerId, playerItems)
    local dealer = Markets.Dealers[dealerId]
    local options = {}

    for itemName, itemData in pairs(playerItems) do
        table.insert(options, {
            title = itemData.label or itemName,
            description = ('Price: $%d | You have: %d'):format(itemData.price, itemData.count),
            icon = 'hand-holding-usd',
            onSelect = function()
                local input = ox_lib:inputDialog('Sell ' .. (itemData.label or itemName), {
                    {type = 'number', label = 'Quantity', description = 'How many to sell?', min = 1, max = itemData.count}
                })

                if input then
                    TriggerServerEvent('ND_SecretMarkets:sellItem', dealerId, itemName, input[1])
                end
            end
        })
    end

    if #options == 0 then
        ox_lib:notify({
            type = 'error',
            description = 'You have no items to sell to this dealer'
        })
        return
    end

    ox_lib:registerContext({
        id = 'secretmarket_sell',
        title = dealer.name .. ' - Sell',
        options = options
    })

    ox_lib:showContext('secretmarket_sell')
end)

-- Quest Menu
RegisterNetEvent('ND_SecretMarkets:openQuestMenu')
AddEventHandler('ND_SecretMarkets:openQuestMenu', function(dealerId)
    TriggerServerEvent('ND_SecretMarkets:requestQuestMenu', dealerId)
end)

RegisterNetEvent('ND_SecretMarkets:showQuestMenu')
AddEventHandler('ND_SecretMarkets:showQuestMenu', function(dealerId, availableQuests)
    local dealer = Markets.Dealers[dealerId]

    if next(availableQuests) == nil then
        ox_lib:notify({
            type = 'error',
            description = 'No jobs available right now. Check back later.'
        })
        return
    end

    -- Create inventory-style quest menu
    TriggerServerEvent('ND_SecretMarkets:openQuestShop', dealerId, availableQuests)
end)

RegisterNetEvent('ND_SecretMarkets:showQuestBoard')
AddEventHandler('ND_SecretMarkets:showQuestBoard', function(dealerId, availableQuests)
    print('[ND_SecretMarkets] showQuestBoard called with dealer:', dealerId)
    print('[ND_SecretMarkets] Available quests:', json.encode(availableQuests))

    local dealer = Markets.Dealers[dealerId]

    -- Fallback to context menu if NUI fails
    local questOptions = {}

    for questId, questData in pairs(availableQuests) do
        local rewards = {}
        if questData.rewards.cash then
            table.insert(rewards, '$' .. questData.rewards.cash)
        end
        if questData.rewards.items then
            for _, item in ipairs(questData.rewards.items) do
                table.insert(rewards, item.count .. 'x ' .. item.name:gsub('item_barter_valuable_', ''))
            end
        end

        local typeIcon = ''
        if questData.type == 'delivery' then
            typeIcon = '🚚'
        elseif questData.type == 'collection' then
            typeIcon = '📋'
        elseif questData.type == 'elimination' then
            typeIcon = '🎯'
        elseif questData.type == 'heist_prep' then
            typeIcon = '💻'
        end

        table.insert(questOptions, {
            title = typeIcon .. ' ' .. questData.title,
            description = questData.description .. '\n\n💰 Rewards: ' .. table.concat(rewards, ', '),
            icon = 'clipboard-list',
            onSelect = function()
                local alert = ox_lib:alertDialog({
                    header = typeIcon .. ' ' .. questData.title,
                    content = questData.description .. '\n\nRewards:\n' .. table.concat(rewards, '\n') .. '\n\nAccept this mission?',
                    centered = true,
                    cancel = true,
                    size = 'md',
                    labels = {
                        confirm = 'Accept Mission',
                        cancel = 'Cancel'
                    }
                })

                if alert == 'confirm' then
                    TriggerServerEvent('ND_SecretMarkets:acceptQuest', dealerId, questId)
                end
            end
        })
    end

    ox_lib:registerContext({
        id = 'secretmarket_questboard',
        title = dealer.name .. ' - Mission Board',
        options = questOptions
    })

    ox_lib:showContext('secretmarket_questboard')
end)

-- Turn In Quest Menu
RegisterNetEvent('ND_SecretMarkets:openTurnInMenu')
AddEventHandler('ND_SecretMarkets:openTurnInMenu', function(dealerId)
    TriggerServerEvent('ND_SecretMarkets:requestTurnInMenu', dealerId)
end)

RegisterNetEvent('ND_SecretMarkets:showTurnInMenu')
AddEventHandler('ND_SecretMarkets:showTurnInMenu', function(dealerId, activeQuests)
    if next(activeQuests) == nil then
        ox_lib:notify({
            type = 'error',
            description = 'You have no active quests to turn in'
        })
        return
    end

    local options = {}

    for questId, questData in pairs(activeQuests) do
        table.insert(options, {
            title = questData.title,
            description = 'Turn in quest: ' .. questData.description,
            icon = 'check-circle',
            onSelect = function()
                TriggerServerEvent('ND_SecretMarkets:turnInQuest', dealerId, questId)
            end
        })
    end

    ox_lib:registerContext({
        id = 'secretmarket_turnin',
        title = 'Turn In Quests',
        options = options
    })

    ox_lib:showContext('secretmarket_turnin')
end)

-- NUI Callbacks for quest board
RegisterNUICallback('acceptQuest', function(data, cb)
    TriggerServerEvent('ND_SecretMarkets:acceptQuest', data.dealerId, data.questId)
    cb('ok')
end)

RegisterNUICallback('closeQuestBoard', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Emergency cursor fix command
RegisterCommand('fixcursor', function()
    SetNuiFocus(false, false)
    ox_lib:notify({
        type = 'success',
        description = 'Cursor focus reset'
    })
end, false)

CreateThread(function()
    -- Wait for other resources to stabilize
    Wait(2000)

    -- Check if ox_inventory is started before continuing
    while GetResourceState('ox_inventory') ~= 'started' and not shutdownFlag do
        Wait(1000)
    end

    if not shutdownFlag then
        TriggerServerEvent('ND_SecretMarkets:playerLoaded')
    end

    while not shutdownFlag do
        if GetResourceState('ox_inventory') == 'started' then
            checkMarketAvailability()
        end
        Wait(60000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        shutdownFlag = true

        -- Safe cleanup with timeout
        local cleanupTimer = GetGameTimer()
        for dealerId in pairs(spawnedNPCs) do
            if GetGameTimer() - cleanupTimer > 5000 then
                break -- Prevent hanging during shutdown
            end
            despawnNPC(dealerId)
        end
    end
end)