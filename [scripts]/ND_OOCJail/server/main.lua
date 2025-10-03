local NDCore = exports["ND_Core"]

-- Store jailed players in memory for quick access
local jailedPlayers = {}

-- Function to check if player has required Discord role
local function hasPermission(source, requiredRoles)
    local identifiers = GetPlayerIdentifiers(source)
    local discordId = nil

    for _, id in pairs(identifiers) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if not discordId then
        return false
    end

    -- Check roles via Discord bot API (direct call, not callback)
    local hasRole = checkDiscordRole(discordId, requiredRoles)
    return hasRole or false
end

-- Jail a player
local function jailPlayer(targetId, adminId, reason)
    local player = NDCore:getPlayer(targetId)
    if not player then return false, "Player not found" end

    local targetIdentifiers = GetPlayerIdentifiers(targetId)
    local discordId = nil

    for _, id in pairs(targetIdentifiers) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if not discordId then
        return false, "Player has no Discord linked"
    end

    -- Update character metadata
    player.setMetadata("oocJailed", true)
    player.setMetadata("oocJailReason", reason or "Server rule violation")
    player.setMetadata("oocJailTime", os.time())
    player.setMetadata("oocJailedBy", GetPlayerName(adminId))

    -- Add to memory
    jailedPlayers[targetId] = true

    -- Send Discord role assignment request
    TriggerEvent('ND_OOCJail:assignDiscordRole', discordId, reason, GetPlayerName(adminId))

    -- Notify target player
    TriggerClientEvent('ND_OOCJail:jailed', targetId, reason)

    return true, "Player jailed successfully"
end

-- Unjail a player
local function unjailPlayer(targetId, adminId)
    local player = NDCore:getPlayer(targetId)
    if not player then return false, "Player not found" end

    local targetIdentifiers = GetPlayerIdentifiers(targetId)
    local discordId = nil

    for _, id in pairs(targetIdentifiers) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if not discordId then
        return false, "Player has no Discord linked"
    end

    -- Update character metadata
    player.setMetadata("oocJailed", false)
    player.setMetadata("oocJailReason", nil)
    player.setMetadata("oocJailTime", nil)
    player.setMetadata("oocJailedBy", nil)

    -- Remove from memory
    jailedPlayers[targetId] = nil

    -- Remove Discord role
    TriggerEvent('ND_OOCJail:removeDiscordRole', discordId, GetPlayerName(adminId))

    -- Notify target player
    TriggerClientEvent('ND_OOCJail:unjailed', targetId)

    return true, "Player unjailed successfully"
end

-- Check jail status on player load
RegisterNetEvent('ND:characterLoaded', function(character)
    local source = source

    Wait(2000) -- Wait for full character load

    if character.metadata and character.metadata.oocJailed then
        jailedPlayers[source] = true
        TriggerClientEvent('ND_OOCJail:jailed', source, character.metadata.oocJailReason or "Server rule violation")
    end
end)

-- Admin command to open jail menu
RegisterCommand('oocjail', function(source, args, rawCommand)
    if source == 0 then
        print("This command cannot be run from console")
        return
    end

    -- Check permission
    if not hasPermission(source, Config.Permissions.AdminRoles) then
        lib.notify(source, {
            title = 'Permission Denied',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    -- Open jail menu
    TriggerClientEvent('ND_OOCJail:openMenu', source)
end, false)

-- Callback to jail player from menu
lib.callback.register('ND_OOCJail:jailPlayer', function(source, targetId, reason)
    local success, message = jailPlayer(targetId, source, reason)

    if success then
        lib.notify(source, {
            title = 'Success',
            description = message,
            type = 'success'
        })
    else
        lib.notify(source, {
            title = 'Error',
            description = message,
            type = 'error'
        })
    end

    return success
end)

-- Callback to unjail player
lib.callback.register('ND_OOCJail:unjailPlayer', function(source, targetId)
    -- Check permission for judges/admins
    if not hasPermission(source, Config.Permissions.JudgeRoles) then
        lib.notify(source, {
            title = 'Permission Denied',
            description = 'Only judges and admins can unjail players',
            type = 'error'
        })
        return false
    end

    local success, message = unjailPlayer(targetId, source)

    if success then
        lib.notify(source, {
            title = 'Success',
            description = message,
            type = 'success'
        })
    else
        lib.notify(source, {
            title = 'Error',
            description = message,
            type = 'error'
        })
    end

    return success
end)

-- Get all online players for menu
lib.callback.register('ND_OOCJail:getPlayers', function(source)
    local players = {}

    for _, playerId in pairs(GetPlayers()) do
        local player = NDCore:getPlayer(tonumber(playerId))
        if player then
            table.insert(players, {
                id = tonumber(playerId),
                name = GetPlayerName(playerId),
                isJailed = jailedPlayers[tonumber(playerId)] or false
            })
        end
    end

    return players
end)

-- Check if player is jailed
lib.callback.register('ND_OOCJail:isJailed', function(source)
    return jailedPlayers[source] or false
end)

-- Player disconnect - keep jail status in database
AddEventHandler('playerDropped', function(reason)
    local source = source
    jailedPlayers[source] = nil
end)

-- Export functions
exports('jailPlayer', jailPlayer)
exports('unjailPlayer', unjailPlayer)
exports('isPlayerJailed', function(source)
    return jailedPlayers[source] or false
end)
