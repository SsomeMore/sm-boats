Config = {}
-- Set Language
Config.defaultlang = "en_lang"
-- Open Boat Shop Menu
Config.shopKey = 0xCEFD9220 --[E]
-- Open Boat Options Menu
Config.optionKey = 0xF1301666 --[O] opens menu for anchor and remote return while in boat
-- Return Boat to Shop at Prompt
Config.returnKey = 0xD9D0E1C0 --[spacebar]
-- Allow to Transfer Boats
Config.transferAllow = true -- If true, Boats Can Be Transferred To Different Shops
-- Block NPC Boat Spawns
Config.blockNpcBoats = true -- If true, will block the spawning of NPC boats
-- Boat Shops
Config.boatShops = {
    lagras = {
        shopName = "Lagras Boats", -- Name of Shop in Menu Header
        location = "lagras", -- DON'T CHANGE / Used for Location in Database
        promptName = "Lagras Boats", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blips On / Off
        blipName = "Lagras Boats", -- Name of the Blip on the Map
        blipSprite = -1018164873, -- 2005921736 = Canoe / -1018164873 = Tugboat
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Shop Open - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Shop Closed - Blip Colors Shown Below
        npcx = 2123.95, npcy = -551.63, npcz = 41.53, npch = 113.62, -- Blip and NPC Positions
        boatx = 2122.8, boaty = -544.76, boatz = 40.55, boath = 46.69, -- Boat Spawn and Return Positions
        playerx = 2121.31, playery = -552.65, playerz = 42.7, playerh = 316.34, -- Player Return Teleport Position
        -- Preview Location (Added for boat preview system)
        previewx = 2125.0, previewy = -540.0, previewz = 40.55, previewh = 46.69, -- Preview Spawn Position
        distanceShop = 2.0, -- Distance from NPC to Get Menu Prompt
        distanceReturn = 6.0, -- Distance from Shop to Get Return Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "A_M_M_UniBoatCrew_01", -- Sets Model for NPCs
        shopHours = false, -- If You Want the Shops to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
        boats = { -- Change ONLY These Values: boatName, buyPrice, sellPrice and transferPrice
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15 },
            canoe          = { boatName = "Canoe",          boatModel = "canoe",          buyPrice = 40,   sellPrice = 25,  transferPrice = 15 },
            pirogue        = { boatName = "Pirogue Canoe",  boatModel = "pirogue",        buyPrice = 5000,   sellPrice = 3000,  transferPrice = 15 },
            pirogue2       = { boatName = "Pirogue2 Canoe", boatModel = "pirogue2",       buyPrice = 5000,   sellPrice = 3000,  transferPrice = 15 },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6000,   sellPrice = 2000,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },
    saintdenis = {
        shopName = "Saint Denis Boats",
        location = "saintdenis", -- DON'T CHANGE
        promptName = "Saint Denis Boats",
        blipAllowed = true,
        blipName = "Saint Denis Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = 2949.77, npcy = -1250.18, npcz = 41.411, npch = 95.39,
        boatx = 2947.50, boaty = -1257.21, boatz = 41.58, boath = 274.14,
        playerx = 2946.99, playery = -1250.47, playerz = 42.41, playerh = 270.52,
        -- Preview Location
        previewx = 2950.0, previewy = -1260.0, previewz = 41.58, previewh = 274.14,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },
    annesburg = {
        shopName = "Annesburg Boats",
        location = "annesburg", -- DON'T CHANGE
        promptName = "Annesburg Boats",
        blipAllowed = true,
        blipName = "Annesburg Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = 3033.23, npcy = 1369.64, npcz = 41.62, npch = 67.42,
        boatx = 3036.05, boaty = 1374.40, boatz = 40.27, boath = 251.0,
        playerx = 3030.44, playery = 1370.84, playerz = 42.63, playerh = 244.6,
        -- Preview Location
        previewx = 3040.0, previewy = 1378.0, previewz = 40.27, previewh = 251.0,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },
    blackwater = {
        shopName = "Blackwater Boats",
        location = "blackwater", -- DON'T CHANGE
        promptName = "Blackwater Boats",
        blipAllowed = true,
        blipName = "Blackwater Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = -682.36, npcy = -1242.97, npcz = 42.11, npch = 88.90,
        boatx = -682.22, boaty = -1252.50, boatz = 40.27, boath = 277.0,
        playerx = -685.16, playery = -1242.98, playerz = 43.11, playerh = 266.15,
        -- Preview Location
        previewx = -680.0, previewy = -1255.0, previewz = 40.27, previewh = 277.0,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },
    wapiti = {
        shopName = "Wapiti Boats",
        location = "wapiti", -- DON'T CHANGE
        promptName = "Wapiti Boats",
        blipAllowed = true,
        blipName = "Wapiti Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = 614.46, npcy = 2209.5, npcz = 222.01, npch = 194.08,
        boatx = 635.8, boaty = 2212.13, boatz = 220.78, boath = 212.13,
        playerx = 614.14, playery = 2207.46, playerz = 223.06, playerh = 344.27,
        -- Preview Location
        previewx = 640.0, previewy = 2215.0, previewz = 220.78, previewh = 212.13,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },
    manteca = {
        shopName = "Manteca Falls Boats",
        location = "manteca", -- DON'T CHANGE
        promptName = "Manteca Falls Boats",
        blipAllowed = true,
        blipName = "Manteca Falls Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = -2017.76, npcy = -3048.91, npcz = -12.21, npch = 21.23,
        boatx = -2025.37, boaty = -3048.24, boatz = -12.69, boath = 197.53,
        playerx = -2018.88, playery = -3046.35, playerz = -11.21, playerh = 201.5,
        -- Preview Location
        previewx = -2030.0, previewy = -3050.0, previewz = -12.69, previewh = 197.53,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },

    rhodes = {
        shopName = "Rhodes Boats",
        location = "rhodes", -- DON'T CHANGE
        promptName = "Rhodes Boats",
        blipAllowed = true,
        blipName = "Rhodes Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = 884.84252, npcy = -1781.401, npcz = 41.0, npch = 312.20,
        boatx = 881.88031, boaty = -1776.697, boatz = 40.228984, boath = 137.40,
        playerx = 887.35107, playery = -1778.023, playerz = 42.136745, playerh = 304.14208,
        -- Preview Location
        previewx = 885.0, previewy = -1772.0, previewz = 40.228984, previewh = 137.40,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = true,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            canoetreetrunk = { boatName = "Dugout Canoe",   boatModel = "canoetreetrunk", buyPrice = 45,   sellPrice = 15,  transferPrice = 15  },
            rowboat        = { boatName = "Rowboat",        boatModel = "rowboat",        buyPrice = 4500,   sellPrice = 1500,  transferPrice = 15 },
            rowboatSwamp   = { boatName = "Swamp Rowboat",  boatModel = "rowboatSwamp",   buyPrice = 6500,   sellPrice = 4500,  transferPrice = 15 },
            keelboat       = { boatName = "Keelboat",       boatModel = "keelboat",       buyPrice = 14000,  sellPrice = 12050, transferPrice = 15 },
            boatsteam02x   = { boatName = "Steamboat",      boatModel = "boatsteam02x",   buyPrice = 19000, sellPrice = 13500, transferPrice = 15 },
        },
    },

    quakercove = {
        shopName = "Personal Boat Garage",
        location = "quaker cove", -- DON'T CHANGE
        promptName = "Personal Boat Garage",
        blipAllowed = false,
        blipName = "Quaker Cove Boats",
        blipSprite = -1018164873,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        npcx = -1178.092, npcy = -1975.752, npcz = 42.339, npch = 341.043,
        boatx = -1171.566, boaty = -1975.499, boatz = 42.409, boath = 155.000,
        playerx = 1177.776, playery = -1975.106, playerz = 42.342, playerh = 154.231,
        -- Preview Location
        previewx = -1175.0, previewy = -1978.0, previewz = 42.409, previewh = 155.000,
        distanceShop = 2.0,
        distanceReturn = 6.0,
        npcAllowed = false,
        npcModel = "A_M_M_UniBoatCrew_01",
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        boats = {
            -- This is a personal garage, only stored boats can be here, none can be buyable here.
        },
    },
}

--[[--------BLIP_COLORS----------
LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
RED           = 'BLIP_MODIFIER_MP_COLOR_10',
LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
WHITE         = 'BLIP_MODIFIER_MP_COLOR_32']]
