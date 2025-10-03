-- Unified Tilted HUD Configuration
-- Customize your HUD settings here

Config = {}

-- =================== DISPLAY TOGGLES ===================
Config.Display = {
    healthBar = true,           -- Show/hide health bar
    armorBar = true,            -- Show/hide armor bar
    staminaBar = true,          -- Show/hide stamina bar
    priorityPanel = true,       -- Show/hide priority status panel
    locationPanel = true,       -- Show/hide location info panel
    timeDisplay = true,         -- Show/hide time display
    minimap = {
        alwaysShow = false,     -- true = always show, false = only in vehicle
        hideInVehicle = false   -- true = hide in vehicle, false = show in vehicle
    }
}

-- =================== PANEL POSITIONS ===================
-- Adjust X and Y positions (0.0 - 1.0 scale)
Config.Positions = {
    priority = {
        x = 0.02,  -- Left margin (0.02 = 2% from left)
        y = 0.02   -- Top margin (0.02 = 2% from top)
    },
    location = {
        x = 0.98,  -- Right side (0.98 = 2% from right when right-aligned)
        y = 0.02   -- Top margin
    },
    health = {
        x = 0.02,  -- Left margin
        y = 0.98   -- Bottom (0.98 = 2% from bottom)
    },
    time = {
        x = 0.98,  -- Right side
        y = 0.98   -- Bottom
    }
}

-- =================== COLORS & STYLES ===================
Config.Colors = {
    -- Health bar colors (use hex or rgba)
    health = {
        normal = "#ff6666",      -- Normal health color
        low = "#ff2222",          -- Low health color (below 25%)
        background = "rgba(0, 0, 0, 0.6)"
    },

    -- Armor bar colors
    armor = {
        normal = "#66aaff",
        background = "rgba(0, 0, 0, 0.6)"
    },

    -- Stamina bar colors
    stamina = {
        normal = "#66ff66",         -- Normal stamina color (green)
        low = "#ffaa44",           -- Low stamina color (orange)
        background = "rgba(0, 0, 0, 0.6)"
    },

    -- Priority status colors
    priority = {
        available = "#44ff44",    -- Green
        active = "#ff4444",        -- Red
        hold = "#ffaa44",          -- Orange
        cooldown = "#66aaff"       -- Blue
    },

    -- Text colors
    text = {
        primary = "#ffffff",       -- Main text
        secondary = "#cccccc",     -- Secondary text
        labels = "#ffffff"         -- Label text
    }
}

-- =================== SIZES & SCALES ===================
Config.Sizes = {
    -- Font sizes (in pixels)
    fontSize = {
        headers = 12,
        labels = 11,
        values = 11,
        time = 14
    },

    -- Panel scales (1.0 = normal, 0.5 = half size, 2.0 = double size)
    panelScale = {
        priority = 1.0,
        location = 1.0,
        health = 1.0,
        time = 1.0
    },

    -- Bar dimensions
    healthBar = {
        width = 200,
        height = 12
    },
    armorBar = {
        segmentWidth = 35,
        height = 12
    }
}

-- =================== VISUAL EFFECTS ===================
Config.Effects = {
    -- Tilted perspective angles (in degrees)
    tilt = {
        enabled = true,
        rotateY = 8,     -- Left/right tilt
        rotateX = 3,     -- Up/down tilt
        rotateZ = -1     -- Rotation
    },

    -- Animations
    animations = {
        fadeIn = true,
        damageFlash = true,
        lowHealthPulse = true
    },

    -- Shadows and glows
    shadows = {
        enabled = true,
        textShadow = true,
        glowEffect = true
    },

    -- Background for panels (set to true for dark background)
    panelBackgrounds = false  -- false = transparent, true = dark background
}

