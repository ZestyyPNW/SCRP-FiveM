-- No config import needed here as it will be loaded via shared_script

-- Original TiltedHUD variables
local playerPed = nil
local isInVehicle = false
local lastHealth = 200
local lastArmor = 0
local hudVisible = true

-- Stamina system variables
local currentStamina = 100
local lastStamina = 100
local isRunning = false
local runStartTime = 0
local staminaDrainRate = 5.0 -- Stamina lost per second while running (faster drain)
local staminaRegenRate = 1.5 -- Stamina gained per second while not running
local runThreshold = 2000 -- Time in ms before stamina starts draining
local isLawEnforcement = false
local maxStamina = 100
local staminaInitialized = false

-- New unified HUD variables
local priorityText = ""
local aopText = "Los Angeles, CA"
local zoneName = ""
local streetName = ""
local crossingRoad = ""
local nearestPostal = { code = "000" }
local time = ""
local postals = {}

-- Bodycam integration
local bodycamActive = false

-- Speed limit variables
local speedLimitEnabled = true
local speedLimitVisible = false
local currentSpeedLimit = nil
local lastStreetName = nil

-- Weapon display variables
local currentWeapon = nil
local lastWeaponHash = 0
local weaponDisplayVisible = false

-- Priority system variables
local socalStatus = "Cooldown"
local nocalStatus = "Cooldown"
local socalUser = ""
local nocalUser = ""

-- Panel visibility states
local panels = {
    health = true,
    priority = true,
    location = true,
    time = true
}

-- Hide default GTA HUD components
CreateThread(function()
    while true do
        Wait(0)

        -- Hide default HUD components we don't want
        HideHudComponentThisFrame(1)  -- Wanted stars
        -- HideHudComponentThisFrame(2)  -- Weapon icon (ENABLED FOR NATIVE TILTEDHUD)
        HideHudComponentThisFrame(3)  -- Cash
        HideHudComponentThisFrame(4)  -- MP Cash
        HideHudComponentThisFrame(6)  -- Vehicle name
        HideHudComponentThisFrame(7)  -- Area name
        HideHudComponentThisFrame(8)  -- Vehicle class
        HideHudComponentThisFrame(9)  -- Street name
        HideHudComponentThisFrame(13) -- Cash change
        HideHudComponentThisFrame(11) -- Floating help text
        HideHudComponentThisFrame(12) -- Floating help text key
        HideHudComponentThisFrame(15) -- Subtitle text
        HideHudComponentThisFrame(18) -- Game stream

        -- MOST IMPORTANT: Show native health/armor/weapon for TiltedHUD
        -- HideHudComponentThisFrame(17) -- Health + Armor (ENABLED FOR NATIVE TILTEDHUD)
        -- HideHudComponentThisFrame(19) -- Weapon wheel stats (ENABLED FOR NATIVE TILTEDHUD)

        -- Hide minimap unless in vehicle
        if not isInVehicle then
            DisplayRadar(false)
        else
            DisplayRadar(true)
        end
    end
end)

-- Health and armor monitoring thread
CreateThread(function()
    while true do
        Wait(100) -- Check every 100ms for smooth updates

        playerPed = PlayerPedId()
        isInVehicle = IsPedInAnyVehicle(playerPed, false)

        local health = GetEntityHealth(playerPed) - 100 -- GTA health starts at 100

        -- Normalize health to 0-100 range
        health = math.max(0, math.min(100, health))

        -- Update HUD if values changed
        if health ~= lastHealth then
            SendNUIMessage({
                type = 'updateHealth',
                health = health
            })
            lastHealth = health
        end

        -- Armor is now handled by equipment system events, not direct reading

        -- Check for weapon changes
        local weaponHash = GetSelectedPedWeapon(playerPed)
        if weaponHash ~= lastWeaponHash then
            lastWeaponHash = weaponHash
            updateWeaponDisplay()
        end
    end
end)

