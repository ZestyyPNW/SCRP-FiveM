local player = nil
local onDuty = false
local alcoholCount = 0
local Targets = {}
local Props = {}
local Blips = {}

local function jobCheck()
	canDo = true
	if not onDuty then lib.notify({title = "Error", description = Loc[Config.Lan].error["not_clocked_in"], type = 'error'}) canDo = false end
	return canDo
end

RegisterNetEvent('ND:characterLoaded', function(character)
	player = character
	if player.job and player.job.name == "pizzathis" then
		onDuty = player.job.onduty or false
	end
end)

RegisterNetEvent('ND:characterUnloaded', function()
	player = nil
end)

RegisterNetEvent('ND:updateJob', function(job)
	if player then
		player.job = job
		onDuty = job.onduty
	end
end)

-- Duty toggle event
RegisterNetEvent('ND_PizzaThis:toggleDuty')
AddEventHandler('ND_PizzaThis:toggleDuty', function(duty)
    onDuty = duty
end)

-- Duty toggle handler
RegisterNetEvent("ND_PizzaThis:duty")
AddEventHandler("ND_PizzaThis:duty", function()
    onDuty = not onDuty
    TriggerServerEvent('ND_PizzaThis:server:setDuty', onDuty)
    lib.notify({
        title = 'Pizza This',
        description = onDuty and 'You are now on duty' or 'You are now off duty',
        type = 'success'
    })
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
	-- Player will be set when they join/load character
	-- Just reset local state
	player = nil
	onDuty = false
end)

