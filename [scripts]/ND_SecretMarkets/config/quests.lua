Quests = {}

Quests.Types = {
    ['delivery'] = {
        name = 'Package Delivery',
        description = 'Deliver a package to the specified location without getting caught',
        base_reward = 500,
        heat_generated = 15
    },
    ['collection'] = {
        name = 'Item Collection',
        description = 'Collect specific items from around the city',
        base_reward = 300,
        heat_generated = 5
    },
    ['elimination'] = {
        name = 'Elimination Contract',
        description = 'Take out a specific target',
        base_reward = 1000,
        heat_generated = 25
    },
    ['heist_prep'] = {
        name = 'Heist Preparation',
        description = 'Steal equipment or intel for future operations',
        base_reward = 750,
        heat_generated = 20
    }
}

Quests.Available = {
    -- Delivery Missions
    ['deliver_package_1'] = {
        type = 'delivery',
        title = 'Discreet Delivery',
        description = 'Take this package to the docks. Avoid police attention.',
        objectives = {
            {
                type = 'goto',
                location = vector3(-1066.48, -2796.75, 27.84),
                radius = 5.0,
                label = 'Deliver package to the docks'
            }
        },
        rewards = {
            cash = 500,
            items = {
                {name = 'item_barter_valuable_gp', count = 1}
            }
        },
        time_limit = 600000, -- 10 minutes
        cooldown = 1800000 -- 30 minutes
    },

    ['deliver_package_2'] = {
        type = 'delivery',
        title = 'Midnight Drop',
        description = 'Drop this package at the parking garage. Be quick and quiet.',
        objectives = {
            {
                type = 'goto',
                location = vector3(227.13, -1848.58, 26.96),
                radius = 3.0,
                label = 'Drop package at garage'
            }
        },
        rewards = {
            cash = 750,
            items = {
                {name = 'item_barter_valuable_bitcoin', count = 1}
            }
        },
        time_limit = 480000, -- 8 minutes
        cooldown = 2400000 -- 40 minutes
    },

    -- Collection Missions
    ['collect_evidence'] = {
        type = 'collection',
        title = 'Evidence Collection',
        description = 'Collect police evidence bags from around the city.',
        objectives = {
            {
                type = 'collect',
                item = 'evidence_bag',
                amount = 3,
                label = 'Collect 3 evidence bags'
            }
        },
        rewards = {
            cash = 400,
            items = {
                {name = 'item_barter_valuable_elibadge', count = 1}
            }
        },
        time_limit = 900000, -- 15 minutes
        cooldown = 3600000 -- 1 hour
    },

    ['collect_electronics'] = {
        type = 'collection',
        title = 'Tech Acquisition',
        description = 'Gather electronic components from various sources.',
        objectives = {
            {
                type = 'collect',
                item = 'phone',
                amount = 2,
                label = 'Collect 2 phones'
            },
            {
                type = 'collect',
                item = 'laptop',
                amount = 1,
                label = 'Collect 1 laptop'
            }
        },
        rewards = {
            cash = 600,
            items = {
                {name = 'item_barter_valuable_cat', count = 1}
            }
        },
        time_limit = 1200000, -- 20 minutes
        cooldown = 2700000 -- 45 minutes
    },

    -- Elimination Contracts
    ['eliminate_rival'] = {
        type = 'elimination',
        title = 'Rival Cleanup',
        description = 'A rival dealer is causing problems. Deal with them permanently.',
        objectives = {
            {
                type = 'eliminate',
                target = 'rival_dealer',
                location = vector3(-1569.85, -3014.23, -74.41),
                radius = 50.0,
                label = 'Eliminate the rival dealer'
            }
        },
        rewards = {
            cash = 1500,
            items = {
                {name = 'item_barter_valuable_bitcoin', count = 2},
                {name = 'item_barter_valuable_gp', count = 1}
            }
        },
        time_limit = 1800000, -- 30 minutes
        cooldown = 7200000 -- 2 hours
    },

    -- Heist Prep Missions
    ['steal_security_codes'] = {
        type = 'heist_prep',
        title = 'Security Breach',
        description = 'Infiltrate a building and steal security access codes.',
        objectives = {
            {
                type = 'goto',
                location = vector3(-1915.45, 365.78, 93.59),
                radius = 2.0,
                label = 'Infiltrate the building'
            },
            {
                type = 'hack',
                duration = 30000, -- 30 seconds
                label = 'Hack the security system'
            }
        },
        rewards = {
            cash = 800,
            items = {
                {name = 'security_codes', count = 1},
                {name = 'item_barter_valuable_elibadge', count = 1}
            }
        },
        time_limit = 900000, -- 15 minutes
        cooldown = 5400000 -- 1.5 hours
    },

    ['acquire_intel'] = {
        type = 'heist_prep',
        title = 'Intelligence Gathering',
        description = 'Gather intel on police patrol routes and schedules.',
        objectives = {
            {
                type = 'observe',
                location = vector3(451.7, -992.8, 30.7), -- Police station
                duration = 120000, -- 2 minutes
                radius = 10.0,
                label = 'Observe police station'
            }
        },
        rewards = {
            cash = 650,
            items = {
                {name = 'police_radio', count = 1},
                {name = 'item_barter_valuable_chicken', count = 1}
            }
        },
        time_limit = 600000, -- 10 minutes
        cooldown = 4500000 -- 1.25 hours
    }
}

-- Quest difficulty tiers
Quests.Difficulty = {
    ['easy'] = {
        multiplier = 1.0,
        heat_reduction = 0.8
    },
    ['medium'] = {
        multiplier = 1.5,
        heat_reduction = 1.0
    },
    ['hard'] = {
        multiplier = 2.0,
        heat_reduction = 1.3
    }
}

-- Daily quest rotation
Quests.DailyQuests = {
    'deliver_package_1',
    'collect_evidence',
    'acquire_intel'
}

-- Weekly special quests
Quests.WeeklyQuests = {
    'eliminate_rival',
    'steal_security_codes'
}

return Quests