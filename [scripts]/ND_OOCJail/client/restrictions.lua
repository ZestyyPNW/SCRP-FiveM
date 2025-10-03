-- Jail Restrictions - Prevent death escape, remove weapons, block vehicles

CreateThread(function()
    while true do
        local sleep = 1000

        if exports['ND_OOCJail']:isJailed() then
            sleep = 0
            local playerPed = PlayerPedId()

            -- Remove all weapons
            if Config.JailSettings.RemoveWeapons then
                RemoveAllPedWeapons(playerPed, true)
            end

            -- Disable vehicle entry
            if Config.JailSettings.DisableVehicles then
                DisableControlAction(0, 23, true) -- F (Enter Vehicle)
                DisableControlAction(0, 75, true) -- F (Exit Vehicle)

                -- If somehow in vehicle, kick them out
                if IsPedInAnyVehicle(playerPed, false) then
                    TaskLeaveVehicle(playerPed, GetVehiclePedIsIn(playerPed, false), 16)
                end
            end

            -- Handle death
            if IsEntityDead(playerPed) and Config.JailSettings.FreezeOnDeath then
                -- Freeze player when dead
                FreezeEntityPosition(playerPed, true)

                -- Wait for respawn
                while IsEntityDead(playerPed) do
                    Wait(100)
                end

                -- Teleport back to jail on respawn
                Wait(1000)
                SetEntityCoords(playerPed, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
                SetEntityHeading(playerPed, Config.JailLocation.heading)
                FreezeEntityPosition(playerPed, false)

                -- Restore health
                SetEntityHealth(playerPed, 200)
            end

            -- Prevent certain actions
            DisableControlAction(0, 288, true) -- F1 (Phone)
            DisableControlAction(0, 289, true) -- F2 (Inventory)
            DisableControlAction(0, 170, true) -- F3 (Animation menu)
            DisableControlAction(0, 167, true) -- F6 (Radio)
            DisableControlAction(0, 56, true) -- F9 (Context menu)
            DisableControlAction(0, 57, true) -- F10
            DisableControlAction(0, 344, true) -- F11
            DisableControlAction(0, 243, true) -- ~ (Console)
        end

        Wait(sleep)
    end
end)

-- Prevent player from using /respawn or similar commands while jailed
AddEventHandler('ND:revivePlayer', function()
    if exports['ND_OOCJail']:isJailed() then
        CancelEvent()

        -- Teleport back to jail
        local playerPed = PlayerPedId()
        SetEntityCoords(playerPed, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, false)
        SetEntityHeading(playerPed, Config.JailLocation.heading)
        SetEntityHealth(playerPed, 200)
    end
end)
