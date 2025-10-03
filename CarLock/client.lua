-- CONFIG
local lockDistance = 30 -- The radius you have to be in to lock/unlock your vehicle.

--[[
CarLock - Created by Lama
Modified for ox_inventory integration
For support - https://discord.gg/etkAKTw3M7
Do not edit below if you don't know what you are doing
]]--

local savedVehicles = {}

-- Request animation
Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
	RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end)

-- Lock lights event
RegisterNetEvent('lockLights')
AddEventHandler('lockLights', function(vehicle)
	SetVehicleLights(vehicle, 2)
	Wait(200)
	SetVehicleLights(vehicle, 0)
	Wait(200)
	SetVehicleLights(vehicle, 2)
	Wait(400)
	SetVehicleLights(vehicle, 0)
end)

-- Lock vehicle
RegisterKeyMapping('lock', 'Lock and unlock your car', 'keyboard', 'u')
RegisterCommand("lock", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = nil
    local closestDistance = lockDistance + 1

    print("[CarLock Client] Lock command triggered")
    print("[CarLock Client] Saved vehicles count: " .. #savedVehicles)

    -- Find closest owned vehicle
    for plate, vehData in pairs(savedVehicles) do
        print("[CarLock Client] Checking vehicle: " .. plate)
        local vehEntity = NetworkGetEntityFromNetworkId(vehData.netId)
        if DoesEntityExist(vehEntity) then
            local vehCoords = GetEntityCoords(vehEntity)
            local distance = #(coords - vehCoords)
            print("[CarLock Client] Distance to " .. plate .. ": " .. distance)
            if distance < closestDistance then
                closestDistance = distance
                vehicle = vehEntity
                print("[CarLock Client] Found closer vehicle: " .. plate)
            end
        else
            print("[CarLock Client] Vehicle " .. plate .. " doesn't exist (NetID: " .. vehData.netId .. ")")
        end
    end

    if vehicle and closestDistance <= lockDistance then
        print("[CarLock Client] Triggering lock for vehicle")
        TriggerServerEvent('CarLock:toggleLock', VehToNet(vehicle))
    else
        print("[CarLock Client] No vehicle found - closest distance: " .. closestDistance)
        ShowNotification("~b~[CarLock] ~r~No owned vehicle nearby")
    end
end)

-- Server events
RegisterNetEvent('CarLock:lockVehicle')
AddEventHandler('CarLock:lockVehicle', function(netId, hasKey)
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        local dict = "anim@mp_player_intmenu@key_fob@"
        local isLocked = GetVehicleDoorLockStatus(vehicle)

        if hasKey then
            if isLocked == 1 then
                -- Lock vehicle
                PlaySoundFrontend(-1, "BUTTON", "MP_PROPERTIES_ELEVATOR_DOORS", 1)
                TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                SetVehicleDoorsLocked(vehicle, 2)
                ShowNotification("~b~[CarLock] ~w~Vehicle ~r~locked")
                TriggerEvent('lockLights', vehicle)
            else
                -- Unlock vehicle
                PlaySoundFrontend(-1, "BUTTON", "MP_PROPERTIES_ELEVATOR_DOORS", 1)
                TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                SetVehicleDoorsLocked(vehicle, 1)
                ShowNotification("~b~[CarLock] ~w~Vehicle ~g~unlocked")
                TriggerEvent('lockLights', vehicle)
            end
        else
            ShowNotification("~b~[CarLock] ~r~You don't have the key for this vehicle")
        end
    end
end)

RegisterNetEvent('CarLock:updateVehicles')
AddEventHandler('CarLock:updateVehicles', function(vehicles)
    savedVehicles = vehicles
    print("[CarLock Client] Updated vehicles:")
    for plate, data in pairs(savedVehicles) do
        print("  - Plate: " .. plate .. " | NetID: " .. data.netId)
    end
end)

-- Save vehicle
RegisterKeyMapping('save', 'Get keys for the car you are in', 'keyboard', 'delete')
RegisterCommand("save", function()
	local ped = PlayerPedId()
	if GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
        local vehicle = GetVehiclePedIsIn(ped, false)
        TriggerServerEvent('CarLock:saveVehicle', VehToNet(vehicle))
	else
        ShowNotification("~b~[CarLock] ~r~You must be the driver to get keys")
    end
end)

-- Notification function
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
