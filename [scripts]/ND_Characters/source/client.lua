-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local currentResourceName = GetCurrentResourceName()
local changeAppearence = false
local started = false
local firstSpawn = true
local characters = {}
local lastSource = GetResourceKvpInt("ND_Characters:source")
local lastCharacter = GetResourceKvpInt("ND_Characters:character")

-- Cinematic Camera System (Safe Implementation)
local cinematicCamera = nil
local isCharacterMenuOpen = false
local currentCameraIndex = 1
local cameraThread = nil
local previewPed = nil
local previewCamera = nil
local isPreviewing = false

-- Static camera position
local staticCameraPos = vector3(1612.19, 3402.53, 137.11)
local staticCameraHeading = 329.67

-- Safe Camera Functions with Error Handling
local function stopPreviewCamera(restoreCinematic)
    if previewCamera then
        pcall(function()
            DestroyCam(previewCamera, false)
        end)
        previewCamera = nil
    end

    if previewPed then
        pcall(function()
            DeleteEntity(previewPed)
        end)
        previewPed = nil
    end

    isPreviewing = false

    -- Restore cinematic camera if it still exists
    if restoreCinematic and cinematicCamera and isCharacterMenuOpen then
        pcall(function()
            SetCamActive(cinematicCamera, true)
            RenderScriptCams(true, true, 1000, true, true)
        end)
    end
end

local function stopCinematicCamera()
    print("[ND_Characters] Stopping cinematic camera")

    if cameraThread then
        cameraThread = nil
    end

    isCharacterMenuOpen = false

    stopPreviewCamera()

    if cinematicCamera then
        pcall(function()
            RenderScriptCams(false, true, 1000, true, true)
            DestroyCam(cinematicCamera, false)
            print("[ND_Characters] Cinematic camera stopped successfully")
        end)
        cinematicCamera = nil
    end

    -- Safely restore HUD
    pcall(function()
        DisplayHud(true)
        DisplayRadar(true)
    end)
end

local function startCinematicCamera()
    -- Safety check - don't start if already running
    if cinematicCamera or isCharacterMenuOpen then
        return
    end

    -- Start camera immediately since we're not using SwitchOutPlayer
    CreateThread(function()
        Wait(500) -- Small delay to ensure menu is ready

        local success = pcall(function()
            cinematicCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

            -- Set static camera position
            SetCamCoord(cinematicCamera, staticCameraPos.x, staticCameraPos.y, staticCameraPos.z)
            SetCamRot(cinematicCamera, 0.0, 0.0, staticCameraHeading, 2)
            SetCamFov(cinematicCamera, 50.0)
            SetCamActive(cinematicCamera, true)
            RenderScriptCams(true, true, 2000, true, true)

            print("[ND_Characters] Static cinematic camera started at", staticCameraPos)
            isCharacterMenuOpen = true
        end)

        if not success then
            print("[ND_Characters] Camera system failed to start safely")
            stopCinematicCamera()
        end
    end)
end

local config = {
    spawns = lib.load("data.spawns") or {},
    configuration = lib.load("data.configuration") or {
        changeCharacterCommand = "changecharacter",
        characterLimit = 5,
        logo = "https://i.imgur.com/02A5Cgl.png",
        backgrounds = {
            "https://i.imgur.com/E51ckFx.png",
            "https://i.imgur.com/SeZD7TP.png",
            "https://i.imgur.com/ZWKfYD9.png"
        }
    }    
}

local function getAop()
    local resources = {
        "SimpleHUD",
        "ModernHUD"
    }
    for i=1, #resources do
        local resource = resources[i]
        if GetResourceState(resource) == "started" then
            return exports[resource]:getAOP()
        end
    end
end

local function startChangeAppearence(dontReturn)
    exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
        if not appearance then
            return not dontReturn and start(true)
        end
        
        Wait(4000)
        TriggerServerEvent("ND_Characters:updateClothing", appearance)
    end, {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = false
    })
end

-- Set the player to creating the ped if they haven't already.
local function setCharacterClothes(character)
    if GetResourceState("fivem-appearance") ~= "started" then return end
    local clothing = character.metadata.clothing

    if not clothing or not next(clothing) then
        Wait(3000)
        return startChangeAppearence()
    end

    exports["fivem-appearance"]:setPlayerModel(clothing.model or clothing.appearance.model)

    local ped = PlayerPedId()
    exports["fivem-appearance"]:setPedAppearance(ped, clothing.appearance or clothing)
end

local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count += 1
    end
    return count
end

function SetDisplay(bool, typeName, bg, chars)
    local characterAmount = chars or characters
    if not characterAmount then
        characterAmount = {}
    end

    -- Safe camera system integration
    if bool then
        startCinematicCamera()
    else
        stopCinematicCamera()
    end

    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = typeName,
        status = bool,
        serverName = NDCore.getConfig("serverName"),
        characterAmount = ("%d/%d"):format(tablelength(characterAmount), config.configuration.characterLimit)
    })
    Wait(500)
    local aop = getAop()
    if not aop then return end
    SendNUIMessage({
        type = "aop",
        aop = aop
    })
