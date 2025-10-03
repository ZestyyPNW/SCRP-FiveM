Items = {}

Items.MarketInventories = {
    ['drugs'] = {
        buy = {
            ['weedbag'] = {
                price = {min = 50, max = 80},
                stock = {min = 10, max = 25}
            },
            ['baggy_cocaine'] = {
                price = {min = 200, max = 300},
                stock = {min = 5, max = 15}
            },
            ['meth_baggy'] = {
                price = {min = 150, max = 250},
                stock = {min = 3, max = 10}
            },
            ['lsd'] = {
                price = {min = 100, max = 150},
                stock = {min = 2, max = 8}
            },
            ['armor_prettyheavy'] = {
                price = {min = 500, max = 750},
                stock = {min = 2, max = 5}
            },
            ['armor_extremelyheavy'] = {
                price = {min = 1000, max = 1500},
                stock = {min = 1, max = 3}
            },
            ['armor_superheavy'] = {
                price = {min = 2000, max = 3000},
                stock = {min = 1, max = 2}
            }
        },
        sell = {
            ['weedbag'] = {
                price = {min = 30, max = 50}
            },
            ['baggy_cocaine'] = {
                price = {min = 120, max = 180}
            },
            ['meth_baggy'] = {
                price = {min = 90, max = 150}
            }
        }
    },

    ['weapons'] = {
        buy = {
            ['weapon_pistol'] = {
                price = {min = 2500, max = 3500},
                stock = {min = 1, max = 3},
                reputation_required = 25
            },
            ['weapon_smg'] = {
                price = {min = 8000, max = 12000},
                stock = {min = 1, max = 2},
                reputation_required = 50
            },
            ['weapon_rifle'] = {
                price = {min = 15000, max = 20000},
                stock = {min = 1, max = 1},
                reputation_required = 75
            },
            ['ammo_pistol'] = {
                price = {min = 5, max = 10},
                stock = {min = 50, max = 200},
                reputation_required = 0
            },
            ['ammo_smg'] = {
                price = {min = 8, max = 15},
                stock = {min = 30, max = 100},
                reputation_required = 25
            }
        }
    },

    ['stolen_goods'] = {
        buy = {
            ['lockpick'] = {
                price = {min = 75, max = 125},
                stock = {min = 5, max = 15},
                reputation_required = 0
            },
            ['phone'] = {
                price = {min = 200, max = 400},
                stock = {min = 3, max = 8},
                reputation_required = 10
            },
            ['laptop'] = {
                price = {min = 800, max = 1200},
                stock = {min = 1, max = 3},
                reputation_required = 25
            }
        },
        sell = {
            ['phone'] = {
                price = {min = 150, max = 250}
            },
            ['laptop'] = {
                price = {min = 500, max = 800}
            },
            ['jewelry'] = {
                price = {min = 100, max = 300}
            },
            ['watch'] = {
                price = {min = 200, max = 500}
            }
        }
    },

    ['information'] = {
        buy = {
            ['security_codes'] = {
                price = {min = 1000, max = 2000},
                stock = {min = 1, max = 5},
                reputation_required = 50
            },
            ['police_radio'] = {
                price = {min = 500, max = 800},
                stock = {min = 1, max = 3},
                reputation_required = 75
            },
            ['blueprints'] = {
                price = {min = 2500, max = 5000},
                stock = {min = 1, max = 2},
                reputation_required = 100
            }
        }
    },

    ['luxury'] = {
        buy = {
            ['rolex'] = {
                price = {min = 15000, max = 25000},
                stock = {min = 1, max = 2},
                reputation_required = 75
            },
            ['diamond'] = {
                price = {min = 5000, max = 10000},
                stock = {min = 1, max = 3},
                reputation_required = 50
            },
            ['gold_bar'] = {
                price = {min = 8000, max = 12000},
                stock = {min = 1, max = 2},
                reputation_required = 75
            }
        },
        sell = {
            ['jewelry'] = {
                price = {min = 800, max = 1500}
            },
            ['watch'] = {
                price = {min = 1000, max = 2500}
            },
            ['gold'] = {
                price = {min = 2000, max = 4000}
            }
        }
    }
}

return Items