-- Stamina monitoring thread
CreateThread(function()
    while true do
        Wait(100) -- Update every 100ms for smooth animations

        if hudVisible and not bodycamActive then
            local playerPed = PlayerPedId()

            -- Don't drain stamina if player is in a vehicle
            if IsPedInAnyVehicle(playerPed, false) then
                isRunning = false
                runStartTime = 0
            else
                -- Try different detection methods
                local isPlayerRunning = IsPedRunning(playerPed) or IsPedSprinting(playerPed)
                local velocity = GetEntityVelocity(playerPed)
                local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
                local isMovingFast = speed > 3.0 -- Threshold for running speed

                -- Use movement speed as backup detection
                if not isPlayerRunning and isMovingFast then
                    isPlayerRunning = true
                end


                -- Track running state
                if isPlayerRunning and not isRunning then
                    isRunning = true
                    runStartTime = GetGameTimer()
                elseif not isPlayerRunning then
                    isRunning = false
                    runStartTime = 0
                end
            end

            -- Calculate stamina changes (only when not in vehicle)
            if not IsPedInAnyVehicle(playerPed, false) then
                if isRunning and (GetGameTimer() - runStartTime) > runThreshold then
                    -- Drain stamina while running
                    currentStamina = math.max(0, currentStamina - (staminaDrainRate * 0.1))

                    -- Reduce player stamina when exhausted
                    if currentStamina <= 0 then
                        RestorePlayerStamina(PlayerId(), 0.0)
                        SetPlayerStamina(PlayerId(), 0.0)
                    end
                elseif not isRunning and currentStamina < maxStamina then
                    -- Regenerate stamina when not running
                    currentStamina = math.min(maxStamina, currentStamina + (staminaRegenRate * 0.1))

                    -- Restore player stamina as it regenerates
                    local restoreThreshold = isLawEnforcement and 35 or 25
                    if currentStamina > restoreThreshold then
                        RestorePlayerStamina(PlayerId(), currentStamina / maxStamina)
                    end
                end
            elseif currentStamina < maxStamina then
                -- Regenerate stamina when in vehicle
                currentStamina = math.min(maxStamina, currentStamina + (staminaRegenRate * 0.1))

                -- Restore stamina in vehicle
                RestorePlayerStamina(PlayerId(), currentStamina / maxStamina)
            end

            -- Update HUD if stamina changed
            if math.abs(currentStamina - lastStamina) > 0.5 then
                SendNUIMessage({
                    type = 'updateStamina',
                    stamina = currentStamina
                })
                lastStamina = currentStamina
            end
        end
    end
end)

-- Vehicle detection thread for minimap
CreateThread(function()
    while true do
        Wait(0) -- Check every frame for instant detection

        local playerPed = PlayerPedId()
        local newInVehicle = IsPedInAnyVehicle(playerPed, false)

        if newInVehicle ~= isInVehicle then
            isInVehicle = newInVehicle

            -- Show/hide minimap based on vehicle status
            if isInVehicle then
                DisplayRadar(true)
            else
                DisplayRadar(false)
            end

            -- Update HUD position with smooth animation
            SendNUIMessage({
                type = 'updateVehicleState',
                inVehicle = isInVehicle
            })
        end
    end
end)

-- Bodycam integration thread
CreateThread(function()
    while true do
        Wait(500) -- Check every 500ms

        -- Check if bodycam resource exists and is started
        if GetResourceState('bodycam') == 'started' then
            local newBodycamActive = exports.bodycam:isBodycamActive()

            if newBodycamActive ~= bodycamActive then
                bodycamActive = newBodycamActive

                if bodycamActive then
                    SendNUIMessage({
                        type = 'setDisplay',
                        display = false
                    })
                else
                    SendNUIMessage({
                        type = 'setDisplay',
                        display = hudVisible
                    })
                end
            end
        end
    end
end)

-- Listen for bodycam state changes
RegisterNetEvent('bodycam:stateChanged')
AddEventHandler('bodycam:stateChanged', function(isActive)
    bodycamActive = isActive

    if bodycamActive then
        SendNUIMessage({
            type = 'setDisplay',
            display = false
        })
    else
        SendNUIMessage({
            type = 'setDisplay',
            display = hudVisible
        })
    end
end)

-- Equipment system armor update event
RegisterNetEvent('TiltedHUD:updateArmor')
AddEventHandler('TiltedHUD:updateArmor', function(armorValue)
    lastArmor = armorValue
    SendNUIMessage({
        type = 'updateArmor',
        armor = armorValue
    })
end)

-- Initialize HUD when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000) -- Wait for everything to load

        -- Enable NUI
        SetNuiFocus(false, false)

        -- Initialize vehicle state
        playerPed = PlayerPedId()
        isInVehicle = IsPedInAnyVehicle(playerPed, false)

        -- Send initial values
        local health = math.max(0, math.min(100, GetEntityHealth(playerPed) - 100))

        SendNUIMessage({
            type = 'updateHealth',
            health = health
        })

        -- Don't send initial armor update since it should be hidden at 0
        -- The armor bar will only appear when armor is equipped

        -- Check law enforcement status and set max stamina
        checkLawEnforcementStatus()

        -- Set stamina to full on resource start
        currentStamina = maxStamina
        lastStamina = maxStamina

        -- Don't send initial stamina update since it should be hidden at full
        -- The stamina bar will only appear when it drops below max

        SendNUIMessage({
            type = 'setDisplay',
            display = true
        })

        -- Send initial vehicle state
        SendNUIMessage({
            type = 'updateVehicleState',
            inVehicle = isInVehicle
        })
    end
end)

