local isJailed = false
local jailReason = ""
local lastNotification = 0

-- Open admin menu
RegisterNetEvent('ND_OOCJail:openMenu', function()
    -- Get all online players
    local players = lib.callback.await('ND_OOCJail:getPlayers', false)

    if not players or #players == 0 then
        lib.notify({
            title = 'No Players',
            description = 'No players online',
            type = 'error'
        })
        return
    end

    -- Build player list for menu
    local options = {}

    for _, player in ipairs(players) do
        local statusIcon = player.isJailed and '🔒' or '✅'
        local statusText = player.isJailed and ' [JAILED]' or ''

        table.insert(options, {
            title = statusIcon .. ' ' .. player.name .. statusText,
            description = 'ID: ' .. player.id,
            icon = player.isJailed and 'lock' or 'user',
            onSelect = function()
                openPlayerMenu(player)
            end
        })
    end

    -- Show menu
    lib.registerContext({
        id = 'oocjail_menu',
        title = 'OOC Jail Management',
        options = options
    })

    lib.showContext('oocjail_menu')
end)

-- Open player-specific menu
function openPlayerMenu(player)
    local options = {}

    if player.isJailed then
        -- Show unjail option
        table.insert(options, {
            title = '🔓 Release from OOC Jail',
            description = 'Remove player from OOC jail',
            icon = 'unlock',
            onSelect = function()
                local success = lib.callback.await('ND_OOCJail:unjailPlayer', false, player.id)
                if success then
                    lib.notify({
                        title = 'Success',
                        description = player.name .. ' has been released',
                        type = 'success'
                    })
                end
            end
        })
    else
        -- Show jail option
        table.insert(options, {
            title = '🔒 Send to OOC Jail',
            description = 'Place player in OOC jail',
            icon = 'lock',
            onSelect = function()
                -- Show reason input
                local input = lib.inputDialog('OOC Jail Reason', {
                    {
                        type = 'textarea',
                        label = 'Reason',
                        description = 'Enter the reason for jailing this player',
                        required = true,
                        min = 10,
                        max = 500
                    }
                })

                if input and input[1] then
                    local success = lib.callback.await('ND_OOCJail:jailPlayer', false, player.id, input[1])
                    if success then
                        lib.notify({
                            title = 'Success',
                            description = player.name .. ' has been jailed',
                            type = 'success'
                        })
                    end
                end
            end
        })
    end

    -- Back button
    table.insert(options, {
        title = '← Back',
        icon = 'arrow-left',
        onSelect = function()
            ExecuteCommand('oocjail')
        end
    })

    lib.registerContext({
        id = 'oocjail_player_menu',
        title = 'OOC Jail - ' .. player.name,
        menu = 'oocjail_menu',
        options = options
    })

    lib.showContext('oocjail_player_menu')
end

-- Player gets jailed
RegisterNetEvent('ND_OOCJail:jailed', function(reason)
    isJailed = true
    jailReason = reason or "Server rule violation"

    -- Notify player
    lib.notify({
        title = Config.Messages.JailNotification.title,
        description = Config.Messages.JailNotification.description,
        duration = Config.Messages.JailNotification.duration,
        position = Config.Messages.JailNotification.position,
        type = Config.Messages.JailNotification.type
    })

    -- Start jail routine
    TriggerEvent('ND_OOCJail:startJailRoutine')
end)

-- Player gets unjailed
RegisterNetEvent('ND_OOCJail:unjailed', function()
    isJailed = false
    jailReason = ""

    -- Notify player
    lib.notify({
        title = Config.Messages.UnjailNotification.title,
        description = Config.Messages.UnjailNotification.description,
        duration = Config.Messages.UnjailNotification.duration,
        position = Config.Messages.UnjailNotification.position,
        type = Config.Messages.UnjailNotification.type
    })
end)

-- Start jail routine (teleporting, restrictions)
RegisterNetEvent('ND_OOCJail:startJailRoutine', function()
    CreateThread(function()
        while isJailed do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local jailCoords = vector3(Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z)

            -- Check distance from jail
            local distance = #(playerCoords - jailCoords)

            -- If player is too far from jail, teleport them back
            if distance > 10.0 then
                SetEntityCoords(playerPed, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
                SetEntityHeading(playerPed, Config.JailLocation.heading)
            end

            -- Show reminder notification every 5 minutes
            if GetGameTimer() - lastNotification > Config.Messages.ReminderInterval then
                lib.notify({
                    title = 'OOC JAIL REMINDER',
                    description = 'You are still awaiting a Staff Judge.\n\nReason: ' .. jailReason,
                    duration = 10000,
                    position = 'top',
                    type = 'warning'
                })
                lastNotification = GetGameTimer()
            end

            Wait(Config.JailSettings.CheckInterval)
        end
    end)
end)

-- Check jail status on spawn
AddEventHandler('playerSpawned', function()
    Wait(3000) -- Wait for character to fully load

    local jailed = lib.callback.await('ND_OOCJail:isJailed', false)

    if jailed then
        isJailed = true
        TriggerEvent('ND_OOCJail:startJailRoutine')
    end
end)

-- Export to check jail status
exports('isJailed', function()
    return isJailed
end)
