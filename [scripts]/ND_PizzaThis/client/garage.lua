local Targets = {}
local parking = {}
local player = nil

RegisterNetEvent('ND:characterLoaded', function(character)
	player = character
end)

RegisterNetEvent('ND:characterUnloaded', function()
	player = nil
end)

RegisterNetEvent('ND:updateJob', function(job)
	if player then
		player.job = job
	end
end)

--Garage Locations
CreateThread(function()
	for k, v in pairs(Config.Locations) do
		if v.garage then
			local out = v.garage.out
			Targets["PizzaGarage: "..k] =
			exports.ox_target:addBoxZone({
				coords = vector3(out.x, out.y, out.z-1.03),
				size = vec3(0.8, 0.5, 1.4),
				rotation = out[4]+180.0,
				debug = Config.Debug,
				options = {
					{
						name = "pizzathis_garage_"..k,
						event = "ND_PizzaThis:client:Garage:Menu",
						icon = "fas fa-clipboard",
						label = Loc[Config.Lan].targetinfo["job_vehicles"],
						groups = v.job,
						coords = v.garage.spawn,
						list = v.garage.list
					}
				}
			})
			parking[#parking+1] = makeProp({prop = `prop_parkingpay`, coords = vector4(out.x, out.y, out.z, out.w+180)}, 1, 0)
		end
	end
end)

local currentVeh = { out = false, current = nil }
RegisterNetEvent('ND_PizzaThis:client:Garage:Menu', function(data)
	RequestAnimDict('amb@prop_human_atm@male@enter') while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do Wait(1) end
	if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true) end

	local contextMenu = {
		id = 'pizzathis_garage',
		title = Loc[Config.Lan].menu["job_garage"],
		options = {}
	}

	if currentVeh.out and DoesEntityExist(currentVeh.current) then
		table.insert(contextMenu.options, {
			title = Loc[Config.Lan].menu["vehicle_out_of_garage"],
			description = Loc[Config.Lan].menu["vehicle"]..GetDisplayNameFromVehicleModel(GetEntityModel(currentVeh.current))..Loc[Config.Lan].menu["plate"]..GetVehicleNumberPlateText(currentVeh.current).."]",
			icon = "fas fa-clipboard-list",
			event = "ND_PizzaThis:client:Garage:Blip"
		})
		table.insert(contextMenu.options, {
			title = Loc[Config.Lan].menu["remove_vehicle"],
			icon = "fas fa-car-burst",
			event = "ND_PizzaThis:client:RemSpawn"
		})
	else
		currentVeh = { out = false, current = nil }
		table.sort(data.list, function(a, b) return a:lower() < b:lower() end)
		for k,v in pairs(data.list) do
			local spawnName = v
			v = string.lower(GetDisplayNameFromVehicleModel(GetHashKey(spawnName)))	v = v:sub(1,1):upper()..v:sub(2).." "..GetMakeNameFromVehicleModel(GetHashKey(tostring(spawnName)))
			table.insert(contextMenu.options, {
				title = v,
				event = "ND_PizzaThis:client:SpawnList",
				args = { spawnName = spawnName, coords = data.coords }
			})
		end
	end

	lib.registerContext(contextMenu)
	lib.showContext('pizzathis_garage')
end)

RegisterNetEvent("ND_PizzaThis:client:SpawnList", function(data)
	local oldveh = GetClosestVehicle(data.coords.x, data.coords.y, data.coords.z, 2.5, 0, 71)
	if oldveh ~= 0 then
		local name = GetDisplayNameFromVehicleModel(GetEntityModel(oldveh)):lower()
		-- Get vehicle name from server
		local vehicleName = lib.callback.await('ND_PizzaThis:GetVehicleName', false, GetEntityModel(oldveh))
		if vehicleName then name = vehicleName end
		lib.notify({title = "Error", description = name..Loc[Config.Lan].error["in_the_way"], type = "error"})
	else
		-- Use ND Framework vehicle spawn if available, otherwise fallback
		local coords = data.coords
		local veh = CreateVehicle(GetHashKey(data.spawnName), coords.x, coords.y, coords.z, coords.w, true, false)
		while not DoesEntityExist(veh) do Wait(10) end

		currentVeh = { out = true, current = veh }
		SetVehicleModKit(veh, 0)
		NetworkRequestControlOfEntity(veh)
		local plateText = "PIZZ"..tostring(math.random(100, 999))
		if player and player.job then
			plateText = string.sub(player.job.name, 1, 5)..tostring(math.random(100, 999))
		end
		SetVehicleNumberPlateText(veh, plateText)
		SetEntityHeading(veh, coords.w)
		TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
		SetVehicleColours(veh, 131, 128)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
		SetVehicleEngineOn(veh, true, true)
		Wait(250)
		SetVehicleDirtLevel(veh, 0.0)
		lib.notify({title = "Success", description = Loc[Config.Lan].success["retrieved"]..GetDisplayNameFromVehicleModel(GetHashKey(data.spawnName)).." ["..GetVehicleNumberPlateText(currentVeh.current).."]", type = "success"})
	end
end)

RegisterNetEvent("ND_PizzaThis:client:RemSpawn", function(data)
	-- SetVehicleEngineHealth(currentVeh.current, 200.0)
	-- SetVehicleBodyHealth(currentVeh.current, 200.0)
	-- for i = 0, 7 do SmashVehicleWindow(currentVeh.current, i) Wait(150) end PopOutVehicleWindscreen(currentVeh.current)
	-- for i = 0, 5 do	SetVehicleTyreBurst(currentVeh.current, i, true, 0) Wait(150) end
	-- for i = 0, 5 do SetVehicleDoorBroken(currentVeh.current, i, false) Wait(150) end
	-- Wait(800)
	DeleteEntity(currentVeh.current) currentVeh = { out = false, current = nil }
end)

local markerOn = false
RegisterNetEvent("ND_PizzaThis:client:Garage:Blip", function(data)
	lib.notify({title = "Info", description = Loc[Config.Lan].info["job_vehicle_map"], type = "info"})
	if markerOn then markerOn = not markerOn end
	markerOn = true
	local carBlip = GetEntityCoords(currentVeh.current)
	if not DoesBlipExist(garageBlip) then
		garageBlip = AddBlipForCoord(carBlip.x, carBlip.y, carBlip.z)
		SetBlipColour(garageBlip, 8)
		SetBlipRoute(garageBlip, true)
		SetBlipSprite(garageBlip, 85)
		SetBlipRouteColour(garageBlip, 3)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString("Job Vehicle")
		EndTextCommandSetBlipName(garageBlip)
	end
	while markerOn do
		local time = 5000
		local carLoc = GetEntityCoords(currentVeh.current)
		local playerLoc = GetEntityCoords(PlayerPedId())
		if DoesEntityExist(currentVeh.current) then
			if #(carLoc - playerLoc) <= 30.0 then time = 100
			elseif #(carLoc - playerLoc) <= 1.5 then
				RemoveBlip(garageBlip)
				garageBlip = nil
				markerOn = not markerOn
			else time = 5000 end
		else
			RemoveBlip(garageBlip)
			garageBlip = nil
			markerOn = not markerOn
		end
		Wait(time)
	end
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	for k in pairs(Targets) do exports.ox_target:removeZone(k) end
	for i = 1, #parking do DeleteEntity(parking[i]) end
end)