CreateThread(function()
	-- Wait for PolyZone to be ready
	Wait(1000)

	local bossroles = {}
	-- Get boss roles from server - in ND Framework, ranks are an array, boss is determined by minimumBossRank
	local ranks = lib.callback.await('ND_PizzaThis:GetJobGrades', false)
	-- Boss roles are managed by ND_Core, we don't need to track them here

	for _, v in pairs(Config.Locations) do
		if v.zoneEnable then
			local JobLocation = PolyZone:Create(v.zones, { name = v.label, debugPoly = Config.Debug })
			JobLocation:onPlayerInOut(function(isPointInside)
				if not isPointInside and onDuty and player and player.job and player.job.name == "pizzathis" then
					-- Auto clock out when leaving zone
					TriggerEvent("ND_PizzaThis:duty")
				end
			end)

			Blips[#Blips+1] = makeBlip({coords = v.blip, sprite = 267, col = v.blipcolor, scale = 0.6, disp = 6, name = v.label})
		end
	end
	Targets["PizzTray"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1344.862, -1065.422, 7.2822449),
		size = vec3(0.6, 1.6, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_tray',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-box-open",
				label = Loc[Config.Lan].targetinfo["toppings_tray"],
				groups = "pizzathis",
				stash = "Toppings"
			}
		}
	})

	Targets["PizzBase"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1337.087, -1059.077, 7.3797767),
		size = vec3(0.4, 0.4, 1.6),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_base',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-pizza-slice",
				label = Loc[Config.Lan].targetinfo["prepare_pizza"],
				groups = "pizzathis",
				craftable = Crafting.Base,
				header = Loc[Config.Lan].menu["pizza_base"],
				coords = vector3(-1337.087, -1059.077, 7.3797767)
			}
		}
	})

	Targets["PizzDough"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1339.897, -1062.728, 7.2976868),
		size = vec3(1.2, 3.2, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_dough',
				event = "ND_PizzaThis:JustGive",
				icon = "fas fa-cookie",
				label = Loc[Config.Lan].targetinfo["prepare_dough"],
				groups = "pizzathis",
				id = "pizzadough",
				coords = vector3(-1339.897, -1062.728, 7.2976868)
			}
		}
	})

	Targets["PizzOven"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1338.289, -1061.726, 7.35443),
		size = vec3(2.8, 0.7, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_oven',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-temperature-high",
				label = Loc[Config.Lan].targetinfo["use_oven"],
				groups = "pizzathis",
				craftable = Crafting.Oven,
				header = Loc[Config.Lan].menu["oven_menu"],
				coords = vector3(-1338.289, -1061.726, 7.35443)
			}
		}
	})

	Targets["PizzChop"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1337.024, -1060.984, 7.4907014),
		size = vec3(0.6, 0.6, 2.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_chop',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-utensils",
				label = Loc[Config.Lan].targetinfo["chopping_board"],
				groups = "pizzathis",
				craftable = Crafting.ChoppingBoard,
				header = Loc[Config.Lan].menu["chopping_board"],
				coords = vector3(-1337.024, -1060.984, 7.4907014)
			}
		}
	})

	Targets["PizzChop2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(809.26, -761.19, 26.78),
		size = vec3(0.55, 0.4, 1.2),
		rotation = 10.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_chop2',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-utensils",
				label = Loc[Config.Lan].targetinfo["chopping_board"],
				groups = "pizzathis",
				craftable = Crafting.ChoppingBoard,
				header = Loc[Config.Lan].menu["chopping_board"],
				coords = vector3(809.26, -761.19, 26.78)
			}
		}
	})

	Targets["PizzBurner"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1341.339, -1060.205, 7.9560703),
		size = vec3(2.4, 1.2, 3.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_burner',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-temperature-high",
				label = Loc[Config.Lan].targetinfo["stone_oven"],
				groups = "pizzathis",
				craftable = Crafting.PizzaOven,
				header = Loc[Config.Lan].menu["stone_pizza"],
				coords = vector3(-1341.339, -1060.205, 7.9560703)
			}
		}
	})

	Targets["PizzWine"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1347.544, -1065.422, 7.9928905),
		size = vec3(0.4, 1.7, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wine',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-archive",
				label = Loc[Config.Lan].targetinfo["wine_rack"],
				groups = "pizzathis",
				shop = Config.WineItems,
				coords = vector3(-1347.544, -1065.422, 7.9928905)
			}
		}
	})

	Targets["PizzWine2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(807.25, -761.79, 22.3),
		size = vec3(0.4, 1.7, 1.6),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wine2',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-archive",
				label = Loc[Config.Lan].targetinfo["wine_rack"],
				groups = "pizzathis",
				shop = Config.WineItems,
				coords = vector3(807.25, -761.79, 22.3)
			}
		}
	})

	Targets["PizzFridge"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1345.454, -1062.513, 7.0255303),
		size = vec3(0.6, 0.6, 1.85),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_fridge',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-archive",
				label = Loc[Config.Lan].targetinfo["drink_fridge"],
				groups = "pizzathis",
				shop = Config.DrinkItems,
				coords = vector3(-1345.454, -1062.513, 7.0255303)
			}
		}
	})

	Targets["PizzFridge2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(814.07, -748.64, 26.78),
		size = vec3(0.6, 0.6, 0.85),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_fridge2',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-archive",
				label = Loc[Config.Lan].targetinfo["drink_fridge"],
				groups = "pizzathis",
				shop = Config.DrinkItems,
				coords = vector3(814.07, -748.64, 26.78)
			}
		}
	})

	Targets["PizzFridge3"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1347.576, -1063.36, 7.5435709),
		size = vec3(1.6, 0.6, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_fridge3',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-temperature-low",
				label = Loc[Config.Lan].targetinfo["food_fridge"],
				groups = "pizzathis",
				shop = Config.FoodItems,
				coords = vector3(805.68, -761.62, 26.78)
			}
		}
	})

	Targets["PizzFreezer"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1344.923, -1062.11, 6.9067578),
		size = vec3(0.6, 4.0, 1.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_freezer',
				event = "ND_PizzaThis:Shop",
				icon = "fas fa-temperature-low",
				label = Loc[Config.Lan].targetinfo["open_freezer"],
				groups = "pizzathis",
				shop = Config.FreezerItems,
				coords = vector3(802.75, -756.85, 26.78)
			}
		}
	})

	Targets["PizzWash1"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1338.485, -1058.086, 7.1495629),
		size = vec3(0.6, 0.8, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash1',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(-1338.485, -1058.086, 7.3495629)
			}
		}
	})

	Targets["PizzWash2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1342.328, -1061.009, 7.3740572),
		size = vec3(0.8, 0.6, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash2',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(-1342.328, -1061.009, 7.1740572)
			}
		}
	})

	Targets["PizzWash3"] =
	exports.ox_target:addBoxZone({
		coords = vector3(813.35, -755.46, 26.78),
		size = vec3(0.4, 0.8, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash3',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(813.35, -755.46, 26.78)
			}
		}
	})

	Targets["PizzWash4"] =
	exports.ox_target:addBoxZone({
		coords = vector3(800.88, -767.88, 26.78),
		size = vec3(0.8, 0.6, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash4',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				groups = "pizzathis",
				coords = vector3(800.88, -767.88, 26.78)
			}
		}
	})

	Targets["PizzWash5"] =
	exports.ox_target:addBoxZone({
		coords = vector3(800.85, -767.07, 26.78),
		size = vec3(0.8, 0.6, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash5',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(800.85, -767.07, 26.78)
			}
		}
	})

	Targets["PizzWash6"] =
	exports.ox_target:addBoxZone({
		coords = vector3(800.85, -761.18, 26.78),
		size = vec3(0.8, 0.6, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash6',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(800.85, -761.18, 26.78)
			}
		}
	})

	Targets["PizzWash7"] =
	exports.ox_target:addBoxZone({
		coords = vector3(800.89, -762.04, 26.78),
		size = vec3(0.8, 0.6, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash7',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(800.89, -762.04, 26.78)
			}
		}
	})

	Targets["PizzWash8"] =
	exports.ox_target:addBoxZone({
		coords = vector3(809.9, -765.32, 31.27),
		size = vec3(0.6, 0.6, 1.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash8',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(809.9, -765.32, 31.27)
			}
		}
	})

	Targets["PizzWash9"] =
	exports.ox_target:addBoxZone({
		coords = vector3(808.91, -765.34, 31.27),
		size = vec3(0.6, 0.6, 1.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_wash9',
				event = "ND_PizzaThis:washHands",
				icon = "fas fa-hand-holding-water",
				label = Loc[Config.Lan].targetinfo["wash_hands"],
				coords = vector3(808.91, -765.34, 31.27)
			}
		}
	})

	Targets["PizzCounter"] =
	exports.ox_target:addBoxZone({
		coords = vector3(810.98, -752.9, 26.78),
		size = vec3(0.6, 0.6, 0.8),
		rotation = 9.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_counter',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_counter"],
				stash = "CounterRight",
				coords = vector3(810.98, -752.9, 26.78)
			}
		}
	})

	Targets["PizzCounter2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(810.93, -749.92, 26.78),
		size = vec3(0.7, 0.7, 0.8),
		rotation = 30.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_counter2',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_counter"],
				stash = "CounterLeft",
				coords = vector3(810.93, -749.92, 26.78)
			}
		}
	})

	Targets["PizzReceipt"] =
	exports.ox_target:addBoxZone({
		coords = vector3(811.32, -750.77, 26.78),
		size = vec3(0.7, 0.35, 0.4),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_receipt',
				event = "qb-payments:client:Charge",
				icon = "fas fa-credit-card",
				label = Loc[Config.Lan].targetinfo["charge_customer"],
				groups = "pizzathis",
				coords = vector3(811.32, -750.77, 26.78),
				img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/5/59/PizzaThis.png width=200px></p>"
			}
		}
	})

	Targets["PizzReceipt2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(811.29, -752.09, 26.78),
		size = vec3(0.7, 0.35, 0.4),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_receipt2',
				event = "qb-payments:client:Charge",
				icon = "fas fa-credit-card",
				label = Loc[Config.Lan].targetinfo["charge_customer"],
				groups = "pizzathis",
				coords = vector3(811.29, -752.09, 26.78),
				img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/5/59/PizzaThis.png width=200px></p>"
			}
		}
	})

	Targets["PizzTap"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1343.482, -1060.852, 7.5970356),
		size = vec3(0.9, 0.6, 1.7),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_tap',
				event = "ND_PizzaThis:Crafting",
				icon = "fas fa-beer",
				label = Loc[Config.Lan].targetinfo["pour_beer"],
				groups = "pizzathis",
				craftable = Crafting.Beer,
				header = Loc[Config.Lan].menu["beer_menu"],
				coords = vector3(-1343.482, -1060.852, 7.5970356)
			}
		}
	})

	Targets["PizzCoffee"] =
	exports.ox_target:addBoxZone({
		coords = vector3(-1346.096, -1062.769, 7.7535719),
		size = vec3(0.6, 0.6, 2.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_coffee',
				event = "ND_PizzaThis:JustGive",
				icon = "fas fa-mug-hot",
				label = Loc[Config.Lan].targetinfo["pour_coffee"],
				groups = "pizzathis",
				id = "coffee",
				coords = vector3(-1346.096, -1062.769, 7.7535719)
			}
		}
	})

	Targets["PizzCoffee2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(811.49, -764.82, 26.78),
		size = vec3(1.6, 0.63, 1.0),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_coffee2',
				event = "ND_PizzaThis:JustGive",
				icon = "fas fa-mug-hot",
				label = Loc[Config.Lan].targetinfo["pour_coffee"],
				groups = "pizzathis",
				id = "coffee",
				coords = vector3(811.49, -764.82, 26.78)
			}
		}
	})

	Targets["PizzClockin"] =
	exports.ox_target:addBoxZone({
		coords = vector3(807.15, -761.83, 31.27),
		size = vec3(1.2, 0.2, 1.25),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_clockin',
				event = "ND_PizzaThis:duty",
				icon = "fas fa-user-check",
				label = Loc[Config.Lan].targetinfo["toggle_duty"],
				groups = "pizzathis",
			}
		}
	})

	Targets["PizzClockin2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(804.44, -760.52, 31.27),
		size = vec3(0.4, 0.4, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_clockin2',
				event = "ND_PizzaThis:duty",
				icon = "fas fa-user-check",
				label = Loc[Config.Lan].targetinfo["toggle_duty"],
				groups = "pizzathis",
			}
		}
	})

	Targets["PizzBoss"] =
	exports.ox_target:addBoxZone({
		coords = vector3(797.46, -751.52, 31.27),
		size = vec3(1.5, 1.0, 1.0),
		rotation = 90.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_boss',
				event = "qb-bossmenu:client:OpenMenu",
				icon = "fas fa-list",
				label = Loc[Config.Lan].targetinfo["open_bossmenu"],
				groups = bossroles,
				coords = vector3(797.46, -751.52, 31.27)
			}
		}
	})

	Targets["PizzBoss2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(794.91, -767.06, 31.27),
		size = vec3(0.6, 0.6, 1.0),
		rotation = 90.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_boss2',
				event = "qb-bossmenu:client:OpenMenu",
				icon = "fas fa-list",
				label = Loc[Config.Lan].targetinfo["open_bossmenu"],
				groups = bossroles,
				coords = vector3(794.91, -767.06, 31.27)
			}
		}
	})

	Targets["PizzTable"] =
	exports.ox_target:addBoxZone({
		coords = vector3(807.08, -751.57, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table1"
			}
		}
	})

	Targets["PizzTable2"] =
	exports.ox_target:addBoxZone({
		coords = vector3(803.13, -751.59, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table2',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table2"
			}
		}
	})

	Targets["PizzTable3"] =
	exports.ox_target:addBoxZone({
		coords = vector3(799.13, -751.57, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table3',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table3"
			}
		}
	})

	Targets["PizzTable4"] =
	exports.ox_target:addBoxZone({
		coords = vector3(797.96, -748.86, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table4',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table4"
			}
		}
	})

	Targets["PizzTable5"] =
	exports.ox_target:addBoxZone({
		coords = vector3(795.25, -751.55, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table5',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table5"
			}
		}
	})

	Targets["PizzTable6"] =
	exports.ox_target:addBoxZone({
		coords = vector3(799.46, -755.04, 26.78),
		size = vec3(1.0, 1.0, 1.2),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table6',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table6"
			}
		}
	})

	Targets["PizzTable7"] =
	exports.ox_target:addBoxZone({
		coords = vector3(807.71, -754.9, 26.78),
		size = vec3(2.0, 0.8, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table7',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table7"
			}
		}
	})

	Targets["PizzTable8"] =
	exports.ox_target:addBoxZone({
		coords = vector3(805.61, -754.89, 26.78),
		size = vec3(2.0, 0.8, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table8',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table8"
			}
		}
	})

	Targets["PizzTable9"] =
	exports.ox_target:addBoxZone({
		coords = vector3(803.51, -754.9, 26.78),
		size = vec3(2.0, 0.8, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table9',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table9"
			}
		}
	})

	Targets["PizzTable10"] =
	exports.ox_target:addBoxZone({
		coords = vector3(801.42, -754.93, 26.78),
		size = vec3(2.0, 0.8, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table10',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table10"
			}
		}
	})

	Targets["PizzTable11"] =
	exports.ox_target:addBoxZone({
		coords = vector3(799.32, -757.63, 26.78),
		size = vec3(0.8, 1.4, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table11',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table11"
			}
		}
	})

	Targets["PizzTable12"] =
	exports.ox_target:addBoxZone({
		coords = vector3(799.32, -759.72, 26.78),
		size = vec3(0.8, 1.4, 0.8),
		rotation = 0.0,
		debug = Config.Debug,
		options = {
			{
				name = 'pizzathis_table12',
				event = "ND_PizzaThis:Stash",
				icon = "fas fa-hamburger",
				label = Loc[Config.Lan].targetinfo["open_table"],
				stash = "Table12"
			}
		}
	})

	-- Quick Prop Changes
	if not Props["box1"] then Props["box1"] = makeProp({prop = `prop_pizza_box_01`, coords = vector4(810.94, -749.94, 28.06, -150.0)}, 1, false) end
	if not Props["box2"] then Props["box2"] = makeProp({prop = `prop_pizza_box_02`, coords = vector4(810.98, -752.89, 28.06, -80.0)}, 1, false) end
	if not Props["clockin"] then Props["clockin"] = makeProp({prop = `v_ind_tor_clockincard`, coords = vector4(807.07, -761.83, 32.27, -270.0)}, 1, false) end