-- Player spawn handler
AddEventHandler('playerSpawned', function()
    Wait(2000) -- Wait for spawn to complete

    -- Reset HUD values
    playerPed = PlayerPedId()
    isInVehicle = IsPedInAnyVehicle(playerPed, false)
    local health = math.max(0, math.min(100, GetEntityHealth(playerPed) - 100))

    SendNUIMessage({
        type = 'updateHealth',
        health = health
    })

    -- Don't send initial armor update since it should be hidden at 0
    -- The armor bar will only appear when armor is equipped

    -- Check law enforcement status and set max stamina
    checkLawEnforcementStatus()

    -- Set stamina to full on player spawn
    currentStamina = maxStamina
    lastStamina = maxStamina

    SendNUIMessage({
        type = 'updateStamina',
        stamina = maxStamina
    })

    -- Send current vehicle state
    SendNUIMessage({
        type = 'updateVehicleState',
        inVehicle = isInVehicle
    })
end)

-- Command to toggle HUD visibility (for testing)
RegisterCommand('togglehud', function()
    hudVisible = not hudVisible

    -- Don't show HUD if bodycam is active
    local shouldDisplay = hudVisible and not bodycamActive

    SendNUIMessage({
        type = 'setDisplay',
        display = shouldDisplay
    })

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"HUD", hudVisible and "enabled" or "disabled"}
    })

    if hudVisible and bodycamActive then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"HUD", "HUD hidden due to active bodycam"}
        })
    end
end, false)

-- Export functions for other resources
exports('getHealth', function()
    return lastHealth
end)

exports('getArmor', function()
    return lastArmor
end)

exports('isHudVisible', function()
    return hudVisible
end)

exports('setHudVisibility', function(visible)
    hudVisible = visible
    SendNUIMessage({
        type = 'setDisplay',
        display = visible
    })
end)

-- Law enforcement detection function
function checkLawEnforcementStatus()
    -- Check if player is in law enforcement groups (customize these job names as needed)
    local lawEnforcementJobs = {
        'lapd',
        'lasd',
        'chp'
    }

    local wasLawEnforcement = isLawEnforcement
    isLawEnforcement = false

    -- Try ND_Core method to get player data
    if exports['ND_Core'] then
        local NDCore = exports['ND_Core']
        local player = NDCore:getPlayer()

        if player and player.groups then
            -- Check if player has any of the law enforcement groups
            for _, job in ipairs(lawEnforcementJobs) do
                if player.groups[job] then
                    isLawEnforcement = true
                    break
                end
            end
        else
        end
    else
    end

    -- Update max stamina based on law enforcement status
    maxStamina = isLawEnforcement and 140 or 100

    -- Initialize stamina to max on first check or status change
    if not staminaInitialized or wasLawEnforcement ~= isLawEnforcement then
        currentStamina = maxStamina
        lastStamina = maxStamina
        staminaInitialized = true
    else
        currentStamina = math.min(currentStamina, maxStamina)
    end

    -- Only send update if status changed
    if wasLawEnforcement ~= isLawEnforcement then
        SendNUIMessage({
            type = 'setLawEnforcement',
            isLawEnforcement = isLawEnforcement
        })

    end
end