-- =================== FEATURE SETTINGS ===================
Config.Features = {
    -- Location settings
    location = {
        updateInterval = 1000,     -- How often to update location (ms)
        showPostal = true,
        showStreet = true,
        showZone = false,          -- Show zone name
        showCompass = false        -- Show compass direction
    },

    -- Priority system
    priority = {
        enabled = true,
        showUser = true,           -- Show username in active priority
        cooldownTimer = 45,        -- Minutes
        zones = {
            socal = true,
            nocal = true
        }
    },

    -- Health/Armor settings
    health = {
        showText = true,           -- Show numeric value
        lowHealthThreshold = 25    -- Percentage for low health warning
    },
    armor = {
        showText = true,           -- Show numeric value
        segments = 5               -- Number of armor segments
    },

    -- Stamina settings
    stamina = {
        enabled = true,             -- Enable stamina system
        showText = true,            -- Show numeric value
        lowStaminaThreshold = 25,   -- Percentage for low stamina warning (civilians)
        drainRate = 5.0,           -- Stamina lost per second while running
        regenRate = 1.5,           -- Stamina gained per second while not running
        runThreshold = 2000,       -- Milliseconds before stamina starts draining
        autoHide = true,           -- Hide when stamina is full
        autoHideDelay = 3000,      -- Delay before hiding (ms)
        lawEnforcement = {
            enabled = true,         -- Enable extra stamina for law enforcement
            bonusSegments = 2,      -- Extra stamina segments for law enforcement
            lowThreshold = 35,      -- Higher low stamina threshold for law enforcement
            jobs = {               -- Law enforcement job names
                'lapd',
                'lasd',
                'chp'
            }
        }
    },

    -- Speed Limit settings
    speedLimits = {
        enabled = true,            -- Enable speed limit display
        updateInterval = 2000,     -- Update frequency in ms
        showOnlyInVehicle = true,  -- Only show when in vehicle
        position = {
            bottom = "20vh",       -- Distance from bottom
            left = "3vw"          -- Distance from left
        },
        size = "45px"             -- Size of speed limit sign
    }
}

-- =================== KEYBINDS ===================
Config.Keybinds = {
    toggleHUD = "F7",              -- Key to toggle entire HUD
    togglePriority = "F8",         -- Key to toggle priority panel
    toggleLocation = "F9",         -- Key to toggle location panel
    customizeHUD = "F10"           -- Key to open customization menu
}

-- =================== COMMANDS ===================
Config.Commands = {
    toggleHUD = "togglehud",
    togglePriority = "toggleprio",
    toggleLocation = "toggleloc",
    toggleSpeedLimits = "togglespeed",
    customizeHUD = "hudsettings",
    resetHUD = "hudreset"
}