end)

RegisterNetEvent('ND_PizzaThis:washHands', function(data)
	lookEnt(data.coords)
	if lib.progressCircle({
		duration = 5000,
		label = Loc[Config.Lan].progressbar["washing_hands"],
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			combat = false,
		},
		anim = {
			dict = "mp_arresting",
			clip = "a_uncuff",
			flag = 8
		}
	}) then
		lib.notify({title = "Success", description = Loc[Config.Lan].success["washed_hands"], type = 'success'})
	else
		TriggerEvent('inventory:client:busy:status', false)
		lib.notify({title = "Error", description = Loc[Config.Lan].error["cancelled"], type = 'error'})
	end
end)

RegisterNetEvent('ND_PizzaThis:Shop', function(data)
	if not jobCheck() then return end
	lookEnt(data.coords)
	local event = "inventory:server:OpenInventory"
	if Config.QBShop then event = "qb-shops:ShopOpen" end
	TriggerServerEvent(event, "shop", "pizzathis", data.shop)
end)

RegisterNetEvent('ND_PizzaThis:Stash', function(data)
	lookEnt(data.coords)
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "pizza_"..data.stash)
	TriggerEvent("inventory:client:SetCurrentStash", "pizza_"..data.stash)
end)

function FoodProgress(ItemMake, itemData)
	if ItemMake == "pizzadough" then
		bartext = Loc[Config.Lan].progress["grabbing"]..(itemData and itemData.label or ItemMake)
		bartime = 7000
		animDictNow = "anim@heists@prison_heiststation@cop_reactions"
		animNow = "cop_b_idle"
	elseif ItemMake == "coffee" then
		bartext = Loc[Config.Lan].progress["pouring"]..(itemData and itemData.label or ItemMake)
		bartime = 3000
		animDictNow = "mp_ped_interaction"
		animNow = "handshake_guy_a"
	end

	if lib.progressCircle({
		duration = bartime,
		label = bartext,
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			combat = true,
		},
		anim = {
			dict = animDictNow,
			clip = animNow,
			flag = 8
		}
	}) then
		TriggerServerEvent('ND_PizzaThis:Crafting:GetItem', ItemMake)
		StopAnimTask(PlayerPedId(), animDictNow, animNow, 1.0)
	else
		TriggerEvent('inventory:client:busy:status', false)
		lib.notify({title = "Error", description = Loc[Config.Lan].error["cancelled"], type = 'error'})
	end
