local K, C, L, _ = select(2, ...):unpack()
if C.General.ReplaceBlizzardFonts ~= true then return end

local KkthnxUIFonts = CreateFrame("Frame", "KkthnxUIFonts", UIParent)

local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
end

KkthnxUIFonts:RegisterEvent("ADDON_LOADED")
KkthnxUIFonts:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "KkthnxUI") then return end

	local NORMAL = C.Media.Font
	local COMBAT = C.Media.Combat_Font
	local NUMBER = C.Media.Font

	if (K.ScreenWidth > 3840) then
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells", 0)
		SetCVar("PetMeleeDamage", 0)
		SetCVar("CombatDamage", 0)
		SetCVar("CombatHealing", 0)

		COMBAT = C.Media.Blank_Font
		DAMAGE_TEXT_FONT = C.Media.Blank_Font
	end

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT = NORMAL
	DAMAGE_TEXT_FONT = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	-- BASE FONTS
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE") -- NUMBER HERE JUST INCREASE THE FONT QUALITY.
	SetFont(FriendsFont_Large, NORMAL, 14)
	SetFont(FriendsFont_Normal, NORMAL, 12)
	SetFont(FriendsFont_Small, NORMAL, 11)
	SetFont(FriendsFont_UserText, NORMAL, 11)
	SetFont(GameFontHighlightMedium, NORMAL, 15)
	SetFont(GameFontNormalMed3, NORMAL, 15)
	SetFont(GameTooltipHeader, NORMAL, 12)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 12, "OUTLINE")
	SetFont(NumberFont_Outline_Huge, NUMBER, 28, "THINOUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NUMBER, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, 12)
	SetFont(NumberFont_Shadow_Small, NORMAL, 12)
	SetFont(PVPArenaTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(QuestFont, NORMAL, 14)
	SetFont(QuestFont_Large, NORMAL, 14)
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(SystemFont_Large, NORMAL, 15)
	SetFont(SystemFont_Med1, NORMAL, 12)
	SetFont(SystemFont_Med3, NORMAL, 13)
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "THINOUTLINE")
	SetFont(SystemFont_Outline_Small, NUMBER, 12, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "THINOUTLINE")
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Large_Outline, NUMBER, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Med1, NORMAL, 12)
	SetFont(SystemFont_Shadow_Med3, NORMAL, 13 * 1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, 11 * 0.9)
	SetFont(SystemFont_Shadow_Small2, NORMAL, 11)
	SetFont(SystemFont_Small, NORMAL, 12)
	SetFont(SystemFont_Tiny, NORMAL, 12)
	SetFont(Tooltip_Med, NORMAL, 12)
	SetFont(Tooltip_Small, NORMAL, 12)
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")

	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
end)