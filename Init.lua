local version = GetBuildInfo()

RETAIL = 1
if (version == "1.12.0" or version == "1.12.1") then
    RETAIL = 0
end

RETAIL_BACKDROP = nil
if (RETAIL == 1) then
    RETAIL_BACKDROP = "BackdropTemplate"
end

WHC = CreateFrame("Frame", "WowHcUIFrame", UIParent, RETAIL_BACKDROP)
-- Define the frame names here so my IDE can do a usage search.
WHC.Frames = {
    UItabHeader = nil,
    UItab = nil,
    MapIcon = nil,
    DeathLogFrame = nil,
    Achievements = nil,
    AchievementButtonCharacter = nil,
    AchievementButtonInspect = nil,
    UIBattleGrounds = {
        ws = nil,
        ab = nil,
        av = nil,
    },
    UIspecialEvent = nil
}

WHC:RegisterEvent("ADDON_LOADED")
WHC:SetScript("OnEvent", function(self, event, addonName)
    addonName = addonName or arg1
    if addonName ~= "WOW_HC" then
        return
    end
    WHC:UnregisterEvent("ADDON_LOADED")

    RETAIL = 1
    local version = GetBuildInfo()
    if (version == "1.12.0" or version == "1.12.1") then
        RETAIL = 0
    end

    RETAIL_BACKDROP = nil
    if (RETAIL == 1) then
        RETAIL_BACKDROP = "BackdropTemplate"
    end

    WHC.player = {
        name = UnitName("player"),
        class = UnitClass("player"),
    }

    local locale = GetLocale()
    WHC.client = {
        isEnglish = locale == "enUS" or locale == "enGB"
    }

    WHC.sounds = {
        checkBoxOn = RETAIL == 0 and "igMainMenuOptionCheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
        checkBoxOff = RETAIL == 0 and "igMainMenuOptionCheckBoxOff" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF,
        openFrame = RETAIL == 0 and "igCharacterInfoOpen" or SOUNDKIT.IG_CHARACTER_INFO_OPEN,
        closeFrame = RETAIL == 0 and "igCharacterInfoClose" or SOUNDKIT.IG_CHARACTER_INFO_CLOSE,
        selectTab = RETAIL == 0 and "igCharacterInfoTab" or SOUNDKIT.IG_CHARACTER_INFO_TAB,
    }

    WhcAddonSettings = WhcAddonSettings or {}
    -- Ensure the specific setting exists and has a default value
    WhcAddonSettings.minimapicon = WhcAddonSettings.minimapicon or 1
    WhcAddonSettings.achievementbtn = WhcAddonSettings.achievementbtn or 1
    WhcAddonSettings.splash = WhcAddonSettings.splash or 0
    WhcAddonSettings.minimapX = WhcAddonSettings.minimapX or 0
    WhcAddonSettings.minimapY = WhcAddonSettings.minimapY or 0
    WhcAddonSettings.auction_short = WhcAddonSettings.auction_short or 0
    WhcAddonSettings.auction_medium = WhcAddonSettings.auction_medium or 0
    WhcAddonSettings.auction_long = WhcAddonSettings.auction_long or 0
    WhcAddonSettings.auction_deposit = WhcAddonSettings.auction_deposit or 0
    WhcAddonSettings.recentDeaths = WhcAddonSettings.recentDeaths or 1

    WhcAchievementSettings = WhcAchievementSettings or {}
    WhcAchievementSettings.blockInvites = WhcAchievementSettings.blockInvites or 0
    WhcAchievementSettings.blockTrades = WhcAchievementSettings.blockTrades or 0
    WhcAchievementSettings.blockAuctionSell = WhcAchievementSettings.blockAuctionSell or 0
    WhcAchievementSettings.blockAuctionBuy = WhcAchievementSettings.blockAuctionBuy or 0
    WhcAchievementSettings.blockRepair = WhcAchievementSettings.blockRepair or 0
    WhcAchievementSettings.blockTaxiService = WhcAchievementSettings.blockTaxiService or 0
    WhcAchievementSettings.blockMagicItems = WhcAchievementSettings.blockMagicItems or 0
    WhcAchievementSettings.blockMagicItemsTooltip = WhcAchievementSettings.blockMagicItemsTooltip or 0
    WhcAchievementSettings.blockArmorItems = WhcAchievementSettings.blockArmorItems or 0
    WhcAchievementSettings.blockArmorItemsTooltip = WhcAchievementSettings.blockArmorItemsTooltip or 0
    WhcAchievementSettings.blockNonSelfMadeItems = WhcAchievementSettings.blockNonSelfMadeItems or 0
    WhcAchievementSettings.blockNonSelfMadeItemsTooltip = WhcAchievementSettings.blockNonSelfMadeItemsTooltip or 0
    WhcAchievementSettings.blockMailItems = WhcAchievementSettings.blockMailItems or 0
    WhcAchievementSettings.blockRidingSkill = WhcAchievementSettings.blockRidingSkill or 0
    WhcAchievementSettings.blockProfessions = WhcAchievementSettings.blockProfessions or 0
    WhcAchievementSettings.blockQuests = WhcAchievementSettings.blockQuests or 0
    WhcAchievementSettings.blockTalents = WhcAchievementSettings.blockTalents or 0
    WhcAchievementSettings.onlyKillDemons = WhcAchievementSettings.onlyKillDemons or 0
    WhcAchievementSettings.onlyKillUndead = WhcAchievementSettings.onlyKillUndead or 0
    WhcAchievementSettings.onlyKillBoars = WhcAchievementSettings.onlyKillBoars or 0

    WHC.InitializeUI()
    WHC.InitializeMinimapIcon()
    WHC.InitializeDeathLogFrame()
    WHC.InitializeAchievementButtons()
    WHC.InitializeSupport()

    if (WhcAddonSettings.minimapicon == 1) then
        WHC.Frames.MapIcon:Show()
    else
        WHC.Frames.MapIcon:Hide()
    end

    if (WhcAddonSettings.recentDeaths == 1) then
        WHC.Frames.DeathLogFrame:Show()
    else
        WHC.Frames.DeathLogFrame:Hide()
    end

    local msg = ".whc version " .. GetAddOnMetadata("WOW_HC", "Version")
    if (RETAIL == 1) then
        SendChatMessage(msg, "WHISPER", GetDefaultLanguage(), UnitName("player"));
    else
        SendChatMessage(msg);
    end

    if (WhcAddonSettings.splash == 0) then
        WhcAddonSettings.splash = 1

        WHC.UIShowTabContent("General")
    end

    WHC.SetBlockInvites()
    WHC.SetBlockTrades()
    WHC.SetBlockAuctionSell()
    WHC.SetBlockAuctionBuy()
    WHC.SetBlockRepair()
    WHC.SetBlockTaxiService()
    WHC.SetBlockMailItems()
    WHC.SetBlockTrainSkill()
    WHC.SetBlockQuests()
    WHC.SetWarningOnlyKill()
    if RETAIL == 0 then
        WHC.SetBlockEquipItems()
    end
end)
