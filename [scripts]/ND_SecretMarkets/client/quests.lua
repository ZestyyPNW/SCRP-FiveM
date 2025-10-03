local ox_lib = exports.ox_lib

local activeQuests = {}
local questBlips = {}
local questAreas = {}

-- Quest objective handlers
local objectiveHandlers = {
    ['goto'] = function(questId, objective, objectiveIndex)
        print(('[ND_SecretMarkets] Starting goto objective for quest %s'):format(questId))
        print(('[ND_SecretMarkets] Target location: %s, radius: %f'):format(objective.location, objective.radius))

        local coords = objective.location
        local radius = objective.radius

        -- Create blip for location
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(objective.label)
        EndTextCommandSetBlipName(blip)

        questBlips[questId] = questBlips[questId] or {}
        questBlips[questId][objectiveIndex] = blip

        print(('[ND_SecretMarkets] Created blip %d for quest %s'):format(blip, questId))

        -- Create area check thread
        CreateThread(function()
            print(('[ND_SecretMarkets] Starting area check thread for quest %s'):format(questId))

            while activeQuests[questId] and not activeQuests[questId].objectives[objectiveIndex].completed do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)

                if distance <= radius then
                    print(('[ND_SecretMarkets] Player reached objective location for quest %s'):format(questId))
                    -- Complete objective
                    TriggerServerEvent('ND_SecretMarkets:completeQuestObjective', questId, objectiveIndex)
                    break
                end

                Wait(500)
            end

            print(('[ND_SecretMarkets] Area check thread ended for quest %s'):format(questId))

            -- Clean up blip
            if questBlips[questId] and questBlips[questId][objectiveIndex] then
                RemoveBlip(questBlips[questId][objectiveIndex])
                questBlips[questId][objectiveIndex] = nil
                print(('[ND_SecretMarkets] Cleaned up blip for quest %s'):format(questId))
            end
        end)
    end,

    ['collect'] = function(questId, objective, objectiveIndex)
        print(('[ND_SecretMarkets] Starting collect objective for quest %s'):format(questId))
        print(('[ND_SecretMarkets] Need to collect %d x %s'):format(objective.amount, objective.item))

        -- Show an informational notification about where to find evidence bags
        ox_lib:notify({
            type = 'info',
            description = 'Search around police stations and crime scenes for evidence bags. Return to dealer when you have them.'
        })

        -- This objective doesn't auto-complete, player must return to dealer
        -- The dealer interaction will check if player has required items
    end,

    ['eliminate'] = function(questId, objective, objectiveIndex)
        local coords = objective.location
        local radius = objective.radius

        -- Create blip for target area
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 432)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(objective.label)
        EndTextCommandSetBlipName(blip)

        questBlips[questId] = questBlips[questId] or {}
        questBlips[questId][objectiveIndex] = blip

        -- Create target area monitoring
        CreateThread(function()
            while activeQuests[questId] and not activeQuests[questId].objectives[objectiveIndex].completed do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)

                if distance <= radius then
                    -- Show elimination prompt
                    ox_lib:showTextUI('[E] Eliminate Target', {
                        position = "top-center",
                        icon = 'hand'
                    })

                    if IsControlJustPressed(0, 38) then -- E key
                        ox_lib:hideTextUI()
                        TriggerServerEvent('ND_SecretMarkets:completeQuestObjective', questId, objectiveIndex)
                        break
                    end
                else
                    ox_lib:hideTextUI()
                end

                Wait(100)
            end

            ox_lib:hideTextUI()

            -- Clean up blip
            if questBlips[questId] and questBlips[questId][objectiveIndex] then
                RemoveBlip(questBlips[questId][objectiveIndex])
                questBlips[questId][objectiveIndex] = nil
            end
        end)
    end,

    ['hack'] = function(questId, objective, objectiveIndex)
        CreateThread(function()
            local success = exports.ox_lib:skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})

            if success then
                ox_lib:notify({
                    type = 'success',
                    description = 'System hacked successfully'
                })
                TriggerServerEvent('ND_SecretMarkets:completeQuestObjective', questId, objectiveIndex)
            else
                ox_lib:notify({
                    type = 'error',
                    description = 'Hack failed. Try again.'
                })
            end
        end)
    end,

    ['observe'] = function(questId, objective, objectiveIndex)
        local coords = objective.location
        local duration = objective.duration
        local radius = objective.radius

        -- Create blip for observation point
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 469)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(objective.label)
        EndTextCommandSetBlipName(blip)

        questBlips[questId] = questBlips[questId] or {}
        questBlips[questId][objectiveIndex] = blip

        CreateThread(function()
            while activeQuests[questId] and not activeQuests[questId].objectives[objectiveIndex].completed do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)

                if distance <= radius then
                    -- Start observation
                    local progressBar = ox_lib:progressBar({
                        duration = duration,
                        label = 'Observing...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        }
                    })

                    if progressBar then
                        TriggerServerEvent('ND_SecretMarkets:completeQuestObjective', questId, objectiveIndex)
                    end
                    break
                end

                Wait(500)
            end

            -- Clean up blip
            if questBlips[questId] and questBlips[questId][objectiveIndex] then
                RemoveBlip(questBlips[questId][objectiveIndex])
                questBlips[questId][objectiveIndex] = nil
            end
        end)
    end
}

