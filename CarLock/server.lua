--[[
CarLock - Created by Lama
Modified for ox_inventory integration
For support - https://discord.gg/etkAKTw3M7
Do not edit below if you don't know what you are doing
]]--

local ox_inventory = exports.ox_inventory
local playerVehicles = {} -- Store player vehicles
local hasRunSyncKeys = {} -- Track who has run synckeys

-- Save vehicle and give key
RegisterNetEvent('CarLock:saveVehicle')
AddEventHandler('CarLock:saveVehicle', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        plate = string.gsub(plate, '^%s*(.-)%s*$', '%1') -- Trim whitespace

        -- Check if player already has a key for this vehicle
        local hasKey = ox_inventory:Search(src, 'count', 'car_key', {plate = plate})

        if hasKey and hasKey > 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'You already have keys for this vehicle'
            })
            return
        end

        -- Give the player a key
        local success = ox_inventory:AddItem(src, 'car_key', 1, {
            plate = plate,
            description = 'Car key for vehicle: ' .. plate
        })

        if success then
            -- Store vehicle info
            if not playerVehicles[src] then
                playerVehicles[src] = {}
            end

            playerVehicles[src][plate] = {
                netId = netId,
                plate = plate
            }

            -- Update client with all vehicle data
            TriggerClientEvent('CarLock:updateVehicles', src, playerVehicles[src])

            print("[CarLock] Player " .. src .. " got keys for vehicle: " .. plate)

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You received keys for vehicle: ' .. plate
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'Failed to give you keys'
            })
        end
    end
end)

-- Toggle vehicle lock
RegisterNetEvent('CarLock:toggleLock')
AddEventHandler('CarLock:toggleLock', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        plate = string.gsub(plate, '^%s*(.-)%s*$', '%1') -- Trim whitespace

        -- Check if player has the key
        local hasKey = ox_inventory:Search(src, 'count', 'car_key', {plate = plate})

        -- If they have the key but vehicle isn't tracked, sync
        if hasKey and hasKey > 0 then
            if not playerVehicles[src] or not playerVehicles[src][plate] then
                syncPlayerVehicles(src)
            end
        else
            -- They don't have key for this vehicle, check if they have any keys and haven't been told about synckeys
            local anyKeys = ox_inventory:Search(src, 'count', 'car_key')
            if anyKeys and anyKeys > 0 and not hasRunSyncKeys[src] then
                TriggerClientEvent('ox_lib:notify', src, {
                    type = 'info',
                    description = 'If you have traded keys, run /synckeys to sync your vehicles'
                })
            end
        end

        TriggerClientEvent('CarLock:lockVehicle', src, netId, hasKey and hasKey > 0)
    end
end)

-- Sync player vehicles on join
AddEventHandler('playerJoining', function()
    local src = source
    Citizen.SetTimeout(5000, function() -- Wait for player to fully load
        syncPlayerVehicles(src)
    end)
end)

-- Function to sync vehicles based on keys in inventory
function syncPlayerVehicles(src)
    local keys = ox_inventory:Search(src, 'slots', 'car_key')
    if keys then
        if not playerVehicles[src] then
            playerVehicles[src] = {}
        end

        local updated = false
        for _, key in pairs(keys) do
            if key.metadata and key.metadata.plate then
                local plate = key.metadata.plate
                -- Only add if not already tracked
                if not playerVehicles[src][plate] then
                    -- Find the vehicle with this plate
                    local vehicles = GetAllVehicles()
                    for _, vehicle in pairs(vehicles) do
                        if DoesEntityExist(vehicle) then
                            local vehPlate = GetVehicleNumberPlateText(vehicle)
                            vehPlate = string.gsub(vehPlate, '^%s*(.-)%s*$', '%1')
                            if vehPlate == plate then
                                playerVehicles[src][plate] = {
                                    netId = NetworkGetNetworkIdFromEntity(vehicle),
                                    plate = plate
                                }
                                updated = true
                                break
                            end
                        end
                    end
                end
            end
        end

        if updated then
            TriggerClientEvent('CarLock:updateVehicles', src, playerVehicles[src])
        end
    end
end

-- Clean up vehicles when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    if playerVehicles[src] then
        playerVehicles[src] = nil
    end
    if hasRunSyncKeys[src] then
        hasRunSyncKeys[src] = nil
    end
end)

-- Command to sync vehicles (for testing)
RegisterCommand('synckeys', function(source, args, rawCommand)
    syncPlayerVehicles(source)
    hasRunSyncKeys[source] = true -- Mark that they've run it
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Vehicle keys synced'
    })
end, false)

-- Export for ox_inventory item usage
exports('useKey', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id
        local plate = item.metadata.plate

        if playerVehicles[src] and playerVehicles[src][plate] then
            local vehicle = NetworkGetEntityFromNetworkId(playerVehicles[src][plate].netId)
            if DoesEntityExist(vehicle) then
                local ped = GetPlayerPed(src)
                local pedCoords = GetEntityCoords(ped)
                local vehCoords = GetEntityCoords(vehicle)

                if #(pedCoords - vehCoords) <= 30 then
                    TriggerClientEvent('CarLock:lockVehicle', src, playerVehicles[src][plate].netId, true)
                else
                    TriggerClientEvent('ox_lib:notify', src, {
                        type = 'error',
                        description = 'You must be closer to your vehicle'
                    })
                end
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    type = 'error',
                    description = 'Vehicle not found'
                })
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'No vehicle registered for this key'
            })
        end
    end
end)
