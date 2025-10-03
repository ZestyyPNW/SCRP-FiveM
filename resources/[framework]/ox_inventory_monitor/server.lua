-- ox_inventory Health Monitor & Auto-Restart System
-- Keeps ox_inventory alive and responsive

local Config = {
    checkInterval = 30000,      -- Check health every 30 seconds
    restartCooldown = 60000,    -- Minimum 60 seconds between restarts
    maxRestarts = 3,            -- Max restarts within cooldown period before giving up
    healthTimeout = 5000,       -- Timeout for health check responses
}

local restartHistory = {}
local isRestarting = false
local lastHealthCheck = GetGameTimer()
local consecutiveFailures = 0

-- Clean old restart history
local function cleanRestartHistory()
    local now = GetGameTimer()
    local cutoff = now - Config.restartCooldown

    local cleaned = {}
    for _, timestamp in ipairs(restartHistory) do
        if timestamp > cutoff then
            table.insert(cleaned, timestamp)
        end
    end
    restartHistory = cleaned
end

-- Check if we can restart (not too many recent restarts)
local function canRestart()
    cleanRestartHistory()
    return #restartHistory < Config.maxRestarts
end

-- Perform health check on ox_inventory
local function healthCheck()
    local resourceState = GetResourceState('ox_inventory')

    -- Check if resource is running
    if resourceState ~= 'started' then
        print('^1[OX_MONITOR] ox_inventory is not started (state: '..resourceState..'), attempting restart...^7')
        return false
    end

    -- Check if exports are available
    local success, result = pcall(function()
        return exports.ox_inventory ~= nil
    end)

    if not success or not result then
        print('^3[OX_MONITOR] ox_inventory exports not available^7')
        return false
    end

    -- Try to call a simple export to verify functionality
    success, result = pcall(function()
        return exports.ox_inventory:Items() ~= nil
    end)

    if not success then
        print('^3[OX_MONITOR] ox_inventory exports not responding: '..tostring(result)..'^7')
        return false
    end

    return true
end

-- Restart ox_inventory with optimization
local function restartInventory()
    if isRestarting then
        print('^3[OX_MONITOR] Restart already in progress, skipping...^7')
        return
    end

    if not canRestart() then
        print('^1[OX_MONITOR] Too many restarts in short period, manual intervention required^7')
        print('^1[OX_MONITOR] Please check ox_inventory configuration and server logs^7')
        return
    end

    isRestarting = true
    table.insert(restartHistory, GetGameTimer())

    print('^3[OX_MONITOR] Restarting ox_inventory...^7')

    -- Notify all players of brief inventory downtime
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 165, 0},
        multiline = false,
        args = {'[System]', 'Inventory system restarting, please wait...'}
    })

    -- Stop the resource
    ExecuteCommand('stop ox_inventory')

    -- Wait a moment for clean shutdown
    Wait(2000)

    -- Start the resource
    ExecuteCommand('start ox_inventory')

    -- Wait for startup
    Wait(5000)

    -- Verify restart
    local healthy = healthCheck()

    if healthy then
        print('^2[OX_MONITOR] ox_inventory restarted successfully^7')
        consecutiveFailures = 0

        TriggerClientEvent('chat:addMessage', -1, {
            color = {0, 255, 0},
            multiline = false,
            args = {'[System]', 'Inventory system restored'}
        })
    else
        print('^1[OX_MONITOR] ox_inventory restart failed health check^7')
        consecutiveFailures = consecutiveFailures + 1

        if consecutiveFailures >= 3 then
            print('^1[OX_MONITOR] CRITICAL: ox_inventory failed to restart after 3 attempts^7')
            print('^1[OX_MONITOR] Please check server logs and restart manually^7')
        end
    end

    isRestarting = false
end

