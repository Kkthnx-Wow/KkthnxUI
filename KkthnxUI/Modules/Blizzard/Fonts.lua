local K, C, L = unpack(select(2, ...))
if C.Blizzard.ReplaceBlizzardFonts ~= true or K.CheckAddOn("tekticles") then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local MAX_CHANNEL_BUTTONS = MAX_CHANNEL_BUTTONS
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: AchievementFont_Small, CoreAbilityFont, GameTooltipTextSmall, InvoiceFont_Med
-- GLOBALS: CHAT_FONT_HEIGHTS, UNIT_NAME_FONT, DAMAGE_TEXT_FONT, STANDARD_TEXT_FONT
-- GLOBALS: FriendsFont_Small, FriendsFont_Large, FriendsFont_UserText, GameFontHighlightMedium
-- GLOBALS: GameTooltipHeader, SystemFont_Shadow_Large_Outline, NumberFont_OutlineThick_Mono_Small
-- GLOBALS: InvoiceFont_Small, MailFont_Large, NumberFontNormalSmall, QuestFont_Huge, QuestFont_Shadow_Huge
-- GLOBALS: NumberFont_Outline_Huge, NumberFont_Outline_Large, NumberFont_Outline_Med
-- GLOBALS: NumberFont_Shadow_Med, NumberFont_Shadow_Small, QuestFont, QuestFont_Large
-- GLOBALS: PVPInfoTextString, PVPArenaTextString, CombatTextFont, FriendsFont_Normal
-- GLOBALS: QuestFont_Shadow_Small, GameFontHighlightSmallLeft,SystemFont_Shadow_Med2, SystemFont_OutlineThick_Huge4
-- GLOBALS: QuestFont_Super_Huge, QuestMapRewardsFont, ReputationDetailFont, SpellFont_Small, SystemFont_InverseShadow_Small
-- GLOBALS: SystemFont_Large, GameFontNormalMed3, SystemFont_Shadow_Huge1, SystemFont_Med1
-- GLOBALS: SystemFont_Med2, SystemFont_OutlineThick_WTF, SystemFont_Shadow_Huge3, SystemFont_Shadow_Small2, ErrorFont
-- GLOBALS: SystemFont_Med3, SystemFont_OutlineThick_Huge2, SystemFont_Outline_Small
-- GLOBALS: SystemFont_Shadow_Large, SystemFont_Shadow_Med1, SystemFont_Shadow_Med3
-- GLOBALS: SystemFont_Shadow_Outline_Huge2, SystemFont_Shadow_Small, SystemFont_Small
-- GLOBALS: SystemFont_Tiny, Tooltip_Med,  Tooltip_Small, ZoneTextString, SubZoneTextString
-- GLOBALS: WhiteNormalNumberFont, BossEmoteNormalHuge, HelpFrameKnowledgebaseNavBarHomeButtonText, QuestFontNormalSmall
-- GLOBALS: WorldMapTextFont, GameFontNormalSmallLeft, PaperDollTitlesPane

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
end

local KkthnxUIFonts = CreateFrame("Frame", nil, UIParent)
KkthnxUIFonts:RegisterEvent("ADDON_LOADED")
KkthnxUIFonts:SetScript("OnEvent", function(self, event)
	local NORMAL = C.Media.Font
	local COMBAT = C.Media.Combat_Font

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT = NORMAL
	DAMAGE_TEXT_FONT = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	-- Base fonts
	SetFont(AchievementFont_Small, NORMAL, 11)
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE")
	SetFont(CoreAbilityFont, NORMAL, 32)
	SetFont(FriendsFont_Large, NORMAL, 14)
	SetFont(FriendsFont_Normal, NORMAL, 12)
	SetFont(FriendsFont_Small, NORMAL, 11)
	SetFont(FriendsFont_UserText, NORMAL, 11)
	SetFont(Game15Font_o1, NORMAL, 15)
	SetFont(GameFontHighlightMedium, NORMAL, 15)
	SetFont(GameFontNormalMed3, NORMAL, 15)
	SetFont(GameFontNormalSmall, NORMAL, 10)
	SetFont(GameTooltipHeader, NORMAL, 12)
	SetFont(GameTooltipTextSmall, NORMAL, 12)
	SetFont(InvoiceFont_Med, NORMAL, 13)
	SetFont(InvoiceFont_Small, NORMAL, 11)
	SetFont(MailFont_Large, NORMAL, 15)
	SetFont(NumberFont_Outline_Huge, NORMAL, 28, "OUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NORMAL, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NORMAL, 13 * 1.1, "OUTLINE")
	SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL, 12, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, 12)
	SetFont(NumberFont_Shadow_Small, NORMAL, 12)
	SetFont(NumberFontNormalSmall, NORMAL, 11, "OUTLINE")
	SetFont(PVPArenaTextString, NORMAL, 22, "OUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "OUTLINE")
	SetFont(QuestFont_Huge, NORMAL, 17)
	SetFont(QuestFont_Large, NORMAL, 14)
	SetFont(QuestFont_Shadow_Huge, NORMAL, 19)
	SetFont(QuestFont_Shadow_Small, NORMAL, 15)
	SetFont(QuestFont_Super_Huge, NORMAL, 20)
	SetFont(QuestFont, NORMAL, 14)
	SetFont(QuestMapRewardsFont, NORMAL, 12)
	SetFont(ReputationDetailFont, NORMAL, 11)
	SetFont(SpellFont_Small, NORMAL, 11)
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(SystemFont_InverseShadow_Small, NORMAL, 11)
	SetFont(SystemFont_Large, NORMAL, 15)
	SetFont(SystemFont_Med1, NORMAL, 12)
	SetFont(SystemFont_Med2, NORMAL, 14)
	SetFont(SystemFont_Med3, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Outline_Small, NORMAL, 12, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4, NORMAL, 27, "OUTLINE")
	SetFont(SystemFont_OutlineThick_WTF, NORMAL, 31, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge3, NORMAL, 25)
	SetFont(SystemFont_Shadow_Large_Outline, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1, NORMAL, 12)
	SetFont(SystemFont_Shadow_Med2, NORMAL, 13)
	SetFont(SystemFont_Shadow_Med3, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, 11 * 0.9)
	SetFont(SystemFont_Shadow_Small2, NORMAL, 11)
	SetFont(SystemFont_Small, NORMAL, 12)
	SetFont(SystemFont_Tiny, NORMAL, 12)
	SetFont(Tooltip_Med, NORMAL, 12)
	SetFont(Tooltip_Small, NORMAL, 12)
	SetFont(WhiteNormalNumberFont, NORMAL, 11)
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")

	-- Derived fonts
	SetFont(BossEmoteNormalHuge, NORMAL, 27, "OUTLINE")
	SetFont(ErrorFont, NORMAL, 16)
	SetFont(HelpFrameKnowledgebaseNavBarHomeButtonText, NORMAL, 13)
	SetFont(QuestFontNormalSmall, NORMAL, 13)
	SetFont(WorldMapTextFont, NORMAL, 31, "OUTLINE")

	-- Channel list
	for i = 1, MAX_CHANNEL_BUTTONS do
		local f = _G["ChannelButton"..i.."Text"]
		f:SetFontObject(GameFontNormalSmallLeft)
	end

	-- Player title
	for _, butt in pairs(PaperDollTitlesPane.buttons) do butt.text:SetFontObject(GameFontHighlightSmallLeft) end
end)