local K, C, _ = unpack(select(2, ...))
if C.Blizzard.ReplaceBlizzardFonts ~= true or K.CheckAddOn("tekticles") then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local SetCVar = _G.SetCVar

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CHAT_FONT_HEIGHTS, GameTooltipHeader, NumberFont_OutlineThick_Mono_Small, SystemFont_Shadow_Large_Outline
-- GLOBALS: DestinyFontHuge, Game24Font, SystemFont_Huge1, SystemFont_Huge1_Outline, Fancy22Font, Fancy24Font, Game30Font
-- GLOBALS: FriendsFont_Large, FriendsFont_UserText, QuestFont_Shadow_Huge, QuestFont_Shadow_Small, SystemFont_Outline
-- GLOBALS: GameFontNormal, GameFontNormalSmallLeft, PaperDollTitlesPane, GameFontHighlightSmallLeft
-- GLOBALS: GameFontNormalHuge2, Game15Font_o1, Game13FontShadow, NumberFontNormalSmall, WorldMapFrameNavBarHomeButton
-- GLOBALS: GameFontNormalMed2, BossEmoteNormalHuge, GameFontHighlightMedium, GameFontNormalLarge2, QuestFont_Enormous
-- GLOBALS: MailFont_Large, InvoiceFont_Med, InvoiceFont_Small, AchievementFont_Small, ReputationDetailFont
-- GLOBALS: NumberFont_Outline_Huge, NumberFont_Outline_Large, NumberFont_Outline_Med, NumberFont_Shadow_Med
-- GLOBALS: NumberFont_Shadow_Small, QuestFont, SystemFont_Large, GameFontNormalMed3, SystemFont_Shadow_Huge1
-- GLOBALS: STANDARD_TEXT_FONT, DAMAGE_TEXT_FONT, UNIT_NAME_FONT, MAX_CHANNEL_BUTTONS
-- GLOBALS: SubZoneTextString, PVPInfoTextString, PVPArenaTextString, CombatTextFont, FriendsFont_Normal, FriendsFont_Small
-- GLOBALS: SystemFont_Med1, SystemFont_Med3, QuestFont_Large, SystemFont_OutlineThick_Huge2, SystemFont_Outline_Small
-- GLOBALS: SystemFont_OutlineThick_WTF, SubZoneTextFont, QuestFont_Super_Huge, QuestFont_Huge, CoreAbilityFont
-- GLOBALS: SystemFont_Shadow_Large, SystemFont_Shadow_Med1, SystemFont_Shadow_Med3, SystemFont_Shadow_Outline_Huge2
-- GLOBALS: SystemFont_Shadow_Med2, WhiteNormalNumberFont, GameFontHighlightSmall2, Game18Font, GameFontNormalSmall2
-- GLOBALS: SystemFont_Shadow_Small, SystemFont_Small, SystemFont_Tiny, Tooltip_Med, Tooltip_Small, ZoneTextString

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local function UpdateBlizzardFonts()
    local NORMAL_FONT = C.Media.Font or [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]]
    local COMBAT_FONT = C.Media.Combat_Font or [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]]
		local BLANK_FONT = C.Media.Blank_Font or [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]]

    local SHADOW_COLOR = 0, 0, 0, 1
    local NORMAL_OFFSET = 1.25, -1.25
    local BIG_OFFSET = 2, -2

    CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

    UNIT_NAME_FONT = NORMAL_FONT
    DAMAGE_TEXT_FONT = COMBAT_FONT
    STANDARD_TEXT_FONT = NORMAL_FONT

    if (K.ScreenWidth > 3840) then
        SetCVar("floatingcombattextcombatdamage", 0)
        SetCVar("floatingcombattextcombathealing", 0)
        SetCVar("floatingcombattextcombatlogperiodicspells", 0)
        SetCVar("floatingcombattextpetmeleedamage", 0)

        -- set an invisible font for xp, honor kill, etc
        COMBAT_FONT = BLANK_FONT
    end

    -- Base font
    SetFont(AchievementFont_Small, NORMAL_FONT, C.General.FontSize) -- Achiev dates
    SetFont(BossEmoteNormalHuge, NORMAL_FONT, 24) -- Talent Title
    SetFont(CombatTextFont, COMBAT_FONT, 200, "OUTLINE") -- number here just increase the font quality.
    SetFont(CoreAbilityFont, NORMAL_FONT, 26) -- Core abilities(title)
    SetFont(DestinyFontHuge, NORMAL_FONT, 20, nil, SHADOW_COLOR, BIG_OFFSET) -- Garrison Mission Report
    SetFont(Fancy22Font, NORMAL_FONT, 20) -- Talking frame Title font
    SetFont(Fancy24Font, NORMAL_FONT, 20) -- Artifact frame - weapon name
    SetFont(FriendsFont_Large, NORMAL_FONT, C.General.FontSize)
    SetFont(FriendsFont_Normal, NORMAL_FONT, C.General.FontSize)
    SetFont(FriendsFont_Small, NORMAL_FONT, C.General.FontSize)
    SetFont(FriendsFont_UserText, NORMAL_FONT, C.General.FontSize)
    SetFont(Game13FontShadow, NORMAL_FONT, 14) -- InspectPvpFrame
    SetFont(Game15Font_o1, NORMAL_FONT, 15) -- CharacterStatsPane (ItemLevelFrame)
    SetFont(Game18Font, NORMAL_FONT, 18) -- MissionUI Bonus Chance
    SetFont(Game24Font, NORMAL_FONT, 24) -- Garrison Mission level (in detail frame)
    SetFont(Game30Font, NORMAL_FONT, 28) -- Mission Level
    SetFont(GameFontHighlightMedium, NORMAL_FONT, 15)
    SetFont(GameFontHighlightMedium, NORMAL_FONT, 15) -- Fix QuestLog Title mouseover
    SetFont(GameFontHighlightSmall2, NORMAL_FONT, C.General.FontSize) -- Skill or Recipe description on TradeSkill frame
    SetFont(GameFontNormalHuge2, NORMAL_FONT, 22) -- Mythic weekly best dungeon name
    SetFont(GameFontNormalLarge2, NORMAL_FONT, 15) -- Garrison Follower Names
    SetFont(GameFontNormalMed2, NORMAL_FONT, C.General.FontSize * 1.1) -- Quest tracker
    SetFont(GameFontNormalMed3, NORMAL_FONT, 15)
    SetFont(GameFontNormalSmall2, NORMAL_FONT, 12)			 					 	 -- MissionUI Followers names
    SetFont(GameTooltipHeader, NORMAL_FONT, C.General.FontSize)
    SetFont(InvoiceFont_Med, NORMAL_FONT, 12) -- mail
    SetFont(InvoiceFont_Small, NORMAL_FONT, C.General.FontSize)			 -- mail
    SetFont(MailFont_Large, NORMAL_FONT, 14) -- mail
    SetFont(NumberFont_Outline_Huge, NORMAL_FONT, 28, "OUTLINE", 28)
    SetFont(NumberFont_Outline_Large, NORMAL_FONT, 15, "OUTLINE")
    SetFont(NumberFont_Outline_Med, NORMAL_FONT, C.General.FontSize * 1.1, "OUTLINE")
    SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL_FONT, C.General.FontSize, "OUTLINE")
    SetFont(NumberFont_Shadow_Med, NORMAL_FONT, C.General.FontSize) -- chat editbox uses this
    SetFont(NumberFont_Shadow_Small, NORMAL_FONT, C.General.FontSize)
    SetFont(NumberFontNormalSmall, NORMAL_FONT, 11, "OUTLINE") -- Calendar, EncounterJournal
    SetFont(PVPArenaTextString, NORMAL_FONT, 22, "OUTLINE")
    SetFont(PVPInfoTextString, NORMAL_FONT, 22, "OUTLINE")
    SetFont(QuestFont_Enormous, NORMAL_FONT, 24, nil, SHADOW_COLOR, NORMAL_OFFSET) -- Garrison Titles
    SetFont(QuestFont_Huge, NORMAL_FONT, 15, nil, SHADOW_COLOR, BIG_OFFSET) -- Quest rewards title(Rewards)
    SetFont(QuestFont_Large, NORMAL_FONT, 14)
    SetFont(QuestFont_Shadow_Huge, NORMAL_FONT, 15, nil, SHADOW_COLOR, NORMAL_OFFSET) -- Quest Title
    SetFont(QuestFont_Shadow_Small, NORMAL_FONT, 14, nil, SHADOW_COLOR, NORMAL_OFFSET)
    SetFont(QuestFont_Super_Huge, NORMAL_FONT, 22, nil, SHADOW_COLOR, BIG_OFFSET)
    SetFont(QuestFont, NORMAL_FONT, C.General.FontSize)
    SetFont(ReputationDetailFont, NORMAL_FONT, C.General.FontSize) -- Rep Desc when clicking a rep
    SetFont(SubZoneTextFont, NORMAL_FONT, 24, "OUTLINE") -- World Map(SubZone)
    SetFont(SubZoneTextString, NORMAL_FONT, 25, "OUTLINE")
    SetFont(SystemFont_Huge1_Outline, NORMAL_FONT, 18, "OUTLINE") -- Garrison Mission Chance
    SetFont(SystemFont_Huge1, NORMAL_FONT, 20) -- Garrison Mission XP
    SetFont(SystemFont_Large, NORMAL_FONT, 15)
    SetFont(SystemFont_Med1, NORMAL_FONT, C.General.FontSize)
    SetFont(SystemFont_Med3, NORMAL_FONT, C.General.FontSize * 1.1)
    SetFont(SystemFont_Outline_Small, NORMAL_FONT, C.General.FontSize, "OUTLINE")
    SetFont(SystemFont_Outline, NORMAL_FONT, 13, "OUTLINE") -- Pet level on World map
    SetFont(SystemFont_OutlineThick_Huge2, NORMAL_FONT, 20, "OUTLINE")
    SetFont(SystemFont_OutlineThick_WTF, NORMAL_FONT, 32, "OUTLINE") -- World Map
    SetFont(SystemFont_Shadow_Huge1, NORMAL_FONT, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
    SetFont(SystemFont_Shadow_Large_Outline,	NORMAL_FONT, 20, "OUTLINE")
    SetFont(SystemFont_Shadow_Large, NORMAL_FONT, 15)
    SetFont(SystemFont_Shadow_Med1, NORMAL_FONT, C.General.FontSize)
    SetFont(SystemFont_Shadow_Med2, NORMAL_FONT, 15)	 -- Shows Order resourses on OrderHallTalentFrame
    SetFont(SystemFont_Shadow_Med3, NORMAL_FONT, C.General.FontSize * 1.1)
    SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL_FONT, 20, "OUTLINE")
    SetFont(SystemFont_Shadow_Small, NORMAL_FONT, C.General.FontSize * 0.9)
    SetFont(SystemFont_Small, NORMAL_FONT, C.General.FontSize)
    SetFont(SystemFont_Tiny, NORMAL_FONT, C.General.FontSize)
    SetFont(Tooltip_Med, NORMAL_FONT, C.General.FontSize)
    SetFont(Tooltip_Small, NORMAL_FONT, C.General.FontSize)
    SetFont(WhiteNormalNumberFont, NORMAL_FONT, C.General.FontSize) -- Statusbar Numbers on TradeSkill frame
    SetFont(ZoneTextString, NORMAL_FONT, 32, "OUTLINE")

    -- Fix Navbar font button text
    WorldMapFrameNavBarHomeButton.text:SetFontObject(SystemFont_Shadow_Med1)

    -- Fix issue with labels not following changes to GameFontNormal as they should
    local function SetLabelFontObject(self, btnIndex)
        local button = self.CategoryButtons[btnIndex]
        if button then
            button.Label:SetFontObject(GameFontNormal)
        end
    end
    hooksecurefunc("LFGListCategorySelection_AddButton", SetLabelFontObject)

    -- I have no idea why the channel list is getting fucked up
    -- but re-setting the font obj seems to fix it
    for i = 1, MAX_CHANNEL_BUTTONS do
        _G["ChannelButton"..i.."Text"]:SetFontObject(GameFontNormalSmallLeft)
    end

    for _, btn in pairs(PaperDollTitlesPane.buttons) do
        btn.text:SetFontObject(GameFontHighlightSmallLeft)
    end

    -- Fix help frame category buttons, NFI why they need fixing
    for i = 1, 6 do
        _G["HelpFrameButton"..i.."Text"]:SetFontObject(GameFontNormalMed3)
    end
end

-- New Fonts Need to be set as soon as possible...
UpdateBlizzardFonts()