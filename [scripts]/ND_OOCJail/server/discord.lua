-- Discord Bot Communication

-- Assign Discord role when player is jailed
RegisterNetEvent('ND_OOCJail:assignDiscordRole', function(discordId, reason, adminName)
    -- Send request to Discord bot API
    PerformHttpRequest(Config.Discord.BotAPIUrl .. '/jail', function(statusCode, response, headers)
        if statusCode == 200 then
            print(("[OOC Jail] Successfully assigned role to Discord ID: %s"):format(discordId))
        else
            print(("[OOC Jail] Failed to assign role. Status: %s, Response: %s"):format(statusCode, response))
        end
    end, 'POST', json.encode({
        discordId = discordId,
        action = 'jail',
        reason = reason,
        adminName = adminName
    }), {['Content-Type'] = 'application/json'})
end)

-- Remove Discord role when player is unjailed
RegisterNetEvent('ND_OOCJail:removeDiscordRole', function(discordId, adminName)
    -- Send request to Discord bot API
    PerformHttpRequest(Config.Discord.BotAPIUrl .. '/unjail', function(statusCode, response, headers)
        if statusCode == 200 then
            print(("[OOC Jail] Successfully removed role from Discord ID: %s"):format(discordId))
        else
            print(("[OOC Jail] Failed to remove role. Status: %s, Response: %s"):format(statusCode, response))
        end
    end, 'POST', json.encode({
        discordId = discordId,
        action = 'unjail',
        adminName = adminName
    }), {['Content-Type'] = 'application/json'})
end)

-- Function to check if player has required Discord role
function checkDiscordRole(discordId, requiredRoles)
    local hasRole = false

    -- Synchronous HTTP request to check role
    local promise = promise.new()

    PerformHttpRequest(Config.Discord.BotAPIUrl .. '/checkrole', function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.hasRole then
                hasRole = true
            end
        end
        promise:resolve(hasRole)
    end, 'POST', json.encode({
        discordId = discordId,
        requiredRoles = requiredRoles
    }), {['Content-Type'] = 'application/json'})

    return Citizen.Await(promise)
end
