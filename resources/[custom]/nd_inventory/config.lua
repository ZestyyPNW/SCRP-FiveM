Config = {}

-- Inventory Settings
Config.MaxWeight = 30000 -- grams (30kg)
Config.MaxSlots = 50

-- Slot Configuration
Config.WeaponSlots = {1, 2} -- Primary and Secondary weapon slots
Config.PocketSlots = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27} -- 5x5 grid (25 slots)
Config.InventorySlots = {28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50} -- Additional inventory slots

-- Equipment Slots
Config.EquipmentSlots = {
    [41] = 'backpack', -- Backpack slot
    [42] = 'vest',     -- Vest/Armor slot
}

-- Drop Settings
Config.DropSlots = 24
Config.DropWeight = 30000
Config.DropLifetime = 600 -- seconds (10 minutes)

-- Vehicle Storage
Config.TrunkSizes = {
    [0] = {slots = 30, weight = 50000},  -- Compacts
    [1] = {slots = 35, weight = 60000},  -- Sedans
    [2] = {slots = 40, weight = 70000},  -- SUVs
    [3] = {slots = 25, weight = 40000},  -- Coupes
    [4] = {slots = 30, weight = 50000},  -- Muscle
    [5] = {slots = 25, weight = 40000},  -- Sports Classics
    [6] = {slots = 20, weight = 30000},  -- Sports
    [7] = {slots = 20, weight = 30000},  -- Super
    [8] = {slots = 10, weight = 20000},  -- Motorcycles
    [9] = {slots = 35, weight = 60000},  -- Off-road
    [10] = {slots = 50, weight = 100000}, -- Industrial
    [11] = {slots = 40, weight = 80000},  -- Utility
    [12] = {slots = 50, weight = 100000}, -- Vans
    [13] = {slots = 0, weight = 0},       -- Cycles (no storage)
    [14] = {slots = 10, weight = 15000},  -- Boats
    [15] = {slots = 0, weight = 0},       -- Helicopters
    [16] = {slots = 0, weight = 0},       -- Planes
    [17] = {slots = 40, weight = 70000},  -- Service
    [18] = {slots = 50, weight = 100000}, -- Emergency
    [19] = {slots = 50, weight = 100000}, -- Military
    [20] = {slots = 60, weight = 120000}, -- Commercial
}

Config.GloveboxSize = {slots = 8, weight = 5000}

-- UI Settings
Config.OpenKey = 'I'
Config.HotbarKey = 'TAB'
Config.UseBlur = true
Config.ImagePath = 'nui://nd_inventory/ui/build/images/'

-- Framework
Config.Framework = 'nd' -- NDCore integration
