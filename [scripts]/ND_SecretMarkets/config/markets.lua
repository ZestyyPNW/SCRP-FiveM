Markets = {}

Markets.Dealers = {
    -- Drug Dealer - Downtown Alley
    ['drugs_downtown'] = {
        name = 'Sketchy Mike',
        model = 's_m_y_dealer_01',
        coords = vector4(227.13, -1848.58, 25.96, 315.0),
        blip = {
            enabled = false, -- Hidden by default
            sprite = 51,
            color = 1,
            scale = 0.8,
            label = 'Contact'
        },
        availability = {
            days = {1, 2, 3, 4, 5, 6, 7}, -- Monday-Sunday (1=Monday)
            hours = {
                start = 0, -- Always available
                finish = 23  -- Always available
            }
        },
        market_type = 'drugs',
        heat_generation = 10, -- Higher heat for drug deals
        reputation_required = 0,
        interactions = {
            buy = true,
            sell = true
        }
    }
}

return Markets