# ND_SmallResources

A collection of small features and quality of life improvements for ND Framework servers.

## Features

### 🎭 Subtle Idle Animations
Automatically plays subtle idle animations when players are standing still (e.g., talking in a group). Adds realistic character fidgeting and weight shifting.

**Features:**
- Plays after **3 seconds** of standing still (configurable)
- **Cycles through different animations** every 4 seconds while standing
- Random subtle emote selection (checks watch, fidgets, waits)
- Never repeats the same animation twice in a row
- Automatic cancellation when player moves or presses any key
- Smart detection (won't play during combat, swimming, driving, etc.)
- Perfect for RP scenarios where you're standing and talking
- Works with rpemotes-reborn

## Installation

1. Place `ND_SmallResources` in your `[scripts]` folder
2. Add `ensure ND_SmallResources` to your server.cfg
3. Make sure `rpemotes-reborn` is started before this resource
4. Configure settings in `config.lua`

## Configuration

### Idle System Settings (`config.lua`)

```lua
Config.IdleSystem = {
    enabled = true,                -- Enable/disable idle system
    idleTime = 3000,              -- Time before idle animation (3 seconds)
    cycleTime = 4000,             -- Time between cycling animations (4 seconds)
    checkInterval = 1000,         -- How often to check for idle players (1 second)
    cancelOnMovement = true,      -- Cancel animation when player moves
    movementThreshold = 1.0,      -- Distance to register as movement (higher = less sensitive)
}
```

### Idle Emotes List

You can customize which emotes are played by editing `Config.IdleEmotes` in the config file. All emotes must be valid rpemotes-reborn emote commands.

Default subtle emotes included:
- idle variations (idle, idle8, idle9, idle11)
- checkout, checkwatch
- damn, damn2
- wait variations (wait4, wait6, wait12)

## Commands

### Testing Commands
- `/testidleemote` - Manually trigger a random idle emote
- `/cancelidle` - Cancel current idle animation

## Exports

### Client Exports

```lua
-- Play a random idle emote
exports['ND_SmallResources']:PlayIdleEmote()

-- Cancel current idle emote
exports['ND_SmallResources']:CancelIdleEmote()

-- Check if player is currently idle
local isIdle = exports['ND_SmallResources']:IsPlayerIdle()
```

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [rpemotes-reborn](https://github.com/Smokey/rpemotes-reborn) - Required for idle animations

## Future Features

This resource is designed to be expandable. Future additions planned:
- Player status indicators
- Proximity voice range display
- Vehicle fuel warnings
- Custom notifications system
- And more QoL features!

## Support

For issues or suggestions, please contact the server development team.

## License

Designed for use with ND Framework servers.
