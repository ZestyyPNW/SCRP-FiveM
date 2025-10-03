local NDCore = exports["ND_Core"]

-- Safe ox_inventory wrapper to prevent crashes
local function safeOxInventory(method, ...)
    local args = {...}
    local success, result = pcall(function()
        return exports.ox_inventory[method](table.unpack(args))
    end)

    if not success then
        print(('[ND_SecretMarkets] ox_inventory error: %s'):format(tostring(result)))
        return nil
    end

    return result
end

local Quests = require 'config.quests'
local playerQuests = {}
local questCooldowns = {}

-- Initialize player quest data
local function initializePlayerQuests(playerId)
    if not playerQuests[playerId] then
        playerQuests[playerId] = {
            active = {},
            completed = {},
            objectives = {}
        }
    end
end

-- Get available quests for dealer
local function getAvailableQuests(dealerId, playerId)
    initializePlayerQuests(playerId)

    local available = {}
    local currentTime = os.time()

    for questId, questData in pairs(Quests.Available) do
        -- Check if quest is on cooldown
        local cooldownKey = playerId .. "_" .. questId
        local lastCompleted = questCooldowns[cooldownKey] or 0
        local cooldownRemaining = (lastCompleted + (questData.cooldown / 1000)) - currentTime

        -- Check if player already has this quest active
        local isActive = playerQuests[playerId].active[questId] ~= nil

        if cooldownRemaining <= 0 and not isActive then
            available[questId] = questData
        end
    end

    return available
end

-- Start quest for player
local function startQuest(playerId, questId, dealerId)
    initializePlayerQuests(playerId)

    local questData = Quests.Available[questId]
    if not questData then
        return false, "Quest not found"
    end

    -- Check if already active
    if playerQuests[playerId].active[questId] then
        return false, "Quest already active"
    end

    -- Initialize quest
    playerQuests[playerId].active[questId] = {
        dealerId = dealerId,
        startTime = os.time(),
        objectives = {},
        currentObjective = 1
    }

    -- Initialize objectives
    for i, objective in ipairs(questData.objectives) do
        playerQuests[playerId].active[questId].objectives[i] = {
            completed = false,
            progress = 0
        }
    end

    -- Send quest data to client
    TriggerClientEvent('ND_SecretMarkets:startQuest', playerId, questId, questData)

    return true, "Quest started"
end

-- Complete quest objective
local function completeObjective(playerId, questId, objectiveIndex)
    if not playerQuests[playerId] or not playerQuests[playerId].active[questId] then
        return false
    end

    local questProgress = playerQuests[playerId].active[questId]
    if not questProgress.objectives[objectiveIndex] then
        return false
    end

    questProgress.objectives[objectiveIndex].completed = true
    questProgress.objectives[objectiveIndex].progress = 100

    -- Check if all objectives completed
    local questData = Quests.Available[questId]
    local allCompleted = true

    for i = 1, #questData.objectives do
        if not questProgress.objectives[i].completed then
            allCompleted = false
            break
        end
    end

    if allCompleted then
        completeQuest(playerId, questId)
    else
        -- Move to next objective
        questProgress.currentObjective = questProgress.currentObjective + 1
        TriggerClientEvent('ND_SecretMarkets:updateQuestObjective', playerId, questId, questProgress.currentObjective)
    end

    return true
end

-- Complete quest and give rewards
function completeQuest(playerId, questId)
    if not playerQuests[playerId] or not playerQuests[playerId].active[questId] then
        return false
    end

    local questData = Quests.Available[questId]
    local player = NDCore:getPlayer(playerId)

    if not player then
        return false
    end

    -- Give cash reward
    if questData.rewards.cash then
        player.addMoney("cash", questData.rewards.cash)
    end

    -- Give item rewards
    if questData.rewards.items then
        for _, item in ipairs(questData.rewards.items) do
            ox_inventory:AddItem(playerId, item.name, item.count)
        end
    end

    -- Move quest to completed
    playerQuests[playerId].completed[questId] = {
        completedTime = os.time(),
        dealerId = playerQuests[playerId].active[questId].dealerId
    }

    -- Set cooldown
    local cooldownKey = playerId .. "_" .. questId
    questCooldowns[cooldownKey] = os.time()

    -- Remove from active quests
    playerQuests[playerId].active[questId] = nil

    -- Notify client
    TriggerClientEvent('ND_SecretMarkets:questCompleted', playerId, questId, questData.rewards)

    return true
end