end

RegisterNetEvent('ND_PizzaThis:JustGive', function(data)
	if not jobCheck() then return end
	lookEnt(data.coords)
	-- Get item data from server
	local itemData = lib.callback.await('ND_PizzaThis:GetItemData', false, data.id)
	FoodProgress(data.id, itemData)
end)

RegisterNetEvent('ND_PizzaThis:Crafting:MakeItem', function(data)
	local bartext = ""
	bartime = 7000
	animDictNow = "anim@heists@prison_heiststation@cop_reactions"
	animNow = "cop_b_idle"
	for i = 1, #Crafting.ChoppingBoard do
		for k, v in pairs(Crafting.ChoppingBoard[i]) do
			if data.item == k then
				bartext = Loc[Config.Lan].progress["mixing"]
				bartime = 7000
				animDictNow = "anim@heists@prison_heiststation@cop_reactions"
				animNow = "cop_b_idle"
			end
		end
	end
	for i = 1, #Crafting.Oven do
		for k, v in pairs(Crafting.Oven[i]) do
			if data.item == k then
				bartext = Loc[Config.Lan].progress["cooking"]
				bartime = 5000
				animDictNow = "amb@prop_human_bbq@male@base"
				animNow = "base"
			end
		end
	end
	for i = 1, #Crafting.PizzaOven do
		for k, v in pairs(Crafting.PizzaOven[i]) do
			if data.item == k then
				bartext = Loc[Config.Lan].progress["cooking"]
				bartime = 5000
				animDictNow = "amb@prop_human_bbq@male@base"
				animNow = "base"
			end
		end
	end
	for i = 1, #Crafting.Beer do
		for k, v in pairs(Crafting.Beer[i]) do
			if data.item == k then
				bartext = Loc[Config.Lan].progress["pouring"]
				bartime = 3000
				animDictNow = "mp_ped_interaction"
				animNow = "handshake_guy_a"
			end
		end
	end

	-- Get item data from server
	local itemData = lib.callback.await('ND_PizzaThis:GetItemData', false, data.item)
	local itemLabel = itemData and itemData.label or data.item

	if lib.progressCircle({
		duration = bartime,
		label = bartext..itemLabel,
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = false,
			combat = false,
		},
		anim = {
			dict = animDictNow,
			clip = animNow,
			flag = 8
		}
	}) then
		TriggerServerEvent('ND_PizzaThis:Crafting:GetItem', data.item, data.craft)
		Wait(500)
		TriggerEvent("ND_PizzaThis:Crafting", data)
	else
		TriggerEvent('inventory:client:busy:status', false)
	end