end

function start(switch)
    local success, result, permsResult = pcall(lib.callback.await, "ND_Characters:fetchCharacters")

    if not success then
        print("^1[ND_Characters] Error fetching characters: " .. tostring(result))
        characters, perms = {}, {}
    else
        characters, perms = result or {}, permsResult or {}
    end

    if switch then
        local ped = PlayerPedId()
        -- Don't use SwitchOutPlayer as it creates conflicting camera
        -- SwitchOutPlayer(ped, 0, 1)
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, 0)
        SetEntityAlpha(ped, 0, false)
    end
    SendNUIMessage({
        type = "givePerms",
        deptRoles = json.encode(perms)
    })
    SendNUIMessage({
        type = "refresh",
        characters = json.encode(characters)
    })
    SendNUIMessage({
        type = "logo",
        logo = config.configuration.logo or "https://i.imgur.com/02A5Cgl.png"
    })
    SetDisplay(true, "ui", background, characters)
    local aop = getAop()
    if not aop then return end
    SendNUIMessage({
        type = "aop",
        aop = aop
    })
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= currentResourceName then return end
    Wait(500)
    if lastSource == cache.serverId and lastCharacter then
        -- Verify the character still exists before trying to select it
        local success, characters = pcall(lib.callback.await, "ND_Characters:fetchCharacters")
        if success and characters and characters[lastCharacter] then
            TriggerServerEvent("ND_Characters:select", lastCharacter)
            return
        else
            -- Character no longer exists, clear saved data and show character selection
            SetResourceKvpInt("ND_Characters:source", 0)
            SetResourceKvpInt("ND_Characters:character", 0)
        end
    end
    Wait(1500)
    start(false)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= currentResourceName then return end

    -- Safe camera cleanup
    stopCinematicCamera()

    local player = NDCore.getPlayer()
    if not player then return end
    SetResourceKvpInt("ND_Characters:source", cache.serverId)
    SetResourceKvpInt("ND_Characters:character", player.id)
end)

AddEventHandler("playerSpawned", function()
    start(true)
end)

