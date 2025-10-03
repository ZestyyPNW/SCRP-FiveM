-- ND Framework conversion - McDonald's Menu System using ox_lib

RegisterNetEvent('ND_McDonalds:craftmenu', function()
    lib.registerContext({
        id = 'mcdonalds_craft_menu',
        title = 'Craft Menu',
        options = {
            {
                title = 'Small Bag',
                description = 'Craft a small bag',
                icon = 'box',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:smallpacket')
                end
            },
            {
                title = 'Big Bag',
                description = 'Craft a big bag',
                icon = 'box',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:bigpacket')
                end
            },
            {
                title = 'Special Menu',
                description = 'Craft special menu',
                icon = 'star',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:goatpacket')
                end
            },
            {
                title = 'Coffee Menu',
                description = 'Craft coffee menu',
                icon = 'mug-hot',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:coffeepacket')
                end
            }
        }
    })
    lib.showContext('mcdonalds_craft_menu')
end)

RegisterNetEvent('ND_McDonalds:ordermenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_order_menu',
        title = 'Fridge',
        options = {
            {
                title = 'Order Items',
                description = 'Order ingredients from storage',
                icon = 'box-open',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:shop')
                end
            },
            {
                title = 'Fridge Storage',
                description = 'Access fridge storage',
                icon = 'snowflake',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:storge2')
                end
            },
            {
                title = 'Ice Cream Station',
                description = 'Make ice cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:icecream')
                end
            }
        }
    })
    lib.showContext('mcdonalds_order_menu')
end)

RegisterNetEvent('ND_McDonalds:dutymenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_duty_menu',
        title = 'Duty Menu',
        options = {
            {
                title = 'Toggle Duty',
                description = 'Clock in/out',
                icon = 'clock',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:duty')
                end
            }
        }
    })
    lib.showContext('mcdonalds_duty_menu')
end)

RegisterNetEvent('ND_McDonalds:friesmenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_fries_menu',
        title = 'Fries Menu',
        options = {
            {
                title = 'Fries Station',
                description = '',
                icon = 'fire-burner',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:friestlist')
                end
            }
        }
    })
    lib.showContext('mcdonalds_fries_menu')
end)

RegisterNetEvent('ND_McDonalds:friestlist', function(data)
    lib.registerContext({
        id = 'mcdonalds_fries_list',
        title = 'Fries Station',
        menu = 'mcdonalds_fries_menu',
        options = {
            {
                title = 'Large Fries',
                description = 'Make large fries',
                icon = 'fire',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:bigpotato')
                end
            },
            {
                title = 'Small Fries',
                description = 'Make small fries',
                icon = 'fire',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:smallpotato')
                end
            },
            {
                title = 'Onion Rings',
                description = 'Make onion rings',
                icon = 'ring',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:rings')
                end
            },
            {
                title = 'Chicken Nuggets',
                description = 'Make chicken nuggets',
                icon = 'drumstick-bite',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:nuggets')
                end
            }
        }
    })
    lib.showContext('mcdonalds_fries_list')
end)

RegisterNetEvent('ND_McDonalds:meatmenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_meat_menu',
        title = 'Meat Station',
        options = {
            {
                title = 'Cook Meat',
                description = 'Cook frozen meat',
                icon = 'burger',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:meat')
                end
            }
        }
    })
    lib.showContext('mcdonalds_meat_menu')
end)

RegisterNetEvent('ND_McDonalds:drinkmenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_drink_menu',
        title = 'Drink Station',
        options = {
            {
                title = 'Large Cola',
                description = 'Make large cola',
                icon = 'glass',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:bigcola')
                end
            },
            {
                title = 'Small Cola',
                description = 'Make small cola',
                icon = 'glass',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:smallcola')
                end
            },
            {
                title = 'Coffee',
                description = 'Make coffee',
                icon = 'mug-hot',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:coffee')
                end
            }
        }
    })
    lib.showContext('mcdonalds_drink_menu')
end)

RegisterNetEvent('ND_McDonalds:burgermenu', function(data)
    lib.registerContext({
        id = 'mcdonalds_burger_menu',
        title = 'Burger Station',
        options = {
            {
                title = 'Bleeder Burger',
                description = 'Make bleeder burger',
                icon = 'burger',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:bleederburger')
                end
            },
            {
                title = 'Big Mac',
                description = 'Make Big Mac burger',
                icon = 'burger',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:bigkingburger')
                end
            },
            {
                title = 'Wrap',
                description = 'Make wrap',
                icon = 'bread-slice',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:wrap')
                end
            }
        }
    })
    lib.showContext('mcdonalds_burger_menu')
end)

