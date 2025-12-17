-- Scanner.lua
WRS_Scanner = {}

function WRS_Scanner:ProcessMessage(msg, sender, channel)
    if not msg or not sender then return end
    
    local contentUpper = string.upper(msg)
    local foundType = "OTHER"
    local foundKey = nil
    
    -- Check for Guild Recruitment
    if string.find(contentUpper, "<") and string.find(contentUpper, ">") then
         if string.find(contentUpper, "GUILD") or string.find(contentUpper, "RECRUIT") then
             foundType = "GUILD"
         end
    end
    
    -- Check for Quest Links
    if string.find(msg, "|Hquest:") then
        foundType = "QUEST"
    end
    
    -- Prioritize specific Raids/Dungeons over generic types
    if foundType == "OTHER" then
        -- Check Raids
        for keyword, key in pairs(WRS_Data.Raids) do
            if self:FindKeyword(contentUpper, keyword) then
                foundType = "RAID"
                foundKey = key
                break
            end
        end
    end
    
    if foundType == "OTHER" then
         -- Check Dungeons
        for keyword, key in pairs(WRS_Data.Dungeons) do
            if self:FindKeyword(contentUpper, keyword) then
                foundType = "DUNGEON"
                foundKey = key
                break
            end
        end
    end
    
    -- Check Group Size
    -- Look for patterns like "10m", "25man", "25", or implicit "Kara10"
    local groupSize = nil
    
    -- Check specific alias-embedded size (e.g. KARA10 -> 10)
    if foundKey then
        if string.find(foundKey, "10") then groupSize = 10 end
        if string.find(foundKey, "20") then groupSize = 20 end
        if string.find(foundKey, "25") then groupSize = 25 end
        if string.find(foundKey, "40") then groupSize = 40 end
    end
    
    -- Check Regex in message overrides alias default? 
    -- "Kara10 need 2 more" -> Size is still 10 for the raid.
    -- "LFM MC 25" -> Size 25.
    
    -- Simple check for numbers near "m" or "man"
    -- Lua 5.0 pattern limitations apply
    for s in string.gfind(contentUpper, "(%d+)M") do
        groupSize = tonumber(s)
    end
    if not groupSize then
        for s in string.gfind(contentUpper, "(%d+)MAN") do
            groupSize = tonumber(s)
        end
    end
    
    -- Check simple LFM X (LFM 3) -> This is "Need count", not "Group Size" usually.
    -- Warning: We need Raid Size (Total) vs Spots Needed. 
    -- User asked: "how big is the raid" -> usually Raid Size.
    
    local isLFG = false
    for _, pattern in ipairs(WRS_Data.Patterns.LFG) do
        if string.find(contentUpper, pattern) then
            isLFG = true
            break
        end
    end
    
    if (foundType ~= "OTHER" or isLFG) then
        self:AddEntry(sender, msg, foundType, foundKey, groupSize)
    end
end

function WRS_Scanner:FindKeyword(text, keyword)
    local p1 = string.find(text, keyword)
    if not p1 then return false end
    
    local validBefore = true
    if p1 > 1 then
        local charBefore = string.sub(text, p1-1, p1-1)
        if string.find(charBefore, "%a") then validBefore = false end
    end
    
    local validAfter = true
    local p2 = p1 + string.len(keyword) - 1
    if p2 < string.len(text) then
        local charAfter = string.sub(text, p2+1, p2+1)
        if string.find(charAfter, "%a") then validAfter = false end
    end
    
    return validBefore and validAfter
end

function WRS_Scanner:AddEntry(sender, message, category, key, size)
    if not WorldRaidScanDB then return end
    if not WorldRaidScanDB.activeRaids then WorldRaidScanDB.activeRaids = {} end
    
    for i, entry in ipairs(WorldRaidScanDB.activeRaids) do
        if entry.sender == sender then
            table.remove(WorldRaidScanDB.activeRaids, i)
            break
        end
    end
    
    table.insert(WorldRaidScanDB.activeRaids, {
        timestamp = time(),
        sender = sender,
        message = message,
        type = category,
        raid = key or (category == "GUILD" and "GUILD") or (category == "QUEST" and "QUEST") or "OTHER",
        groupSize = size
    })
    
    if WRS_GUI and WRS_GUI.UpdateList then
        WRS_GUI:UpdateList()
    end
end
