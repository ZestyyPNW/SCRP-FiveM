return {
    ["LAPD"] = {
        categories = {"LAPD"},
        blip = {
            coords = vec3(438.8677, -994.0984, 21.3361),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles Police Department Garage",
        },
        groups = {
            ["lapd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(438.8677, -994.0984, 21.3361, 266.8286),
            vehicleCoords = vec4(405.13, -957.99, -99.54, 156.02)
        },
        spawns = {
            vec4(446.7964, -996.1648, 21.3361, 87.9853),
            vec4(442.0436, -996.1314, 21.3360, 87.9416)
        },
    },
    ["LAPDAIR"] = {
        categories = {"LAPDAIR"},
        blip = {
            coords = vec3(-728.8256, -1505.9702, 5.0108),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles Police Department Air Fleet",
        },
        groups = {
            ["lapd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(-728.8256, -1505.9702, 5.0108, 157.5429),
            vehicleCoords = vec4(-738.3168, -1517.2559, 5.0105, 24.5590)
        },
        spawns = {
            vec4(-745.3015, -1468.4358, 5.0007, 316.2081)
        },
    },
    ["LAFDAIR"] = {
        categories = {"LAFDAIR"},
        blip = {
            coords = vec3(-728.8256, -1505.9702, 5.0108),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles Fire Department Air Fleet",
        },
        groups = {
            ["lafd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(-1177.7874, -2831.2041, 13.9468, 150.2189),
            vehicleCoords = vec4(-1166.1118, -2599.0828, 13.9449, 60.3212)
        },
        spawns = {
            vec4(-1178.2661, -2845.9155, 13.9458, 335.1462)
        },
    },
    ["LAPS"] = {
        categories = {"LAPS"},
        blip = {
            coords = vec3(438.8677, -994.0984, 21.3361),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "LAPS Garage",
        },
        groups = {
            ["laps"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(732.7925, -1361.7922, 26.6751, 88.9342),
            vehicleCoords = vec4(701.6467, -1372.7877, 26.1170, 280.6972)
        },
        spawns = {
            vec4(709.9599, -1350.0677, 25.5418, 263.9451)
        },
    },
    ["LASD"] = {
        categories = {"LASD"},
        blip = {
            coords = vec3(438.8677, -994.0984, 21.3361),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles County Sheriffs Department Garage",
        },
        groups = {
            ["lasd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(371.3282, -1612.8143, 29.2924, 320.5505),
            vehicleCoords = vec4(344.1184, -1630.5479, 23.7850, 229.7780)
        },
        spawns = {
            vec4(391.0440, -1610.4436, 29.2924, 226.8748),
            vec4(388.9496, -1612.8748, 29.2924, 229.0927)
        },
    },
    ["LASDSANDY"] = {
        categories = {"LASD"},
        blip = {
            coords = vec3(1750.3125, 3885.1963, 34.6674),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles County Sheriffs Department Garage",
        },
        groups = {
            ["lasd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(1750.3125, 3885.1963, 34.6674, 120.1663),
            vehicleCoords = vec4(1609.3810, 3822.5454, 34.7698, 259.1157)
        },
        spawns = {
            vec4(1746.4580, 3873.4333, 34.6466, 211.8579)
        },
    },
    ["CHP"] = {
        categories = {"CHP"},
        blip = {
            coords = vec3(438.8677, -994.0984, 21.3361),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "California Highway Patrol Garage",
        },
        groups = {
            ["chp"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(-3161.3643, 1129.5133, 21.0935, 196.9596),
            vehicleCoords = vec4(-3292.4807, 1053.9532, 2.9419, 300.5473)
        },
        spawns = {
            vec4(-3170.9973, 1126.6295, 20.9690, 338.2091),
            vec4(-3168.2793, 1131.8846, 21.0171, 332.3384)
        },
    },
    ["LAFDSANDY"] = {
        categories = {"LAFD"},
        blip = {
            coords = vec3(189.4939, 3179.3181, 42.4938),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles Fire Department",
        },
        groups = {
            ["lafd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(189.4939, 3179.3181, 42.4938, 274.5132),
            vehicleCoords = vec4(176.1926, 3165.1011, 42.4813, 42.5717)
        },
        spawns = {
            vec4(161.3572, 3191.9260, 42.2168, 327.2872)
        },
    },
    ["LAFD"] = {
        categories = {"LAFD"},
        blip = {
            coords = vec3(1210.3853, -1490.5226, 34.8422),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Los Angeles Fire Department Garage",
        },
        groups = {
            ["lafd"] = {
                switch = true,
                testdrive = true,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(1210.3853, -1490.5226, 34.8422, 178.5536),
            vehicleCoords = vec4(1217.9727, -1518.0122, 34.7044, 59.4432)
        },
        spawns = {
            vec4(1191.3093, -1539.8751, 39.4015, 5.0328),
            vec4(1186.4451, -1536.8600, 39.4015, 179.7037)
        },
    }
}
