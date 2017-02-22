local K, C, L = unpack(select(2, ...))
if C.Blizzard.ReplaceBlizzardFonts ~= true or K.CheckAddOn("tekticles") then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local MAX_CHANNEL_BUTTONS = _G.MAX_CHANNEL_BUTTONS
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = _G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
local SetCVar = _G.SetCVar

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
-- GLOBALS: SystemFont_Tiny, Tooltip_Med, Tooltip_Small, ZoneTextString, SubZoneTextString
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
	_G.CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	_G.UNIT_NAME_FONT = NORMAL
	_G.NAMEPLATE_FONT = NORMAL
	_G.DAMAGE_TEXT_FONT = COMBAT
	_G.STANDARD_TEXT_FONT = NORMAL

	if (K.ScreenWidth > 3840) then
		K.KillMenuOption(true, "InterfaceOptionsCombatTextPanelHealing")
		K.KillMenuOption(true, "InterfaceOptionsCombatTextPanelPeriodicDamage")
		K.KillMenuOption(true, "InterfaceOptionsCombatTextPanelPetDamage")
		K.KillMenuOption(true, "InterfaceOptionsCombatTextPanelTargetDamage")
		SetCVar("CombatDamage", 0)
		SetCVar("CombatHealing", 0)
		SetCVar("CombatLogPeriodicSpells", 0)
		SetCVar("PetMeleeDamage", 0)

		local INVISIBLE = [=[Interface\Addons\KkthnxUI\Media\Fonts\Invisible.ttf]=]
		COMBAT = INVISIBLE
		DAMAGE_TEXT_FONT = INVISIBLE
	end

	-- Base fonts
	SetFont(AchievementFont_Small, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(BossEmoteNormalHuge, NORMAL, 27, "OUTLINE")
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE")
	SetFont(CombatTextFontOutline, NORMAL, 48, "OUTLINE")
	SetFont(CoreAbilityFont, NORMAL, 32, nil, 1, 0.82, 0, 0, 0, 0, 1, -1)
	SetFont(DestinyFontHuge, NORMAL, 32)
	SetFont(DestinyFontLarge, NORMAL, 18)
	SetFont(ErrorFont, NORMAL, 16, nil, 60)
	SetFont(Fancy24Font, NORMAL, 22, "OUTLINE")
	SetFont(FriendsFont_Large, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(FriendsFont_Normal, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(FriendsFont_Small, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(FriendsFont_UserText, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(Game11Font_o1, NORMAL, 11, "OUTLINE")
	SetFont(Game12Font_o1, NORMAL, 12, "OUTLINE")
	SetFont(Game13Font_o1, NORMAL, 13, "OUTLINE")
	SetFont(Game13FontShadow, NORMAL, 13)
	SetFont(Game15Font_o1, NORMAL, 16, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(Game18Font, NORMAL, 18)
	SetFont(Game18Font, NORMAL, 18)
	SetFont(Game24Font, NORMAL, 24)
	SetFont(Game24Font, NORMAL, 24) -- there are two of these, good job Blizzard
	SetFont(Game27Font, NORMAL, 27)
	SetFont(Game27Font, NORMAL, 27)
	SetFont(Game30Font, NORMAL, 30)
	SetFont(Game30Font, NORMAL, 30)
	SetFont(Game32Font, NORMAL, 32)
	SetFont(Game32Font, NORMAL, 32)
	SetFont(GameFont_Gigantic, NORMAL, 32, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(GameFontHighlightMedium, NORMAL, 15)
	SetFont(GameFontNormalHuge2, NORMAL, 24)
	SetFont(GameFontNormalMed3,	NORMAL, 15)
	SetFont(GameTooltipHeader, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(GameTooltipTextSmall, NORMAL, 11, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(HelpFrameKnowledgebaseNavBarHomeButtonText, NORMAL, 13, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(InvoiceFont_Med, NORMAL, 12, nil, 0.15, 0.09, 0.04)
	SetFont(InvoiceFont_Small, NORMAL, 11, nil, 0.15, 0.09, 0.04)
	SetFont(MailFont_Large, NORMAL, 15, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
	SetFont(NumberFont_GameNormal, NORMAL, 11)
	SetFont(NumberFont_Normal_Med, NORMAL, 14)
	SetFont(NumberFont_Outline_Huge, NORMAL, 28, "OUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NORMAL, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NORMAL, 12 * 1.1, "OUTLINE")
	SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL, 12, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, 12) -- Chat editbox uses this
	SetFont(NumberFont_Shadow_Small, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(NumberFontNormalSmall, NORMAL, 11, "OUTLINE")
	SetFont(PVPArenaTextString, NORMAL, 22, "OUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "OUTLINE")
	SetFont(QuestFont_Huge, NORMAL, 18, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(QuestFont_Large, NORMAL, 16)
	SetFont(QuestFont_Shadow_Huge, NORMAL, 19, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(QuestFont_Shadow_Small, NORMAL, 14)
	SetFont(QuestFont_Super_Huge, NORMAL, 20, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(QuestFont, NORMAL, 13)
	SetFont(QuestFontNormalSmall, NORMAL, 13, nil, nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(QuestMapRewardsFont, NORMAL, 12, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(ReputationDetailFont, NORMAL, 11, nil, nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SpellFont_Small, NORMAL, 11)
	SetFont(SubZoneTextFont, NORMAL, 18, "OUTLINE")
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(SystemFont_Huge1_Outline, NORMAL, 18, "OUTLINE")
	SetFont(SystemFont_InverseShadow_Small, NORMAL, 11)
	SetFont(SystemFont_Large, NORMAL, 17)
	SetFont(SystemFont_Med1, NORMAL, 12)
	SetFont(SystemFont_Med2, NORMAL, 13 * 1.1, nil, 0.15, 0.09, 0.04)
	SetFont(SystemFont_Med3, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Outline_Small, NORMAL, 12, "OUTLINE")
	SetFont(SystemFont_Outline, NORMAL, 13, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4, NORMAL, 24, "OUTLINE")
	SetFont(SystemFont_OutlineThick_WTF, NORMAL, 32, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Shadow_Huge2, NORMAL, 22)
	SetFont(SystemFont_Shadow_Huge3, NORMAL, 24)
	SetFont(SystemFont_Shadow_Large_Outline, NORMAL, 16, "OUTLINE")
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Large2, NORMAL, 18)
	SetFont(SystemFont_Shadow_Med1_Outline, NORMAL, 12, "OUTLINE")
	SetFont(SystemFont_Shadow_Med1, NORMAL, 12)
	SetFont(SystemFont_Shadow_Med2, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Shadow_Med3, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, 12 * 0.9)
	SetFont(SystemFont_Shadow_Small2, NORMAL, 12 * 0.9)
	SetFont(SystemFont_Small, NORMAL, 12 * 0.9)
	SetFont(SystemFont_Small2, NORMAL, 12 * 0.9)
	SetFont(SystemFont_Tiny, NORMAL, 10)
	SetFont(Tooltip_Med, NORMAL, 12)
	SetFont(Tooltip_Small, NORMAL, 12)
	SetFont(WhiteNormalNumberFont, NORMAL, 11)
	SetFont(WorldMapTextFont, NORMAL, 31, "OUTLINE", 40, nil, nil, 0, 0, 0, 1, -1)
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")

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

	-- Player title
	for _, btn in pairs(PaperDollTitlesPane.buttons) do
		btn.text:SetFontObject(GameFontHighlightSmallLeft)
	end

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
end)

K.Fonts = KkthnxUIFonts