-- ND Framework conversion of qb-burgershot to McDonald's
local player = nil
local onDuty = false
local clean = false
local client = false
local status = false
local smallblip = false
local bigblip = false
local bliptable = {}
local delivery = 0

-- Player loading event using ND Framework
AddEventHandler('ND:characterLoaded', function(character)
    player = character
    PlayerPed = PlayerPedId()
    if player.job and player.job.name == Config.Job then
        if onDuty then
            onDuty = false
        end
    end
end)

-- OPTIMIZED: Clear peds every 10 seconds instead of every frame (60+ FPS improvement)
Citizen.CreateThread(function()
    while true do
        Wait(10000)  -- Every 10 seconds
        ClearAreaOfPeds(-1519.754, -1314.039, 2.0656788, 145.59857, 1.0)
        ClearAreaOfPeds(205.48794, -925.5386, 29.807975, 162.48976, 1.0)
        ClearAreaOfPeds(842.23986, 4236.5395, 51.972747, 254.78793, 1.0)
    end
end)

-- Job update event
AddEventHandler('ND:updateJob', function(job)
    player.job = job
end)

-- Duty toggle event
RegisterNetEvent('ND_McDonalds:toggleDuty')
AddEventHandler('ND_McDonalds:toggleDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent('ND_McDonalds:CraftSmallBagItem', function()
    TriggerServerEvent('ND_McDonalds:SmallBagItem')
    TriggerServerEvent('ND_McDonalds:givetoyMcDonalds')
end)

RegisterNetEvent('ND_McDonalds:CraftBigBagItem', function()
    TriggerServerEvent('ND_McDonalds:BigBagItem')
    TriggerServerEvent('ND_McDonalds:givetoyMcDonalds')
end)

RegisterNetEvent('ND_McDonalds:CraftGoatMenuItem', function()
    TriggerServerEvent('ND_McDonalds:GoatMenuItem')
    TriggerServerEvent('ND_McDonalds:givetoyMcDonalds')
end)

RegisterNetEvent('ND_McDonalds:CraftCoffeeMenuItem', function()
    TriggerServerEvent('ND_McDonalds:CoffeeMenuItem')
    TriggerServerEvent('ND_McDonalds:givetoyMcDonalds')
end)

