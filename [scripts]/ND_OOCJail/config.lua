Config = {}

-- Discord Configuration
Config.Discord = {
    ServerId = "934502096831672390",
    RoleName = "Awaiting Staff Judgment", -- Role name to give jailed players
    BotAPIUrl = "http://localhost:3000", -- Discord bot API endpoint (change when bot is set up)
    BotToken = "MTQyMDUwMjQ5NjU4NDkyOTQ4MQ.GisJnJ.uXK1zPTujgjqf051ScVq7wS5wPHzxmBCmAX6Ag" -- Will be used by bot, not FiveM
}

-- Permission Configuration
Config.Permissions = {
    AdminRoles = { "Development Team" }, -- Discord roles that can jail
    JudgeRoles = { "Development Team" } -- Discord roles that can unjail
}

-- Jail Location (Mission Row PD Cells)
Config.JailLocation = {
    x = 1695.29,
    y = 2667.76,
    z = 45.56,
    heading = 291.00
}

-- Jail Settings
Config.JailSettings = {
    RespawnInJail = true, -- Always respawn in jail if jailed
    RemoveWeapons = true, -- Remove all weapons
    DisableVehicles = true, -- Prevent entering vehicles
    FreezeOnDeath = true, -- Freeze player on death until respawn in jail
    CheckInterval = 5000 -- Check jail status every 5 seconds (ms)
}

-- UI Messages
Config.Messages = {
    JailNotification = {
        title = "OUT OF CHARACTER JAIL",
        description = "You have been placed in OOC Jail for violating server rules.\n\nYou must wait for a Staff Judge to review your case.\n\nDo not disconnect or you will be banned.",
        duration = 0, -- 15 seconds
        position = "top",
        type = "error"
    },
    UnjailNotification = {
        title = "RELEASED FROM OOC JAIL",
        description = "You have been released from OOC Jail by staff.\n\nPlease review server rules to avoid future violations.",
        duration = 10000,
        position = "top",
        type = "success"
    },
    ReminderInterval = 300000 -- Remind every 5 minutes (ms)
}