local function sortSpawns(chars, id)
    local player = chars[id]
    if not player then return end
    
    local defaultSpawns = config.spawns["default"] or config.spawns["DEFAULT"]
    local spawns = {}
    for _, spawn in pairs(defaultSpawns) do
        spawns[#spawns+1] = spawn
    end
    
    local job = player.job
    if not job then return spawns end
    
    local jobSpawns = {}
    for k, v in pairs(config.spawns) do
        if k:lower() == job:lower() then
            jobSpawns = v
            break
        end
    end
    
    for _, newSpawn in pairs(jobSpawns) do
        spawns[#spawns+1] = newSpawn
    end

    return spawns
end

-- Preview character when clicked
RegisterNUICallback("previewCharacter", function(data)
    local id = tonumber(data.id)
    local character = characters[id]
    if not character then return end

    -- Stop any existing preview (don't restore cinematic yet)
    stopPreviewCamera(false)

    CreateThread(function()
        local success = pcall(function()
            -- Spawn location for preview (use static camera area)
            local spawnPos = vector3(1612.19, 3402.53, 137.11)
            local spawnHeading = staticCameraHeading

            -- Get character appearance
            local clothing = character.metadata.clothing
            local model = clothing and (clothing.model or clothing.appearance and clothing.appearance.model) or "mp_m_freemode_01"

            -- Load and create ped
            local modelHash = GetHashKey(model)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(10)
            end

            previewPed = CreatePed(4, modelHash, spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading, false, true)
            SetEntityInvincible(previewPed, true)
            FreezeEntityPosition(previewPed, true)
            SetBlockingOfNonTemporaryEvents(previewPed, true)

            -- Apply appearance if available
            if GetResourceState("fivem-appearance") == "started" and clothing then
                Wait(100) -- Small delay to ensure ped is fully loaded
                exports["fivem-appearance"]:setPedAppearance(previewPed, clothing.appearance or clothing)
            end

            -- Create and set camera focused on character
            previewCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            local camPos = vector3(spawnPos.x - 2.0, spawnPos.y - 2.0, spawnPos.z + 0.5)
            SetCamCoord(previewCamera, camPos.x, camPos.y, camPos.z)
            PointCamAtEntity(previewCamera, previewPed, 0.0, 0.0, 0.5, true)
            SetCamFov(previewCamera, 50.0)

            -- Smoothly transition to preview camera
            SetCamActive(previewCamera, true)
            RenderScriptCams(true, true, 1000, true, true)

            isPreviewing = true
            print("[ND_Characters] Preview camera focused on character", id)
        end)

        if not success then
            print("[ND_Characters] Failed to create character preview")
            stopPreviewCamera(true)
        end
    end)
end)

-- Selecting a player from the iu.
RegisterNUICallback("setMainCharacter", function(data)
    local id = tonumber(data.id)
    local spawns = sortSpawns(characters, id)

    if not spawns then return end
    SendNUIMessage({
        type = "setSpawns",
        spawns = json.encode(spawns),
        id = id
    })
end)

-- Creating a character from the ui.
RegisterNUICallback("newCharacter", function(data)
    if tablelength(characters) > config.configuration.characterLimit then return end
    lib.callback("ND_Characters:new", false, function(player)
        if not player then
            return lib.print.warn("creating character unsuccessful")
        end
        characters[player.id] = player
        SendNUIMessage({
            type = "refresh",
            characters = json.encode(characters),
            characterAmount = ("%d/%d"):format(tablelength(characters), config.configuration.characterLimit)
        })
    end, {
        firstName = data.firstName,
        lastName = data.lastName,
        dob = data.dateOfBirth,
        gender = data.gender,
        ethnicity = data.ethnicity,
        job = data.department
    })
end)

-- editing a character from the ui.
RegisterNUICallback("editCharacter", function(data)
    lib.callback("ND_Characters:edit", false, function(player)
        if not player then
            return lib.print.warn("editing character unsuccessful")
        end
        characters[player.id] = player
        SendNUIMessage({
            type = "refresh",
            characters = json.encode(characters),
            characterAmount = ("%d/%d"):format(tablelength(characters), config.configuration.characterLimit)
        })
    end, {
        id = data.id,
        firstName = data.firstName,
        lastName = data.lastName,
        dob = data.dateOfBirth,
        gender = data.gender,
        ethnicity = data.ethnicity,
        job = data.department
    })
end)

-- deleting a character from the ui.
RegisterNUICallback("delCharacter", function(data)
    lib.callback("ND_Characters:delete", false, function(success)
        if not success then return end
        characters[data.character] = nil
        SendNUIMessage({
            type = "refresh",
            characters = json.encode(characters),
            characterAmount = ("%d/%d"):format(tablelength(characters), config.configuration.characterLimit)
        })
    end, data.character)
end)

-- Quit button from ui.
RegisterNUICallback("exitGame", function()
    TriggerServerEvent("ND_Characters:exitGame")
end)

-- Teleporting using ui.
RegisterNUICallback("tpToLocation", function(data)
    local ped = PlayerPedId()
    local character = characters[data.id]
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, tonumber(data.x), tonumber(data.y), tonumber(data.z), false, false, false, false)
    -- Don't use SwitchInPlayer as it interferes with our camera
    -- SwitchInPlayer(ped)
    Wait(500)
    SetDisplay(false, "ui")
    Wait(500)
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(100)
    end
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, 0)
    SetEntityAlpha(ped, 255, false)
    setCharacterClothes(character)
    TriggerServerEvent("ND_Characters:select", data.id)
    SetTimeout(1000, function()
        if firstSpawn then
            firstSpawn = false
            SendNUIMessage({
                type = "firstSpawn"
            })
        end
    end)
end)

-- Choosing the do not tp button.
RegisterNUICallback("tpDoNot", function(data)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    local character = characters[data.id]
    if firstSpawn then
        local data = character and character.metadata
        if data and data.location then
            SetEntityCoords(ped, data.location.x, data.location.y, data.location.z)
            if data.location.w then
                SetEntityHeading(ped, data.location.w)
            end
        end
        SetTimeout(1000, function()
            firstSpawn = false
            SendNUIMessage({
                type = "firstSpawn"
            })
        end)
    end
    -- Don't use SwitchInPlayer as it interferes with our camera
    -- SwitchInPlayer(ped)
    Wait(500)
    SetDisplay(false, "ui")
    Wait(500)
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(100)
    end
    SetEntityVisible(ped, true, 0)
    SetEntityAlpha(ped, 255, false)
    FreezeEntityPosition(ped, false)
    Wait(100)
    setCharacterClothes(character)
    TriggerServerEvent("ND_Characters:select", data.id)
end)

RegisterNetEvent("ND:clothingMenu", function()
    startChangeAppearence(true)
end)

RegisterNetEvent("ND:characterMenu", function()
    start(true)
end)

local allowChangeCommand = true -- this doesn't do anything if config option is set.
local disabledReason = "can't change character right now!"

exports("allowChangeCommand", function(status, reason)
    allowChangeCommand = status
    disabledReason = reason or "can't change character right now!"
end)

if config.configuration.changeCharacterCommand then
    -- Change character command
    RegisterCommand(config.configuration.changeCharacterCommand, function()
        if not allowChangeCommand then
            return TriggerEvent("chat:addMessage", {
                color = {50, 100, 235},
                multiline = true,
                args = {"Error", disabledReason}
            })
        end

        start(true)
    end, false)
    
    -- chat suggestions
    TriggerEvent("chat:addSuggestion", "/" .. config.configuration.changeCharacterCommand, "Change your character.")
end
