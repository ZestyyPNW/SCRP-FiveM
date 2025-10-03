-- Unified Tilted HUD Server Script
-- Handles priority system commands and AOP management

-- Default values
local currentAOP = "Los Angeles, CA"
local socalStatus = "Available"
local nocalStatus = "Available"
local socalUsers = {}
local nocalUsers = {}
local socalCooldownEnd = 0
local nocalCooldownEnd = 0

-- Helper function to get time remaining in cooldown
local function getCooldownRemaining(endTime)
    local remaining = endTime - os.time()
    return remaining > 0 and remaining or 0
end

-- Helper function to format time as MM:SS
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

-- Helper function to format user list
local function formatUserList(users)
    if #users == 0 then
        return ""
    elseif #users == 1 then
        return users[1]
    else
        return table.concat(users, ", ")
    end
end

-- Helper function to check if user is in list
local function isUserInList(users, playerName)
    for i, user in ipairs(users) do
        if user == playerName then
            return true, i
        end
    end
    return false, 0
end

-- Priority system commands
RegisterCommand('city', function(source, args, rawCommand)
    local player = source

    if not args[1] then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "Usage: /city [start|end|hold|available]"}
        })
        return
    end

    local action = string.lower(args[1])
    local playerName = GetPlayerName(player)

    if action == "start" then
        socalStatus = "Active"
        socalUsers = {playerName}
        local userString = formatUserList(socalUsers)
        TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, userString)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 100, 100},
            args = {"PRIORITY", "SoCal priority started by " .. playerName}
        })
    elseif action == "end" then
        socalStatus = "Cooldown"
        socalUsers = {}
        socalCooldownEnd = os.time() + 300 -- 5 minute cooldown
        TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, "")
        TriggerClientEvent('chat:addMessage', -1, {
            color = {100, 100, 255},
            args = {"PRIORITY", "SoCal priority ended by " .. playerName .. " (5 min cooldown)"}
        })
    elseif action == "hold" then
        socalStatus = "Hold"
        local userString = formatUserList(socalUsers)
        TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, userString)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 200, 100},
            args = {"PRIORITY", "SoCal priority on hold"}
        })
    elseif action == "available" then
        socalStatus = "Available"
        socalUsers = {}
        TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, "")
        TriggerClientEvent('chat:addMessage', -1, {
            color = {100, 255, 100},
            args = {"PRIORITY", "SoCal priority available"}
        })
    end
end, false)

RegisterCommand('county', function(source, args, rawCommand)
    local player = source

    if not args[1] then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "Usage: /county [start|end|hold|available]"}
        })
        return
    end

    local action = string.lower(args[1])
    local playerName = GetPlayerName(player)

    if action == "start" then
        nocalStatus = "Active"
        nocalUsers = {playerName}
        local userString = formatUserList(nocalUsers)
        TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, userString)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 100, 100},
            args = {"PRIORITY", "NoCal priority started by " .. playerName}
        })
    elseif action == "end" then
        nocalStatus = "Cooldown"
        nocalUsers = {}
        nocalCooldownEnd = os.time() + 300 -- 5 minute cooldown
        TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, "")
        TriggerClientEvent('chat:addMessage', -1, {
            color = {100, 100, 255},
            args = {"PRIORITY", "NoCal priority ended by " .. playerName .. " (5 min cooldown)"}
        })
    elseif action == "hold" then
        nocalStatus = "Hold"
        local userString = formatUserList(nocalUsers)
        TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, userString)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 200, 100},
            args = {"PRIORITY", "NoCal priority on hold"}
        })
    elseif action == "available" then
        nocalStatus = "Available"
        nocalUsers = {}
        TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, "")
        TriggerClientEvent('chat:addMessage', -1, {
            color = {100, 255, 100},
            args = {"PRIORITY", "NoCal priority available"}
        })
    end
end, false)

