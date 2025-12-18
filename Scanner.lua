WRS_Scanner = {}

function WRS_Scanner:ProcessMessage(msg, sender, channel)
    if not msg or not sender then return end
    
    local contentUpper = string.upper(msg)
    local foundType = "OTHER"
    local foundKey = nil
    
    local isGuild = false
    if string.find(contentUpper, "GUILD") then isGuild = true end
    if string.find(contentUpper, "RECRUIT") then isGuild = true end
    
    if string.find(contentUpper, "<") and string.find(contentUpper, ">") and (string.find(contentUpper, "GUILD") or string.find(contentUpper, "RECRUIT") or string.find(contentUpper, "INV")) then 
        isGuild = true 
    end
    
    if isGuild then
         foundType = "GUILD"
    end
    
    if string.find(msg, "|Hquest:") then
        foundType = "QUEST"
    end
    
    if foundType == "OTHER" then
        for keyword, key in pairs(WRS_Data.Raids) do
            if self:FindKeyword(contentUpper, keyword) then
                foundType = "RAID"
                foundKey = key
                break
            end
        end
    end
    
    if foundType == "OTHER" then
        for keyword, key in pairs(WRS_Data.Dungeons) do
            if self:FindKeyword(contentUpper, keyword) then
                foundType = "DUNGEON"
                foundKey = key
                break
            end
        end
    end
    
    local groupSize = nil
    local currentCount = nil
    local maxCount = nil
    
    for cur, max in string.gfind(msg, "%[(%d+)/(%d+)%]") do
        currentCount = tonumber(cur)
        maxCount = tonumber(max)
        groupSize = maxCount
    end
    
    if not groupSize and foundKey then
        if string.find(foundKey, "10") then groupSize = 10 end
        if string.find(foundKey, "20") then groupSize = 20 end
        if string.find(foundKey, "25") then groupSize = 25 end
        if string.find(foundKey, "40") then groupSize = 40 end
    end
    
    if not groupSize then
        for s in string.gfind(contentUpper, "(%d+)M") do groupSize = tonumber(s) end
        if not groupSize then for s in string.gfind(contentUpper, "(%d+)MAN") do groupSize = tonumber(s) end end
    end

    local reserves = {}
    if string.find(contentUpper, "SR") then table.insert(reserves, "SR") end
    if string.find(contentUpper, "HR") then table.insert(reserves, "HR") end
    if string.find(contentUpper, "RESERVED") or string.find(contentUpper, "RES") then 
        if table.getn(reserves) == 0 then table.insert(reserves, "Res") end
    end
    if string.find(contentUpper, "GDKP") then table.insert(reserves, "GDKP") end
    if string.find(contentUpper, "DKP") and not string.find(contentUpper, "GDKP") then table.insert(reserves, "DKP") end
    
    local reservesStr = table.concat(reserves, ", ")
    
    local notes = {}
    if string.find(contentUpper, "SUMM") then table.insert(notes, "Summ") end
    if string.find(contentUpper, "DISC") then table.insert(notes, "Disc") end
    if string.find(contentUpper, "WB") or string.find(contentUpper, "BUFF") then table.insert(notes, "WB") end
    
    local notesStr = table.concat(notes, ", ")
    
    local roles = {}
    if string.find(contentUpper, "TANK") or string.find(contentUpper, "TN") then table.insert(roles, "Tank") end
    if string.find(contentUpper, "HEAL") then table.insert(roles, "Heal") end
    if string.find(contentUpper, "DPS") or string.find(contentUpper, "DMG") then table.insert(roles, "DPS") end
    
    local rolesStr = table.concat(roles, " ")
    
    local isLFG = false
    local lfgPatterns = WRS_Data.Patterns.General or WRS_Data.Patterns.LFG
    if lfgPatterns then
        for _, pattern in ipairs(lfgPatterns) do
            if string.find(contentUpper, pattern) then
                isLFG = true
                break
            end
        end
    end
    
    local questLink = nil
    local qStart, qEnd, qLink = string.find(msg, "(|Hquest:.-|h.-|h)")
    if qLink then
        questLink = qLink
        foundType = "QUEST"
    end
    
    local guildName = nil
    for gName in string.gfind(msg, "<(.-)>") do
        if string.len(gName) > 1 and string.len(gName) < 60 and not string.find(gName, "server") then 
             guildName = gName
             break 
        end
    end
    if not guildName then
        for gName in string.gfind(msg, "{(.-)}") do
             if string.len(gName) > 2 and string.len(gName) < 60 then guildName = gName break end
        end
    end
    
    local guildSubType = nil
    if foundType == "GUILD" then
        local isPlayerLFG = false
        if WRS_Data.Patterns.GuildLFG then
            for _, pat in ipairs(WRS_Data.Patterns.GuildLFG) do
                if string.find(contentUpper, pat) then isPlayerLFG = true break end
            end
        end

        local isGuildLFM = false
        if WRS_Data.Patterns.GuildLFM then
             for _, pat in ipairs(WRS_Data.Patterns.GuildLFM) do
                if string.find(contentUpper, pat) then isGuildLFM = true break end
            end
        end

        if isPlayerLFG then
            guildSubType = "LFG"
        elseif isGuildLFM then
            guildSubType = "LFM"
        else
            if isLFG then 
                guildSubType = "LFM" 
            else
                guildSubType = "LFM" 
            end
        end
    end

    local discordLink = nil
    
    local function FindDiscordCode(text)
        local s, e, code = string.find(text, "discord%.gg/(%w+)")
        if code then return code end
        s, e, code = string.find(text, "discord%.me/(%w+)")
        if code then return code end
        s, e, code = string.find(text, "discord%.io/(%w+)")
        if code then return code end
        s, e, code = string.find(text, "discord%.com/invite/(%w+)")
        if code then return code end
        return nil
    end
    
    local discCode = FindDiscordCode(msg)
    if discCode then
         discordLink = "discord.gg/" .. discCode
    end

    if (foundType ~= "OTHER" or isLFG) then
        self:AddEntry(sender, msg, foundType, foundKey, groupSize, currentCount, maxCount, reservesStr, notesStr, rolesStr, questLink, guildName, guildSubType, discordLink)
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

