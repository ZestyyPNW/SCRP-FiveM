-- Client-side inventory management
local inventoryOpen = false
local playerInventory = nil
local secondaryInventory = nil

-- Open inventory
function OpenInventory(secondary)
    if inventoryOpen then return end

    inventoryOpen = true
    SetNuiFocus(true, true)

    if Config.UseBlur then
        TriggerScreenblurFadeIn(0)
    end

    -- Disable controls while inventory is open
    CreateThread(function()
        while inventoryOpen do
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 140, true) -- Melee attack light
            DisableControlAction(0, 141, true) -- Melee attack heavy
            DisableControlAction(0, 142, true) -- Melee attack alternate
            DisableControlAction(0, 257, true) -- Attack 2
            Wait(0)
        end
    end)

    SendNUIMessage({
        action = 'openInventory',
        playerInventory = playerInventory,
        secondaryInventory = secondary
    })
end

-- Close inventory
function CloseInventory()
    if not inventoryOpen then return end

    inventoryOpen = false
    SetNuiFocus(false, false)

    if Config.UseBlur then
        TriggerScreenblurFadeOut(0)
    end

    SendNUIMessage({
        action = 'closeInventory'
    })
end

-- NUI Callbacks
RegisterNUICallback('closeInventory', function(data, cb)
    CloseInventory()
    cb('ok')
end)

RegisterNUICallback('moveItem', function(data, cb)
    TriggerServerEvent('nd_inventory:server:moveItem', data.fromInv, data.fromSlot, data.toInv, data.toSlot, data.count)
    cb('ok')
end)

RegisterNUICallback('useItem', function(data, cb)
    TriggerServerEvent('nd_inventory:server:useItem', data.slot)
    cb('ok')
end)

-- Keybinds
lib.addKeybind({
    name = 'open_inventory',
    description = 'Open Inventory',
    defaultKey = Config.OpenKey,
    onPressed = function()
        if inventoryOpen then
            CloseInventory()
        else
            OpenInventory()
        end
    end
})

-- Events
RegisterNetEvent('nd_inventory:client:refreshInventory', function(inventory)
    if inventory.type == 'player' then
        playerInventory = inventory
    else
        secondaryInventory = inventory
    end

    if inventoryOpen then
        SendNUIMessage({
            action = 'refreshInventory',
            playerInventory = playerInventory,
            secondaryInventory = secondaryInventory
        })
    end
end)

RegisterNetEvent('nd_inventory:client:notify', function(type, message)
    lib.notify({
        type = type,
        description = message
    })
end)

RegisterNetEvent('nd_inventory:client:openInventory', function(secondary)
    OpenInventory(secondary)
end)

-- On player loaded
AddEventHandler('ND:characterLoaded', function()
    print('[nd_inventory] Character loaded, requesting inventory...')
    Wait(2000) -- Wait 2 seconds to ensure character is fully loaded
    TriggerServerEvent('nd_inventory:server:loadInventory')
end)

-- Exports
exports('OpenInventory', OpenInventory)
exports('CloseInventory', CloseInventory)

print('[nd_inventory] Client initialized')
