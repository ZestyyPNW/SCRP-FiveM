-- =====================================================
-- EXAMPLE FUEL INTEGRATION FOR TILTEDHUD
-- =====================================================
-- Add this to your client-side script or fuel resource
-- Modify according to your fuel system

-- Configuration
local UPDATE_INTERVAL = 1000 -- Update fuel display every 1 second (1000ms)
local FUEL_DECAY_RATE = 0.1 -- Fuel consumption rate per second (adjust as needed)

-- Variables
local currentFuel = 100
local lastVehicle = nil
local isInVehicle = false

-- =====================================================
-- METHOD 1: Basic Integration (Standalone)
-- =====================================================

CreateThread(function()
    while true do
        Wait(UPDATE_INTERVAL)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            if not isInVehicle then
                -- Player just entered vehicle
                isInVehicle = true
                lastVehicle = vehicle

                -- Get initial fuel level (use your fuel system here)
                currentFuel = GetVehicleFuelLevel(vehicle) -- Replace with your fuel system

                -- Show fuel display
                SendNUIMessage({
                    type = 'updateFuel',
                    fuel = currentFuel
                })
            else
                -- Player is in vehicle, update fuel
                -- Replace this with your actual fuel system logic
                local fuelLevel = GetVehicleFuelLevel(vehicle) -- Replace with your fuel system

                SendNUIMessage({
                    type = 'updateFuel',
                    fuel = fuelLevel
                })
            end
        else
            if isInVehicle then
                -- Player just exited vehicle
                isInVehicle = false
                lastVehicle = nil

                -- Hide fuel display
                SendNUIMessage({
                    type = 'hideFuel'
                })
            end
        end
    end
end)

-- =====================================================
-- METHOD 2: Event-Based Integration (for existing fuel systems)
-- =====================================================

-- Listen for fuel updates from your fuel system
RegisterNetEvent('fuel:client:update')
AddEventHandler('fuel:client:update', function(fuelLevel)
    SendNUIMessage({
        type = 'updateFuel',
        fuel = fuelLevel
    })
end)

-- =====================================================
-- METHOD 3: Export-Based Integration
-- =====================================================

-- If your fuel system exports fuel data, use this:
CreateThread(function()
    while true do
        Wait(UPDATE_INTERVAL)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            -- Example: Using LegacyFuel export
            -- local fuelLevel = exports['LegacyFuel']:GetFuel(vehicle)

            -- Example: Using custom fuel export
            -- local fuelLevel = exports['your-fuel-resource']:GetVehicleFuel(vehicle)

            -- Replace with your export call
            local fuelLevel = GetVehicleFuelLevel(vehicle)

            SendNUIMessage({
                type = 'updateFuel',
                fuel = fuelLevel
            })
        else
            SendNUIMessage({
                type = 'hideFuel'
            })
        end
    end
end)

-- =====================================================
-- METHOD 4: BigDaddy Fuel Integration Example
-- =====================================================

-- If using BigDaddy fuel system
CreateThread(function()
    while true do
        Wait(UPDATE_INTERVAL)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            -- Get fuel from BigDaddy system (adjust export name as needed)
            -- local fuelLevel = exports['bd-fuel']:GetFuel(vehicle)

            -- Or if BigDaddy uses entity state
            local fuelLevel = Entity(vehicle).state.fuel or 100

            SendNUIMessage({
                type = 'updateFuel',
                fuel = fuelLevel
            })
        else
            SendNUIMessage({
                type = 'hideFuel'
            })
        end
    end
end)

-- =====================================================
-- METHOD 5: State Bag Integration (Modern FiveM)
-- =====================================================

-- Monitor vehicle fuel via statebags
CreateThread(function()
    local currentVehicle = nil

    while true do
        Wait(500)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and vehicle ~= currentVehicle then
            currentVehicle = vehicle

            -- Listen for fuel changes via statebag
            AddStateBagChangeHandler('fuel', ('vehicle:%s'):format(vehicle), function(bagName, key, value)
                if value then
                    SendNUIMessage({
                        type = 'updateFuel',
                        fuel = value
                    })
                end
            end)
        elseif vehicle == 0 and currentVehicle then
            currentVehicle = nil
            SendNUIMessage({
                type = 'hideFuel'
            })
        end
    end
end)

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Manual fuel update function (call from anywhere)
function UpdateFuelDisplay(fuelLevel)
    SendNUIMessage({
        type = 'updateFuel',
        fuel = fuelLevel
    })
end

-- Hide fuel display manually
function HideFuelDisplay()
    SendNUIMessage({
        type = 'hideFuel'
    })
end

-- Export these functions if needed
exports('UpdateFuelDisplay', UpdateFuelDisplay)
exports('HideFuelDisplay', HideFuelDisplay)

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

--[[

Example 1: Update from another resource
exports['TiltedHUD']:UpdateFuelDisplay(75)

Example 2: Hide from another resource
exports['TiltedHUD']:HideFuelDisplay()

Example 3: Use in a command
RegisterCommand('testfuel', function(source, args)
    local fuelLevel = tonumber(args[1]) or 50
    SendNUIMessage({
        type = 'updateFuel',
        fuel = fuelLevel
    })
end, false)

Example 4: Gradual fuel consumption simulation
CreateThread(function()
    local fuel = 100

    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            -- Simulate fuel consumption
            fuel = math.max(0, fuel - 0.1)

            SendNUIMessage({
                type = 'updateFuel',
                fuel = fuel
            })

            -- Refill if empty (for testing)
            if fuel <= 0 then
                fuel = 100
            end
        end
    end
end)

]]

print('^2[TiltedHUD]^7 Fuel integration example loaded. Uncomment the method you want to use.')
