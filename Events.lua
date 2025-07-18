local playerLogin = CreateFrame("Frame");
playerLogin:RegisterEvent("PLAYER_LOGIN")
playerLogin:SetScript("OnEvent", function(self, event)
    if (RETAIL == 1) then
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_SAY")
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_YELL")
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_EMOTE")
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_WHISPER")
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_BOSS_EMOTE")
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "MONSTER_BOSS_WHISPER")
    else
        ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, "CREATURE")
        JoinChannelByName("world", nil, DEFAULT_CHAT_FRAME) -- Not working on retail version
    end

    local msg = ".whc version " .. GetAddOnMetadata("WOW_HC", "Version")
    if (RETAIL == 1) then
        SendChatMessage(msg, "WHISPER", GetDefaultLanguage(), UnitName("player"));
    else
        SendChatMessage(msg);
    end
end)

local function createAchievementButton(frame, name)
    local viewAchButton = CreateFrame("Button", "TabCharFrame" .. name, frame)

    viewAchButton:SetWidth(28)
    viewAchButton:SetHeight(28)

    viewAchButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -24, -41) -- Start position for the first tab
    viewAchButton:SetNormalTexture("Interface\\AddOns\\WOW_HC\\Images\\wow-hardcore-logo-round")

    viewAchButton:EnableMouse(true)

    viewAchButton:SetFrameStrata("HIGH")
    viewAchButton:SetFrameLevel(10)

    local border = viewAchButton:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("CENTER", viewAchButton, "CENTER", 13, -14)
    border:SetWidth(64)
    border:SetHeight(64)

    if (name == "character") then
        viewAchButton:SetScript("OnClick", function()
            WHC.UIShowTabContent("Achievements")
        end)
    else
        viewAchButton:SetScript("OnClick", function()
            WHC.UIShowTabContent("Achievements", UnitName("target"))
        end)
    end

    viewAchButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(viewAchButton, "ANCHOR_CURSOR")
        GameTooltip:SetText("View character achievements", 1, 1, 1)
        GameTooltip:Show()
    end)

    viewAchButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        ResetCursor()
    end)

    viewAchButton:Hide()
    if (WhcAddonSettings.achievementbtn == 1) then
        viewAchButton:Show()
    end

    return viewAchButton
end

function WHC.InitializeAchievementButtons()
    WHC.Frames.AchievementButtonCharacter = createAchievementButton(CharacterFrame, "character")

    local inspectUIEventListener = CreateFrame("Frame")
    inspectUIEventListener:RegisterEvent("ADDON_LOADED")
    inspectUIEventListener:SetScript("OnEvent", function(self, event, addonName)
        addonName = addonName or arg1
        if addonName ~= "Blizzard_InspectUI" then
            return
        end
        inspectUIEventListener:UnregisterEvent("ADDON_LOADED")

        WHC.Frames.AchievementButtonInspect = createAchievementButton(InspectFrame, "inspect")
    end)
end

local function getAuctionButtonText(duration)
    local plural = ""
    if duration ~= 1 then
        plural = "s"
    end

    return duration .. " day" .. plural
end

local auctionHouseEvents = CreateFrame("Frame")
auctionHouseEvents:RegisterEvent("AUCTION_HOUSE_SHOW")
auctionHouseEvents:SetScript("OnEvent", function()
    local short = WhcAddonSettings.auction_short / 60 / 24
    getglobal(AuctionsShortAuctionButton:GetName() .. "Text"):SetText(getAuctionButtonText(short));

    local medium = WhcAddonSettings.auction_medium / 60 / 24
    getglobal(AuctionsMediumAuctionButton:GetName() .. "Text"):SetText(getAuctionButtonText(medium));

    local long = WhcAddonSettings.auction_long / 60 / 24
    getglobal(AuctionsLongAuctionButton:GetName() .. "Text"):SetText(getAuctionButtonText(long));
end)

local xx_MoneyFrame_Update = MoneyFrame_Update
function MoneyFrame_Update(frameName, money)
    if frameName == "AuctionsDepositMoneyFrame" then
        local customDeposit = money * WhcAddonSettings.auction_deposit
        xx_MoneyFrame_Update(frameName, customDeposit)
    else
        xx_MoneyFrame_Update(frameName, money)
    end
end

