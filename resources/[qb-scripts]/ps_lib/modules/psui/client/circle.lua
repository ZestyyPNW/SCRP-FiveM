local p = nil

--- @param cb function|boolean: Callback function that will receive the result of the game (true for success, false for failure)
--- @param circles number|nil: Number of circles in the game (default is 1 if nil or less than 1)
--- @param seconds number|nil: Time duration of the game in seconds (default is 10 if nil or less than 1)
local function circle(cb, circles, seconds)
    if circles == nil or circles < 1 then circles = 1 end
    if seconds == nil or seconds < 1 then seconds = 10 end
    p = promise.new()
    SendNUIMessage({
        action = 'CircleGame',
        data = {
            circles = circles,
            time = seconds,
        }
    })
    SetNuiFocus(true, true)
    local result = Citizen.Await(p)
    if cb ~= false then
        cb(result)
    end

    return result

end

--- @param data any: Data sent from the NUI (not used in this function)
--- @param cb function: Callback function to signal completion of the NUI callback (must be called to complete the NUI callback)
RegisterNuiCallback('circle-result', function(data, cb)
    p:resolve(data)
    p = nil
    SetNuiFocus(false, false)
    cb('ok')
end)

exports("Circle", circle)
ps.exportChange('ps-ui', "Circle", circle)

RegisterCommand("testCircle", function(source, args, rawCommand)
    local circles = tonumber(args[1]) or 1
    local seconds = tonumber(args[2]) or 10
    local c = circle(false, circles, seconds)
    if c then
        ps.notify("Circle game completed successfully with result: " .. tostring(c), 'success')
    else
        ps.notify("Circle game failed or was cancelled.", 'error')
    end
end, false)