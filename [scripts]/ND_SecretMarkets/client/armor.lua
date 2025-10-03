local ox_lib = exports.ox_lib

local armorValues = {
    ['armor_prettyheavy'] = 50,
    ['armor_extremelyheavy'] = 75,
    ['armor_superheavy'] = 100
}

exports('useArmor', function(data, slot)
    local armorType = data.name
    local armorAmount = armorValues[armorType]

    if not armorAmount then
        return
    end

    -- Play zipper sound
    PlaySoundFrontend(-1, "Clothes1", "mp_safehouseshower_soundset", true)

    -- Animation
    local ped = PlayerPedId()
    local dict = "clothingtie"
    local anim = "try_tie_negative_a"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 3000, 49, 0, false, false, false)

    Wait(3000)

    -- Apply armor
    SetPedArmour(ped, armorAmount)

    ox_lib:notify({
        type = 'success',
        description = 'Armor equipped'
    })
end)