-- Start quest tracking
RegisterNetEvent('ND_SecretMarkets:startQuest')
AddEventHandler('ND_SecretMarkets:startQuest', function(questId, questData)
    print(('[ND_SecretMarkets] Client received startQuest for: %s'):format(questId))
    print(('[ND_SecretMarkets] Quest data: %s'):format(json.encode(questData, {indent = true})))

    activeQuests[questId] = {
        data = questData,
        startTime = GetGameTimer(),
        currentObjective = 1,
        objectives = {}
    }

    -- Initialize objectives
    for i, objective in ipairs(questData.objectives) do
        activeQuests[questId].objectives[i] = {
            completed = false,
            progress = 0
        }
        print(('[ND_SecretMarkets] Initialized objective %d: %s'):format(i, objective.label))
    end

    print(('[ND_SecretMarkets] Starting first objective for quest: %s'):format(questId))

    -- Start first objective
    startObjective(questId, 1)

    -- Start time limit countdown if applicable
    if questData.time_limit then
        CreateThread(function()
            Wait(questData.time_limit)

            if activeQuests[questId] then
                ox_lib:notify({
                    type = 'error',
                    description = 'Quest failed: Time limit exceeded'
                })

                cancelQuest(questId)
            end
        end)
    end

    ox_lib:notify({
        type = 'success',
        description = 'Quest started: ' .. questData.title
    })
end)

-- Start specific objective
function startObjective(questId, objectiveIndex)
    print(('[ND_SecretMarkets] startObjective called for quest %s, objective %d'):format(questId, objectiveIndex))

    local quest = activeQuests[questId]
    if not quest then
        print(('[ND_SecretMarkets] ERROR: Quest %s not found in activeQuests'):format(questId))
        return
    end

    local objective = quest.data.objectives[objectiveIndex]
    if not objective then
        print(('[ND_SecretMarkets] ERROR: Objective %d not found for quest %s'):format(objectiveIndex, questId))
        return
    end

    print(('[ND_SecretMarkets] Starting objective: %s (type: %s)'):format(objective.label, objective.type))

    ox_lib:notify({
        type = 'info',
        description = 'New Objective: ' .. objective.label
    })

    -- Start objective handler
    if objectiveHandlers[objective.type] then
        print(('[ND_SecretMarkets] Found handler for objective type: %s'):format(objective.type))
        objectiveHandlers[objective.type](questId, objective, objectiveIndex)
    else
        print(('[ND_SecretMarkets] ERROR: No handler found for objective type: %s'):format(objective.type))
    end
end

-- Update quest objective
RegisterNetEvent('ND_SecretMarkets:updateQuestObjective')
AddEventHandler('ND_SecretMarkets:updateQuestObjective', function(questId, objectiveIndex)
    if activeQuests[questId] then
        activeQuests[questId].currentObjective = objectiveIndex
        startObjective(questId, objectiveIndex)
    end
end)

-- Quest completion
RegisterNetEvent('ND_SecretMarkets:questCompleted')
AddEventHandler('ND_SecretMarkets:questCompleted', function(questId, rewards)
    if activeQuests[questId] then
        local questData = activeQuests[questId].data

        -- Show completion notification
        local rewardText = {}
        if rewards.cash then
            table.insert(rewardText, '$' .. rewards.cash)
        end
        if rewards.items then
            for _, item in ipairs(rewards.items) do
                table.insert(rewardText, item.count .. 'x ' .. item.name)
            end
        end

        ox_lib:notify({
            type = 'success',
            description = 'Quest Completed: ' .. questData.title .. '\nRewards: ' .. table.concat(rewardText, ', ')
        })

        -- Clean up quest
        cleanupQuest(questId)
    end
end)

-- Cancel quest
function cancelQuest(questId)
    cleanupQuest(questId)

    ox_lib:notify({
        type = 'error',
        description = 'Quest cancelled'
    })
end

-- Clean up quest data
function cleanupQuest(questId)
    if activeQuests[questId] then
        -- Remove blips
        if questBlips[questId] then
            for _, blip in pairs(questBlips[questId]) do
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end
            questBlips[questId] = nil
        end

        -- Remove areas
        if questAreas[questId] then
            questAreas[questId] = nil
        end

        -- Remove quest
        activeQuests[questId] = nil
    end
end

-- Export functions
exports('getActiveQuests', function()
    return activeQuests
end)

exports('isQuestActive', function(questId)
    return activeQuests[questId] ~= nil
end)

-- Client debug event
RegisterNetEvent('ND_SecretMarkets:debugQuests')
AddEventHandler('ND_SecretMarkets:debugQuests', function()
    print('=== Client Active Quests ===')
    print(json.encode(activeQuests, {indent = true}))
end)