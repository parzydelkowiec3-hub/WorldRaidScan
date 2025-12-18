-- GUI.lua
if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WorldRaidScan: Loading GUI...") end

WRS_GUI = {}
WRS_GUI.SelectedTab = "RAID"
WRS_GUI.CollapsedGroups = {} 
WRS_GUI.SortBy = "time" -- time, sender, sum, res, disc, role
WRS_GUI.SortAsc = true

local function CreateMinimapButton()
    local btn = CreateFrame("Button", "WRS_MinimapButton", Minimap)
    btn:SetWidth(32)
    btn:SetHeight(32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetPoint("CENTER", -12, -80)
    btn:EnableMouse(true)
    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    -- Using a very standard, safe icon (Warrior T2 Helm)
    icon:SetTexture("Interface\\Icons\\INV_Helmet_44") 
    
    local mask = btn:CreateTexture(nil, "ARTWORK")
    mask:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    mask:SetWidth(20)
    mask:SetHeight(20)
    mask:SetPoint("CENTER", 0, 0)
    icon:SetAllPoints(mask)
    
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(52)
    border:SetHeight(52)
    border:SetPoint("TOPLEFT", 0, 0)
    
    btn:SetScript("OnDragStart", function() this:StartMoving() end)
    btn:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    btn:SetScript("OnClick", function() 
        if WRS_GUI.Toggle then WRS_GUI:Toggle() end 
    end)
    
    -- Tooltip
    btn:SetScript("OnEnter", function() 
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("WorldRaidScan")
        GameTooltip:AddLine("Version: 1.0", 1, 1, 1)
        GameTooltip:AddLine("Author: Tuziak", 1, 1, 1)
        local cRaid, cDung, cOther, cQuest, cGuild = 0, 0, 0, 0, 0
        if WorldRaidScanDB and WorldRaidScanDB.activeRaids then
            for _, e in ipairs(WorldRaidScanDB.activeRaids) do
                local t = e.type or "OTHER"
                if t == "RAID" then cRaid = cRaid + 1
                elseif t == "DUNGEON" then cDung = cDung + 1
                elseif t == "QUEST" then cQuest = cQuest + 1
                elseif t == "GUILD" then cGuild = cGuild + 1
                else cOther = cOther + 1 end
            end
        end
        GameTooltip:AddLine("Active: "..(cRaid+cDung+cOther+cQuest+cGuild), 1, 1, 1)
        GameTooltip:AddLine("Raids: "..cRaid.."  Dungeons: "..cDung, 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Others: "..cOther.." (Q:"..cQuest.." G:"..cGuild..")", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Left-Click to open.", 0, 1, 0)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    return btn
end

WRS_GUI.MinimapButton = CreateMinimapButton()

-- Main Frame
WRS_GUI.MainFrame = CreateFrame("Frame", "WorldRaidScanFrame", UIParent)
WRS_GUI.MainFrame:SetWidth(600)
WRS_GUI.MainFrame:SetHeight(450)
WRS_GUI.MainFrame:SetPoint("CENTER", 0, 0)
WRS_GUI.MainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
WRS_GUI.MainFrame:SetMovable(true)
WRS_GUI.MainFrame:EnableMouse(true)
WRS_GUI.MainFrame:SetScript("OnMouseDown", function() if arg1 == "LeftButton" then this:StartMoving() end end)
WRS_GUI.MainFrame:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
WRS_GUI.MainFrame:Hide()



StaticPopupDialogs["WRS_COPY_LINK"] = {
    text = "Press Ctrl+C to copy the Discord link:\n\n\n",
    button1 = "Close",
    hasEditBox = 1,
    maxLetters = 255,
    OnShow = function()
        local eb = getglobal(this:GetName().."EditBox")
        if eb then
            eb:SetText(WRS_GUI.LastDiscordLink or "Error: No Link Found") 
            eb:SetFocus()
            eb:HighlightText()
            
            -- Fix Close Button Position
            local btn = getglobal(this:GetName().."Button1")
            if btn then
                 btn:ClearAllPoints()
                 btn:SetPoint("TOP", eb, "BOTTOM", 0, -10)
            end
        end
    end,
    EditBoxOnEnterPressed = function() this:GetParent():Hide() end,
    EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}

local closeBtn = CreateFrame("Button", nil, WRS_GUI.MainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local title = WRS_GUI.MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -15)
title:SetText("WorldRaidScan")

function WRS_GUI:Initialize()
    if not WorldRaidScanDB.settings then

        WorldRaidScanDB.settings = { scanWhenClosed = true }
    end
    -- Initialize default layout
    self:UpdateLayout("RAID")
end


local settingsBtn = CreateFrame("Button", "WRS_SettingsButton", WRS_GUI.MainFrame, "UIPanelButtonTemplate")
settingsBtn:SetWidth(24)
settingsBtn:SetHeight(24)
settingsBtn:SetPoint("TOPRIGHT", -30, -5)
settingsBtn:SetText("S")
settingsBtn:SetScript("OnClick", function() 
    if not WRS_GUI.SettingsFrame then
        WRS_GUI:CreateSettingsFrame()
    end
    if WRS_GUI.SettingsFrame:IsVisible() then
        WRS_GUI.SettingsFrame:Hide()
    else
        WRS_GUI.SettingsFrame:Show()
    end
end)

function WRS_GUI:CreateSettingsFrame()
    local f = CreateFrame("Frame", "WRS_SettingsFrame", WRS_GUI.MainFrame)
    f:SetWidth(400)
    f:SetHeight(150)
    f:SetPoint("CENTER", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:EnableMouse(true)
    f:SetFrameStrata("DIALOG")
    
    local sTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sTitle:SetPoint("TOP", 0, -15)
    sTitle:SetText("Settings")
    
    local sClose = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    sClose:SetWidth(80)
    sClose:SetHeight(24)
    sClose:SetPoint("BOTTOM", 0, 15)
    sClose:SetText("Close")
    sClose:SetScript("OnClick", function() f:Hide() end)
    
    local cb = CreateFrame("CheckButton", "WRS_ScanClosedCheck", f, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -50)
    local cbText = getglobal(cb:GetName().."Text")
    if cbText then cbText:SetText("Scan when window is closed") end
    
    if WorldRaidScanDB and WorldRaidScanDB.settings then
        cb:SetChecked(WorldRaidScanDB.settings.scanWhenClosed)
    end
    
    cb:SetScript("OnClick", function()
        if WorldRaidScanDB and WorldRaidScanDB.settings then
            WorldRaidScanDB.settings.scanWhenClosed = this:GetChecked()
        end
    end)
    
    -- REMOVED: Clear Scan Button (User Request)
    -- REMOVED: Remove Entry Button (User Request)
    -- local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate") 
    -- ...
    
    WRS_GUI.SettingsFrame = f
end


WRS_GUI.Tabs = {"RAID", "DUNGEON", "GUILD", "QUEST", "OTHER"}
WRS_GUI.TabButtons = {}
WRS_GUI.MainFrame.numTabs = table.getn(WRS_GUI.Tabs)
WRS_GUI.MainFrame.selectedTab = 1

for i, name in ipairs(WRS_GUI.Tabs) do
    -- Naming convention MUST be FrameName.."Tab"..id for PanelTemplates to work
    local tabName = "WorldRaidScanFrameTab"..i
    local tab = CreateFrame("Button", tabName, WRS_GUI.MainFrame, "CharacterFrameTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(name)
    
    tab.tabName = name
    
    if i == 1 then
        tab:SetPoint("BOTTOMLEFT", 15, -30)
    else
        -- Anchor to the right of the previous tab with standard overlap
        local prevTab = getglobal("WorldRaidScanFrameTab"..(i-1))
        tab:SetPoint("LEFT", prevTab, "RIGHT", -5, 0)
    end
    
    tab:SetScript("OnClick", function() 
        local tName = this.tabName
        if tName then
            WRS_GUI:SelectTab(tName) 
        end
    end)
    tab:SetScript("OnEnter", function()
        if this.tabName then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.tabName)
            local count = 0
            if WRS_GUI.TabCounts and WRS_GUI.TabCounts[this.tabName] then count = WRS_GUI.TabCounts[this.tabName] end
            GameTooltip:AddLine("Active: "..count, 0, 1, 0)
            GameTooltip:Show()
        end
    end)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    WRS_GUI.TabButtons[name] = tab
end


function WRS_GUI:UpdateTabsVisuals()
    local selected = self.SelectedTab
    if not self.Tabs then return end
    
    for _, name in ipairs(self.Tabs) do
        local tab = self.TabButtons[name]
        if tab and type(tab) == "table" then
             -- Simple safe logic: Selected = Disabled (Standard WoW behavior), Unselected = Enabled
             if name == selected then
                 tab:Disable()
             else
                 tab:Enable()
             end
        end
    end
end

-- Initialize the visual state of tabs
WRS_GUI:UpdateTabsVisuals()


WRS_GUI.ScrollFrame = CreateFrame("ScrollFrame", "WRS_ScrollFrame", WRS_GUI.MainFrame, "FauxScrollFrameTemplate")
WRS_GUI.ScrollFrame:SetPoint("TOPLEFT", 15, -75) -- Adjusted to make room for headers
WRS_GUI.ScrollFrame:SetPoint("BOTTOMRIGHT", -35, 10) -- Extended downwards

local cleanupTimer = 0
local CLEANUP_INTERVAL = 60
local ENTRY_MAX_OLDEST = 3 * 60 * 60 -- 3 hours

local cleanupFrame = CreateFrame("Frame")
cleanupFrame:SetScript("OnUpdate", function()
    cleanupTimer = cleanupTimer + arg1
    if cleanupTimer > CLEANUP_INTERVAL then
        cleanupTimer = 0
        if WorldRaidScanDB and WorldRaidScanDB.activeRaids then
            local now = time()
            local changed = false
            local i = 1
            while i <= table.getn(WorldRaidScanDB.activeRaids) do
                local entry = WorldRaidScanDB.activeRaids[i]
                if (now - entry.timestamp) > ENTRY_MAX_OLDEST then
                    table.remove(WorldRaidScanDB.activeRaids, i)
                    changed = true
                else
                    i = i + 1
                end
            end
            if changed and WRS_GUI and WRS_GUI.UpdateData then
                WRS_GUI:UpdateData()
            end
        end
    end
end)

local function GetTimeAgo(timestamp)
    if not timestamp then return "" end
    local diff = time() - timestamp
    if diff < 60 then return diff.."s" end
    if diff < 3600 then return math.floor(diff/60).."m" end
    return math.floor(diff/3600).."h"
end

WRS_GUI.EntryButtons = {}
local MAX_ROWS = 16 
local ROW_HEIGHT = 20

for i=1, MAX_ROWS do
    local btn = CreateFrame("Button", "WRS_Entry"..i, WRS_GUI.MainFrame)
    btn:SetHeight(ROW_HEIGHT)
    btn:SetWidth(535) -- Width reduced to fit ScrollBar (600 - PAD - SCROLL)
    btn:SetPoint("TOPLEFT", 15, -45 - ((i-1)*ROW_HEIGHT))
    
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    
    btn.stripe = btn:CreateTexture(nil, "BACKGROUND")
    btn.stripe:SetAllPoints(btn)
    btn.stripe:SetTexture(0.5, 0.5, 0.5)
    btn.stripe:SetAlpha(0.1)
    btn.stripe:Hide()
    
    btn.expandIcon = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.expandIcon:SetPoint("LEFT", 5, 0)
    btn.expandIcon:SetText("+")
    btn.expandIcon:Hide()


    btn.colTime = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.colTime:SetPoint("LEFT", 5, 0)
    btn.colTime:SetWidth(45)
    btn.colTime:SetJustifyH("RIGHT")

    btn.colSender = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.colSender:SetPoint("LEFT", 55, 0)
    btn.colSender:SetWidth(130)
    btn.colSender:SetJustifyH("LEFT")

    btn.colSum = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.colSum:SetPoint("LEFT", 190, 0)
    btn.colSum:SetWidth(40)
    btn.colSum:SetJustifyH("CENTER")

    btn.colReserves = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.colReserves:SetPoint("LEFT", 235, 0)
    btn.colReserves:SetWidth(90)
    btn.colReserves:SetJustifyH("LEFT")

    btn.colDisc = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.colDisc:SetPoint("LEFT", 330, 0)
    btn.colDisc:SetWidth(40)
    btn.colDisc:SetJustifyH("CENTER")

    btn.colDisc:SetJustifyH("CENTER")

    btn.discBtn = CreateFrame("Button", nil, btn)
    btn.discBtn:SetPoint("LEFT", 330, 0)
    btn.discBtn:SetWidth(40)
    btn.discBtn:SetHeight(20)
    btn.discBtn:SetScript("OnEnter", function() 
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to Copy Link")
        GameTooltip:Show()
    end)
    btn.discBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn.discBtn:SetScript("OnClick", function()
        if this.url then 
            WRS_GUI.LastDiscordLink = this.url
            StaticPopup_Show("WRS_COPY_LINK")
        end
    end)
    btn.discBtn:Hide()

    btn.colInfo = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.colInfo:SetPoint("LEFT", 375, 0)
    btn.colInfo:SetWidth(150)
    btn.colInfo:SetJustifyH("LEFT")
    
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(0.5, 0.5, 0.5, 0.3)
    
    btn:SetScript("OnEnter", function()
        if not this.isHeader and this.data then
             GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
             GameTooltip:SetText(this.data.sender, 1, 1, 1)
             GameTooltip:AddLine(this.data.message, 0.9, 0.9, 0.9, 1)
             GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    btn:SetScript("OnClick", function()
        if this.isHeader then
            local key = this.groupKey
            if WRS_GUI.CollapsedGroups[key] then
                WRS_GUI.CollapsedGroups[key] = nil
            else
                WRS_GUI.CollapsedGroups[key] = true
            end
            WRS_GUI:UpdateList()
        else
            WRS_GUI.SelectedEntry = this.data
            WRS_GUI:UpdateSelection()
        end
    end)
    
    btn:Hide()
    WRS_GUI.EntryButtons[i] = btn
end

local function CreateHeader(name, text, width, sortKey, point, relPoint, x, y, tipTitle, tipText)
    local btn = CreateFrame("Button", name, WRS_GUI.MainFrame)
    btn:SetWidth(width)
    btn:SetHeight(20)
    btn:SetPoint(point, relPoint, x, y)
    
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetAllPoints(btn)
    btn.fs = fs -- Store reference for update
    
    if WRS_GUI.SelectedTab == "GUILD" then
        fs:SetText("Guild Name")
    else
        fs:SetText(text)
    end
    fs:SetJustifyH("LEFT")
    if sortKey == "time" or sortKey == "sum" or sortKey == "disc" then fs:SetJustifyH("CENTER") end
    
    local ht = btn:CreateTexture(nil, "HIGHLIGHT")
    ht:SetAllPoints(btn)
    ht:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    ht:SetBlendMode("ADD")
    
    btn.tipTitle = tipTitle or text
    btn.tipText = tipText
    
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:SetText(this.tipTitle, 1, 1, 1)
        if this.tipText then GameTooltip:AddLine(this.tipText, 0.8, 0.8, 0.8, 1) end
        GameTooltip:AddLine("Click to Sort", 0, 1, 0)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    btn:SetScript("OnClick", function()
        if WRS_GUI.SortBy == sortKey then
            WRS_GUI.SortAsc = not WRS_GUI.SortAsc
        else
            WRS_GUI.SortBy = sortKey
            WRS_GUI.SortAsc = true -- Default ASCII for new sort? Or DESC for time? 
            -- Actually for Time, DESC is usually preferred (newest first).
            if sortKey == "time" then WRS_GUI.SortAsc = false end
        end
        WRS_GUI:UpdateList()
    end)
    return btn
end

local hTime = CreateHeader("WRS_HeaderTime", "Time", 45, "time", "TOPLEFT", WRS_GUI.MainFrame, 20, -30, "Time Ago", "Time since the last message was seen.")

local hSender = CreateHeader("WRS_HeaderSender", "Sender", 130, "sender", "TOPLEFT", WRS_GUI.MainFrame, 70, -30, "Sender", "Player or Channel Name.")

local hSum = CreateHeader("WRS_HeaderSum", "Sum", 40, "sum", "TOPLEFT", WRS_GUI.MainFrame, 205, -30, "Summon", "Does the group have a summoning stone?")

local hRes = CreateHeader("WRS_HeaderRes", "Res", 90, "res", "TOPLEFT", WRS_GUI.MainFrame, 250, -30, "Reserves", "Hard Reserved (HR) or Soft Reserved (SR) items.")

local hDisc = CreateHeader("WRS_HeaderDisc", "Disc", 40, "disc", "TOPLEFT", WRS_GUI.MainFrame, 345, -30, "Discord", "Was a Discord link detected?")

local hInfo = CreateHeader("WRS_HeaderInfo", "Role Info", 150, "role", "TOPLEFT", WRS_GUI.MainFrame, 390, -30, "Roles / Info", "Roles needed or parsing info.")

local discordBtn = CreateFrame("Button", "WRS_DiscordButton", WRS_GUI.MainFrame, "UIPanelButtonTemplate")
discordBtn:SetWidth(80)
discordBtn:SetHeight(22)
discordBtn:SetPoint("BOTTOMRIGHT", -10, 15)
discordBtn:SetText("Discord")
discordBtn:Disable()
discordBtn:SetScript("OnClick", function()
    if WRS_GUI.SelectedEntry and WRS_GUI.SelectedEntry.discordLink then
        WRS_GUI.LastDiscordLink = WRS_GUI.SelectedEntry.discordLink
        StaticPopup_Show("WRS_COPY_LINK")
    end
end)
WRS_GUI.DiscordButton = discordBtn

local whisperBtn = CreateFrame("Button", "WRS_WhisperButton", WRS_GUI.MainFrame, "UIPanelButtonTemplate")
whisperBtn:SetWidth(80)
whisperBtn:SetHeight(22)
whisperBtn:SetPoint("RIGHT", discordBtn, "LEFT", -5, 0) -- Left of Discord
whisperBtn:SetText("Whisper")
whisperBtn:Disable()
whisperBtn:SetScript("OnClick", function()
    if WRS_GUI.SelectedEntry then
        if ChatFrame_OpenChat then
            ChatFrame_OpenChat("/w " .. WRS_GUI.SelectedEntry.sender .. " ")
        end
    end
end)
WRS_GUI.WhisperButton = whisperBtn



function WRS_GUI:Toggle()
    if WRS_GUI.MainFrame:IsVisible() then
        WRS_GUI.MainFrame:Hide()
    else
        WRS_GUI.MainFrame:Show()
        self:UpdateData()
    end
end

function WRS_GUI:SelectTab(tabName)
    if not tabName then return end

    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WRS: Selecting Tab ["..tabName.."]") end
    
    self.SelectedTab = tabName
    self.SelectedEntry = nil
    
    local id = 0
    for i, name in ipairs(self.Tabs) do 
        if name == tabName then id = i break end 
    end
    
    if id > 0 then
        WRS_GUI.MainFrame.selectedTab = id
        WRS_GUI:UpdateTabsVisuals()
    end
    
    self:UpdateLayout(tabName)

    
    if WRS_GUI.ScrollFrame and FauxScrollFrame_SetOffset and WRS_ScrollFrameScrollBar then
        FauxScrollFrame_SetOffset(WRS_GUI.ScrollFrame, 0)
        WRS_ScrollFrameScrollBar:SetValue(0)
    end
    
    self:UpdateSelection()
end

WRS_GUI.WhisperButton = whisperBtn




function WRS_GUI:SortList(items)
    table.sort(items, function(a, b)
        local valA, valB
        local k = WRS_GUI.SortBy or "time"
        
        if k == "time" then
            valA = a.timestamp
            valB = b.timestamp
        elseif k == "sender" then
            valA = a.sender or ""
            valB = b.sender or ""
        elseif k == "sum" then
             valA = (a.notes and string.find(a.notes, "Summ")) and 1 or 0
             valB = (b.notes and string.find(b.notes, "Summ")) and 1 or 0
        elseif k == "res" then
            valA = a.reserves or ""
            valB = b.reserves or ""
        elseif k == "disc" then
            valA = (a.notes and string.find(a.notes, "Disc")) and 1 or 0
            valB = (b.notes and string.find(b.notes, "Disc")) and 1 or 0
        elseif k == "role" then
            valA = a.roles or ""
            valB = b.roles or ""
        else
            valA = a.timestamp
            valB = b.timestamp
        end
        
        if valA == valB then
             return a.timestamp > b.timestamp -- always fallback to newest time
        end
        
        if WRS_GUI.SortAsc then
            return valA < valB
        else
            return valA > valB
        end
    end)
end

function WRS_GUI:Toggle()
    if WRS_GUI.MainFrame:IsVisible() then
        WRS_GUI.MainFrame:Hide()
    else
        WRS_GUI.MainFrame:Show()
        self:UpdateData()
    end
end

function WRS_GUI:SelectTab(tabName)
    if not tabName then return end
    -- DEBUG:
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WRS: Selecting Tab ["..tabName.."]") end
    self.SelectedTab = tabName
    self.SelectedEntry = nil
    
    -- Visual Update
    local id = 0
    for i, name in ipairs(self.Tabs) do 
        if name == tabName then id = i break end 
    end
    
    if id > 0 then
        -- PanelTemplates_SetTab(WRS_GUI.MainFrame, id) -- Removed to use custom update
        WRS_GUI.MainFrame.selectedTab = id
        WRS_GUI:UpdateTabsVisuals()
    end
    
    self:UpdateLayout(tabName)
    
    -- Reset Scroll
    if WRS_GUI.ScrollFrame and FauxScrollFrame_SetOffset and WRS_ScrollFrameScrollBar then
        FauxScrollFrame_SetOffset(WRS_GUI.ScrollFrame, 0)
        WRS_ScrollFrameScrollBar:SetValue(0)
    end
    
    self:UpdateSelection()
end

function WRS_GUI:UpdateLayout(tabName)
    local l = {
        SenderText = "Sender", SenderX = 55, SenderW = 130,
        SumVisible = true, SumX = 190,
        ResVisible = true, ResX = 235,
        DiscVisible = true, DiscX = 330,
        InfoText = "Role Info", InfoX = 375, InfoW = 150
    }
    
    if tabName == "QUEST" then
        l.SenderText = "Quest Name"
        l.SenderX = 55
        l.SenderW = 320 -- Big width for quest
        l.SumVisible = false
        l.ResVisible = false
        l.DiscVisible = false
        l.InfoText = "Player"
        l.InfoX = 385
        l.InfoW = 140
    elseif tabName == "GUILD" then
        l.SenderText = "Name / Guild"
        l.SenderX = 55
        l.SenderW = 220
        l.SumVisible = false
        l.ResVisible = false
        l.DiscVisible = false
        l.InfoText = "Note"
        l.InfoX = 285
        l.InfoW = 200
    elseif tabName == "OTHER" then
        l.SenderText = "Sender"
        l.SenderX = 55
        l.SenderW = 100
        l.SumVisible = false
        l.ResVisible = false
        l.DiscVisible = false
        l.InfoText = "Message"
        l.InfoX = 160
        l.InfoW = 350 -- Use remaining space
    end
    
    WRS_GUI.CurrentLayout = l

     
    local hSender = getglobal("WRS_HeaderSender")
    if hSender then
        hSender.fs:SetText(l.SenderText)
        hSender:SetWidth(l.SenderW)
        hSender:SetPoint("TOPLEFT", WRS_GUI.MainFrame, 15 + l.SenderX, -30)
        hSender.tipTitle = l.SenderText 
    end
    
    local hSum = getglobal("WRS_HeaderSum")
    if hSum then
        if l.SumVisible then hSum:Show() else hSum:Hide() end
    end
    
    local hRes = getglobal("WRS_HeaderRes")
    if hRes then
        if l.ResVisible then hRes:Show() else hRes:Hide() end
    end
    
    local hDisc = getglobal("WRS_HeaderDisc")
    if hDisc then
        if l.DiscVisible then hDisc:Show() else hDisc:Hide() end
    end
    
    local hInfo = getglobal("WRS_HeaderInfo")
    if hInfo then
        hInfo.fs:SetText(l.InfoText)
        hInfo:SetWidth(l.InfoW)
        hInfo:SetPoint("TOPLEFT", WRS_GUI.MainFrame, 15 + l.InfoX, -30)
        hInfo.tipTitle = l.InfoText
    end
end


function WRS_GUI:GetDisplayList()
    if not WorldRaidScanDB or not WorldRaidScanDB.activeRaids then return {} end
    
    local tab = self.SelectedTab or "OTHER"
    local display = {}
    
    if tab == "QUEST" then

        local quests = {}
        for _, entry in ipairs(WorldRaidScanDB.activeRaids) do
            local eType = entry.type or "OTHER"
            if eType == "QUEST" then
                table.insert(quests, entry)
            end
        end
        
        self:SortList(quests, "QUEST")
        
        for _, item in ipairs(quests) do
            table.insert(display, { isHeader=false, data=item })
        end
    elseif tab == "GUILD" then
        local lfmItems = {}
        local lfgItems = {}
        
        for _, entry in ipairs(WorldRaidScanDB.activeRaids) do
            local eType = entry.type or "OTHER"
            if eType == "GUILD" then
                if entry.subType == "LFM" then
                    table.insert(lfmItems, entry)
                else
                    table.insert(lfgItems, entry)
                end
            end
        end
        
        self:SortList(lfmItems, "GUILD")
        self:SortList(lfgItems, "GUILD")
        
        self:SortList(lfgItems, "GUILD")
        
        if table.getn(lfmItems) > 0 then
             local key = "GUILD_LFM"
             local isCollapsed = WRS_GUI.CollapsedGroups[key]
             table.insert(display, { isHeader=true, key=key, text="Guilds Recruiting ("..table.getn(lfmItems)..")", collapsed=isCollapsed })
             if not isCollapsed then
                 for _, item in ipairs(lfmItems) do
                     table.insert(display, { isHeader=false, data=item })
                 end
             end
        end

        
        if table.getn(lfgItems) > 0 then
             local key = "GUILD_LFG"
             local isCollapsed = WRS_GUI.CollapsedGroups[key]
             table.insert(display, { isHeader=true, key=key, text="Players Looking for Guild ("..table.getn(lfgItems)..")", collapsed=isCollapsed })
             if not isCollapsed then
                 for _, item in ipairs(lfgItems) do
                     table.insert(display, { isHeader=false, data=item })
                 end
             end
        end 
    else
        local groups = {}
        for _, entry in ipairs(WorldRaidScanDB.activeRaids) do
            local eType = entry.type or "OTHER"
            if eType == tab then
                local key = entry.raid or "Others"
                if not groups[key] then groups[key] = { items={} } end
                table.insert(groups[key].items, entry)
            end
        end

        
        for k, g in pairs(groups) do
            self:SortList(g.items)
        end
        
        local keys = {}
        for k in pairs(groups) do table.insert(keys, k) end
        table.sort(keys)
        
        for _, key in ipairs(keys) do
            local g = groups[key]
            if g then
                local count = table.getn(g.items)
                local isCollapsed = WRS_GUI.CollapsedGroups[key]

                
                local displayName = key
                if WRS_Data and WRS_Data.FullNames and WRS_Data.FullNames[key] then
                    displayName = WRS_Data.FullNames[key]
                end
                
                table.insert(display, { isHeader=true, key=key, text=displayName.." ("..count..")", collapsed=isCollapsed })
                if not isCollapsed then
                    for _, item in ipairs(g.items) do
                        table.insert(display, { isHeader=false, data=item })
                    end
                end
            end
        end
    end
    
    return display
end

function WRS_GUI:UpdateData()
    self:UpdateTabCounts()
    self:UpdateList()
end

function WRS_GUI:UpdateList()
    if not WRS_GUI.MainFrame:IsVisible() then return end

    
    local list = self:GetDisplayList()
    local numItems = table.getn(list)
    FauxScrollFrame_Update(WRS_GUI.ScrollFrame, numItems, MAX_ROWS, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(WRS_GUI.ScrollFrame)
    
    for i=1, MAX_ROWS do
        local index = offset + i
        local btn = WRS_GUI.EntryButtons[i]
        if index <= numItems then
            local item = list[index]
            btn:Show()
            
            if item.isHeader then
                btn.isHeader = true
                btn.groupKey = item.key
                btn.data = nil
                
                -- Header Config
                btn.colSender:SetText("|cffffd100" .. item.text .. "|r")
                btn.colSender:SetPoint("LEFT", 20, 0) 
                btn.colSender:SetWidth(400)
                
                btn.colTime:SetText("")
                btn.colSum:SetText("")
                btn.colReserves:SetText("")
                btn.colDisc:SetText("")
                btn.colInfo:SetText("")
                
                btn.expandIcon:Show()
                btn.expandIcon:SetText(item.collapsed and "+" or "-")
                btn:SetNormalTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
            else
                btn.isHeader = false
                btn.data = item.data
                btn.expandIcon:Hide()
                local entry = item.data
                
                btn.colTime:SetText(GetTimeAgo(entry.timestamp))
                
                if (math.mod(i, 2) == 0) then
                    btn.stripe:Show()
                else
                    btn.stripe:Hide()
                end
                
                local layout = WRS_GUI.CurrentLayout
                
                -- Col 2: Sender / Quest / Guild
                btn.colSender:SetPoint("LEFT", layout.SenderX, 0)
                btn.colSender:SetWidth(layout.SenderW)
                
                if WRS_GUI.SelectedTab == "QUEST" and entry.questLink then
                     btn.colSender:SetText(entry.questLink)
                elseif WRS_GUI.SelectedTab == "GUILD" then

                    if entry.subType == "LFG" then
                         btn.colSender:SetText("|cffffffff"..entry.sender.."|r")
                    else
                        if entry.guildName then
                             local gName = entry.guildName
                             if gName ~= "<Unknown>" then gName = "<"..gName..">" end
                             btn.colSender:SetText("|cffffd100"..gName.."|r")
                        else
                             btn.colSender:SetText("|cffffffff"..entry.sender.."|r")
                        end

                    end
                else
                     btn.colSender:SetText("|cffffffff"..entry.sender.."|r")
                end

                if layout.SumVisible then
                    local sumTxt = ""
                    if entry.notes and string.find(entry.notes, "Summ") then sumTxt = "|cff00ff00Yes|r" end
                    btn.colSum:SetText(sumTxt)
                    btn.colSum:Show()
                else
                    btn.colSum:Hide()
                end
                
                if layout.ResVisible then
                    local resTxt = entry.reserves or ""
                    if resTxt ~= "" then resTxt = "|cffff0000"..resTxt.."|r" end
                    btn.colReserves:SetText(resTxt)
                    btn.colReserves:Show()
                else
                    btn.colReserves:Hide()
                end
                
                if layout.DiscVisible then
                    local discTxt = ""
                     if entry.discordLink then
                         discTxt = "|cff00ffffLink|r"
                         btn.discBtn:Show()
                         btn.discBtn.url = entry.discordLink
                     else
                         btn.discBtn:Hide()
                         if entry.notes and string.find(entry.notes, "Disc") then discTxt = "|cff5555ffYes|r" end
                     end
                     btn.colDisc:SetText(discTxt)
                     btn.colDisc:Show()
                else
                    btn.colDisc:Hide()
                    btn.discBtn:Hide()
                end

                
                btn.colInfo:SetPoint("LEFT", layout.InfoX, 0)
                btn.colInfo:SetWidth(layout.InfoW)
                
                if WRS_GUI.SelectedTab == "QUEST" then
                     -- Show sender name as Player
                     btn.colInfo:SetText("|cffffffff"..entry.sender.."|r")
                elseif WRS_GUI.SelectedTab == "GUILD" then
                     -- Show note or extra info
                     if entry.subType == "LFM" then
                         -- For recruiting, show what they need (Roles/Note)
                         local info = entry.roles or entry.notes or "Recruiting"
                         btn.colInfo:SetText("|cff00ff00"..info.."|r")
                     else
                         -- For LFG, show class/spec if available (from message parsing? Scanner doesn't extract Class yet, maybe roles)
                         local info = entry.roles or entry.notes or "Looking"
                         btn.colInfo:SetText("|cff00ff00"..info.."|r")
                     end

                elseif WRS_GUI.SelectedTab == "OTHER" then
                     local msg = entry.message or ""
                     if string.len(msg) > 45 then msg = string.sub(msg, 1, 42).."..." end
                     btn.colInfo:SetText("|cffffffff"..msg.."|r")
                else
                    local infoParts = {}
                    if entry.currentInfo then table.insert(infoParts, "|cff00ff00"..entry.currentInfo.."|r") end
                    if entry.roles and string.len(entry.roles) > 0 then table.insert(infoParts, entry.roles) end
                    local info = table.concat(infoParts, " - ")
                    if info == "" then info = "LFM" end
                    btn.colInfo:SetText(info)
                end
                
                btn:SetNormalTexture("")
                
                if WRS_GUI.SelectedEntry == entry then
                    btn:LockHighlight()
                else
                    btn:UnlockHighlight()
                end
            end
        else
            btn:Hide()
        end
    end
    

    if WRS_HeaderTime then
         WRS_GUI:UpdateHeaderVisuals()
    end
end

function WRS_GUI:UpdateHeaderVisuals()
    local s = WRS_GUI.SortBy or "time"
    local a = WRS_GUI.SortAsc
    local arrow = a and " |cff00ff00^|r" or " |cff00ff00v|r"
    
    if s == "time" and WRS_HeaderTime then
        WRS_HeaderTime.fs:SetText("Time" .. arrow)
    else
        WRS_HeaderTime.fs:SetText("Time")
    end
    
    if s == "sender" and WRS_HeaderSender then
        if WRS_GUI.SelectedTab == "GUILD" then
             WRS_HeaderSender.fs:SetText("Guild Name" .. arrow)
        else
             WRS_HeaderSender.fs:SetText("Sender" .. arrow)
        end
    else
        if WRS_GUI.SelectedTab == "GUILD" then
             WRS_HeaderSender.fs:SetText("Guild Name")
        else
             WRS_HeaderSender.fs:SetText("Sender")
        end
    end
    
    if s == "sum" and WRS_HeaderSum then WRS_HeaderSum.fs:SetText("Sum" .. arrow) else WRS_HeaderSum.fs:SetText("Sum") end
    if s == "res" and WRS_HeaderRes then WRS_HeaderRes.fs:SetText("Res" .. arrow) else WRS_HeaderRes.fs:SetText("Res") end
    if s == "disc" and WRS_HeaderDisc then WRS_HeaderDisc.fs:SetText("Disc" .. arrow) else WRS_HeaderDisc.fs:SetText("Disc") end
    if s == "role" and WRS_HeaderInfo then WRS_HeaderInfo.fs:SetText(WRS_GUI.SelectedTab == "GUILD" and "Guild Name" or "Role Info" .. arrow) else WRS_HeaderInfo.fs:SetText(WRS_GUI.SelectedTab == "GUILD" and "Guild Name" or "Role Info") end
end

function WRS_GUI:UpdateTabCounts()
    if not WorldRaidScanDB or not WorldRaidScanDB.activeRaids then return end
    
    local counts = { RAID=0, DUNGEON=0, GUILD=0, QUEST=0, OTHER=0 }
    
    for _, entry in ipairs(WorldRaidScanDB.activeRaids) do
        local t = entry.type or "OTHER"
        if counts[t] then
            counts[t] = counts[t] + 1
        else
            counts["OTHER"] = counts["OTHER"] + 1
        end
    end
    
    WRS_GUI.TabCounts = counts
    local tabs = WRS_GUI.Tabs
    for _, name in ipairs(tabs) do
        local btn = WRS_GUI.TabButtons[name]
        if btn and type(btn) == "table" then
            -- Reset text to just name
            btn:SetText(name)
            
            -- Use Blizzard's TabResize to handle textures correctly ("pretty")
            -- Custom Safe Resize
            -- Using getglobal for safety in 1.12
            local fs = getglobal(btn:GetName().."Text")
            if fs and fs.GetStringWidth then
                local w = fs:GetStringWidth()
                if w and w > 0 then
                   btn:SetWidth(w + 30)
                else
                   btn:SetWidth(100)
                end
            else
                btn:SetWidth(110)
            end
            
            -- Keep textures if possible (CharacterFrameTabButtonTemplate has Left/Middle/Right)
            -- We don't touch them, just resize the button.
            local left = getglobal(btn:GetName().."Left")
            local middle = getglobal(btn:GetName().."Middle")
            local right = getglobal(btn:GetName().."Right")
            
            -- If textures exist, we might need to adjust them, but usually they are anchored to the button size in the template.
            -- CharacterFrameTabButtonTemplate:
            -- Middle: Point TOPLEFT Left RIGHT; Point TOPRIGHT Right LEFT.
            -- So resizing the button *should* stretch the middle if anchored correctly?
            -- Actually, in 1.12 templates, they often need manual sizing.
            if middle then
                middle:SetWidth(btn:GetWidth() - 32) -- Approx padding for ends
            end
        end
    end
end

function WRS_GUI:UpdateSelection()
    self:UpdateList()
    if self.SelectedEntry then
        self.WhisperButton:Enable()
        if self.SelectedEntry.discordLink then
             self.DiscordButton:Enable()
        else
             self.DiscordButton:Disable()
        end
    else
        self.WhisperButton:Disable()
        self.DiscordButton:Disable()
    end
end

if WRS_GUI.ScrollFrame then
    WRS_GUI.ScrollFrame:SetScript("OnVerticalScroll", function()
        if FauxScrollFrame_OnVerticalScroll then
            FauxScrollFrame_OnVerticalScroll(ROW_HEIGHT, function() WRS_GUI:UpdateList() end)
        end
    end)
else
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: ScrollFrame creation failed!") end
end

if WRS_GUI and WRS_GUI.UpdateLayout then
    WRS_GUI:UpdateLayout("RAID")
end

if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WorldRaidScan: GUI Refactored & Loaded.") end
