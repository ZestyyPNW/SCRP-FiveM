-- Wait for NDCore to be available
CreateThread(function()
    while not NDCore do
        Wait(100)
    end
    print("[ND_TaxiJob] NDCore loaded successfully")
end)

function NearTaxi(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for k,v in pairs(Config.NPCLocations.DeliverLocations) do
        local dist = #(coords - vector3(v.x,v.y,v.z))
        if dist < 50 then -- Increased range from 20 to 50
            return true
        end
    end
    return false
end

RegisterNetEvent('ND_TaxiJob:server:NpcPay', function(Payment)
    local src = source

    print("[ND_TaxiJob] Payment request from player " .. src)
    print("[ND_TaxiJob] Payment amount: $" .. Payment)

    if not NDCore then
        print("[ND_TaxiJob] ERROR: NDCore is not loaded!")
        return
    end

    print("[ND_TaxiJob] NDCore is available")
    local player = NDCore.getPlayer(src)

    if not player then
        print("[ND_TaxiJob] ERROR: Player not found")
        return
    end

    print("[ND_TaxiJob] Player job type: " .. type(player.job))
    print("[ND_TaxiJob] Player job value: " .. tostring(player.job))

    -- Check if job is a table and print its structure
    if type(player.job) == "table" then
        print("[ND_TaxiJob] player.job is a TABLE")
        for k,v in pairs(player.job) do
            print("[ND_TaxiJob]   job." .. k .. " = " .. tostring(v))
        end
    end

    -- Try both string and table.name comparisons
    local isCorrectJob = false
    if type(player.job) == "string" and player.job == "taxi" then
        isCorrectJob = true
        print("[ND_TaxiJob] Job check: PASSED (string comparison)")
    elseif type(player.job) == "table" and player.job.name == "taxi" then
        isCorrectJob = true
        print("[ND_TaxiJob] Job check: PASSED (table.name comparison)")
    else
        print("[ND_TaxiJob] Job check: FAILED")
    end

    if isCorrectJob then
        local isNear = NearTaxi(src)
        print("[ND_TaxiJob] Near delivery location: " .. tostring(isNear))

        if isNear then
            local randomAmount = math.random(1, 5)
            local r1, r2 = math.random(1, 5), math.random(1, 5)
            if randomAmount == r1 or randomAmount == r2 then
                local bonus = math.random(10, 20)
                Payment = Payment + bonus
                print("[ND_TaxiJob] Bonus tip added: $" .. bonus)
            end

            print("[ND_TaxiJob] Adding money: $" .. Payment)
            player.addMoney("cash", Payment, "Taxi fare")

            player.notify({
                title = 'Taxi Job',
                description = 'You earned $' .. Payment,
                type = 'success'
            })

            -- 0.1% chance to get cryptostick as bonus (1 in 1000)
            local chance = math.random(1, 1000)
            if chance == 1 then
                print("[ND_TaxiJob] Attempting to give cryptostick...")
                local success = exports.ox_inventory:AddItem(src, "cryptostick", 1)
                if success then
                    print("[ND_TaxiJob] Cryptostick given successfully")
                    player.notify({
                        title = 'Taxi Job',
                        description = 'You found a cryptostick!',
                        type = 'success'
                    })
                else
                    print("[ND_TaxiJob] Failed to give cryptostick")
                end
            end
        else
            print("[ND_TaxiJob] ERROR: Player not near delivery location - possible exploit")
            DropPlayer(src, 'Taxi Job: Not near delivery location')
        end
    else
        print("[ND_TaxiJob] ERROR: Player job is not taxi - possible exploit")
        DropPlayer(src, 'Taxi Job: Invalid job')
    end
end)
