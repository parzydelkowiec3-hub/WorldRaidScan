-- WorldRaidScan.lua

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_SAY")
-- Maybe Guild too?
frame:RegisterEvent("CHAT_MSG_GUILD")

frame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if not WorldRaidScanDB then
            WorldRaidScanDB = {}
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00WorldRaidScan|r v1.0 by |cffffd100Tuziak|r loaded.")
            DEFAULT_CHAT_FRAME:AddMessage("Type |cffffd100/wrs|r or click the minimap button to open.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00WorldRaidScan|r v1.0 by |cffffd100Tuziak|r loaded.")
            DEFAULT_CHAT_FRAME:AddMessage("Type |cffffd100/wrs|r or click the minimap button to open.")
        end
        
        -- Initialize default values if needed
        if not WorldRaidScanDB.settings then
            WorldRaidScanDB.settings = {
                enabled = true,
                scanInterval = 60,
                scanWhenClosed = true
            }
        end
        if WRS_GUI then WRS_GUI:Initialize() end
        
    elseif event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_GUILD" then
        if WorldRaidScanDB and WorldRaidScanDB.settings and WorldRaidScanDB.settings.enabled then
            -- Check scanWhenClosed logic
            local scan = true
            if not WorldRaidScanDB.settings.scanWhenClosed and WRS_MainFrame and not WRS_MainFrame:IsVisible() then
                scan = false
            end
            
            if scan and WRS_Scanner then
                WRS_Scanner:ProcessMessage(arg1, arg2, event)
            end
        end
    end
end)

-- Slash Commands
SLASH_WORLDRAIDSCAN1 = "/wrs"
SLASH_WORLDRAIDSCAN2 = "/worldraidscan"
SlashCmdList["WORLDRAIDSCAN"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: Slash command received.")
    if WRS_GUI then
        DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: WRS_GUI exists. Toggling...")
        if WRS_GUI.Toggle then
            WRS_GUI:Toggle()
        else
             DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: WRS_GUI.Toggle function is missing!")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("WRS Debug: WRS_GUI is nil! GUI.lua failed to load.")
    end
end
