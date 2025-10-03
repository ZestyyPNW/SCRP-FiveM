Config = {}

-- Idle System Configuration
-- Subtle animations when standing still (e.g., while talking in a group)
Config.IdleSystem = {
    enabled = true,
    idleTime = 3000, -- Time in milliseconds before playing idle animation (3000ms = 3 seconds)
    cycleTime = 4000, -- Time between cycling to a new animation (4000ms = 4 seconds)
    checkInterval = 1000, -- How often to check for idle players (1000ms = 1 second)
    cancelOnMovement = true, -- Cancel idle animation when player moves
    movementThreshold = 1.0, -- Distance in units to register as "movement" (higher = less sensitive)
}

-- List of subtle idle emotes to randomly play
-- These are from rpemotes-reborn - chosen for being subtle/natural while standing
Config.IdleEmotes = {
    "idle",
    "idle8",
    "idle9",
    "idle11",
    "checkout",
    "checkwatch",
    "damn",
    "damn2",
    "wait4",
    "wait6",
    "wait12",
}
