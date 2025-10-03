-- ND_SmallResources Server
-- Currently no server-side functionality needed for idle system

print("^2[ND_SmallResources]^7 Server started successfully")

-- Placeholder for future server-side features
RegisterNetEvent('ND_SmallResources:server:logIdlePlayer', function()
    local src = source
    print(string.format("[ND_SmallResources] Player %s went idle", GetPlayerName(src)))
end)
