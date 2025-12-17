-- Data.lua
WRS_Data = {}

-- Raid Aliases
-- Maps accepted keywords to a normalized Key
WRS_Data.Raids = {
    ["MC"] = "MC",
    ["MOLTEN CORE"] = "MC",
    ["BWL"] = "BWL",
    ["BLACKWING LAIR"] = "BWL",
    ["ZG"] = "ZG",
    ["ZUL'GURUB"] = "ZG",
    ["ZULGURUB"] = "ZG",
    ["AQ20"] = "AQ20",
    ["RAQ"] = "AQ20",
    ["RUINS OF AHN'QIRAJ"] = "AQ20",
    ["AQ40"] = "AQ40",
    ["TAQ"] = "AQ40",
    ["TEMPLE OF AHN'QIRAJ"] = "AQ40",
    ["NAXX"] = "NAXX",
    ["NAXXRAMAS"] = "NAXX",
    ["ONY"] = "ONY",
    ["ONYXIA"] = "ONY",
    ["KARA10"] = "KARA10",
    ["KARA 10"] = "KARA10",
    ["KARAZHAN"] = "KARA10", -- Default to 10 if unspecified? Or maybe separate check.
    ["KZ"] = "KARA10",
    ["KARA40"] = "KARA40",
    ["KARA 40"] = "KARA40",
    ["KARAZJAN40"] = "KARA40", -- From logs
    ["KARA"] = "KARA10",
    ["KARA10"] = "KARA10",
    ["ES"] = "ES", -- Emerald Sanctum (Custom)
    ["EMERALD SANCTUM"] = "ES",
    ["HM"] = "ES", -- "ES HM" found in logs (Heroic Mode?) - Context might be risky, but if "ES HM"
    ["HFQ"] = "HFQ", -- Hateforge Quarry
    ["HATEFORGE"] = "HFQ",
    ["HYJAL"] = "HYJAL", -- WTB SUMMON TO HYJAL (Not raid LFG, but location)
    -- Logs show: "Into the Dream VI" quest
    -- Logs show: "DM East"
    -- Logs show: "SM ARM"
    -- Logs show: "SCHOLO", "STRATHOLME", "KHARA"
    ["KHARA"] = "KARA10",
    ["NAXX"] = "NAXX",
    ["NAXXRAMAS"] = "NAXX",
}

-- Dungeon Aliases
WRS_Data.Dungeons = {
    ["UBRS"] = "UBRS",
    ["LBRS"] = "LBRS",
    ["BRD"] = "BRD",
    ["SCHOLO"] = "SCHOLO",
    ["SCHOOL"] = "SCHOLO",
    ["STRAT"] = "STRAT",
    ["STRATHOLME"] = "STRAT",
    ["LIVING"] = "STRAT",
    ["UNDEAD"] = "STRAT",
    ["DM"] = "DM", -- Dire Maul or Deadmines context usually DM N/E/W is Dire Maul
    ["DM EAST"] = "DM",
    ["DM WEST"] = "DM",
    ["DM NORTH"] = "DM",
    ["TRIBUTE"] = "DM",
    ["HFQ"] = "HFQ", -- Hateforge Quarry (Custom)
    ["HATEFORGE"] = "HFQ",
    ["SM"] = "SM",
    ["ARM"] = "SM", -- Scarlet Monastery Armory
    ["CATH"] = "SM",
    ["LIB"] = "SM",
    ["GY"] = "SM",
    ["ZF"] = "ZF",
    ["ZUL'FARRAK"] = "ZF",
}

-- Patterns
-- Simple string API in Lua 5.0 (find, match, gfind)
WRS_Data.Patterns = {
    LFG = { "LFM", "LF%dM", "LF", "WTB", "RECRUITING", "LOOKING FOR" },
    Roles = { "TANK", "HEAL", "DPS", "DMG" },
}
