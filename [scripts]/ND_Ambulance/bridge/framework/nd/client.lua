local bridge = {}
local NDCore

-- Load NDCore safely
CreateThread(function()
    while not NDCore do
        local success, result = pcall(require, "@ND_Core.init")
        if success and type(result) == 'table' then
            NDCore = result
        else
            Wait(1000)
        end
    end
end)

local player

-- Wait for player to be loaded before getting data
CreateThread(function()
    while not NDCore or not player do
        if NDCore then
            player = NDCore.getPlayer()
        end
        if not player then
            Wait(1000)
        end
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    player = NDCore.getPlayer()
end)

RegisterNetEvent("ND:characterLoaded", function(character)
    player = character
end)

RegisterNetEvent("ND:updateCharacter", function(character)
    player = character
end)

function bridge.hasJobs(jobs)
    return player and lib.table.contains(jobs, player.job)
end

function bridge.notify(data)
    NDCore.notify(data)
end

function bridge.createAiPed(info)
    if NDCore and NDCore.createAiPed then
        NDCore.createAiPed(info)
    end
end

function bridge.isDead()
    return player and player.metadata.dead
end

return bridge