-- Weapon display update function
function updateWeaponDisplay()
    local weaponHash = GetSelectedPedWeapon(playerPed)

    -- If no weapon or unarmed
    if weaponHash == `WEAPON_UNARMED` or weaponHash == 0 then
        SendNUIMessage({
            type = 'updateWeapon',
            weapon = nil
        })
        weaponDisplayVisible = false
        return
    end

    -- Get weapon information using weapon hash name
    local weaponHashName = string.upper(tostring(weaponHash))

    -- Map of weapon hashes to weapon names from ox_inventory data
    local weaponNames = {
            -- Custom weapons from ox_inventory
            ["WEAPON_BATTLERIFLE"] = "Battle Rifle",
            ["WEAPON_AIRSOFTGLOCK20"] = "Airsoft Glock 20",
            ["WEAPON_STUNGRENADE"] = "Flashbang",
            ["WEAPON_GRENADE_TEARGAS"] = "Tear Gas",
            ["WEAPON_AIRSOFTMP5"] = "Airsoft MP5",
            ["WEAPON_ARPISTOL"] = "ARP Pistol",
            ["WEAPON_M9"] = "Beretta M9",
            ["WEAPON_BPX4"] = "Beretta PX4 Storm",
            ["WEAPON_HKP30"] = "HK P30",
            ["WEAPON_STACCATOPTBLACKMETRO"] = "Staccato P ( Metro )",
            ["WEAPON_HALLIGAN"] = "Halligan",
            ["WEAPON_SPREADER"] = "Spreader",
            ["WEAPON_SAW"] = "Saw",
            ["WEAPON_HOSE"] = "Fire Hose",
            ["WEAPON_M1911"] = "Colt M1911",
            ["WEAPON_SWM657"] = "S&W Model 657",
            ["WEAPON_SWM659"] = "S&W Model 659",
            ["WEAPON_SWMP9L"] = "S&W Model M&P9L",
            ["WEAPON_STACCATOPTBLACKSWAT"] = "Staccato P ( SWAT )",
            ["WEAPON_STACCATOPTCHROMESWAT"] = "Staccato P ( SWAT Chrome )",
            ["WEAPON_FN509MRDLE"] = "FN-509 MRD-LE",
            ["WEAPON_FN509MRDLE2"] = "FN-509 MRD-LE ( RMR )",
            ["WEAPON_FN509T"] = "FN-509",
            ["WEAPON_FNX45"] = "FNX-45",
            ["WEAPON_FN57"] = "FN Five-Seven",
            ["WEAPON_PT247"] = "Taraus PT247",
            ["WEAPON_DRACO"] = "Micro Draco",
            ["WEAPON_ASPBATON"] = "ASP Baton",
            ["WEAPON_TASER7GREEN"] = "Taser 7",
            ["WEAPON_TASER10"] = "Taser 10",
            ["WEAPON_BEANBAG"] = "Beanbag Shotgun",
            ["WEAPON_ORANGEBEANBAG"] = "Beanbag Shotgun",
            ["WEAPON_LESSLAUNCHER"] = "40MM Less Launcher",
            ["WEAPON_TASER7YELLOW"] = "Taser 7",
            ["WEAPON_G19G5S"] = "Glock 19 Gen 5 ( Switch )",
            ["WEAPON_GLUGER"] = "Gluger",
            ["WEAPON_M4A1"] = "M4A1",
            ["WEAPON_LASDM4A1"] = "M4A1 ( FDE )",
            ["WEAPON_MP5"] = "MP5",
            ["WEAPON_AR15"] = "Colt AR-15",
            ["WEAPON_M24"] = "Remington M24",
            ["WEAPON_HK416"] = "HK416",
            ["WEAPON_19XSWITCH"] = "Glock 19X ( Switch Red )",
            ["WEAPON_19XSWITCHBLACK"] = "Glock 19X ( Switch Black )",
            ["WEAPON_G19G5"] = "Glock 19 Gen 5",
            ["WEAPON_G22"] = "Glock 22",
            ["WEAPON_G43X"] = "Glock 43X",
            ["WEAPON_G41"] = "Glock 41",
            ["WEAPON_GLOCK20"] = "Glock 20 RMR",
            ["WEAPON_GLOCK20A"] = "Glock 20 Aimpoint ACRO P-2",
            ["WEAPON_PITTVIPER"] = "JW4 TTI Pit Viper",
            ["WEAPON_GLOCK19XL"] = "Glock 19 XL",
            ["WEAPON_PDGLOCK17"] = "Glock 17 Gen 3",
            ["WEAPON_M870_SHOTGUN"] = "Remington M870",
            ["WEAPON_M870WOOD"] = "Remington M870",
            ["WEAPON_MPA30"] = "MPA-30",
            ["WEAPON_MP7"] = "MP7",
            ["WEAPON_SWITCHBLUE"] = "Glock 19 ( Switch Blue )",
            ["WEAPON_SWITCHGOLD"] = "Glock 19 ( Switch Gold )",
            ["WEAPON_XDM"] = "XDM-Elite",
            -- Standard GTA weapons
            ["WEAPON_UNARMED"] = "Unarmed",
            ["WEAPON_PISTOL"] = "Pistol",
            ["WEAPON_PISTOL_MK2"] = "Pistol Mk II",
            ["WEAPON_COMBATPISTOL"] = "Combat Pistol",
            ["WEAPON_APPISTOL"] = "AP Pistol",
            ["WEAPON_STUNGUN"] = "Stun Gun",
            ["WEAPON_MICROSMG"] = "Micro SMG",
            ["WEAPON_SMG"] = "SMG",
            ["WEAPON_SMG_MK2"] = "SMG Mk II",
            ["WEAPON_ASSAULTSMG"] = "Assault SMG",
            ["WEAPON_COMBATPDW"] = "Combat PDW",
            ["WEAPON_MACHINEPISTOL"] = "Machine Pistol",
            ["WEAPON_MINISMG"] = "Mini SMG",
            ["WEAPON_ASSAULTRIFLE"] = "Assault Rifle",
            ["WEAPON_ASSAULTRIFLE_MK2"] = "Assault Rifle Mk II",
            ["WEAPON_CARBINERIFLE"] = "Carbine Rifle",
            ["WEAPON_CARBINERIFLE_MK2"] = "Carbine Rifle Mk II",
            ["WEAPON_ADVANCEDRIFLE"] = "Advanced Rifle",
            ["WEAPON_SPECIALCARBINE"] = "Special Carbine",
            ["WEAPON_SPECIALCARBINE_MK2"] = "Special Carbine Mk II",
            ["WEAPON_BULLPUPRIFLE"] = "Bullpup Rifle",
            ["WEAPON_BULLPUPRIFLE_MK2"] = "Bullpup Rifle Mk II",
            ["WEAPON_COMPACTRIFLE"] = "Compact Rifle",
            ["WEAPON_MG"] = "MG",
            ["WEAPON_COMBATMG"] = "Combat MG",
            ["WEAPON_COMBATMG_MK2"] = "Combat MG Mk II",
            ["WEAPON_GUSENBERG"] = "Gusenberg Sweeper",
            ["WEAPON_PUMPSHOTGUN"] = "Pump Shotgun",
            ["WEAPON_PUMPSHOTGUN_MK2"] = "Pump Shotgun Mk II",
            ["WEAPON_SAWNOFFSHOTGUN"] = "Sawed-Off Shotgun",
            ["WEAPON_ASSAULTSHOTGUN"] = "Assault Shotgun",
            ["WEAPON_BULLPUPSHOTGUN"] = "Bullpup Shotgun",
            ["WEAPON_MUSKET"] = "Musket",
            ["WEAPON_HEAVYSHOTGUN"] = "Heavy Shotgun",
            ["WEAPON_DBSHOTGUN"] = "Double Barrel Shotgun",
            ["WEAPON_AUTOSHOTGUN"] = "Sweeper Shotgun",
            ["WEAPON_SNIPERRIFLE"] = "Sniper Rifle",
            ["WEAPON_HEAVYSNIPER"] = "Heavy Sniper",
            ["WEAPON_HEAVYSNIPER_MK2"] = "Heavy Sniper Mk II",
            ["WEAPON_MARKSMANRIFLE"] = "Marksman Rifle",
            ["WEAPON_MARKSMANRIFLE_MK2"] = "Marksman Rifle Mk II"
        }
    local weaponName = weaponNames[weaponHashName] or "Unknown Weapon"
    local currentAmmo = GetAmmoInPedWeapon(playerPed, weaponHash)
    local clipAmmo = GetAmmoInClip(playerPed, weaponHash)
    local maxClipSize = GetMaxAmmoInClip(playerPed, weaponHash, true)
    local _, maxAmmo = GetMaxAmmo(playerPed, weaponHash)

    -- Calculate reserve ammo (total - clip)
    local reserveAmmo = math.max(0, currentAmmo - clipAmmo)

    -- Create weapon data object
    local weaponData = {
        name = weaponName,
        ammo = currentAmmo,
        maxAmmo = maxAmmo or 0,
        clip = clipAmmo,
        clipSize = maxClipSize or 0,
        reserve = reserveAmmo
    }

    -- Send to NUI
    SendNUIMessage({
        type = 'updateWeapon',
        weapon = weaponData
    })

    weaponDisplayVisible = true