-- =================== SPEED LIMITS DATABASE ===================
Config.SpeedLimits = {
    ["Golden State Freeway I-5"] = 65,
    ["US Highway 101"] = 65,
    ["Pacific Coast Highway CA-1"] = 65,
    ["Route 86"] = 65,
    ["Barstow Rd"] = 45,
    ["East Joshua Rd"] = 55,
    ["Joshua Rd"] = 55,
    ["Cloverdale Ave"] = 45,
    ["Vermont Ave"] = 45,
    ["Chianski Passage"] = 25,
    ["Union Rd"] = 45,
    ["Catfish View"] = 45,
    ["Grapeseed Ave"] = 45,
    ["Seaview Rd"] = 45,
    ["Grapeseed Main St"] = 45,
    ["Joad Ln"] = 25,
    ["O'Neil Way"] = 25,
    ["Panorama Dr"] = 45,
    ["Marina Dr"] = 45,
    ["Smoke Tree Rd"] = 45,
    ["Cholla Rd"] = 45,
    ["Cat-Claw Ave"] = 45,
    ["Algonquin Blvd"] = 45,
    ["Calafia Rd"] = 45,
    ["Procopio Promenade"] = 45,
    ["Paleto Blvd"] = 45,
    ["Duluoz Ave"] = 45,
    ["Procopio Dr"] = 45,
    ["Zancudo Ave"] = 45,
    ["Niland Ave"] = 45,
    ["Cholla Springs Ave"] = 45,
    ["Meringue Ln"] = 25,
    ["Lesbos Ln"] = 25,
    ["Nowhere Rd"] = 45,
    ["Route 86 Approach"] = 65,
    ["Pyrite Ave"] = 45,
    ["North Calafia Way"] = 25,
    ["Cascabel Ave"] = 45,
    ["Mountain View Dr"] = 45,
    ["Zancudo Barranca"] = 45,
    ["Zancudo Rd"] = 45,
    ["Cassidy Trail"] = 25,
    ["Armadillo Ave"] = 45,
    ["Palisades Dr"] = 45,
    ["Lindsay Circus"] = 25,
    ["Great Ocean Highway"] = 65,
    ["Senora Rd"] = 45,
    ["North Sheldon Ave"] = 35,
    ["South Sheldon Ave"] = 35,
    ["Ineseno Rd"] = 45,
    ["Barbareno Rd"] = 45,
    ["Banham Canyon Dr"] = 45,
    ["Raton Canyon Rd"] = 45,
    ["Galileo Rd"] = 45,
    ["Mt Haan Rd"] = 45,
    ["San Andreas Ave"] = 45,
    ["Senora Way"] = 45,
    ["North Rockford Dr"] = 25,
    ["South Rockford Dr"] = 25,
    ["Wild Oats Dr"] = 25,
    ["Whispymound Dr"] = 25,
    ["Didion Dr"] = 25,
    ["Cox Way"] = 25,
    ["Picture Perfect Dr"] = 25,
    ["South Mo Milton Dr"] = 25,
    ["North Mo Milton Dr"] = 25,
    ["Normandy Dr"] = 25,
    ["Caesars Place"] = 25,
    ["Mad Wayne Thunder Dr"] = 25,
    ["Hangman Ave"] = 25,
    ["Dunstable Ln"] = 25,
    ["Dunstable Dr"] = 25,
    ["Spanish Ave"] = 25,
    ["Edwood Way"] = 25,
    ["Greenwich Pkwy"] = 25,
    ["Kimble Hill Dr"] = 25,
    ["Abe Milton Pkwy"] = 25,
    ["Cockingend Dr"] = 25,
    ["Dorset Dr"] = 25,
    ["Dorset Pl"] = 25,
    ["Richman St"] = 25,
    ["Ace Jones Dr"] = 25,
    ["Los Santos Freeway"] = 65,
    ["Eclipse Blvd"] = 35,
    ["West Eclipse Blvd"] = 35,
    ["Vinewood Blvd"] = 35,
    ["Mirror Park Blvd"] = 35,
    ["Burton Way"] = 35,
    ["Hawick Ave"] = 35,
    ["Alta St"] = 25,
    ["Occupation Ave"] = 25,
    ["South Shambles St"] = 25,
    ["Shambles St"] = 25,
    ["Integrity Way"] = 25,
    ["Swiss St"] = 25,
    ["Strawberry Ave"] = 25,
    ["Capital Blvd"] = 35,
    ["Crusade Rd"] = 25,
    ["Innocence Blvd"] = 35,
    ["Davis Ave"] = 25,
    ["Grove St"] = 25,
    ["Brouge Ave"] = 25,
    ["Covenant Ave"] = 25,
    ["South Blvd Del Perro"] = 35,
    ["Blvd Del Perro"] = 35,
    ["Magellan Ave"] = 35,
    ["Sandcastle Way"] = 25,
    ["Vespucci Blvd"] = 35,
    ["Prosperity St"] = 25,
    ["San Andreas Blvd"] = 45,
    ["Chum St"] = 25,
    ["Chupacabra St"] = 25,
    ["Fantastic Pl"] = 25,
    ["Melanoma St"] = 25,
    ["Nikola Ave"] = 25,
    ["Elysian Fields Fwy"] = 65,
    ["Olympic Fwy"] = 65,
    ["Popular St"] = 25,
    ["Amarillo Way"] = 25,
    ["Labor Pl"] = 25,
    ["Wiwang St"] = 25,
    ["Palomino Ave"] = 25,
    ["Tangerine St"] = 25,
    ["Vanilla Unicorn Way"] = 25,
    ["Elgin Ave"] = 25,
    ["Hawick Pl"] = 25,
    ["Supply St"] = 25,
    ["Tackle St"] = 25,
    ["Invention Ct"] = 25,
    ["Ginger St"] = 25,
    ["Lindsay Circus"] = 25,
    ["Meteor St"] = 25,
    ["San Vitus Blvd"] = 35,
    ["Forum Dr"] = 25,
    ["Strawberry"] = 25,
    ["textile City"] = 25,
    ["Little Seoul"] = 25,
    ["La Puerta Fwy"] = 65,
    ["Power St"] = 25,
    ["Mt Zonah Medical Center"] = 25,
    ["Crusade Rd"] = 25,
    ["Strawberry Ave"] = 25,
    ["Carson Ave"] = 25,
    ["Jamestown St"] = 25,
    ["Roy Lowenstein Blvd"] = 35,
    ["Sustancia Rd"] = 45,
    ["El Rancho Blvd"] = 35,
    ["Cypress Flats"] = 25,
    ["Orchardville Ave"] = 25,
    ["Popular St"] = 25,
    ["Fudge Ln"] = 25,
    ["Voodoo Pl"] = 25,
    ["Donovan St"] = 25,
    ["Macdonald St"] = 25,
    ["Greenwich Way"] = 25,
    ["Greenwich Pl"] = 25,
    ["Movie Star Way"] = 25,
    ["Caesars Pl"] = 25,
    ["Mad Wayne Thunder Dr"] = 25,
    ["Whispymound Dr"] = 25,
    ["Marlowe Dr"] = 25,
    ["Milton Rd"] = 25,
    ["North Conker Ave"] = 25,
    ["South Conker Ave"] = 25,
    ["Hillcrest Ave"] = 25,
    ["Hillcrest Ridge Access Rd"] = 25,
    ["North Sheldon Ave"] = 25,
    ["South Sheldon Ave"] = 25,
    ["Lake Vinewood Dr"] = 25,
    ["Lake Vinewood Estates"] = 25,
    ["Baytree Canyon Rd"] = 25,
    ["Peaceful St"] = 25,
    ["North Rockford Dr"] = 25,
    ["South Rockford Dr"] = 25,
    ["Cortes St"] = 25,
    ["Sam Austin Dr"] = 25,
    ["Steele Way"] = 25,
    ["Wealth Way"] = 25,
    ["Portola Dr"] = 25,
    ["Eastbourne Way"] = 25,
    ["Rhonda Way"] = 25,
    ["Westwegen Dr"] = 25,
    ["Spanish Ave"] = 25,
    ["Normandy Dr"] = 25,
    ["Picture Perfect Dr"] = 25,
    ["Wild Oats Dr"] = 25,
    ["Didion Dr"] = 25,
    ["Cox Way"] = 25,
    ["North Mo Milton Dr"] = 25,
    ["South Mo Milton Dr"] = 25,
    ["Caesars Place"] = 25,
    ["Mad Wayne Thunder Dr"] = 25,
    ["Hangman Ave"] = 25,
    ["Dunstable Ln"] = 25,
    ["Dunstable Dr"] = 25,
    ["Spanish Ave"] = 25,
    ["Edwood Way"] = 25,
    ["Greenwich Pkwy"] = 25,
    ["Kimble Hill Dr"] = 25,
    ["Abe Milton Pkwy"] = 25,
    ["Cockingend Dr"] = 25,
    ["Dorset Dr"] = 25,
    ["Dorset Pl"] = 25,
    ["Richman St"] = 25,
    ["Ace Jones Dr"] = 25,
    ["Buen Vino Rd"] = 45,
    ["North Calafia Way"] = 25,
    ["Calafia Bridge"] = 25
}