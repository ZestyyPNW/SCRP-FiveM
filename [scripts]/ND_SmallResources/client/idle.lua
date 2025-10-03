local isIdle = false
local lastPosition = nil
local idleTimer = 0
local currentIdleEmote = nil
local lastIdleEmote = nil
local cycleTimer = 0

-- List of controls to monitor for keyboard input (excludes mouse movements)
local keyboardControls = {
    -- Movement
    30, 31, 32, 33, 34, 35, -- Move L/R, Up/Down, Left, Right, Cover, Reload
    21, 22, 36, -- Sprint, Jump, Stealth

    -- Actions
    24, 25, 45, 80, 140, 141, 142, 143, -- Attack, Aim, Reload, VEH_CIN_CAM, Melee Attack Light/Heavy/Alternate
    37, 44, -- Select Weapon, Cover
    23, -- Enter Vehicle
    75, -- Exit Vehicle

    -- Phone/Interaction
    27, 47, 74, 289, -- Phone, Detonate, Headlight, Interaction Menu

    -- Other
    19, 20, -- Alt, Z (character switch/special ability)
}

-- Check if player has moved
local function hasPlayerMoved()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return false end

    local currentPos = GetEntityCoords(ped)

    if not lastPosition then
        lastPosition = currentPos
        return false
    end

    -- Check if position has changed (with configurable threshold)
    local distance = #(currentPos - lastPosition)
    lastPosition = currentPos

    return distance > Config.IdleSystem.movementThreshold
end

-- Check if player is in a valid state for idle animations
local function canPlayIdleAnimation()
    local ped = PlayerPedId()

    -- Don't play if player doesn't exist
    if not DoesEntityExist(ped) then return false end

    -- Don't play if player is dead
    if IsEntityDead(ped) then return false end

    -- Don't play if player is in a vehicle
    if IsPedInAnyVehicle(ped, false) then return false end

    -- Don't play if player is swimming
    if IsPedSwimming(ped) then return false end

    -- Don't play if player is climbing
    if IsPedClimbing(ped) then return false end

    -- Don't play if player is jumping
    if IsPedJumping(ped) then return false end

    -- Don't play if player is falling
    if IsPedFalling(ped) then return false end

    -- Don't play if player is ragdolling
    if IsPedRagdoll(ped) then return false end

    -- Don't play if player is in combat
    if IsPedInMeleeCombat(ped) then return false end

    -- Don't play if player is shooting
    if IsPedShooting(ped) then return false end

    return true
end

-- Play a random idle emote (avoids repeating the last emote)
local function playRandomIdleEmote()
    if not Config.IdleSystem.enabled then return end
    if not canPlayIdleAnimation() then return end

    -- Check if rpemotes-reborn exists
    if GetResourceState("rpemotes-reborn") ~= "started" then
        return
    end

    -- Select random emote from config (avoid repeating the same one)
    local randomEmote
    if #Config.IdleEmotes > 1 then
        repeat
            randomEmote = Config.IdleEmotes[math.random(#Config.IdleEmotes)]
        until randomEmote ~= lastIdleEmote
    else
        randomEmote = Config.IdleEmotes[1]
    end

    lastIdleEmote = randomEmote
    currentIdleEmote = randomEmote

    -- Trigger the emote using rpemotes export
    local success = pcall(function()
        exports["rpemotes-reborn"]:EmoteCommandStart(randomEmote)
    end)

    if success then
        isIdle = true
        cycleTimer = 0 -- Reset cycle timer when new animation plays
    end
end

-- Check if any keyboard key is pressed (excluding mouse movements)
local function isKeyboardPressed()
    for _, control in ipairs(keyboardControls) do
        if IsControlPressed(0, control) or IsControlJustPressed(0, control) then
            return true
        end
    end
    return false
end

-- Cancel current idle emote
local function cancelIdleEmote()
    if not isIdle then return end
    if not currentIdleEmote then return end

    -- Cancel the emote using rpemotes export
    pcall(function()
        exports["rpemotes-reborn"]:EmoteCancel()
    end)

    isIdle = false
    currentIdleEmote = nil
    lastIdleEmote = nil
    idleTimer = 0
    cycleTimer = 0
end

-- Main idle detection thread
CreateThread(function()
    if not Config.IdleSystem.enabled then return end

    while true do
        Wait(Config.IdleSystem.checkInterval)

        -- Only check if player is on foot and not in special state
        if canPlayIdleAnimation() then
            -- Check if player has moved or pressed a key
            local hasMoved = hasPlayerMoved()
            local keyPressed = isKeyboardPressed()

            if hasMoved or keyPressed then
                -- Player moved or pressed a key, reset idle timer
                idleTimer = 0

                -- Cancel idle emote if playing
                if isIdle and Config.IdleSystem.cancelOnMovement then
                    cancelIdleEmote()
                end
            else
                -- Player hasn't moved or pressed keys, increment timer
                idleTimer = idleTimer + Config.IdleSystem.checkInterval

                -- Check if player has been idle long enough
                if idleTimer >= Config.IdleSystem.idleTime then
                    if not isIdle then
                        -- Player just became idle, play first random animation
                        playRandomIdleEmote()
                    else
                        -- Player is already idle, check if we should cycle to next animation
                        cycleTimer = cycleTimer + Config.IdleSystem.checkInterval

                        if cycleTimer >= Config.IdleSystem.cycleTime then
                            -- Time to play a new animation
                            playRandomIdleEmote()
                        end
                    end
                end
            end
        else
            -- Player is in an invalid state, reset everything
            if isIdle then
                cancelIdleEmote()
            end
            idleTimer = 0
        end
    end
end)

-- OPTIMIZED: Check less frequently while maintaining responsiveness (10 FPS improvement)
CreateThread(function()
    if not Config.IdleSystem.enabled then return end

    while true do
        -- Check 10 times/sec instead of 60+ for good responsiveness with better performance
        Wait(100)

        -- Only check if an idle emote is currently playing
        if isIdle then
            if isKeyboardPressed() then
                cancelIdleEmote()
            end
        end
    end
end)

-- Event handlers
RegisterNetEvent('ND_SmallResources:client:cancelIdle', function()
    cancelIdleEmote()
end)

-- Commands for testing
RegisterCommand('testidleemote', function()
    playRandomIdleEmote()
end, false)

RegisterCommand('cancelidle', function()
    cancelIdleEmote()
end, false)

-- Export functions
exports('PlayIdleEmote', playRandomIdleEmote)
exports('CancelIdleEmote', cancelIdleEmote)
exports('IsPlayerIdle', function() return isIdle end)
