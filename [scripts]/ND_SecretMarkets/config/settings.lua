Config = {}

-- General Settings
Config.Debug = true
Config.UseTarget = true -- Use ox_target for interactions
Config.Locale = 'en'

-- Market System Settings
Config.MaxHeatLevel = 100
Config.HeatDecayRate = 1 -- Heat decreases by this amount every minute
Config.HeatIncreasePerTransaction = 5
Config.PoliceAlertThreshold = 75 -- Heat level that triggers police alerts

-- Stock Management
Config.RestockInterval = 30 -- Minutes between restocks
Config.StockVariation = 0.2 -- 20% variation in stock amounts

-- Reputation System
Config.EnableReputation = true
Config.ReputationLevels = {
    ['stranger'] = {min = 0, max = 24, label = 'Stranger', discount = 0},
    ['known'] = {min = 25, max = 49, label = 'Known', discount = 0.05},
    ['trusted'] = {min = 50, max = 74, label = 'Trusted', discount = 0.10},
    ['partner'] = {min = 75, max = 100, label = 'Partner', discount = 0.15}
}

-- Time Settings
Config.TimeFormat = 24 -- 12 or 24 hour format

-- Animation Settings
Config.BuyAnimation = {
    dict = 'mp_common',
    name = 'givetake1_a',
    duration = 2000
}

Config.SellAnimation = {
    dict = 'mp_common',
    name = 'givetake2_a',
    duration = 2000
}

return Config