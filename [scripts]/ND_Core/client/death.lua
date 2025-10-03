local ambulance
local usingAmbulance = false
local alreadyEliminated = false

NDCore.isResourceStarted("ND_Ambulance", function(started)
    usingAmbulance = started
    if not usingAmbulance then return end
    ambulance = exports["ND_Ambulance"]
end)

local function PlayerEliminated(deathCause, killerServerId, killerClientId)
    if alreadyEliminated then return end
    alreadyEliminated = true
    local info = {
        deathCause = deathCause,
        killerServerId = killerServerId,
        killerClientId = killerClientId,
        damagedBones = usingAmbulance and ambulance:getBodyDamage() or {}
    }
    TriggerEvent("ND:playerEliminated", info)
    TriggerServerEvent("ND:playerEliminated", info)
    Wait(1000)
    alreadyEliminated = false
end

AddEventHandler("gameEventTriggered", function(name, args)
	if name ~= "CEventNetworkEntityDamage" then return end

	local victim = args[1]
	if not IsPedAPlayer(victim) or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId then return end

    local hit, bone = GetPedLastDamageBone(victim)
    if hit and usingAmbulance then
        local damageWeapon = ambulance:getLastDamagingWeapon(victim)
        ambulance:updateBodyDamage(bone, damageWeapon)
    end
    
    if not IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) > 100 then return end

    local killerEntity, deathCause = GetPedSourceOfDeath(cache.ped), GetPedCauseOfDeath(cache.ped)
    local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
    if killerEntity ~= cache.ped and killerClientId and NetworkIsPlayerActive(killerClientId) then
        return PlayerEliminated(deathCause, GetPlayerServerId(killerClientId), killerClientId)
    end
    PlayerEliminated(deathCause)
end)

local firstSpawn = true

-- Check if spawnmanager export exists before calling
CreateThread(function()
    local retryCount = 0
    while retryCount < 10 do
        local success, result = pcall(function()
            return exports.spawnmanager and exports.spawnmanager.setAutoSpawnCallback
        end)

        if success and result then
            exports.spawnmanager:setAutoSpawnCallback(function()
                if firstSpawn then
                    firstSpawn = false
                    return exports.spawnmanager:spawnPlayer() and exports.spawnmanager:setAutoSpawn(false)
                end
            end)
            return
        end

        retryCount = retryCount + 1
        Wait(1000)
    end

    -- Fallback for newer spawnmanager versions or if export not found
    while not NetworkIsSessionStarted() do
        Wait(100)
    end

    if firstSpawn then
        firstSpawn = false
        -- Use alternative spawn method
        DoScreenFadeOut(500)
        Wait(500)
        DoScreenFadeIn(500)
    end
end)
