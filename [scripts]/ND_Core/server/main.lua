NDCore = {}
NDCore.players = {}
PlayersInfo = {}
local resourceName = GetCurrentResourceName()
local tempPlayersInfo = {}

Config = {
    serverName = GetConvar("core:serverName", "Southern California RP"),
    discordInvite = GetConvar("core:discordInvite", "https://discord.gg/F5WtkYUa4T"),
    discordMemeberRequired = GetConvarInt("core:discordMemeberRequired", 1) == 1,
    discordAppId = GetConvar("core:discordAppId", "1420502496584929481"),
    discordAsset = GetConvar("core:discordAsset", "scrp"),
    discordAssetSmall = GetConvar("core:discordAssetSmall", "scrp"),
    discordActionText = GetConvar("core:discordActionText", "DISCORD"),
    discordActionLink = GetConvar("discordActionLink", "https://discord.gg/F5WtkYUa4T"),
    characterIdentifier = GetConvar("core:characterIdentifier", "discord"),
    discordGuildId = GetConvar("core:discordGuildId", "false"),
    discordBotToken = GetConvar("core:discordBotToken", "false"),
    randomUnlockedVehicleChance = GetConvarInt("core:randomUnlockedVehicleChance", 30),
    disableVehicleAirControl = GetConvarInt("core:disableVehicleAirControl", 1) == 1,
    useInventoryForKeys = GetConvarInt("core:useInventoryForKeys", 1) == 1,
    groups = json.decode(GetConvar("core:groups", "[]")),
    admins = json.decode(GetConvar("core:admins", "[]")),
    adminDiscordRoles = json.decode(GetConvar("core:adminDiscordRoles", "[]")),
    groupRoles = json.decode(GetConvar("core:groupRoles", "[]")),
    multiCharacter = false,
    compatibility = json.decode(GetConvar("core:compatibility", "[]")),
    sv_lan = GetConvar("sv_lan", "false") == "true",
}

SetConvarServerInfo("Discord", Config.discordInvite)
SetConvarServerInfo("NDCore", GetResourceMetadata(resourceName, "version", 0) or "invalid")
SetConvarReplicated("inventory:framework", "nd")

local function getIdentifierList(src)
    local list = {}
    for i=0, GetNumPlayerIdentifiers(src) do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier then
            local colon = identifier:find(":")
            local identifierType = identifier:sub(1, colon-1)
            list[identifierType] = identifier
        end
    end

    if Config.sv_lan then
        list[Config.characterIdentifier] = NDCore.getPlayerIdentifierByType(src, Config.characterIdentifier)
    end

    return list
end

AddEventHandler("playerJoining", function(oldId)
    local src = source
    local oldTempId = tonumber(oldId)
    PlayersInfo[src] = tempPlayersInfo[oldTempId]
    tempPlayersInfo[oldTempId] = nil

    if Config.sv_lan then
        lib.addPrincipal(("player.%s"):format(src), "group.admin")
    end

    if Config.multiCharacter then return end
    -- OPTIMIZED: Removed 3 second artificial delay (3 seconds faster player loading)
    Wait(500)  -- Small delay for client to be ready

    local characters = NDCore.fetchAllCharacters(src)
    local id = next(characters)
    if id then
        return NDCore.setActiveCharacter(src, id)
    end

    local player = NDCore.newCharacter(src, {
        firstname = GetPlayerName(src),
        lastname = "",
        dob = "",
        gender = ""
    })
    NDCore.setActiveCharacter(src, player.id)
end)

local function checkDiscordIdentifier(identifiers)
    if Config.discordBotToken == "false" or Config.discordGuildId == "false" then return end

    local discordIdentifier = identifiers["discord"]
    if not discordIdentifier then return end

    return NDCore.getDiscordInfo(discordIdentifier:gsub("discord:", ""))
end

AddEventHandler("onResourceStart", function(name)
    if name ~= resourceName then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local identifiers = getIdentifierList(src)
        PlayersInfo[src] = {
            identifiers = identifiers,
            discord = checkDiscordIdentifier(identifiers) or {}
        }
        Wait(65)
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local tempSrc = source
    local identifiers = getIdentifierList(tempSrc)
    local mainIdentifier = identifiers[Config.characterIdentifier]
    local discordInfo = nil

    deferrals.defer()
    Wait(0)

    if mainIdentifier and Config.discordBotToken ~= "false" and Config.discordGuildId ~= "false" then
        discordInfo = checkDiscordIdentifier(identifiers)
        if not discordInfo and Config.discordMemeberRequired and not Config.sv_lan then
            deferrals.done(("Your discord was not found, join our discord here: %s."):format(Config.discordInvite))
            Wait(0)
        end
    end

    deferrals.update("Connecting...")
    Wait(0)

    if Config.sv_lan then
        tempPlayersInfo[tempSrc] = {
            identifiers = {
                [Config.characterIdentifier] = "sv_lan"
            },
            discord = discordInfo
        }
        deferrals.done()
        return
    end

    if mainIdentifier then
        tempPlayersInfo[tempSrc] = {
            identifiers = identifiers,
            discord = discordInfo
        }
        deferrals.done()
    else
        deferrals.done(("Your %s was not found."):format(Config.characterIdentifier))
        Wait(0)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local char = NDCore.players[src]
    if char then char.unload() end
    PlayersInfo[src] = nil
end)

AddEventHandler("onResourceStop", function(name)
    if name ~= resourceName then return end
    for _, player in pairs(NDCore.players) do
        player.unload()
        Wait(10)
    end
end)

MySQL.ready(function()
    NDCore.loadSQL({
        "database/characters.sql",
        "database/vehicles.sql"
    }, resourceName)
end)

RegisterNetEvent("ND:playerEliminated", function(info)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.setMetadata({
        dead = true,
        deathInfo = info
    })
end)

RegisterNetEvent("ND:updateClothing", function(clothing)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player or not clothing or type(clothing) ~= "table" then return end
    player.setMetadata("clothing", clothing)
end)
