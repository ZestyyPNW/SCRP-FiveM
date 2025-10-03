NDCore = {}

Config = {
    serverName = GetConvar("core:serverName", "Southern California RP"),
    discordInvite = GetConvar("core:discordInvite", "https://discord.gg/F5WtkYUa4T"),
    discordAppId = GetConvar("core:discordAppId", "1420502496584929481"),
    discordAsset = GetConvar("core:discordAsset", "scrp"),
    discordAssetSmall = GetConvar("core:discordAssetSmall", "scrp"),
    discordActionText = GetConvar("core:discordActionText", "DISCORD"),
    discordActionLink = GetConvar("core:discordActionLink", "https://discord.gg/F5WtkYUa4T"),
    disableVehicleAirControl = GetConvarInt("core:disableVehicleAirControl", 1) == 1,
    randomUnlockedVehicleChance = GetConvarInt("core:randomUnlockedVehicleChance", 30),
    requireKeys = GetConvarInt("core:requireKeys", 1) == 1,
    useInventoryForKeys = GetConvarInt("core:useInventoryForKeys", 1) == 1,
    groups = json.decode(GetConvar("core:groups", "[]")),
    compatibility = json.decode(GetConvar("core:compatibility", "[]")),
    lockpickTries = GetConvarInt("core:lockpickTries", 3)
}

-- Discord rich presence.
CreateThread(function()
    SetDiscordAppId(Config.discordAppId)
    SetDiscordRichPresenceAsset(Config.discordAsset)
    SetDiscordRichPresenceAssetSmall(Config.discordAssetSmall)
    SetDiscordRichPresenceAction(0, Config.discordActionText, Config.discordActionLink)
    SetDiscordRichPresenceAction(1, Config.discordActionText2, Config.discordActionLink2)
    local presenceText = ("Playing: %s"):format(Config.serverName)
    while true do
        if NDCore.player then
            local presence = ("Playing: %s as %s %s"):format(Config.serverName, NDCore.player.firstname, NDCore.player.lastname)
            local presenceTextSmall = ("Playing as: %s %s"):format(NDCore.player.firstname, NDCore.player.lastname)
            SetRichPresence(presence)
            SetDiscordRichPresenceAssetText(presenceText)
            SetDiscordRichPresenceAssetSmallText(presenceTextSmall)
        end
        Wait(60000)
    end
end)

-- Pause menu information.
CreateThread(function()
    AddTextEntry("FE_THDR_GTAO", Config.serverName)
    local sleep = 500
    while true do
        Wait(sleep)
        if NDCore.player and IsPauseMenuActive() then
            sleep = 0
            BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
            ScaleformMovieMethodAddParamPlayerNameString(("%s %s"):format(NDCore.player.firstname, NDCore.player.lastname))
            ScaleformMovieMethodAddParamTextureNameString(("Cash: $%d"):format(NDCore.player.cash))
            ScaleformMovieMethodAddParamTextureNameString(("Bank: $%d"):format(NDCore.player.bank))
            EndScaleformMovieMethod()
        elseif sleep == 0 then
            sleep = 500
        end
    end
end)

AddEventHandler("playerSpawned", function()
    print("^0ND Framework support discord: ^5https://discord.gg/Z9Mxu72zZ6")
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)
