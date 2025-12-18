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
    ["KARAZHAN"] = "KARA10",
    ["KZ"] = "KARA10",
    ["KARA40"] = "KARA40",
    ["KARA 40"] = "KARA40",
    ["KARAZJAN40"] = "KARA40",
    ["KARA"] = "KARA10",
    ["KARA10"] = "KARA10",
    ["ES"] = "ES",
    ["EMERALD SANCTUM"] = "ES",
    ["HM"] = "ES",
    ["HFQ"] = "HFQ",
    ["HATEFORGE"] = "HFQ",
    ["HYJAL"] = "HYJAL",
    ["KHARA"] = "KARA10",
    ["NAXX"] = "NAXX",
    ["NAXXRAMAS"] = "NAXX",
}

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
    ["DM"] = "DM",
    ["DM EAST"] = "DM",
    ["DM WEST"] = "DM",
    ["DM NORTH"] = "DM",
    ["TRIBUTE"] = "DM",
    ["HFQ"] = "HFQ",
    ["HATEFORGE"] = "HFQ",
    ["SM"] = "SM",
    ["ARM"] = "SM",
    ["CATH"] = "SM",
    ["LIB"] = "SM",
    ["GY"] = "SM",
    ["ZF"] = "ZF",
    ["ZUL'FARRAK"] = "ZF",
}

WRS_Data.FullNames = {
    ["MC"] = "Molten Core",
    ["BWL"] = "Blackwing Lair",
    ["ZG"] = "Zul'Gurub",
    ["AQ20"] = "Ruins of Ahn'Qiraj",
    ["AQ40"] = "Temple of Ahn'Qiraj",
    ["NAXX"] = "Naxxramas",
    ["ONY"] = "Onyxia's Lair",
    ["KARA10"] = "Karazhan (10)",
    ["KARA40"] = "Karazhan (40)",
    ["ES"] = "Emerald Sanctum",
    ["HFQ"] = "Hateforge Quarry",
    ["HYJAL"] = "Mount Hyjal",
    
    ["UBRS"] = "Upper Blackrock Spire",
    ["LBRS"] = "Lower Blackrock Spire",
    ["BRD"] = "Blackrock Depths",
    ["SCHOLO"] = "Scholomance",
    ["STRAT"] = "Stratholme",
    ["DM"] = "Dire Maul / Deadmines",
    ["SM"] = "Scarlet Monastery",
    ["ZF"] = "Zul'Farrak",
}

WRS_Data.Patterns = {
    General = { "LFM", "LF%dM", "LF", "WTB", "RECRUITING", "LOOKING FOR" },
    
    GuildLFM = { 
        "RECRUIT", "RECRUITING", "LFM", "LF MEMBERS", "LF RAIDERS", 
        "WE NEED", "JOIN US", "CORE SPOTS", "ROSTER", "PROGRESS" 
    },
    
    GuildLFG = { 
        "LF GUILD", "LOOKING FOR GUILD", "LFG", 
        "LF SOCIAL", "LF CASUAL", "LF RAIDING GUILD",
        "WTJ", "WANT TO JOIN"
    },
    
    Roles = { "TANK", "HEAL", "DPS", "DMG" },
}
