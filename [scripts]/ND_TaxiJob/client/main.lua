-- Variables
local player

-- Wait for ND_Core resource to start, then load it
CreateThread(function()
    while GetResourceState('ND_Core') ~= 'started' do
        print("[ND_TaxiJob] Waiting for ND_Core resource to start...")
        Wait(500)
    end

    Wait(1000) -- Extra wait to ensure exports are ready
    print("[ND_TaxiJob] ND_Core resource started, initializing...")
end)

-- Update player when character loads/updates
RegisterNetEvent("ND:characterLoaded", function(character)
    player = character
    print("[ND_TaxiJob] Player loaded via ND:characterLoaded event")
end)

RegisterNetEvent("ND:updateCharacter", function(character)
    player = character
end)

local meterIsOpen = false
local meterActive = false
local lastLocation = nil

local meterData = {
    fareAmount = 6,
    currentFare = 0,
    distanceTraveled = 0,
}

local NpcData = {
    Active = false,
    CurrentNpc = nil,
    LastNpc = nil,
    CurrentDeliver = nil,
    LastDeliver = nil,
    Npc = nil,
    NpcBlip = nil,
    DeliveryBlip = nil,
    NpcTaken = false,
    NpcDelivered = false,
    CountDown = 180
}

-- Functions

local function ResetNpcTask()
    NpcData = {
        Active = false,
        CurrentNpc = nil,
        LastNpc = nil,
        CurrentDeliver = nil,
        LastDeliver = nil,
        Npc = nil,
        NpcBlip = nil,
        DeliveryBlip = nil,
        NpcTaken = false,
        NpcDelivered = false,
    }
end

local function calculateFareAmount()
    if meterIsOpen and meterActive then
        start = lastLocation

        if start then
            current = GetEntityCoords(PlayerPedId())
            distance = #(start - current)
            meterData['distanceTraveled'] = distance

            fareAmount = (meterData['distanceTraveled'] / 400.00) * meterData['fareAmount']

            meterData['currentFare'] = math.ceil(fareAmount)

            SendNUIMessage({
                action = "updateMeter",
                meterData = meterData
            })
        end
    end
end

local function whitelistedVehicle()
    local ped = PlayerPedId()
    local veh = GetEntityModel(GetVehiclePedIsIn(ped))
    local retval = false

    for i = 1, #Config.AllowedVehicles, 1 do
        if veh == GetHashKey(Config.AllowedVehicles[i].model) then
            retval = true
        end
    end

    if veh == GetHashKey("dynasty") then
        retval = true
    end

    return retval
end

local function IsDriver()
    return GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId()
end

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetDeliveryLocation()
    NpcData.CurrentDeliver = math.random(1, #Config.NPCLocations.DeliverLocations)
    if NpcData.LastDeliver ~= nil then
        while NpcData.LastDeliver ~= NpcData.CurrentDeliver do
            NpcData.CurrentDeliver = math.random(1, #Config.NPCLocations.DeliverLocations)
        end
    end

    if NpcData.DeliveryBlip ~= nil then
        RemoveBlip(NpcData.DeliveryBlip)
    end
    NpcData.DeliveryBlip = AddBlipForCoord(Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].x, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].y, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].z)
    SetBlipColour(NpcData.DeliveryBlip, 3)
    SetBlipRoute(NpcData.DeliveryBlip, true)
    SetBlipRouteColour(NpcData.DeliveryBlip, 3)
    NpcData.LastDeliver = NpcData.CurrentDeliver

    CreateThread(function()
        while true do
            Wait(1000)
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].x, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].y, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].z))

            if dist < 50 then
                while true do
                    ped = PlayerPedId()
                    pos = GetEntityCoords(ped)
                    dist = #(pos - vector3(Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].x, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].y, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].z))

                    if dist >= 50 then break end

                    if dist < 20 then
                        DrawMarker(2, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].x, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].y, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                        if dist < 5 then
                            DrawText3D(Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].x, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].y, Config.NPCLocations.DeliverLocations[NpcData.CurrentDeliver].z, "[E] Drop Off NPC")
                            if IsControlJustPressed(0, 38) then
                                local veh = GetVehiclePedIsIn(ped, 0)

                                -- Make NPC leave vehicle and wander off
                                TaskLeaveVehicle(NpcData.Npc, veh, 0)

                                -- Wait for NPC to fully exit, then make them wander
                                SetTimeout(2000, function()
                                    TaskWanderStandard(NpcData.Npc, 10.0, 10)
                                end)

                                SetEntityAsMissionEntity(NpcData.Npc, false, true)
                                SetEntityAsNoLongerNeeded(NpcData.Npc)
                                SendNUIMessage({
                                    action = "toggleMeter"
                                })

                                print("[ND_TaxiJob Client] Triggering payment event with fare: $" .. meterData.currentFare)
                                TriggerServerEvent('ND_TaxiJob:server:NpcPay', meterData.currentFare)

                                meterActive = false
                                SendNUIMessage({
                                    action = "resetMeter"
                                })
                                lib.notify({
                                    title = 'Taxi Job',
                                    description = 'Person was dropped off! Fare: $' .. meterData.currentFare,
                                    type = 'success'
                                })
                                if NpcData.DeliveryBlip ~= nil then
                                    RemoveBlip(NpcData.DeliveryBlip)
                                end
                                local RemovePed = function(ped)
                                    SetTimeout(60000, function()
                                        DeletePed(ped)
                                    end)
                                end
                                RemovePed(NpcData.Npc)
                                ResetNpcTask()
                                return
                            end
                        end
                    end

                    Wait(50)  -- OPTIMIZED: Check 20x/sec instead of 60+
                end
            end
        end
    end)