-- AOP command
RegisterCommand('aop', function(source, args, rawCommand)
    local player = source

    if not args[1] then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "Current AOP: " .. currentAOP}
        })
        return
    end

    local newAOP = table.concat(args, " ")
    currentAOP = newAOP

    TriggerClientEvent('UnifiedHUD:updateAOP', -1, currentAOP)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {100, 255, 255},
        args = {"AOP", "Area of Play changed to: " .. currentAOP}
    })
end, false)

-- Join commands for priority system
RegisterCommand('city-join', function(source, args, rawCommand)
    local player = source
    local playerName = GetPlayerName(player)

    if socalStatus ~= "Active" then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "SoCal priority is not currently active"}
        })
        return
    end

    local isInList, _ = isUserInList(socalUsers, playerName)
    if isInList then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "You are already part of the SoCal priority"}
        })
        return
    end

    table.insert(socalUsers, playerName)
    local userString = formatUserList(socalUsers)
    TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, userString)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 150, 100},
        args = {"PRIORITY", playerName .. " joined SoCal priority"}
    })
end, false)

RegisterCommand('county-join', function(source, args, rawCommand)
    local player = source
    local playerName = GetPlayerName(player)

    if nocalStatus ~= "Active" then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "NoCal priority is not currently active"}
        })
        return
    end

    local isInList, _ = isUserInList(nocalUsers, playerName)
    if isInList then
        TriggerClientEvent('chat:addMessage', player, {
            color = {255, 255, 0},
            args = {"SYSTEM", "You are already part of the NoCal priority"}
        })
        return
    end

    table.insert(nocalUsers, playerName)
    local userString = formatUserList(nocalUsers)
    TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, userString)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 150, 100},
        args = {"PRIORITY", playerName .. " joined NoCal priority"}
    })
end, false)

-- Player join handler - send current status
AddEventHandler('playerJoining', function()
    local player = source

    -- Send current status to joining player
    local socalUserString = formatUserList(socalUsers)
    local nocalUserString = formatUserList(nocalUsers)
    TriggerClientEvent('UnifiedHUD:updateSocalStatus', player, socalStatus, socalUserString)
    TriggerClientEvent('UnifiedHUD:updateNocalStatus', player, nocalStatus, nocalUserString)
    TriggerClientEvent('UnifiedHUD:updateAOP', player, currentAOP)
end)

-- Export functions
exports('getCurrentAOP', function()
    return currentAOP
end)

exports('getSocalStatus', function()
    return socalStatus, formatUserList(socalUsers)
end)

exports('getNocalStatus', function()
    return nocalStatus, formatUserList(nocalUsers)
end)

-- Cooldown timer thread
CreateThread(function()
    while true do
        Wait(1000) -- Update every second

        -- Check SoCal cooldown
        if socalStatus == "Cooldown" and socalCooldownEnd > 0 then
            local remaining = getCooldownRemaining(socalCooldownEnd)
            if remaining <= 0 then
                socalStatus = "Available"
                socalUsers = {}
                socalCooldownEnd = 0
                TriggerClientEvent('UnifiedHUD:updateSocalStatus', -1, socalStatus, "")
                TriggerClientEvent('chat:addMessage', -1, {
                    color = {100, 255, 100},
                    args = {"PRIORITY", "SoCal priority now available"}
                })
            else
                -- Send cooldown update with timer
                TriggerClientEvent('UnifiedHUD:updateSocalCooldown', -1, formatTime(remaining))
            end
        end

        -- Check NoCal cooldown
        if nocalStatus == "Cooldown" and nocalCooldownEnd > 0 then
            local remaining = getCooldownRemaining(nocalCooldownEnd)
            if remaining <= 0 then
                nocalStatus = "Available"
                nocalUsers = {}
                nocalCooldownEnd = 0
                TriggerClientEvent('UnifiedHUD:updateNocalStatus', -1, nocalStatus, "")
                TriggerClientEvent('chat:addMessage', -1, {
                    color = {100, 255, 100},
                    args = {"PRIORITY", "NoCal priority now available"}
                })
            else
                -- Send cooldown update with timer
                TriggerClientEvent('UnifiedHUD:updateNocalCooldown', -1, formatTime(remaining))
            end
        end
    end
end)