end)

RegisterNetEvent('ND_PizzaThis:Crafting', function(data)
	if not jobCheck() then return end

	-- Get all item data from server in one call
	local itemsData = lib.callback.await('ND_PizzaThis:GetItemsData', false)

	local contextMenu = {
		id = 'pizzathis_crafting',
		title = data.header,
		options = {}
	}

	for i = 1, #data.craftable do
		for k, v in pairs(data.craftable[i]) do
			if k ~= "amount" then
				local itemData = itemsData[k]
				local itemLabel = itemData and itemData.label or k
				local itemImage = itemData and itemData.image or k

				local title = itemLabel
				if data.craftable[i]["amount"] ~= nil then
					title = title.." x"..data.craftable[i]["amount"]
				end

				local description = ""
				local disable = false
				local checktable = {}

				for l, b in pairs(data.craftable[i][tostring(k)]) do
					local ingData = itemsData[l]
					local ingLabel = ingData and ingData.label or l
					if b == 1 then number = "" else number = " x"..b end
					description = description.."- "..ingLabel..number.."\n"
					checktable[l] = HasItem(l, b)
				end

				for _, v in pairs(checktable) do
					if v == false then
						disable = true
						break
					end
				end

				if not disable then title = title.." ✔️" end

				table.insert(contextMenu.options, {
					title = title,
					description = description,
					icon = "fas fa-"..k,
					disabled = disable,
					event = "ND_PizzaThis:Crafting:MakeItem",
					args = {
						item = k,
						craft = data.craftable[i],
						craftable = data.craftable,
						header = data.header
					}
				})
			end
		end
	end

	lib.registerContext(contextMenu)
	lib.showContext('pizzathis_crafting')
	lookEnt(data.coords)
end)