end

-- Check law enforcement status periodically
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        checkLawEnforcementStatus()
    end
end)

-- Debug command to test law enforcement detection
RegisterCommand('testleo', function()
    local NDCore = exports['ND_Core']
    local player = NDCore:getPlayer()

    if player then

        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"DEBUG", "Law enforcement: " .. (isLawEnforcement and "YES" or "NO") .. " | Max stamina: " .. maxStamina}
        })
    else
    end
end, false)

-- =================== NEW UNIFIED HUD FUNCTIONALITY ===================

-- Location and postal updates
CreateThread(function()
    -- Use the shared postal data from postals.lua
    if PostalData and type(PostalData) == "table" then
        postals = PostalData
    else
        postals = {}
    end

    -- Initial update
    Wait(1000)
    SendNUIMessage({
        type = 'updateLocation',
        aop = aopText,
        postal = "Loading...",
        street = "Loading...",
        zone = "Loading..."
    })

    while true do
        Wait(1000)

        if hudVisible and panels.location then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            -- Get street names properly
            local streetHash1, streetHash2 = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
            local currentStreet = GetStreetNameFromHashKey(streetHash1)

            -- Add crossing street if exists
            if streetHash2 ~= 0 then
                local crossStreet = GetStreetNameFromHashKey(streetHash2)
                if crossStreet and crossStreet ~= "" then
                    currentStreet = currentStreet .. " & " .. crossStreet
                end
            end

            -- Get zone/district name
            local zoneHash = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
            local currentZone = GetLabelText(zoneHash)
            zoneName = currentZone ~= "" and currentZone or "Unknown District"

            -- Find nearest postal
            local closestPostal = { code = "000", distance = 99999 }
            if postals and #postals > 0 then
                for i, postal in ipairs(postals) do
                    if postal.x and postal.y and postal.code then
                        local distance = #(playerCoords - vector3(postal.x, postal.y, 0))
                        if distance < closestPostal.distance then
                            closestPostal = { code = tostring(postal.code), distance = distance }
                        end
                    end
                end
            end

            -- Update location info
            SendNUIMessage({
                type = 'updateLocation',
                aop = aopText,
                postal = closestPostal.code,
                street = currentStreet ~= "" and currentStreet or "Unknown Street",
                zone = zoneName
            })
        end
    end
end)

