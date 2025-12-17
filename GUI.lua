-- GUI.lua
if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WorldRaidScan: Loading GUI...") end

WRS_GUI = {}
WRS_GUI.SelectedTab = "RAID"
WRS_GUI.CollapsedGroups = {} 

-- Function to create the minimap button safely
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
    icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore") 
    
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
        local count = 0
        if WorldRaidScanDB and WorldRaidScanDB.activeRaids then
            count = table.getn(WorldRaidScanDB.activeRaids)
        end
        GameTooltip:AddLine("Active Entries: " .. count, 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Left-Click to open.", 0, 1, 0)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    return btn
end

WRS_GUI.MinimapButton = CreateMinimapButton()

-- Main Frame
WRS_GUI.MainFrame = CreateFrame("Frame", "WRS_MainFrame", UIParent)
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

local closeBtn = CreateFrame("Button", nil, WRS_GUI.MainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local title = WRS_GUI.MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -15)
title:SetText("WorldRaidScan")

function WRS_GUI:Initialize()
    if not WorldRaidScanDB.settings then
        WorldRaidScanDB.settings = { scanWhenClosed = true }
    end
end

-- Settings Button
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
    
    WRS_GUI.SettingsFrame = f
end

-- Tabs
local tabs = {"RAID", "DUNGEON", "GUILD", "QUEST", "OTHER"}
WRS_GUI.TabButtons = {}
WRS_GUI.MainFrame.numTabs = table.getn(tabs)
WRS_GUI.MainFrame.selectedTab = 1

for i, name in ipairs(tabs) do
    -- Naming convention MUST be FrameName.."Tab"..id for PanelTemplates to work (PanelTemplates_UpdateTabs looks for this)
    local tabName = "WRS_MainFrameTab"..i
    local tab = CreateFrame("Button", tabName, WRS_GUI.MainFrame, "CharacterFrameTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(name)
    tab:SetPoint("BOTTOMLEFT", 15 + ((i-1)*85), -30)
    tab:SetScript("OnClick", function() 
        PanelTemplates_SetTab(WRS_GUI.MainFrame, this:GetID())
        WRS_GUI:SelectTab(name) 
    end)
    WRS_GUI.TabButtons[name] = tab
end

-- Initialize the visual state of tabs
PanelTemplates_SetTab(WRS_GUI.MainFrame, 1)

-- ScrollFrame (Global WRS_ScrollFrame used by FauxScrollFrame)
WRS_GUI.ScrollFrame = CreateFrame("ScrollFrame", "WRS_ScrollFrame", WRS_GUI.MainFrame, "FauxScrollFrameTemplate")
WRS_GUI.ScrollFrame:SetPoint("TOPLEFT", 15, -45)
WRS_GUI.ScrollFrame:SetPoint("BOTTOMRIGHT", -35, 55)

WRS_GUI.EntryButtons = {}
local MAX_ROWS = 12
local ROW_HEIGHT = 20

for i=1, MAX_ROWS do
    local btn = CreateFrame("Button", "WRS_Entry"..i, WRS_GUI.MainFrame)
    btn:SetHeight(ROW_HEIGHT)
    btn:SetWidth(550)
    btn:SetPoint("TOPLEFT", 15, -45 - ((i-1)*ROW_HEIGHT))
    
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    
    btn.expandIcon = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.expandIcon:SetPoint("LEFT", 5, 0)
    btn.expandIcon:SetText("+")
    btn.expandIcon:Hide()
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("LEFT", 20, 0)
    btn.text:SetJustifyH("LEFT")
    
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

-- Action Buttons
local whisperBtn = CreateFrame("Button", "WRS_WhisperButton", WRS_GUI.MainFrame, "UIPanelButtonTemplate")
whisperBtn:SetWidth(80)
whisperBtn:SetHeight(24)
whisperBtn:SetPoint("BOTTOMRIGHT", -120, 15)
whisperBtn:SetText("Whisper")
whisperBtn:Disable()
whisperBtn:SetScript("OnClick", function()
    if WRS_GUI.SelectedEntry then
        ChatFrame_OpenChat("/w " .. WRS_GUI.SelectedEntry.sender .. " ")
    end
end)
WRS_GUI.WhisperButton = whisperBtn

local removeBtn = CreateFrame("Button", "WRS_RemoveButton", WRS_GUI.MainFrame, "UIPanelButtonTemplate")
removeBtn:SetWidth(80)
removeBtn:SetHeight(24)
removeBtn:SetPoint("BOTTOMRIGHT", -30, 15)
removeBtn:SetText("Remove")
removeBtn:Disable()
removeBtn:SetScript("OnClick", function()
    if WRS_GUI.SelectedEntry and WorldRaidScanDB.activeRaids then
        for i, entry in ipairs(WorldRaidScanDB.activeRaids) do
            if entry == WRS_GUI.SelectedEntry then
                table.remove(WorldRaidScanDB.activeRaids, i)
                break
            end
        end
        WRS_GUI.SelectedEntry = nil
        WRS_GUI:UpdateSelection()
    end
end)
WRS_GUI.RemoveButton = removeBtn

function WRS_GUI:Toggle()
    DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: Toggle called.")
    if WRS_GUI.MainFrame:IsVisible() then
        WRS_GUI.MainFrame:Hide()
    else
        WRS_GUI.MainFrame:Show()
        self:UpdateList()
    end
end

function WRS_GUI:SelectTab(tabName)
    self.SelectedTab = tabName
    self.SelectedEntry = nil
    self:UpdateSelection()
    
    for name, btn in pairs(self.TabButtons) do
        if name == tabName then
            if PanelTemplates_SelectTab then PanelTemplates_SelectTab(btn) end
        else
            if PanelTemplates_DeselectTab then PanelTemplates_DeselectTab(btn) end
        end
    end
    
    -- Reset Scroll
    if WRS_GUI.ScrollFrame and FauxScrollFrame_SetOffset and WRS_ScrollFrameScrollBar then
        FauxScrollFrame_SetOffset(WRS_GUI.ScrollFrame, 0)
        WRS_ScrollFrameScrollBar:SetValue(0)
    end
    
    self:UpdateList()
end

function WRS_GUI:GetDisplayList()
    -- ... (Logic unchanged, just omitted for brevity in thought but tool needs full content usually?
    -- No, I can use replace_file_content safely if I match context.
    -- Wait, this tool REPLACES, I need to provide full function body if I am replacing the block.)
    
    if not WorldRaidScanDB or not WorldRaidScanDB.activeRaids then return {} end
    local groups = {}
    for _, entry in ipairs(WorldRaidScanDB.activeRaids) do
        if entry.type == self.SelectedTab then
            local key = entry.raid or "Others"
            if not groups[key] then groups[key] = { items={} } end
            table.insert(groups[key].items, entry)
        end
    end
    for k, g in pairs(groups) do
        table.sort(g.items, function(a,b) return a.timestamp > b.timestamp end)
    end
    local keys = {}
    for k in pairs(groups) do table.insert(keys, k) end
    table.sort(keys)
    local display = {}
    for _, key in ipairs(keys) do
        local g = groups[key]
        local count = table.getn(g.items)
        local isCollapsed = WRS_GUI.CollapsedGroups[key]
        table.insert(display, { isHeader=true, key=key, text=key.." ("..count..")", collapsed=isCollapsed })
        if not isCollapsed then
            for _, item in ipairs(g.items) do
                table.insert(display, { isHeader=false, data=item })
            end
        end
    end
    return display
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
                btn.text:SetText("|cffffd100" .. item.text .. "|r")
                btn.expandIcon:Show()
                btn.expandIcon:SetText(item.collapsed and "+" or "-")
                btn.text:SetPoint("LEFT", 20, 0)
                btn:SetNormalTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
            else
                btn.isHeader = false
                btn.data = item.data
                btn.expandIcon:Hide()
                local entry = item.data
                local prefix = ""
                if entry.groupSize then prefix = prefix .. entry.groupSize .. "m " end
                btn.text:SetText(string.format("   |cffffffff%s|r%s: %s", prefix, entry.sender, entry.message))
                btn.text:SetPoint("LEFT", 10, 0)
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
end

function WRS_GUI:UpdateSelection()
    self:UpdateList()
    if self.SelectedEntry then
        self.WhisperButton:Enable()
        self.RemoveButton:Enable()
    else
        self.WhisperButton:Disable()
        self.RemoveButton:Disable()
    end
end

if WRS_GUI.ScrollFrame then
    WRS_GUI.ScrollFrame:SetScript("OnVerticalScroll", function()
        FauxScrollFrame_OnVerticalScroll(ROW_HEIGHT, function() WRS_GUI:UpdateList() end)
    end)
else
    DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: ScrollFrame creation failed!")
end

if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("WorldRaidScan: GUI Refactored & Loaded.") end