RegisterNetEvent('ND_PizzaThis:client:DrinkAlcohol', function(itemName)
	if itemName == "ambeer" then TriggerEvent('animations:client:EmoteCommandStart', {"beer3"})
	elseif itemName == "dusche" then TriggerEvent('animations:client:EmoteCommandStart', {"beer1"})
	elseif itemName == "logger" then TriggerEvent('animations:client:EmoteCommandStart', {"beer2"})
	elseif itemName == "pisswasser" then TriggerEvent('animations:client:EmoteCommandStart', {"beer4"})
	elseif itemName == "pisswasser2" then TriggerEvent('animations:client:EmoteCommandStart', {"beer5"})
	elseif itemName == "pisswasser3" then TriggerEvent('animations:client:EmoteCommandStart', {"beer6"})
	elseif itemName == "amarone" or itemName == "barbera" or itemName == "housered" or itemName == "rosso" then	TriggerEvent('animations:client:EmoteCommandStart', {"redwine"})
	elseif itemName == "dolceto" or itemName == "housewhite" then TriggerEvent('animations:client:EmoteCommandStart', {"whitewine"})
	else TriggerEvent('animations:client:EmoteCommandStart', {"flute"}) end

	local itemData = lib.callback.await('ND_PizzaThis:GetItemData', false, itemName)
	local itemLabel = itemData and itemData.label or itemName

	if lib.progressCircle({
		duration = math.random(3000, 6000),
		label = Loc[Config.Lan].progressbar["drinking"]..itemLabel.."..",
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = false,
			car = false,
			combat = true,
		}
	}) then
		TriggerEvent('animations:client:EmoteCommandStart', {"c"})
		toggleItem(false, itemName, 1)
		if itemData and itemData.thirst then TriggerServerEvent("consumables:server:addThirst", itemData.thirst) end
		if itemData and itemData.hunger then TriggerServerEvent("consumables:server:addHunger", itemData.hunger) end
		alcoholCount = alcoholCount + 1
		if alcoholCount > 1 and alcoholCount < 4 then TriggerEvent("evidence:client:SetStatus", "alcohol", 200)
		elseif alcoholCount >= 4 then TriggerEvent("evidence:client:SetStatus", "heavyalcohol", 200)
			AlienEffect()
		end
		if Config.RewardItem == itemName then toggleItem(true, Config.RewardPool[math.random(1, #Config.RewardPool)], 1)end
	else
		TriggerEvent('animations:client:EmoteCommandStart', {"c"})
		lib.notify({title = "Error", description = Loc[Config.Lan].error["cancelled"], type = "error"})
	end
end)

function AlienEffect()
	StartScreenEffect("DrugsMichaelAliensFightIn", 3.0, 0)
	Wait(math.random(5000, 8000))
	local ped = PlayerPedId()
	RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
	while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do Citizen.Wait(0) end
	SetPedCanRagdoll(ped, true )
	ShakeGameplayCam('DRUNK_SHAKE', 2.80)
	SetTimecycleModifier("Drunk")
	SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", true)
	SetPedMotionBlur(ped, true)
	SetPedIsDrunk(ped, true)
	Wait(1500)
	SetPedToRagdoll(ped, 5000, 1000, 1, false, false, false )
	Wait(13500)
	SetPedToRagdoll(ped, 5000, 1000, 1, false, false, false )
	Wait(120500)
	ClearTimecycleModifier()
	ResetScenarioTypesEnabled()
	ResetPedMovementClipset(ped, 0)
	SetPedIsDrunk(ped, false)
	SetPedMotionBlur(ped, false)
	AnimpostfxStopAll()
	ShakeGameplayCam('DRUNK_SHAKE', 0.0)
	StartScreenEffect("DrugsMichaelAliensFight", 3.0, 0)
	Wait(math.random(45000, 60000))
	StartScreenEffect("DrugsMichaelAliensFightOut", 3.0, 0)
	StopScreenEffect("DrugsMichaelAliensFightIn")
	StopScreenEffect("DrugsMichaelAliensFight")
	StopScreenEffect("DrugsMichaelAliensFightOut")
end

RegisterNetEvent('ND_PizzaThis:client:Drink', function(itemName)
	if itemName == "sprunk" or itemName == "sprunklight" then TriggerEvent('animations:client:EmoteCommandStart', {"sprunk"})
	elseif itemName == "ecola" or itemName == "ecolalight" then TriggerEvent('animations:client:EmoteCommandStart', {"ecola"}) end

	local itemData = lib.callback.await('ND_PizzaThis:GetItemData', false, itemName)
	local itemLabel = itemData and itemData.label or itemName

	if lib.progressCircle({
		duration = 5000,
		label = Loc[Config.Lan].progressbar["drinking"]..itemLabel.."..",
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = false,
			car = false,
			combat = true,
		}
	}) then
		toggleItem(false, itemName, 1)
		TriggerEvent('animations:client:EmoteCommandStart', {"c"})
		if itemData and itemData.thirst then TriggerServerEvent("consumables:server:addThirst", itemData.thirst) end
		if itemData and itemData.hunger then TriggerServerEvent("consumables:server:addHunger", itemData.hunger) end
		if Config.RewardItem == itemName then toggleItem(true, Config.RewardPool[math.random(1, #Config.RewardPool)], 1) end
	else
		TriggerEvent('animations:client:EmoteCommandStart', {"c"})
	end
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	for _, v in pairs(Props) do	DeleteEntity(v) end
	for k, v in pairs(Targets) do exports.ox_target:removeZone(k) end
end)