-- Network Events
RegisterNetEvent('ND_SecretMarkets:requestQuestMenu')
AddEventHandler('ND_SecretMarkets:requestQuestMenu', function(dealerId)
    local src = source
    local availableQuests = getAvailableQuests(dealerId, src)

    TriggerClientEvent('ND_SecretMarkets:showQuestMenu', src, dealerId, availableQuests)
end)

RegisterNetEvent('ND_SecretMarkets:requestTurnInMenu')
AddEventHandler('ND_SecretMarkets:requestTurnInMenu', function(dealerId)
    local src = source
    initializePlayerQuests(src)

    local playerActiveQuests = {}

    -- Get player's active quests
    for questId, questProgress in pairs(playerQuests[src].active) do
        local questData = Quests.Available[questId]
        if questData then
            playerActiveQuests[questId] = questData
        end
    end

    TriggerClientEvent('ND_SecretMarkets:showTurnInMenu', src, dealerId, playerActiveQuests)
end)

RegisterNetEvent('ND_SecretMarkets:acceptQuest')
AddEventHandler('ND_SecretMarkets:acceptQuest', function(dealerId, questId)
    local src = source
    print(('[ND_SecretMarkets] Player %d accepting quest %s from dealer %s'):format(src, questId, dealerId))

    local success, message = startQuest(src, questId, dealerId)

    print(('[ND_SecretMarkets] Quest start result: %s, message: %s'):format(tostring(success), message or 'none'))

    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'Quest accepted: ' .. Quests.Available[questId].title
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('ND_SecretMarkets:updateQuestProgress')
AddEventHandler('ND_SecretMarkets:updateQuestProgress', function(questId, objectiveIndex, progress)
    local src = source

    if not playerQuests[src] or not playerQuests[src].active[questId] then
        return
    end

    local questProgress = playerQuests[src].active[questId]
    if questProgress.objectives[objectiveIndex] then
        questProgress.objectives[objectiveIndex].progress = progress

        -- Check if objective completed
        if progress >= 100 then
            completeObjective(src, questId, objectiveIndex)
        end
    end
end)

RegisterNetEvent('ND_SecretMarkets:completeQuestObjective')
AddEventHandler('ND_SecretMarkets:completeQuestObjective', function(questId, objectiveIndex)
    local src = source
    completeObjective(src, questId, objectiveIndex)
end)

RegisterNetEvent('ND_SecretMarkets:openQuestShop')
AddEventHandler('ND_SecretMarkets:openQuestShop', function(dealerId, availableQuests)
    local src = source
    print(('[ND_SecretMarkets] Opening quest board for dealer %s with %d available quests'):format(dealerId, #(availableQuests or {})))

    -- Send quest data back to client for a custom menu
    TriggerClientEvent('ND_SecretMarkets:showQuestBoard', src, dealerId, availableQuests)
end)

RegisterNetEvent('ND_SecretMarkets:turnInQuest')
AddEventHandler('ND_SecretMarkets:turnInQuest', function(dealerId, questId)
    local src = source

    if not playerQuests[src] or not playerQuests[src].active[questId] then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You don\'t have this quest active'
        })
        return
    end

    local questData = Quests.Available[questId]
    local questProgress = playerQuests[src].active[questId]
    local currentObjective = questProgress.objectives[questProgress.currentObjective]

    -- Check if current objective is a collection type
    if questData.objectives[questProgress.currentObjective].type == 'collect' then
        local objective = questData.objectives[questProgress.currentObjective]
        local hasItems = safeOxInventory('Search', src, 'count', objective.item) or 0

        if hasItems >= objective.amount then
            -- Remove items from inventory
            safeOxInventory('RemoveItem', src, objective.item, objective.amount)

            -- Complete objective
            completeObjective(src, questId, questProgress.currentObjective)

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'Items delivered! Quest objective completed.'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'You need ' .. objective.amount .. 'x ' .. objective.item .. ' to complete this objective'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'This quest cannot be turned in here'
        })
    end
end)

-- Player disconnect cleanup
AddEventHandler('playerDropped', function()
    local src = source
    if playerQuests[src] then
        playerQuests[src] = nil
    end
end)

-- Export functions for other scripts
exports('getPlayerActiveQuests', function(playerId)
    return playerQuests[playerId] and playerQuests[playerId].active or {}
end)

exports('isQuestActive', function(playerId, questId)
    return playerQuests[playerId] and playerQuests[playerId].active[questId] ~= nil
end)

exports('completeQuest', completeQuest)