RegisterNetEvent("ND_McDonalds:shop")
AddEventHandler("ND_McDonalds:shop", function()
    if onDuty then
        if player and player.job and player.job.name == Config.Job then
            exports.ox_inventory:openInventory('shop', { type = 'mcdonalds', id = 1 })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

---------McDonald's Job---------

RegisterNetEvent("ND_McDonalds:duty")
AddEventHandler("ND_McDonalds:duty", function()
    onDuty = not onDuty
    TriggerServerEvent('ND_McDonalds:server:setDuty', onDuty)
    lib.notify({
        title = 'McDonald\'s',
        description = onDuty and 'You are now on duty' or 'You are now off duty',
        type = 'success'
    })
end)

RegisterNetEvent("ND_McDonalds:tray")
AddEventHandler("ND_McDonalds:tray", function()
    exports.ox_inventory:openInventory('stash', 'mcdonalds_tray')
end)

RegisterNetEvent("ND_McDonalds:tray2")
AddEventHandler("ND_McDonalds:tray2", function()
    exports.ox_inventory:openInventory('stash', 'mcdonalds_tray2')
end)

RegisterNetEvent("ND_McDonalds:storge")
AddEventHandler("ND_McDonalds:storge", function()
    if onDuty then
        exports.ox_inventory:openInventory('stash', 'mcdonalds_storage')
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:storge2")
AddEventHandler("ND_McDonalds:storge2", function()
    if onDuty then
        exports.ox_inventory:openInventory('stash', 'mcdonalds_storage2')
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:smallpacket")
AddEventHandler("ND_McDonalds:smallpacket", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:smallpacket', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making small bag...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:add:smallpacket')
                        Dirt()
                        client = true
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Package created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:bigpacket")
AddEventHandler("ND_McDonalds:bigpacket", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:bigpacket', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making big bag...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:add:bigpacket')
                        Dirt()
                        client = true
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Package created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:goatpacket")
AddEventHandler("ND_McDonalds:goatpacket", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:goatpacket', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making special menu...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:add:goatpacket')
                        Dirt()
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Package created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:coffeepacket")
AddEventHandler("ND_McDonalds:coffeepacket", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:coffeepacket', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making coffee...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:add:coffeepacket')
                        Dirt()
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Package created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:bigcola")
AddEventHandler("ND_McDonalds:client:bigcola", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making big cola...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:bigcola')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.BigEmptyGlass)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:smallcola")
AddEventHandler("ND_McDonalds:client:smallcola", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making small cola...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:smallcola')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.SmallEmptyGlass)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:coffee")
AddEventHandler("ND_McDonalds:client:coffee", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making coffee...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:coffee')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.CoffeeEmptyGlass)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:bigpotato")
AddEventHandler("ND_McDonalds:client:bigpotato", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:bigpotato', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making large fries...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                        prop = {
                            model = 'prop_cs_fork',
                            bone = 28422,
                            pos = vec3(-0.005, 0.00, 0.00),
                            rot = vec3(175.0, 160.0, 0.0)
                        }
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:bigpotato')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:smallpotato")
AddEventHandler("ND_McDonalds:client:smallpotato", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:smallpotato', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making small fries...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                        prop = {
                            model = 'prop_cs_fork',
                            bone = 28422,
                            pos = vec3(-0.005, 0.00, 0.00),
                            rot = vec3(175.0, 160.0, 0.0)
                        }
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:smallpotato')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:rings")
AddEventHandler("ND_McDonalds:client:rings", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:rings', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making onion rings...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                        prop = {
                            model = 'prop_cs_fork',
                            bone = 28422,
                            pos = vec3(-0.005, 0.00, 0.00),
                            rot = vec3(175.0, 160.0, 0.0)
                        }
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:rings')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:nuggets")
AddEventHandler("ND_McDonalds:client:nuggets", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:nuggets', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making nuggets...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                        prop = {
                            model = 'prop_cs_fork',
                            bone = 28422,
                            pos = vec3(-0.005, 0.00, 0.00),
                            rot = vec3(175.0, 160.0, 0.0)
                        }
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:nuggets')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:meat")
AddEventHandler("ND_McDonalds:client:meat", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Cooking meat...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                        prop = {
                            model = 'prop_cs_fork',
                            bone = 28422,
                            pos = vec3(-0.005, 0.00, 0.00),
                            rot = vec3(175.0, 160.0, 0.0)
                        }
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:meat')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.FrozenMeat)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:bleederburger")
AddEventHandler("ND_McDonalds:client:bleederburger", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:bleederburger', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making burger...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:bleederburger')
                        Dirt()
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:bigkingburger")
AddEventHandler("ND_McDonalds:client:bigkingburger", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:bigkingburger', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making Big Mac...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:bigkingburger')
                        Dirt()
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:wrap")
AddEventHandler("ND_McDonalds:client:wrap", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:server:get:wrap', false, function(HasItems)
                if HasItems then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making wrap...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_player',
                            flag = 49
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:wrap')
                        Dirt()
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:macaroon")
AddEventHandler("ND_McDonalds:client:macaroon", function()
    if onDuty then
        if clean then
            if lib.progressCircle({
                duration = Config.ProgressbarTime,
                position = 'bottom',
                label = 'Making dessert...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                },
                anim = {
                    dict = 'mp_common',
                    clip = 'givetake1_a',
                    flag = 8
                },
            }) then
                TriggerServerEvent('ND_McDonalds:server:macaroon')
                Dirt()
                lib.notify({
                    title = 'McDonald\'s',
                    description = 'Created successfully',
                    type = 'success'
                })
            else
                lib.notify({
                    title = 'McDonald\'s',
                    description = 'Cancelled',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:chocolateicecream")
AddEventHandler("ND_McDonalds:client:chocolateicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making chocolate ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:chocolateicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:vanillaicecream")
AddEventHandler("ND_McDonalds:client:vanillaicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making vanilla ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:vanillaicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:thesmurfsicecream")
AddEventHandler("ND_McDonalds:client:thesmurfsicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making special ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:thesmurfsicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:strawberryicecream")
AddEventHandler("ND_McDonalds:client:strawberryicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making strawberry ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:strawberryicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:matchaicecream")
AddEventHandler("ND_McDonalds:client:matchaicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making matcha ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:matchaicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:ubeicecream")
AddEventHandler("ND_McDonalds:client:ubeicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making ube ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:ubeicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:smurfetteicecream")
AddEventHandler("ND_McDonalds:client:smurfetteicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making special ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:smurfetteicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:unicornicecream")
AddEventHandler("ND_McDonalds:client:unicornicecream", function()
    if onDuty then
        if clean then
            lib.callback('ND_McDonalds:itemcheck', false, function(data)
                if data then
                    if lib.progressCircle({
                        duration = Config.ProgressbarTime,
                        position = 'bottom',
                        label = 'Making unicorn ice cream...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        },
                        anim = {
                            dict = 'amb@prop_human_bbq@male@base',
                            clip = 'base',
                            flag = 8
                        },
                    }) then
                        TriggerServerEvent('ND_McDonalds:server:unicornicecream')
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Created successfully',
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'McDonald\'s',
                            description = 'Cancelled',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'McDonald\'s',
                        description = 'You need the required items',
                        type = 'error'
                    })
                end
            end, Config.Cone)
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need to clean the station first',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:clean")
AddEventHandler("ND_McDonalds:client:clean", function()
    if lib.progressCircle({
        duration = Config.ProgressbarTime,
        position = 'bottom',
        label = 'Cleaning station...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = 'amb@world_human_bum_standing@twitchy@idle_a',
            clip = 'idle_a',
            flag = 49
        },
    }) then
        clean = true
        lib.notify({
            title = 'McDonald\'s',
            description = 'Station is now clean',
            type = 'success'
        })
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'Cancelled',
            type = 'error'
        })
    end
end)

function Dirt()
    if math.random(1,100) < Config.Dirt then
        clean = false
        lib.notify({
            title = 'McDonald\'s',
            description = 'The station has gotten dirty',
            type = 'error'
        })
    end
end

-- DrawText3D helper function for delivery system
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent("ND_McDonalds:client:smallpacketsell")
AddEventHandler("ND_McDonalds:client:smallpacketsell", function()
    if onDuty then
        smallblip = true
        random = math.random(1,#Config.SmallCoords)
        lib.notify({
            title = 'McDonald\'s',
            description = 'New order received! Check your GPS',
            type = 'inform'
        })
        SetNewWaypoint(Config.SmallCoords[random]["x"],Config.SmallCoords[random]["y"])
        status = true
        while status do
            local ped = PlayerPedId()
            local plycoords = GetEntityCoords(ped)
            local distance = #(plycoords - vector3(Config.SmallCoords[random]["x"],Config.SmallCoords[random]["y"],Config.SmallCoords[random]["z"]))
            Citizen.Wait(1)
            if distance < 1.0 and client  then
                DrawText3D(Config.SmallCoords[random]["x"],Config.SmallCoords[random]["y"],Config.SmallCoords[random]["z"], "[E] Deliver Package")
                if IsControlJustPressed(1, 38) then
                    SmallPacketSell()
                end
            end
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:startdeliverysmall")
AddEventHandler("ND_McDonalds:client:startdeliverysmall", function()
    if delivery == 0 then
        TriggerEvent("ND_McDonalds:client:smallpacketsell")
        -- Using ND Framework vehicle spawn (adjust based on your ND Framework setup)
        lib.requestModel(Config.Car)
        local vehicle = CreateVehicle(GetHashKey(Config.Car), Config.CarSpawnCoord.x, Config.CarSpawnCoord.y, Config.CarSpawnCoord.z, Config.CarSpawnCoord.w or 0.0, true, false)
        SetEntityCoords(PlayerPed, Config.CarSpawnCoord.x, Config.CarSpawnCoord.y, Config.CarSpawnCoord.z-1.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleLivery(vehicle, 14)
        SetVehicleColours(vehicle, 30, 30)
        -- Give keys (adjust based on your vehicle keys system)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
        delivery = 1
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You are already on a delivery',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:startdeliverybig")
AddEventHandler("ND_McDonalds:client:startdeliverybig", function()
    if delivery == 0 then
        TriggerEvent("ND_McDonalds:client:bigpacketsell")
        -- Using ND Framework vehicle spawn (adjust based on your ND Framework setup)
        lib.requestModel(Config.Car)
        local vehicle = CreateVehicle(GetHashKey(Config.Car), Config.CarSpawnCoord.x, Config.CarSpawnCoord.y, Config.CarSpawnCoord.z, Config.CarSpawnCoord.w or 0.0, true, false)
        SetEntityCoords(PlayerPed, Config.CarSpawnCoord.x, Config.CarSpawnCoord.y, Config.CarSpawnCoord.z-1.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleLivery(vehicle, 15)
        SetVehicleColours(vehicle, 62, 62)
        -- Give keys (adjust based on your vehicle keys system)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
        delivery = 1
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You are already on a delivery',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:bigpacketsell")
AddEventHandler("ND_McDonalds:client:bigpacketsell", function()
    if onDuty then
        random = math.random(1,#Config.BigCoords)
        lib.notify({
            title = 'McDonald\'s',
            description = 'New order received! Check your GPS',
            type = 'inform'
        })
        SetNewWaypoint(Config.BigCoords[random]["x"],Config.BigCoords[random]["y"])
        bigblip = true
        status = true
        while status do
            local ped = PlayerPedId()
            local plycoords = GetEntityCoords(ped)
            local distance = #(plycoords - vector3(Config.BigCoords[random]["x"],Config.BigCoords[random]["y"],Config.BigCoords[random]["z"]))
            Citizen.Wait(1)
            if distance < 1.0 and client then
                DrawText3D(Config.BigCoords[random]["x"],Config.BigCoords[random]["y"],Config.BigCoords[random]["z"], "[E] Deliver Package")
                if IsControlJustPressed(1, 38) then
                    BigPacketSell()
                end
            end
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be on duty',
            type = 'error'
        })
    end
end)

RegisterNetEvent("ND_McDonalds:client:sellingfinish")
AddEventHandler("ND_McDonalds:client:sellingfinish", function()
    if IsPedInAnyVehicle(PlayerPedId()) then
        if delivery == 1 then
            local car = GetVehiclePedIsIn(PlayerPedId(),true)
            NetworkFadeOutEntity(car, true,false)
            DeleteVehicle(car)
            client = false
            status = false
            delivery = 0
            lib.notify({
                title = 'McDonald\'s',
                description = 'Delivery completed!',
                type = 'success'
            })
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You are not on a delivery',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'McDonald\'s',
            description = 'You must be in the delivery vehicle',
            type = 'error'
        })
    end
end)

function SmallPacketSell()
    local ped = PlayerPedId()
    lib.callback('ND_McDonalds:itemcheck', false, function(data)
        if data then
            if lib.progressCircle({
                duration = Config.ProgressbarTime,
                position = 'bottom',
                label = 'Selling package...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = false,
                    car = false,
                    combat = true,
                },
                anim = {
                    dict = 'timetable@jimmy@doorknock@',
                    clip = 'knockdoor_idle',
                    flag = 49
                },
            }) then
                TriggerServerEvent("ND_McDonalds:server:smallpacketsell")
                TriggerEvent("ND_McDonalds:client:smallpacketsell")
                map = true
                ClearPedTasksImmediately(ped)
            end
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need the required items',
                type = 'error'
            })
            client = false
        end
    end, Config.SmallBagItem)
end

function BigPacketSell()
    local ped = PlayerPedId()
    lib.callback('ND_McDonalds:itemcheck', false, function(data)
        if data then
            if lib.progressCircle({
                duration = Config.ProgressbarTime,
                position = 'bottom',
                label = 'Selling package...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = false,
                    car = false,
                    combat = true,
                },
                anim = {
                    dict = 'timetable@jimmy@doorknock@',
                    clip = 'knockdoor_idle',
                    flag = 49
                },
            }) then
                TriggerServerEvent("ND_McDonalds:server:bigpacketsell")
                TriggerEvent("ND_McDonalds:client:bigpacketsell")
                map = true
                ClearPedTasksImmediately(ped)
            end
        else
            lib.notify({
                title = 'McDonald\'s',
                description = 'You need the required items',
                type = 'error'
            })
            client = false
        end
    end, Config.BigBagItem)
end

Citizen.CreateThread(function()
    McDonalds = AddBlipForCoord(-1178.312, -885.2465, 13.852689, 73.139015)
    SetBlipSprite (McDonalds, 106)
    SetBlipDisplay(McDonalds, 4)
    SetBlipScale  (McDonalds, 0.8)
    SetBlipAsShortRange(McDonalds, true)
    SetBlipColour(McDonalds, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("McDonald's")
    EndTextCommandSetBlipName(McDonalds)
end)

Citizen.CreateThread(function()
    Club77 = AddBlipForCoord(187.78758, -3167.848, 5.7891573)
    SetBlipSprite (Club77, 121)
    SetBlipDisplay(Club77, 4)
    SetBlipScale  (Club77, 0.8)
    SetBlipAsShortRange(Club77, true)
    SetBlipColour(Club77, 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Club77")
    EndTextCommandSetBlipName(Club77)
end)

Citizen.CreateThread(function()
    DARK = AddBlipForCoord(-573.9221, -942.2395, 23.861368)
    SetBlipSprite (DARK, 382)
    SetBlipDisplay(DARK, 4)
    SetBlipScale  (DARK, 0.6)
    SetBlipAsShortRange(DARK, true)
    SetBlipColour(DARK, 38)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("The DarkCast")
    EndTextCommandSetBlipName(DARK)
end)

Citizen.CreateThread(function()
    METAL = AddBlipForCoord(-1338.053, -1252.175, 5.9431118)
    SetBlipSprite (METAL, 468)
    SetBlipDisplay(METAL, 4)
    SetBlipScale  (METAL, 0.8)
    SetBlipAsShortRange(METAL, true)
    SetBlipColour(METAL, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Metal Detecting Sell")
    EndTextCommandSetBlipName(METAL)
end)

Citizen.CreateThread(function()
    judgeblip = AddBlipForCoord(242.61425, -393.1555, 46.348018)
    SetBlipSprite (judgeblip, 609)
    SetBlipDisplay(judgeblip, 4)
    SetBlipScale  (judgeblip, 0.6)
    SetBlipAsShortRange(judgeblip, true)
    SetBlipColour(judgeblip, 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Court Of Justice")
    EndTextCommandSetBlipName(judgeblip)
end)

Citizen.CreateThread(function()
    redline = AddBlipForCoord(467.47555, -582.2586, 28.461963)
    SetBlipSprite (redline, 545)
    SetBlipDisplay(redline, 4)
    SetBlipScale  (redline, 0.6)
    SetBlipAsShortRange(redline, true)
    SetBlipColour(redline, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Redline Mechanic")
    EndTextCommandSetBlipName(redline)
end)

Citizen.CreateThread(function()
    cardealership = AddBlipForCoord(-337.9371, -1370.018, 31.870502, 80.064346)
    SetBlipSprite (cardealership, 523)
    SetBlipDisplay(cardealership, 4)
    SetBlipScale  (cardealership, 0.6)
    SetBlipAsShortRange(cardealership, true)
    SetBlipColour(cardealership, 43)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Car Dealership")
    EndTextCommandSetBlipName(cardealership)
end)

Citizen.CreateThread(function()
    MechanicCosmetic = AddBlipForCoord(-34.89087, -1052.851, 27.765617)
    SetBlipSprite (MechanicCosmetic, 446)
    SetBlipDisplay(MechanicCosmetic, 4)
    SetBlipScale  (MechanicCosmetic, 0.5)
    SetBlipAsShortRange(MechanicCosmetic, true)
    SetBlipColour(MechanicCosmetic, 75)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Bennys")
    EndTextCommandSetBlipName(MechanicCosmetic)
end)

Citizen.CreateThread(function()
    taxii = AddBlipForCoord(908.43652, -175.7562, 74.167457)
    SetBlipSprite (taxii, 227)
    SetBlipDisplay(taxii, 4)
    SetBlipScale  (taxii, 0.5)
    SetBlipAsShortRange(taxii, true)
    SetBlipColour(taxii, 46)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Taxi")
    EndTextCommandSetBlipName(taxii)
end)

Citizen.CreateThread(function()
    boat = AddBlipForCoord(-1247.818, -1842.876, 1.9859631)
    SetBlipSprite (boat, 427)
    SetBlipDisplay(boat, 4)
    SetBlipScale  (boat, 0.7)
    SetBlipAsShortRange(boat, true)
    SetBlipColour(boat, 15)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Beach Boat Rental")
    EndTextCommandSetBlipName(boat)
end)