-- Monitor loop
CreateThread(function()
    -- Initial startup wait
    Wait(10000)

    print('^2[OX_MONITOR] ox_inventory health monitor started^7')
    print('^2[OX_MONITOR] Checking every '..math.floor(Config.checkInterval/1000)..' seconds^7')

    while true do
        Wait(Config.checkInterval)

        if not isRestarting then
            local healthy = healthCheck()
            lastHealthCheck = GetGameTimer()

            if not healthy then
                consecutiveFailures = consecutiveFailures + 1
                print('^3[OX_MONITOR] Health check failed ('..consecutiveFailures..' consecutive failures)^7')

                if consecutiveFailures >= 2 then
                    -- Two failures in a row = restart
                    restartInventory()
                end
            else
                -- Reset failure counter on success
                if consecutiveFailures > 0 then
                    consecutiveFailures = 0
                end
            end
        end
    end
end)

-- Command to manually check health
RegisterCommand('oxhealth', function(source, args, rawCommand)
    if source ~= 0 then return end -- Console only

    print('^3[OX_MONITOR] Running manual health check...^7')
    local healthy = healthCheck()

    if healthy then
        print('^2[OX_MONITOR] ox_inventory is healthy^7')
        print('^2[OX_MONITOR] Consecutive failures: '..consecutiveFailures..'^7')
        print('^2[OX_MONITOR] Restarts in last minute: '..#restartHistory..'^7')
    else
        print('^1[OX_MONITOR] ox_inventory is unhealthy^7')
        print('^1[OX_MONITOR] Use "oxrestart" to force restart^7')
    end
end, true)

-- Command to manually restart ox_inventory
RegisterCommand('oxrestart', function(source, args, rawCommand)
    if source ~= 0 then return end -- Console only

    print('^3[OX_MONITOR] Manual restart requested...^7')
    restartInventory()
end, true)

-- Command to view restart history
RegisterCommand('oxstatus', function(source, args, rawCommand)
    if source ~= 0 then return end -- Console only

    cleanRestartHistory()
    print('^3[OX_MONITOR] === ox_inventory Status ===^7')
    print('^3[OX_MONITOR] Resource State: '..GetResourceState('ox_inventory')..'^7')
    print('^3[OX_MONITOR] Consecutive Failures: '..consecutiveFailures..'^7')
    print('^3[OX_MONITOR] Restarts (last 60s): '..#restartHistory..'^7')
    print('^3[OX_MONITOR] Is Restarting: '..tostring(isRestarting)..'^7')
    print('^3[OX_MONITOR] Last Health Check: '..math.floor((GetGameTimer() - lastHealthCheck)/1000)..'s ago^7')
    print('^3[OX_MONITOR] ===========================^7')
end, true)

-- Handle ox_inventory stop/start events
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'ox_inventory' and not isRestarting then
        print('^1[OX_MONITOR] WARNING: ox_inventory stopped unexpectedly!^7')

        -- Auto-restart after brief delay
        SetTimeout(3000, function()
            if GetResourceState('ox_inventory') ~= 'started' then
                print('^3[OX_MONITOR] Auto-restarting ox_inventory...^7')
                ExecuteCommand('start ox_inventory')
            end
        end)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' then
        print('^2[OX_MONITOR] ox_inventory started/restarted^7')

        -- Verify health after startup
        SetTimeout(5000, function()
            local healthy = healthCheck()
            if healthy then
                print('^2[OX_MONITOR] ox_inventory startup verified^7')
            else
                print('^1[OX_MONITOR] ox_inventory started but health check failed^7')
            end
        end)
    end
end)

-- Quick restart command (bypasses cooldown for immediate restart)
RegisterCommand('oxquickrestart', function(source, args, rawCommand)
    if source ~= 0 then return end -- Console only

    print('^3[OX_MONITOR] Quick restart initiated (bypassing cooldowns)...^7')

    -- Force stop
    ExecuteCommand('stop ox_inventory')
    Wait(500) -- Shorter wait for manual restarts

    -- Force start
    ExecuteCommand('ensure ox_inventory')

    print('^2[OX_MONITOR] Quick restart complete^7')
end, true)

-- Export health check for other resources
exports('isHealthy', function()
    return healthCheck()
end)

exports('getStatus', function()
    cleanRestartHistory()
    return {
        healthy = healthCheck(),
        consecutiveFailures = consecutiveFailures,
        recentRestarts = #restartHistory,
        isRestarting = isRestarting,
        lastCheck = lastHealthCheck
    }
end)
