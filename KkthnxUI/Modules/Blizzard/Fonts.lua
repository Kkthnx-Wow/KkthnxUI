local K, C, L = unpack(select(2, ...))
if C.Blizzard.ReplaceBlizzardFonts ~= true or K.CheckAddOn("tekticles") then return end

-- Lua API
local _G = _G

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local MAX_CHANNEL_BUTTONS = _G.MAX_CHANNEL_BUTTONS
local SetCVar = _G.SetCVar
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = _G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CHAT_FONT_HEIGHTS, UNIT_NAME_FONT, DAMAGE_TEXT_FONT, STANDARD_TEXT_FONT
-- GLOBALS: FriendsFont_Small, FriendsFont_Large, FriendsFont_UserText, GameFontHighlightMedium
-- GLOBALS: GameFontNormalSmallLeft, Game13FontShadow, Game15Font_o1
-- GLOBALS: GameTooltipHeader, SystemFont_Shadow_Large_Outline, NumberFont_OutlineThick_Mono_Small
-- GLOBALS: NumberFont_Outline_Huge, NumberFont_Outline_Large, NumberFont_Outline_Med
-- GLOBALS: NumberFont_Shadow_Med, NumberFont_Shadow_Small, QuestFont, QuestFont_Large
-- GLOBALS: PVPInfoTextString, PVPArenaTextString, CombatTextFont, FriendsFont_Normal
-- GLOBALS: SystemFont_Large, GameFontNormalMed3, SystemFont_Shadow_Huge1, SystemFont_Med1
-- GLOBALS: SystemFont_Med3, SystemFont_OutlineThick_Huge2, SystemFont_Outline_Small
-- GLOBALS: SystemFont_Shadow_Large, SystemFont_Shadow_Med1, SystemFont_Shadow_Med3
-- GLOBALS: SystemFont_Shadow_Outline_Huge2, SystemFont_Shadow_Small, SystemFont_Small
-- GLOBALS: SystemFont_Tiny, Tooltip_Med, Tooltip_Small, ZoneTextString, SubZoneTextString
-- GLOBALS: WorldMapFrameNavBarHomeButton, GameFontNormal, PaperDollTitlesPane, GameFontHighlightSmallLeft

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
end

local UpdateBlizzardFonts = CreateFrame("Frame", nil, UIParent)
UpdateBlizzardFonts:RegisterEvent("ADDON_LOADED")
UpdateBlizzardFonts:SetScript("OnEvent", function(self, event)
	local NORMAL = C.Media.Font
	local COMBAT = C.Media.Combat_Font

	_G.CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	_G.UNIT_NAME_FONT = NORMAL
	_G.NAMEPLATE_FONT = NORMAL
	_G.DAMAGE_TEXT_FONT = COMBAT
	_G.STANDARD_TEXT_FONT = NORMAL

	if (K.ScreenWidth > 3840) then
		SetCVar("floatingcombattextcombatlogperiodicspells",0)
		SetCVar("floatingcombattextpetmeleedamage",0)
		SetCVar("floatingcombattextcombatdamage",0)
		SetCVar("floatingcombattextcombathealing",0)

		-- set an invisible font for xp, honor kill, etc
		COMBAT = [=[Interface\Addons\KkthnxUI\Media\Fonts\Invisible.ttf]=]
	end

	-- Base fonts
	SetFont(GameTooltipHeader, NORMAL, C.General.FontSize)
	SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL, C.General.FontSize, "OUTLINE")
	SetFont(SystemFont_Shadow_Large_Outline,	NORMAL, 20, "OUTLINE")
	SetFont(NumberFont_Outline_Huge, NORMAL, 28, "OUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NORMAL, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NORMAL, C.General.FontSize * 1.1, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, C.General.FontSize) -- chat editbox uses this
	SetFont(NumberFont_Shadow_Small, NORMAL, C.General.FontSize)
	SetFont(QuestFont, NORMAL, C.General.FontSize)
	SetFont(QuestFont_Large, NORMAL, 14)
	SetFont(SystemFont_Large, NORMAL, 15)
	SetFont(GameFontNormalMed3, NORMAL, 15)
	SetFont(GameFontHighlightMedium, NORMAL, 15)
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Med1, NORMAL, C.General.FontSize)
	SetFont(SystemFont_Med3, NORMAL, C.General.FontSize * 1.1)
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small, NORMAL, C.General.FontSize, "OUTLINE")
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1, NORMAL, C.General.FontSize)
	SetFont(SystemFont_Shadow_Med3, NORMAL, C.General.FontSize*1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, C.General.FontSize * 0.9)
	SetFont(SystemFont_Small, NORMAL, C.General.FontSize)
	SetFont(SystemFont_Tiny, NORMAL, C.General.FontSize)
	SetFont(Tooltip_Med, NORMAL, C.General.FontSize)
	SetFont(Tooltip_Small, NORMAL, C.General.FontSize)
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "OUTLINE")
	SetFont(PVPArenaTextString, NORMAL, 22, "OUTLINE")
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE") -- number here just increase the font quality.
	SetFont(FriendsFont_Normal, NORMAL, C.General.FontSize)
	SetFont(FriendsFont_Small, NORMAL, C.General.FontSize)
	SetFont(FriendsFont_Large, NORMAL, C.General.FontSize)
	SetFont(FriendsFont_UserText, NORMAL, C.General.FontSize)
	SetFont(Game13FontShadow, NORMAL, 14)
	SetFont(Game15Font_o1, NORMAL, 16, "OUTLINE")

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
end)

K.Fonts = UpdateBlizzardFonts