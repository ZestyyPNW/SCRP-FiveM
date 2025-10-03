Config = {
	Debug = false,
	Lan = "en", -- Pick your language here
	img = "ox_inventory/web/images/", -- ox_inventory image path

	QBConsumables = false, -- Enable this to disable this scripts control of food/drink items
	CheckMarks = true, -- If true this will show the player if they have the correct items to be able to craft the items

	--Simple Toy Reward Support
	RewardItem = "", --Set this to the name of an item eg "tiramisu"
	RewardPool = { -- Set this to the list of items to be given out as random prizes when the item is used
		"",
		"",
		"",
	},
	Locations = {
		{	zoneEnable = true,
			job = "pizzathis", -- Set this to the required job
			label = "Pizza This", -- Set this to the required job
			zones = {
				vector2(-1355.06, -1107.9),
				vector2(-1387.62, -1051.43),
				vector2(-1350.49, -1031.86),
				vector2(-1323.12, -1084.74)
			},
			blip = vector3(-1340.4, -1080.48, 6.94),
			blipcolor = 43,
			garage = { spawn = vector4(-1336.33, -1099.36, 6.02, 122.84),
			out = vector4(-1338.104, -1094.651, 6.9554667, 209.72561),
			list = { "faggio", } },
		},
	},
	DrinkItems = {
		label = "Drinks Store",
		slots = 5,
		items = {
			{ name = "vodka", price = 0, amount = 50, info = {}, type = "item", slot = 1, },
			{ name = "sprunk", price = 0, amount = 50, info = {}, type = "item", slot = 2, },
			{ name = "sprunklight", price = 0, amount = 50, info = {}, type = "item", slot = 3, },
			{ name = "ecola", price = 0, amount = 50, info = {}, type = "item", slot = 4, },
			{ name = "ecolalight", price = 0, amount = 50, info = {}, type = "item", slot = 5, },
		}
	},
	WineItems = {
		label = "Wine Store",
		slots = 6,
		items = {
			{ name = "amarone", price = 0, amount = 50, info = {}, type = "item", slot = 1, },
			{ name = "barbera", price = 0, amount = 50, info = {}, type = "item", slot = 2, },
			{ name = "dolceto", price = 0, amount = 50, info = {}, type = "item", slot = 3, },
			{ name = "housered", price = 0, amount = 50, info = {}, type = "item", slot = 4, },
			{ name = "housewhite", price = 0, amount = 50, info = {}, type = "item", slot = 5, },
			{ name = "rosso", price = 0, amount = 50, info = {}, type = "item", slot = 6, },
		}
	},

	FoodItems = {
		label = "Food Fridge Store",
		slots = 10,
		items = {
			{ name = "sauce", price = 0, amount = 50, info = {}, type = "item", slot = 1, },
			{ name = "pasta", price = 0, amount = 50, info = {}, type = "item", slot = 2, },
			{ name = "olives", price = 0, amount = 50, info = {}, type = "item", slot = 3, },
			{ name = "basil", price = 0, amount = 50, info = {}, type = "item", slot = 4, },
			{ name = "mozz", price = 0, amount = 50, info = {}, type = "item", slot = 5, },
			{ name = "lettuce", price = 0, amount = 50, info = {}, type = "item", slot = 6, },
			{ name = "pizzmushrooms", price = 0, amount = 50, info = {}, type = "item", slot = 7, },
			{ name = "tiramisu", price = 0, amount = 50, info = {}, type = "item", slot = 8, },
			{ name = "gelato", price = 0, amount = 50, info = {}, type = "item", slot = 9, },
			{ name = "medfruits", price = 0, amount = 50, info = {}, type = "item", slot = 10, },
		}
	},
	FreezerItems = {
		label = "Freezer Store",
		slots = 2,
		items = {
			{ name = "meat", price = 0, amount = 50, info = {}, type = "item", slot = 1, },
			{ name = "squid", price = 0, amount = 50, info = {}, type = "item", slot = 2, },
		}
	},
}
Crafting = {
	Beer = {
		{ ['ambeer'] = { } },
		{ ['dusche'] = { } },
		{ ['logger'] = { } },
		{ ['pisswasser'] = { } },
		{ ['pisswasser2'] = { } },
		{ ['pisswasser3'] = { } },
	},
	Base = {
		{ ['pizzabase'] = { ['pizzadough'] = 1, ['sauce'] = 1, } },
	},
	Oven = {
		{ ['bolognese'] = { ['meat'] = 1, ['sauce'] = 1, } },
		{ ['calamari'] = { ['squid'] = 1, ['sauce'] = 1, } },
		{ ['meatball'] = { ['meat'] = 1, ['pasta'] = 1, } },
		{ ['alla'] = { ['ham'] = 1, ['pasta'] = 1, ['vodka'] = 1, } },
		{ ['pescatore'] = { ['squid'] = 1, } },
	},
	PizzaOven = {
		{ ['margheritabox'] = { ['pizzabase'] = 1, ['mozz'] = 1, } },
		{ ['marinarabox'] = { ['pizzabase'] = 1, ['basil'] = 1, } },
		{ ['prosciuttiobox'] = { ['pizzabase'] = 1, ['mozz'] = 1, ['ham'] = 1, ['pizzmushrooms'] = 1, } },
		{ ['diavolabox'] = { ['pizzabase'] = 1, ['mozz'] = 1, ['salami'] = 1, ['basil'] = 1, } },
		{ ['capricciosabox'] = { ['pizzabase'] = 1, ['ham'] = 1, ['pizzmushrooms'] = 1, ['olives'] = 1, } },
		{ ['vegetarianabox'] = { ['pizzabase'] = 1, ['mozz'] = 1, ['lettuce'] = 1, ['basil'] = 1, } },
	},
	ChoppingBoard = {
		{ ['salami'] = { ['meat'] = 1, } },
		{ ['ham'] = { ['meat'] = 1, } },
	},
}

Loc = {}
