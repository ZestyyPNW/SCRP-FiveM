local cuffItems = {"cuffs", "zipties"}
local uncuffItems = {
    ["cuffs"] = "handcuffkey",
    ["zipties"] = "tools"
}

local function cuffCheck(src, target, cuffType)
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not lib.table.contains(cuffItems, cuffType) or
        exports.ox_inventory:GetItemCount(src, cuffType) == 0
        then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and

        targetState.handsUp or cuffType == "cuffs" and
        not targetState.gettingCuffed and
        not targetState.isCuffing and
        not targetState.isCuffed
end

local function uncuffCheck(src, target, cuffType)
    print("[DEBUG] uncuffCheck called")
    print("[DEBUG] src:", src, "target:", target, "cuffType:", cuffType)

    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)

    local srcInVeh = GetVehiclePedIsIn(ped) ~= 0
    local targetInVeh = GetVehiclePedIsIn(targetPed) ~= 0
    local distance = #(GetEntityCoords(ped)-GetEntityCoords(targetPed))
    local hasUncuffItem = uncuffItems[cuffType]
    local itemCount = exports.ox_inventory:GetItemCount(src, uncuffItems[cuffType] or "")

    print("[DEBUG] srcInVeh:", srcInVeh)
    print("[DEBUG] targetInVeh:", targetInVeh)
    print("[DEBUG] distance:", distance)
    print("[DEBUG] hasUncuffItem:", hasUncuffItem)
    print("[DEBUG] itemCount:", itemCount)

    if srcInVeh or targetInVeh or distance > 5.0 or not hasUncuffItem or itemCount == 0 then
        print("[DEBUG] uncuffCheck failed - basic checks")
        return false
    end

    local playerState = Player(src).state
    local targetState = Player(target).state

    print("[DEBUG] playerState.handsUp:", playerState.handsUp)
    print("[DEBUG] targetState.isCuffed:", targetState.isCuffed)

    local result = not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and
        targetState.isCuffed

    print("[DEBUG] uncuffCheck result:", result)
    return result
end

RegisterNetEvent("ND_Police:syncAgressiveCuff", function(target, angle, cuffType, slot, heading)
    local src = source
    if not cuffCheck(src, target, cuffType) then return end

    local escaped = lib.callback.await("ND_Police:syncAgressiveCuff", target, angle, cuffType, heading)
    if escaped then return end

    Player(target).state.handsUp = false
    exports.ox_inventory:RemoveItem(src, cuffType, 1, nil, slot)
end)

RegisterNetEvent("ND_Police:syncNormalCuff", function(target, angle, cuffType, slot)
    local src = source
    if not cuffCheck(src, target, cuffType) or not exports.ox_inventory:RemoveItem(src, cuffType, 1, nil, slot) then return end
    TriggerClientEvent("ND_Police:syncNormalCuff", target, angle, cuffType)
end)

print("[DEBUG] Registering ND_Police:uncuffPed server event")

RegisterNetEvent("ND_Police:uncuffPed", function(target, cuffType)
    local src = source
    print("[DEBUG] ND_Police:uncuffPed server event received")
    print("[DEBUG] Source:", src)
    print("[DEBUG] Target:", target)
    print("[DEBUG] Cuff type:", cuffType)

    local checkResult = uncuffCheck(src, target, cuffType)
    print("[DEBUG] Uncuff check result:", checkResult)

    if not checkResult then
        print("[DEBUG] Uncuff check failed")
        return
    end

    local playerCuffType = Player(target).state.cuffType or "cuffs"
    print("[DEBUG] Player cuff type:", playerCuffType)
    print("[DEBUG] Requested cuff type:", cuffType)

    if playerCuffType ~= cuffType then
        print("[DEBUG] Cuff type mismatch, returning")
        return
    end

    print("[DEBUG] Triggering client uncuff event")
    print("[DEBUG] Target player ID:", target)

    -- First, force update the player state on server side
    local targetState = Player(target).state
    targetState:set("isCuffed", false, true)
    targetState:set("cuffType", false, true)

    -- Then trigger the client event
    TriggerClientEvent("ND_Police:uncuffPed", target)

    -- Also send a test chat message to verify targeting works
    TriggerClientEvent('chat:addMessage', target, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "UNCUFF", "Debug: Uncuff event sent to you!" }
    })

    -- Refresh all client state sync - force re-sync with all other resources
    TriggerClientEvent("ND_Police:forceStateRefresh", -1, target)

    -- Force server-side state sync to all clients
    TriggerClientEvent("ND_Police:playerUncuffed", -1, target)

    -- Also trigger state bag change to ensure all clients get the update
    TriggerEvent("statebags:onPlayerUncuffed", target)

    -- Give more time for client to process
    Wait(1000)

    -- Double-check the state after the event
    print("[DEBUG] Final target state - isCuffed:", Player(target).state.isCuffed)

    print("[DEBUG] Adding cuff item back to inventory")
    exports.ox_inventory:AddItem(src, cuffType, 1)
    print("[DEBUG] Uncuff process completed")
end)
