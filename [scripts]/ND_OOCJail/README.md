# ND_OOCJail - FiveM Resource

Out-of-Character Jail System with Discord Integration for ND_Core servers.

## Features

- ✅ Admin command to jail rule-breaking players
- ✅ Automatic Discord role assignment/removal
- ✅ Players spawn in jail every time until unjailed
- ✅ Prevents death escape, weapon usage, and vehicle entry
- ✅ ox_lib menu for easy player management
- ✅ Integrated with ND_Core character metadata
- ✅ Permission system using Discord roles
- ✅ UI notifications via ox_lib

## Installation

### 1. Add to server.cfg

```cfg
ensure ND_OOCJail
```

Make sure it's loaded AFTER:
- ND_Core
- ox_lib

### 2. Configure

Edit `config.lua` and set:

```lua
Config.Discord = {
    ServerId = "934502096831672390", -- Your Discord server ID
    RoleName = "Awaiting Staff Judgment", -- Discord role name
    BotAPIUrl = "http://localhost:3000", -- Discord bot API endpoint
    BotToken = "YOUR_BOT_TOKEN_HERE" -- Not used by FiveM
}
```

Edit permission roles:
```lua
Config.Permissions = {
    AdminRoles = { "Admin", "Senior Admin", "Head Admin" },
    JudgeRoles = { "Judge", "Staff Judge", "Admin", "Senior Admin", "Head Admin" }
}
```

Adjust jail location if needed (default is Mission Row PD cells):
```lua
Config.JailLocation = {
    x = 461.88,
    y = -994.54,
    z = 24.91,
    heading = 89.76
}
```

### 3. Start Discord Bot

See `OOCJail-DiscordBot/README.md` for bot setup instructions.

## Usage

### Jailing a Player

1. Admin types `/oocjail` in-game
2. Select player from list
3. Click "Send to OOC Jail"
4. Enter reason (min 10 characters)
5. Player is immediately jailed and Discord role is assigned

### Unjailing a Player

1. Judge/Admin types `/oocjail` in-game
2. Select jailed player (shows 🔒 icon)
3. Click "Release from OOC Jail"
4. Player is freed and Discord role is removed

### What Happens When Jailed

- Player is teleported to jail location
- All weapons are removed
- Cannot enter vehicles
- Cannot die/respawn elsewhere (respawns in jail)
- Receives notification explaining their situation
- Discord role is assigned
- **Every time they join the server, they spawn in jail until unjailed**

## Permissions

### Admin Roles (Can Jail)
- Admin
- Senior Admin
- Head Admin

### Judge Roles (Can Unjail)
- Judge
- Staff Judge
- Admin
- Senior Admin
- Head Admin

*Configure these in config.lua*

## Dependencies

- [ND_Core](https://github.com/ND-Framework/ND_Core)
- [ox_lib](https://github.com/overextended/ox_lib)
- Discord Bot (included)

## Exports

```lua
-- Check if player is jailed
local isJailed = exports['ND_OOCJail']:isPlayerJailed(source)

-- Jail player programmatically
exports['ND_OOCJail']:jailPlayer(targetId, adminId, reason)

-- Unjail player programmatically
exports['ND_OOCJail']:unjailPlayer(targetId, adminId)
```

## Support

- Make sure Discord bot is running before using the system
- Check F8 console for errors
- Verify Discord permissions are correct
- Ensure players have Discord linked to their account