RegisterNetEvent('ND_McDonalds:icecream', function(data)
    lib.registerContext({
        id = 'mcdonalds_icecream_menu',
        title = 'Ice Cream Station',
        menu = 'mcdonalds_order_menu',
        options = {
            {
                title = 'Chocolate Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:chocolateicecream')
                end
            },
            {
                title = 'Vanilla Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:vanillaicecream')
                end
            },
            {
                title = 'Special Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:thesmurfsicecream')
                end
            },
            {
                title = 'Strawberry Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:strawberryicecream')
                end
            },
            {
                title = 'Matcha Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:matchaicecream')
                end
            },
            {
                title = 'Ube Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:ubeicecream')
                end
            },
            {
                title = 'Berry Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:smurfetteicecream')
                end
            },
            {
                title = 'Unicorn Ice Cream',
                icon = 'ice-cream',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:unicornicecream')
                end
            }
        }
    })
    lib.showContext('mcdonalds_icecream_menu')
end)

RegisterNetEvent('ND_McDonalds:sellpacket', function(data)
    lib.registerContext({
        id = 'mcdonalds_sell_menu',
        title = 'Package Delivery',
        options = {
            {
                title = 'Small Package Delivery',
                icon = 'box',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:startdeliverysmall')
                end
            },
            {
                title = 'Big Package Delivery',
                icon = 'boxes',
                onSelect = function()
                    TriggerEvent('ND_McDonalds:client:startdeliverybig')
                end
            }
        }
    })
    lib.showContext('mcdonalds_sell_menu')
end)

-- ox_target integration (replaces qb-target)
exports.ox_target:addBoxZone({
    coords = vec3(Config.Duty.x, Config.Duty.y, Config.Duty.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_duty',
            icon = 'fa-solid fa-hand-holding',
            label = 'Duty',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:dutymenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Tray.x, Config.Tray.y, Config.Tray.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_tray',
            icon = 'fa-solid fa-hand-holding',
            label = 'Tray',
            onSelect = function()
                TriggerEvent('ND_McDonalds:tray')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Tray2.x, Config.Tray2.y, Config.Tray2.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_tray2',
            icon = 'fa-solid fa-hand-holding',
            label = 'Tray',
            onSelect = function()
                TriggerEvent('ND_McDonalds:tray2')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Storge.x, Config.Storge.y, Config.Storge.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_storage',
            icon = 'fa-solid fa-hand-holding',
            label = 'Storage',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:storge')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Fridge.x, Config.Fridge.y, Config.Fridge.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_fridge',
            icon = 'fa-solid fa-hand-holding',
            label = 'Fridge',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:ordermenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Fries.x, Config.Fries.y, Config.Fries.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_fries',
            icon = 'fa-solid fa-hand-holding',
            label = 'Fries Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:friesmenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Drink.x, Config.Drink.y, Config.Drink.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_drink',
            icon = 'fa-solid fa-hand-holding',
            label = 'Drink Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:drinkmenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.MeatStation.x, Config.MeatStation.y, Config.MeatStation.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_meat',
            icon = 'fa-solid fa-hand-holding',
            label = 'Meat Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:meatmenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.BurgerStation.x, Config.BurgerStation.y, Config.BurgerStation.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_burger',
            icon = 'fa-solid fa-hand-holding',
            label = 'Burger Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:burgermenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.PackageStation.x, Config.PackageStation.y, Config.PackageStation.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_package',
            icon = 'fa-solid fa-hand-holding',
            label = 'Package Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:craftmenu')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Clean.x, Config.Clean.y, Config.Clean.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_clean',
            icon = 'fa-solid fa-hand-holding',
            label = 'Clean Station',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:client:clean')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.SellItem.x, Config.SellItem.y, Config.SellItem.z),
    size = vec3(1.0, 1.0, 1.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_sell',
            icon = 'fa-solid fa-hand-holding',
            label = 'Start Delivery',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:sellpacket')
            end
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vec3(Config.Finish.x, Config.Finish.y, Config.Finish.z),
    size = vec3(2.0, 2.0, 2.0),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'mcdonalds_finish',
            icon = 'fa-solid fa-hand-holding',
            label = 'Finish Delivery',
            groups = Config.Job,
            onSelect = function()
                TriggerEvent('ND_McDonalds:client:sellingfinish')
            end
        }
    }
})