function WRS_Scanner:AddEntry(sender, message, category, key, size, cur, max, res, notes, roles, questLink, guildName, subType, discordLink)
    if not WorldRaidScanDB then return end
    if not WorldRaidScanDB.activeRaids then WorldRaidScanDB.activeRaids = {} end
    
    local uniqueKey = ""
    local raidKey = key or "OTHER"
    
    if category == "GUILD" then
        if subType == "LFM" and guildName then
             uniqueKey = "GUILD_LFM_" .. guildName
        elseif subType == "LFG" then
             uniqueKey = "GUILD_LFG_" .. sender
        else
             uniqueKey = "GUILD_OTHER_" .. sender
        end
    elseif category == "QUEST" and questLink then
        uniqueKey = "QUEST_" .. questLink .. "_" .. sender
    elseif (category == "RAID" or category == "DUNGEON") and raidKey ~= "OTHER" then
         uniqueKey = category .. "_" .. raidKey .. "_" .. sender
    else
         uniqueKey = "OTHER_" .. sender
    end
    
    local foundIndex = nil
    for i, entry in ipairs(WorldRaidScanDB.activeRaids) do
        if entry.uniqueKey == uniqueKey then
            foundIndex = i
            break
        end
    end
    
    if foundIndex then
        local entry = WorldRaidScanDB.activeRaids[foundIndex]
        entry.timestamp = time()
        entry.message = message
        
        if category == "GUILD" and subType == "LFM" then
             if not string.find(entry.sender, sender) then
                 entry.sender = entry.sender .. ", " .. sender
             end
        else
             entry.sender = sender
        end
        
        if size then entry.groupSize = size end
        if cur then entry.currentInfo = (cur.."/"..max) end
        if res and res ~= "" then entry.reserves = res end
        if notes and notes ~= "" then entry.notes = notes end
        if roles and roles ~= "" then entry.roles = roles end
        if subType then entry.subType = subType end 
        if discordLink then entry.discordLink = discordLink end
        
    else
        if table.getn(WorldRaidScanDB.activeRaids) >= 400 then
            local oldestI = 1
            local oldestTime = time() + 999999
            for k, e in ipairs(WorldRaidScanDB.activeRaids) do
                if e.timestamp < oldestTime then
                     oldestTime = e.timestamp
                     oldestI = k
                end
            end
            table.remove(WorldRaidScanDB.activeRaids, oldestI)
        end

        table.insert(WorldRaidScanDB.activeRaids, {
            uniqueKey = uniqueKey,
            timestamp = time(),
            sender = sender,
            message = message,
            type = category,
            raid = raidKey,
            groupSize = size,
            currentInfo = (cur and (cur.."/"..max)) or nil,
            reserves = res,
            notes = notes,
            roles = roles,
            questLink = questLink,
            guildName = guildName,
            subType = subType,
            discordLink = discordLink
        })
    end
    
    if WRS_GUI and WRS_GUI.UpdateData then
        WRS_GUI:UpdateData()
    end
end