local function handleChatEvent(arg1)
    local lowerArg = string.lower(arg1)
    if not string.find(lowerArg, "^::whc::") then
        return 1
    end

    if string.find(lowerArg, "^::whc::ticket:") then
        local result = string.gsub(arg1, "::whc::ticket:", "")

        WHC.Frames.UItab["Support"].editBox:SetText(result)
        WHC.Frames.UItab["Support"].createButton:SetText("Update ticket")
        WHC.Frames.UItab["Support"].closeButton:SetText("Cancel ticket")

        return 0
        -- message(result)
    end

    if string.find(lowerArg, "^::whc::achievement:") then
        local result = string.gsub(arg1, "::whc::achievement:", "")

        result = tonumber(result)
        if (WHC.Frames.Achievements[result]) then
            WHC.ToggleAchievement(WHC.Frames.Achievements[result], false)
        else
            -- message("error")
        end

        return 0
        -- message(result)
    end

    if string.find(lowerArg, "^::whc::auction:") then
        local _, _ , variable, result = string.find(lowerArg, "^::whc::auction:(%l+):([%d\.]+)")
        if WhcAddonSettings["auction_"..variable] then
            WhcAddonSettings["auction_"..variable] = tonumber(result)
        end

        return 0
    end

    if string.find(lowerArg, "^::whc::event:") then
        if (WHC.Frames.UIspecialEvent ~= nil) then
            WHC.Frames.UIspecialEvent:SetButtonState("NORMAL")
        end

        return 0
    end

    if string.find(lowerArg, "^::whc::bg:") then
        local _, _, faction, bg, result = string.find(lowerArg, "^::whc::bg:(%l+):(%l+):(%d+)")
        if WHC.Frames.UIBattleGrounds[bg] and WHC.Frames.UIBattleGrounds[bg][faction] then
            WHC.Frames.UIBattleGrounds[bg][faction]:SetText(result)
        end

        return 0
    end

    if string.find(lowerArg, "^::whc::debug:") then
        local result = string.gsub(arg1, "::whc::debug:", "")
        if (RETAIL == 1) then
            SendChatMessage(result, "WHISPER", GetDefaultLanguage(), UnitName("player"));
        else
            SendChatMessage(result);
        end

        return 0
    end

    if string.find(lowerArg, "^::whc::outdated:") then
        if (WHC_ALERT_UPDATE) then
            WHC_ALERT_UPDATE:Show()
        else
            -- Create the URL frame
            local urlFrame = CreateFrame("Frame", "URLFrameUpdate", UIParent, RETAIL_BACKDROP)
            urlFrame:SetWidth(300)
            urlFrame:SetHeight(210)
            urlFrame:SetPoint("TOP", UIParent, "TOP", 0, -154)
            urlFrame:SetBackdrop({
                bgFile = "Interface/RaidFrame/UI-RaidFrame-GroupBg",
                edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                tile = true,
                tileSize = 300,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })

            urlFrame:SetFrameStrata("HIGH")
            urlFrame:SetFrameLevel(10)

            -- Title
            local title = urlFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            title:SetPoint("TOP", urlFrame, "TOP", 0, -20)
            title:SetText(
                "|cffff8000WOW-HC addon|r is out of date.\n\nPlease update it to keep things running smoothly.\n\nCopy and paste this URL\ninto your browser:")
            title:SetWidth(220)

            -- URL input box
            local urlEditBox = CreateFrame("EditBox", "URLInputBox", urlFrame)
            urlEditBox:SetWidth(250)
            urlEditBox:SetHeight(20)
            urlEditBox:SetPoint("TOP", title, "BOTTOM", 0, -20)
            urlEditBox:SetFontObject("ChatFontNormal")
            urlEditBox:SetText("https://wow-hc.com/addon")
            urlEditBox:SetJustifyH("CENTER")
            urlEditBox:SetAutoFocus(false)
            urlEditBox:HighlightText()
            urlEditBox:SetFocus()
            urlEditBox:SetTextColor(1, 0.631, 0.317)
            urlEditBox:SetScript("OnMouseDown", function(self)
                urlEditBox:HighlightText()
                urlEditBox:SetFocus()
            end)

            local closeButton = CreateFrame("Button", "CloseButton", urlFrame, "UIPanelButtonGrayTemplate")
            closeButton:SetWidth(100)
            closeButton:SetHeight(30)
            closeButton:SetPoint("BOTTOMLEFT", urlFrame, "BOTTOMLEFT", 100, 24)
            closeButton:SetText("Close")
            closeButton:SetScript("OnClick", function()
                WHC_ALERT_UPDATE:Hide()
            end)

            urlFrame:Show()
            WHC_ALERT_UPDATE = urlFrame
        end

        return 0
        -- message(result)
    end

    if string.find(lowerArg, "^::whc::difficulty:lead:") then
        local result = string.gsub(arg1, "::whc::difficulty:lead:", "")

        result = tonumber(result)

        if (result == 1) then
            RAID = "Raid |cff06daf0(Dynamic difficulty)|r"
        else
            RAID = "Raid |cffffffff(Normal difficulty)|r"
        end

        if (WHC_ALERT_DIFF) then
            WHC_ALERT_DIFF:Show()
        else
            -- Create the URL frame
            local urlFrame = CreateFrame("Frame", "URLFrameDiff", UIParent, RETAIL_BACKDROP)
            urlFrame:SetWidth(300)
            urlFrame:SetHeight(160)
            urlFrame:SetPoint("TOP", UIParent, "TOP", 0, -154)
            urlFrame:SetBackdrop({
                bgFile = "Interface/RaidFrame/UI-RaidFrame-GroupBg",
                edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                tile = true,
                tileSize = 300,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })

            urlFrame:SetFrameStrata("HIGH")
            urlFrame:SetFrameLevel(10)

            -- Title
            local title = urlFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            title:SetPoint("TOP", urlFrame, "TOP", 0, -20)
            title:SetText(
                "Current raid difficulty:")
            title:SetWidth(220)


            local desc = urlFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            desc:SetPoint("TOP", title, "TOP", 0, -20)
            desc:SetText("Loading..")
            desc:SetFont("Fonts\\FRIZQT__.TTF", 18)
            desc:SetTextColor(0.933, 0.765, 0)

            urlFrame.diff = desc;


            local createButton = CreateFrame("Button", "CreateButtonShop", urlFrame, "UIPanelButtonTemplate")
            createButton:SetWidth(130)
            createButton:SetHeight(35)
            createButton:SetPoint("TOPLEFT", urlFrame, "TOPLEFT", 85, -70)
            createButton:SetText("SWITCH")
            createButton:SetScript("OnClick", function()
                local msg = ".diff"
                if (RETAIL == 1) then
                    SendChatMessage(msg, "WHISPER", GetDefaultLanguage(), UnitName("player"));
                else
                    SendChatMessage(msg);
                end
            end)

            -- Create Close button
            local closeButton = CreateFrame("Button", "CloseButton", urlFrame, "UIPanelButtonGrayTemplate")
            closeButton:SetWidth(100)
            closeButton:SetHeight(30)
            closeButton:SetPoint("TOPLEFT", urlFrame, "TOPLEFT", 100, -110)
            closeButton:SetText("Close")
            closeButton:SetScript("OnClick", function()
                WHC_ALERT_DIFF:Hide()
            end)

            urlFrame:Show()
            WHC_ALERT_DIFF = urlFrame
        end

        if (result == 1) then
            WHC_ALERT_DIFF.diff:SetText("Dynamic")
        else
            WHC_ALERT_DIFF.diff:SetText("Normal")
        end
        return 0
        -- message(result)
    end

    if string.find(lowerArg, "^::whc::difficulty:") then
        local result = string.gsub(arg1, "::whc::difficulty:", "")

        result = tonumber(result)
        if (result == 1) then
            RAID = "Raid |cff06daf0(Dynamic difficulty)|r"
        else
            RAID = "Raid |cffffffff(Normal difficulty)|r"
        end
        return 0
    end

    return 1
end

local function handleMonsterChatEvent(arg1)
    if (strfind(string.lower(arg1), "has died at level")) then

        WHC.LogDeathMessage(arg1)
        return 0
    end

    return 1
end

if (RETAIL == 1) then
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", function(frame, event, message, sender, ...)
        handleMonsterChatEvent(message)
    end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", function(frame, event, message, sender, ...)
       handleMonsterChatEvent(message)
    end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(frame, event, message, sender, ...)
        if (handleChatEvent(message) == 0) then
            return true
        end
    end)
else
    xx_ChatFrame_OnEvent = ChatFrame_OnEvent

    WHC_ALERT_UPDATE = nil
    WHC_ALERT_DIFF = nil
    function ChatFrame_OnEvent(event)
        if (event == "CHAT_MSG_RAID_BOSS_EMOTE" or event == "CHAT_MSG_MONSTER_EMOTE") then
            handleMonsterChatEvent(arg1)
                xx_ChatFrame_OnEvent(event)

        elseif (event == "CHAT_MSG_SYSTEM") then
            if (handleChatEvent(arg1) == 1) then
                xx_ChatFrame_OnEvent(event)
            end
        else
            xx_ChatFrame_OnEvent(event)
        end
    end
end