-- Time display update
CreateThread(function()
    while true do
        Wait(1000)

        if hudVisible then
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            local day = GetClockDayOfMonth()
            local month = GetClockMonth()
            local year = GetClockYear()
            local dayOfWeek = GetClockDayOfWeek()

            -- Convert to 12-hour format
            local ampm = "AM"
            local displayHour = hour
            if hour == 0 then
                displayHour = 12
            elseif hour > 12 then
                displayHour = hour - 12
                ampm = "PM"
            elseif hour == 12 then
                ampm = "PM"
            end

            -- Day names (0 = Sunday)
            local dayNames = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
            -- Month names (0 = January)
            local monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

            local formattedTime = string.format("%d:%02d %s", displayHour, minute, ampm)
            local formattedDate = string.format("%s, %s %02d", dayNames[dayOfWeek + 1], monthNames[month + 1], day)
            local fullDateTime = formattedDate .. " " .. formattedTime

            if fullDateTime ~= time then
                time = fullDateTime
                SendNUIMessage({
                    type = 'updateTime',
                    time = time
                })
            end
        end
    end
end)

-- Priority system events
RegisterNetEvent('UnifiedHUD:updateSocalStatus')
AddEventHandler('UnifiedHUD:updateSocalStatus', function(status, user)
    socalStatus = status
    socalUser = user or ""

    SendNUIMessage({
        type = 'updatePriority',
        zone = 'socal',
        status = status,
        user = user
    })
end)

RegisterNetEvent('UnifiedHUD:updateNocalStatus')
AddEventHandler('UnifiedHUD:updateNocalStatus', function(status, user)
    nocalStatus = status
    nocalUser = user or ""

    SendNUIMessage({
        type = 'updatePriority',
        zone = 'nocal',
        status = status,
        user = user
    })
end)

RegisterNetEvent('UnifiedHUD:updateAOP')
AddEventHandler('UnifiedHUD:updateAOP', function(newAop)
    aopText = newAop

    SendNUIMessage({
        type = 'updateLocation',
        aop = aopText,
        postal = nearestPostal.code,
        street = streetName,
        zone = zoneName
    })
end)

-- Cooldown timer events
RegisterNetEvent('UnifiedHUD:updateSocalCooldown')
AddEventHandler('UnifiedHUD:updateSocalCooldown', function(timeRemaining)
    SendNUIMessage({
        type = 'updatePriority',
        zone = 'socal',
        status = 'Cooldown (' .. timeRemaining .. ')',
        user = ''
    })
end)

RegisterNetEvent('UnifiedHUD:updateNocalCooldown')
AddEventHandler('UnifiedHUD:updateNocalCooldown', function(timeRemaining)
    SendNUIMessage({
        type = 'updatePriority',
        zone = 'nocal',
        status = 'Cooldown (' .. timeRemaining .. ')',
        user = ''
    })
end)

-- Export functions for compatibility
exports('getAOP', function()
    return aopText
end)

exports('getPostal', function()
    return nearestPostal.code
end)

exports('getSocalStatus', function()
    return socalStatus
end)

exports('getNocalStatus', function()
    return nocalStatus
end)

-- =================== CUSTOMIZATION COMMANDS ===================

-- Toggle individual panels
RegisterCommand('toggleprio', function()
    panels.priority = not panels.priority
    SendNUIMessage({
        type = 'togglePanel',
        panel = 'priority',
        visible = panels.priority
    })
    TriggerEvent('chat:addMessage', {
        color = {100, 255, 100},
        args = {"HUD", "Priority panel " .. (panels.priority and "enabled" or "disabled")}
    })
end, false)

RegisterCommand('toggleloc', function()
    panels.location = not panels.location
    SendNUIMessage({
        type = 'togglePanel',
        panel = 'location',
        visible = panels.location
    })
    TriggerEvent('chat:addMessage', {
        color = {100, 255, 100},
        args = {"HUD", "Location panel " .. (panels.location and "enabled" or "disabled")}
    })
end, false)

RegisterCommand('toggletime', function()
    panels.time = not panels.time
    SendNUIMessage({
        type = 'togglePanel',
        panel = 'time',
        visible = panels.time
    })
    TriggerEvent('chat:addMessage', {
        color = {100, 255, 100},
        args = {"HUD", "Time display " .. (panels.time and "enabled" or "disabled")}
    })
end, false)

-- Settings menu state
local settingsOpen = false

-- HUD customization menu
RegisterCommand('hudsettings', function()
    settingsOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openSettings',
        config = Config
    })

    -- Add escape key handler
    CreateThread(function()
        while settingsOpen do
            Wait(0)
            if IsControlJustPressed(0, 322) then -- ESC key
                settingsOpen = false
                SetNuiFocus(false, false)
                SendNUIMessage({
                    type = 'closeSettings'
                })
                break
            end
        end
    end)
end, false)

-- Reset HUD to defaults
RegisterCommand('hudreset', function()
    -- Reset all panels to visible
    panels = {
        health = true,
        priority = true,
        location = true,
        time = true
    }

    SendNUIMessage({
        type = 'resetHUD'
    })

    TriggerEvent('chat:addMessage', {
        color = {100, 255, 100},
        args = {"HUD", "All settings reset to defaults"}
    })
end, false)