end

-- Vehicle Garage Menu (using ox_lib)

function TaxiGarage()
    local options = {}

    for veh, v in pairs(Config.AllowedVehicles) do
        options[#options+1] = {
            title = v.label,
            description = 'Spawn a ' .. v.label,
            onSelect = function()
                TriggerEvent("ND_TaxiJob:client:TakeVehicle", v.model)
            end
        }
    end

    lib.registerContext({
        id = 'taxi_garage',
        title = 'Taxi Vehicles',
        options = options
    })

    lib.showContext('taxi_garage')
end

RegisterNetEvent("ND_TaxiJob:client:TakeVehicle", function(model)
    local coords = Config.Location
    lib.requestModel(model)

    local veh = CreateVehicle(GetHashKey(model), coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleNumberPlateText(veh, "TAXI"..tostring(math.random(1000, 9999)))
    SetVehicleFuelLevel(veh, 100.0)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
    SetVehicleEngineOn(veh, true, true)

    -- Show instructions
    lib.notify({
        title = 'Downtown Cab',
        description = 'Vehicle spawned! Use /taxinpc to find a passenger',
        type = 'success',
        duration = 7000
    })

    Wait(3000)
    lib.notify({
        title = 'Taxi Job Guide',
        description = 'Commands:\n/taxinpc - Start a job\n/taximeter - Toggle meter',
        type = 'info',
        duration = 8000
    })
end)

-- Events

RegisterNetEvent('ND_TaxiJob:client:DoTaxiNpc', function()
    if not player then
        lib.notify({
            title = 'Taxi Job',
            description = 'Player data not loaded yet',
            type = 'error'
        })
        return
    end

    if whitelistedVehicle() then
        if not NpcData.Active then
            NpcData.CurrentNpc = math.random(1, #Config.NPCLocations.TakeLocations)
            if NpcData.LastNpc ~= nil then
                while NpcData.LastNpc ~= NpcData.CurrentNpc do
                    NpcData.CurrentNpc = math.random(1, #Config.NPCLocations.TakeLocations)
                end
            end

            local Gender = math.random(1, #Config.NpcSkins)
            local PedSkin = math.random(1, #Config.NpcSkins[Gender])
            local model = GetHashKey(Config.NpcSkins[Gender][PedSkin])
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            NpcData.Npc = CreatePed(3, model, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z - 0.98, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].w, false, true)
            PlaceObjectOnGroundProperly(NpcData.Npc)
            FreezeEntityPosition(NpcData.Npc, true)
            if NpcData.NpcBlip ~= nil then
                RemoveBlip(NpcData.NpcBlip)
            end
            lib.notify({
                title = 'Taxi Job',
                description = 'Passenger found! Follow the GPS waypoint to pick them up',
                type = 'success',
                duration = 7000
            })
            NpcData.NpcBlip = AddBlipForCoord(Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z)
            SetBlipColour(NpcData.NpcBlip, 3)
            SetBlipRoute(NpcData.NpcBlip, true)
            SetBlipRouteColour(NpcData.NpcBlip, 3)
            NpcData.LastNpc = NpcData.CurrentNpc
            NpcData.Active = true

            CreateThread(function()
                while not NpcData.NpcTaken do
                    Wait(1000)

                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    local dist = #(pos - vector3(Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z))

                    if dist < 50 then
                        while not NpcData.NpcTaken do
                            ped = PlayerPedId()
                            pos = GetEntityCoords(ped)
                            dist = #(pos - vector3(Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z))

                            if dist >= 50 then break end

                            if dist < 20 then
                                DrawMarker(2, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)

                                if dist < 5 then
                                    DrawText3D(Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].x, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].y, Config.NPCLocations.TakeLocations[NpcData.CurrentNpc].z, "[E] Call NPC")
                                    if IsControlJustPressed(0, 38) then
                                        local veh = GetVehiclePedIsIn(ped, 0)
                                        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(veh)

                                        for i=maxSeats - 1, 0, -1 do
                                            if IsVehicleSeatFree(veh, i) then
                                                freeSeat = i
                                                break
                                            end
                                        end

                                        meterIsOpen = true
                                        meterActive = true
                                        lastLocation = GetEntityCoords(PlayerPedId())
                                        SendNUIMessage({
                                            action = "openMeter",
                                            toggle = true,
                                            meterData = Config.Meter
                                        })
                                        SendNUIMessage({
                                            action = "toggleMeter"
                                        })
                                        ClearPedTasksImmediately(NpcData.Npc)
                                        FreezeEntityPosition(NpcData.Npc, false)
                                        TaskEnterVehicle(NpcData.Npc, veh, -1, freeSeat, 1.0, 0)
                                        lib.notify({
                                            title = 'Taxi Job',
                                            description = 'Passenger picked up! Follow GPS to drop-off location',
                                            type = 'info',
                                            duration = 7000
                                        })
                                        if NpcData.NpcBlip ~= nil then
                                            RemoveBlip(NpcData.NpcBlip)
                                        end
                                        GetDeliveryLocation()
                                        NpcData.NpcTaken = true
                                    end
                                end
                            end

                            Wait(50)  -- OPTIMIZED: Check 20x/sec instead of 60+
                        end
                    end
                end
            end)
        else
            lib.notify({
                title = 'Taxi Job',
                description = 'You are already doing an NPC mission',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Taxi Job',
            description = 'You are not in a taxi! Spawn one from the Downtown Cab garage',
            type = 'error',
            duration = 6000
        })
    end
end)

RegisterNetEvent('ND_TaxiJob:client:toggleMeter', function()
    if not player then return end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        if whitelistedVehicle() then
            if not meterIsOpen and IsDriver() then
                SendNUIMessage({
                    action = "openMeter",
                    toggle = true,
                    meterData = Config.Meter
                })
                meterIsOpen = true
            else
                SendNUIMessage({
                    action = "openMeter",
                    toggle = false
                })
                meterIsOpen = false
            end
        else
            lib.notify({
                title = 'Taxi Job',
                description = 'This vehicle has no taxi meter',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Taxi Job',
            description = 'You\'re not in a vehicle',
            type = 'error'
        })
    end
end)

RegisterNetEvent('ND_TaxiJob:client:enableMeter', function()
    if not player then return end

    if meterIsOpen then
        SendNUIMessage({
            action = "toggleMeter"
        })
    else
        lib.notify({
            title = 'Taxi Job',
            description = 'The taxi meter is not active',
            type = 'error'
        })
    end
end)

RegisterNetEvent('ND_TaxiJob:client:toggleMuis', function()
    if not player then return end

    Wait(400)
    if meterIsOpen then
        if not mouseActive then
            SetNuiFocus(true, true)
            mouseActive = true
        end
    else
        lib.notify({
            title = 'Taxi Job',
            description = 'No taxi meter in sight',
            type = 'error'
        })
    end
end)

-- NUI Callbacks

RegisterNUICallback('enableMeter', function(data)
    meterActive = data.enabled

    if not data.enabled then
        SendNUIMessage({
            action = "resetMeter"
        })
    end
    lastLocation = GetEntityCoords(PlayerPedId())
end)

RegisterNUICallback('hideMouse', function()
    SetNuiFocus(false, false)
    mouseActive = false
end)

-- Threads

CreateThread(function()
    -- Wait for player to be loaded before starting threads
    while not player do
        Wait(1000)
    end

    while true do
        Wait(2000)
        calculateFareAmount()
    end
end)

CreateThread(function()
    -- Wait for player to be loaded before starting threads
    while not player do
        Wait(1000)
    end

    while true do
        Wait(1000)

        -- Handle both string and table job formats
        local hasTaxiJob = false
        if player then
            if type(player.job) == "string" and player.job == "taxi" then
                hasTaxiJob = true
            elseif type(player.job) == "table" and player.job.name == "taxi" then
                hasTaxiJob = true
            end
        end

        if hasTaxiJob then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local vehDist = #(pos - vector3(Config.Location.x, Config.Location.y, Config.Location.z))

            if vehDist < 50 then
                while hasTaxiJob do
                    -- Recheck job status
                    hasTaxiJob = false
                    if player then
                        if type(player.job) == "string" and player.job == "taxi" then
                            hasTaxiJob = true
                        elseif type(player.job) == "table" and player.job.name == "taxi" then
                            hasTaxiJob = true
                        end
                    end
                    if not hasTaxiJob then break end
                    ped = PlayerPedId()
                    pos = GetEntityCoords(ped)
                    vehDist = #(pos - vector3(Config.Location.x, Config.Location.y, Config.Location.z))

                    if vehDist >= 50 then break end

                    if vehDist < 30 then
                        DrawMarker(2, Config.Location.x, Config.Location.y, Config.Location.z, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.3, 0.5, 0.2, 200, 0, 0, 222, false, false, false, true, false, false, false)

                        if vehDist < 1.5 then
                            if whitelistedVehicle() then
                                DrawText3D(Config.Location.x, Config.Location.y, Config.Location.z + 0.3, "[E] Vehicle Parking")
                                if IsControlJustReleased(0, 38) then
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    end
                                end
                            else
                                DrawText3D(Config.Location.x, Config.Location.y, Config.Location.z + 0.3, "[E] Job Vehicles")
                                if IsControlJustReleased(0, 38) then
                                    lib.notify({
                                        title = 'Downtown Cab',
                                        description = 'Welcome! Select a vehicle to get started',
                                        type = 'info',
                                        duration = 5000
                                    })
                                    TaxiGarage()
                                end
                            end
                        end
                    end

                    Wait(50)  -- OPTIMIZED: Check 20x/sec instead of 60+
                end
            end
        end
    end
end)

-- Create Taxi Blip
CreateThread(function()
    local TaxiBlip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
    SetBlipSprite(TaxiBlip, 198)
    SetBlipDisplay(TaxiBlip, 4)
    SetBlipScale(TaxiBlip, 0.6)
    SetBlipAsShortRange(TaxiBlip, true)
    SetBlipColour(TaxiBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Downtown Cab")
    EndTextCommandSetBlipName(TaxiBlip)
end)

-- Commands
RegisterCommand('taxinpc', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Taxi Job',
            description = 'You must be inside a taxi vehicle first! Go to the garage marker to spawn one',
            type = 'error',
            duration = 6000
        })
        return
    end
    TriggerEvent('ND_TaxiJob:client:DoTaxiNpc')
end, false)

RegisterCommand('taximeter', function()
    TriggerEvent('ND_TaxiJob:client:toggleMeter')
end, false)

RegisterCommand('taxidebug', function()
    if NpcData.Active then
        local npcLoc = Config.NPCLocations.TakeLocations[NpcData.CurrentNpc]
        print("========== TAXI DEBUG ==========")
        print("NPC Mission Active: YES")
        print("NPC Location Index: " .. NpcData.CurrentNpc)
        print("NPC Taken: " .. tostring(NpcData.NpcTaken))
        print("NPC Coords: " .. npcLoc.x .. ", " .. npcLoc.y .. ", " .. npcLoc.z)

        if NpcData.Npc then
            local coords = GetEntityCoords(NpcData.Npc)
            print("NPC Entity Coords: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
            print("NPC Exists: " .. tostring(DoesEntityExist(NpcData.Npc)))
        end

        local playerPos = GetEntityCoords(PlayerPedId())
        local dist = #(playerPos - vector3(npcLoc.x, npcLoc.y, npcLoc.z))
        print("Your Distance from NPC: " .. math.floor(dist) .. " meters")
        print("================================")

        lib.notify({
            title = 'Taxi Debug',
            description = 'Distance to NPC: ' .. math.floor(dist) .. 'm - Check F8 console',
            type = 'info'
        })
    else
        print("No active NPC mission")
        lib.notify({
            title = 'Taxi Debug',
            description = 'No active mission',
            type = 'error'
        })
    end
end, false)

RegisterCommand('taxigoto', function()
    if NpcData.Active then
        local npcLoc = Config.NPCLocations.TakeLocations[NpcData.CurrentNpc]
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 then
            SetEntityCoords(veh, npcLoc.x, npcLoc.y, npcLoc.z)
            SetEntityHeading(veh, npcLoc.w)
            lib.notify({
                title = 'Taxi Job',
                description = 'Teleported to NPC location',
                type = 'success'
            })
        else
            SetEntityCoords(ped, npcLoc.x, npcLoc.y, npcLoc.z)
            lib.notify({
                title = 'Taxi Job',
                description = 'Teleported to NPC (get in vehicle first!)',
                type = 'info'
            })
        end
    else
        lib.notify({
            title = 'Taxi Job',
            description = 'No active NPC mission',
            type = 'error'
        })
    end
end, false)

RegisterCommand('taxihelp', function()
    lib.notify({
        title = 'Taxi Job - Commands',
        description = [[
**How to Start:**
1. Go to Downtown Cab (yellow blip)
2. Press [E] to spawn a taxi vehicle
3. Use /taxinpc to find a passenger

**Commands:**
/taxinpc - Start a pickup mission
/taximeter - Toggle fare meter
/taxihelp - Show this help menu
        ]],
        type = 'info',
        duration = 15000
    })
end, false)