-- Speed limit toggle command
RegisterCommand(Config.Commands.toggleSpeedLimits, function()
    speedLimitEnabled = not speedLimitEnabled
    SetResourceKvp("speedLimitEnabled", tostring(speedLimitEnabled))

    if not speedLimitEnabled then
        SendNUIMessage({
            type = 'hideSpeedLimit'
        })
        speedLimitVisible = false
        currentSpeedLimit = nil
    end

    TriggerEvent('chat:addMessage', {
        color = {100, 255, 100},
        args = {"HUD", "Speed limits " .. (speedLimitEnabled and "enabled" or "disabled")}
    })
end, false)

-- Speed limit detection thread
CreateThread(function()
    -- Load saved state
    local savedState = GetResourceKvpString("speedLimitEnabled")
    if savedState then
        speedLimitEnabled = savedState == "true"
    else
        SetResourceKvp("speedLimitEnabled", "true")
    end

    while true do
        Wait(Config.Features.speedLimits.updateInterval or 2000)

        if Config.Features.speedLimits.enabled and speedLimitEnabled then
            local playerPed = PlayerPedId()
            local inVehicle = IsPedInAnyVehicle(playerPed, false)

            if inVehicle or not Config.Features.speedLimits.showOnlyInVehicle then
                if not speedLimitVisible then
                    speedLimitVisible = true
                end

                -- Get current street name
                local playerCoords = GetEntityCoords(playerPed)
                local streetHash1, streetHash2 = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                local streetName = GetStreetNameFromHashKey(streetHash1)

                -- Check for crossing street
                if streetHash2 ~= 0 then
                    local crossStreet = GetStreetNameFromHashKey(streetHash2)
                    if crossStreet and crossStreet ~= "" then
                        -- Check if either street has a speed limit
                        local mainSpeed = Config.SpeedLimits[streetName]
                        local crossSpeed = Config.SpeedLimits[crossStreet]

                        if mainSpeed then
                            streetName = streetName
                        elseif crossSpeed then
                            streetName = crossStreet
                        end
                    end
                end

                -- Update speed limit if street changed
                if streetName ~= lastStreetName then
                    lastStreetName = streetName
                    local speedLimit = Config.SpeedLimits[streetName]

                    if speedLimit and speedLimit ~= currentSpeedLimit then
                        currentSpeedLimit = speedLimit
                        SendNUIMessage({
                            type = 'updateSpeedLimit',
                            speed = speedLimit
                        })
                    elseif not speedLimit and currentSpeedLimit then
                        -- No speed limit for this street, hide the sign
                        currentSpeedLimit = nil
                        SendNUIMessage({
                            type = 'hideSpeedLimit'
                        })
                    end
                end
            elseif speedLimitVisible then
                -- Hide speed limit when not in vehicle (if configured)
                speedLimitVisible = false
                currentSpeedLimit = nil
                SendNUIMessage({
                    type = 'hideSpeedLimit'
                })
            end
        end
    end
end)

-- Initialize priority status on resource start
CreateThread(function()
    Wait(2000)
    SendNUIMessage({
        type = 'updatePriority',
        zone = 'socal',
        status = 'cooldown',
        user = ''
    })
    SendNUIMessage({
        type = 'updatePriority',
        zone = 'nocal',
        status = 'cooldown',
        user = ''
    })
end)

-- NUI Callbacks for settings menu
RegisterNUICallback('closeSettings', function(data, cb)
    settingsOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('updateConfig', function(data, cb)
    -- Update local config with user preferences
    if data.setting and data.value ~= nil then
        -- Handle nested config updates
        local keys = {}
        for key in string.gmatch(data.setting, "([^.]+)") do
            table.insert(keys, key)
        end

        local current = Config
        for i = 1, #keys - 1 do
            current = current[keys[i]]
        end
        current[keys[#keys]] = data.value

        -- Apply changes to HUD
        SendNUIMessage({
            type = 'applyConfig',
            setting = data.setting,
            value = data.value
        })
    end
    cb('ok')
end)

-- =====================================================
-- BIGDADDY-FUEL INTEGRATION
-- =====================================================

local currentVehicle = nil
local lastFuelLevel = nil
local fuelUpdateThread = nil
local fuelDebug = true -- Set to false to disable debug logs

-- Monitor vehicle entry/exit and fuel levels
CreateThread(function()
    while true do
        Wait(500)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and vehicle ~= currentVehicle then
            -- Player entered a vehicle
            currentVehicle = vehicle
            lastFuelLevel = nil

            if fuelDebug then
                print('^2[TiltedHUD Fuel]^7 Entered vehicle: ' .. vehicle)
            end

            -- Start monitoring fuel
            if fuelUpdateThread then
                fuelUpdateThread = nil
            end

            fuelUpdateThread = CreateThread(function()
                while currentVehicle and DoesEntityExist(currentVehicle) do
                    Wait(1000) -- Update every second

                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)

                    if veh == currentVehicle then
                        -- Get fuel from BigDaddy-Fuel statebag
                        local fuelLevel = Entity(currentVehicle).state.fuel

                        -- Fallback to DecorGetFloat if statebag not available
                        if not fuelLevel then
                            if DecorExistOn(currentVehicle, "_FUEL_LEVEL") then
                                fuelLevel = DecorGetFloat(currentVehicle, "_FUEL_LEVEL")
                                if fuelDebug then
                                    print('^3[TiltedHUD Fuel]^7 Using decor: ' .. tostring(fuelLevel))
                                end
                            end
                        else
                            if fuelDebug then
                                print('^2[TiltedHUD Fuel]^7 Using state bag: ' .. tostring(fuelLevel))
                            end
                        end

                        -- If we have fuel data, update the display
                        if fuelLevel then
                            if fuelLevel ~= lastFuelLevel then
                                lastFuelLevel = fuelLevel

                                if fuelDebug then
                                    print('^2[TiltedHUD Fuel]^7 Updating display: ' .. tostring(fuelLevel) .. '%')
                                end

                                SendNUIMessage({
                                    type = 'updateFuel',
                                    fuel = fuelLevel
                                })
                            end
                        else
                            if fuelDebug then
                                print('^1[TiltedHUD Fuel]^7 No fuel data found!')
                            end
                        end
                    else
                        -- Player is no longer in this vehicle
                        break
                    end
                end
            end)

        elseif vehicle == 0 and currentVehicle then
            -- Player exited vehicle
            if fuelDebug then
                print('^2[TiltedHUD Fuel]^7 Exited vehicle')
            end

            currentVehicle = nil
            lastFuelLevel = nil
            fuelUpdateThread = nil

            -- Hide fuel display
            SendNUIMessage({
                type = 'hideFuel'
            })
        end
    end
end)

-- Listen for fuel state changes via statebag
AddStateBagChangeHandler('fuel', nil, function(bagName, key, value)
    if not currentVehicle then return end

    -- Check if this is the current vehicle's statebag
    local vehicleNetId = NetworkGetNetworkIdFromEntity(currentVehicle)
    if bagName == ('entity:%s'):format(vehicleNetId) then
        if value and value ~= lastFuelLevel then
            lastFuelLevel = value

            SendNUIMessage({
                type = 'updateFuel',
                fuel = value
            })
        end
    end
end)

-- =====================================================
-- FUEL SYSTEM TEST COMMANDS (for debugging)
-- =====================================================

-- Test command to set fuel level
RegisterCommand('setfuel', function(source, args)
    local fuelLevel = tonumber(args[1]) or 50
    fuelLevel = math.max(0, math.min(100, fuelLevel))

    SendNUIMessage({
        type = 'updateFuel',
        fuel = fuelLevel
    })

    print('^2[TiltedHUD]^7 Fuel level set to: ' .. fuelLevel .. '%')
end, false)

-- Test command to hide fuel display
RegisterCommand('hidefuel', function()
    SendNUIMessage({
        type = 'hideFuel'
    })

    print('^2[TiltedHUD]^7 Fuel display hidden')
end, false)

-- Test command to check current vehicle fuel
RegisterCommand('checkfuel', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        local fuelState = Entity(vehicle).state.fuel
        local fuelDecor = DecorExistOn(vehicle, "_FUEL_LEVEL") and DecorGetFloat(vehicle, "_FUEL_LEVEL") or "N/A"
        local vehicleModel = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)

        print('^2[TiltedHUD]^7 ==================== FUEL DEBUG ====================')
        print('  Vehicle: ' .. vehicleName .. ' (' .. vehicle .. ')')
        print('  State Bag: ' .. tostring(fuelState or "N/A"))
        print('  Decor (_FUEL_LEVEL): ' .. tostring(fuelDecor))
        print('  Current Vehicle Variable: ' .. tostring(currentVehicle or "nil"))
        print('  Last Fuel Level: ' .. tostring(lastFuelLevel or "nil"))
        print('  BigDaddy-Fuel Resource Running: ' .. tostring(GetResourceState('BigDaddy-Fuel') == 'started'))

        -- Try all possible decorator names
        local decorNames = {"_FUEL_LEVEL", "FUEL_LEVEL", "fuel", "Fuel", "fuelLevel"}
        print('^3[TiltedHUD]^7 Testing all possible decorators:')
        for _, decorName in ipairs(decorNames) do
            if DecorExistOn(vehicle, decorName) then
                local value = DecorGetFloat(vehicle, decorName)
                print('  ✓ ' .. decorName .. ': ' .. tostring(value))
            else
                print('  ✗ ' .. decorName .. ': Not found')
            end
        end

        print('^2[TiltedHUD]^7 ===================================================')
    else
        print('^1[TiltedHUD]^7 You are not in a vehicle')
    end
end, false)

-- Export functions for external fuel systems
exports('UpdateFuelDisplay', function(fuelLevel)
    SendNUIMessage({
        type = 'updateFuel',
        fuel = fuelLevel
    })
end)

exports('HideFuelDisplay', function()
    SendNUIMessage({
        type = 'hideFuel'
    })
end)