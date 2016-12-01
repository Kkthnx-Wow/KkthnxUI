local K, C, L = select(2, ...):unpack()
if C.Blizzard.ReplaceBlizzardFonts ~= true then return end

local KkthnxUIFonts = CreateFrame("Frame", nil, UIParent)

function KkthnxUIFonts:SetFont(font, size, style, r, g, b, sr, sg, sb, sox, soy)
	self:SetFont(font, size, style)

	if sr and sg and sb then
		self:SetShadowColor(sr, sg, sb)
	end

	if sox and soy then
		self:SetShadowOffset(sox, soy)
	end

	if r and g and b then
		self:SetTextColor(r, g, b)
	elseif r then
		self:SetAlpha(r)
	end
end

function KkthnxUIFonts:ChangeWoWFonts()
	local SetFont = self.SetFont
	local NORMAL = C.Media.Font
	local COMBAT = C.Media.Combat_Font

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT = NORMAL
	DAMAGE_TEXT_FONT = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	-- Base fonts
	SetFont(AchievementFont_Small, NORMAL, 11)
	SetFont(ChatBubbleFont, NORMAL, 12)
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE")
	SetFont(CoreAbilityFont, NORMAL, 32)
	SetFont(FriendsFont_Large, NORMAL, 14)
	SetFont(FriendsFont_Normal, NORMAL, 12)
	SetFont(FriendsFont_Small, NORMAL, 11)
	SetFont(FriendsFont_UserText, NORMAL, 11)
	SetFont(GameFontHighlightMedium, NORMAL, 15)
	SetFont(GameFontNormalMed3, NORMAL, 15)
	SetFont(GameTooltipHeader, NORMAL, 12)
	SetFont(GameTooltipTextSmall, NORMAL, 12)
	SetFont(InvoiceFont_Med, NORMAL, 13)
	SetFont(InvoiceFont_Small, NORMAL, 11)
	SetFont(MailFont_Large, NORMAL, 15)
	SetFont(NumberFont_Outline_Huge, NORMAL, 28, "THINOUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NORMAL, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NORMAL, 13, "OUTLINE")
	SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL, 12, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, 12)
	SetFont(NumberFont_Shadow_Small, NORMAL, 12)
	SetFont(NumberFontNormalSmall, NORMAL, 11, "OUTLINE")
	SetFont(PVPArenaTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(QuestFont, NORMAL, 14)
	SetFont(QuestFont_Huge, NORMAL, 17)
	SetFont(QuestFont_Large, NORMAL, 14)
	SetFont(QuestFont_Shadow_Huge, NORMAL, 19)
	SetFont(QuestFont_Shadow_Small, NORMAL, 15)
	SetFont(QuestFont_Super_Huge, NORMAL, 20)
	SetFont(QuestMapRewardsFont, NORMAL, 12)
	SetFont(ReputationDetailFont, NORMAL, 11)
	SetFont(SpellFont_Small, NORMAL, 11)
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(SystemFont_InverseShadow_Small, NORMAL, 11)
	SetFont(SystemFont_Large, NORMAL, 15)
	SetFont(SystemFont_Med1, NORMAL, 12)
	SetFont(SystemFont_Med2, NORMAL, 14)
	SetFont(SystemFont_Med3, NORMAL, 13)
	SetFont(SystemFont_Outline_Small, NORMAL, 12, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "THINOUTLINE")
	SetFont(SystemFont_OutlineThick_Huge4, NORMAL, 27, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_WTF, NORMAL, 31, "THICKOUTLINE")
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "THINOUTLINE")
	SetFont(SystemFont_Shadow_Huge3, NORMAL, 25)
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Large_Outline, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Med1, NORMAL, 12)
	SetFont(SystemFont_Shadow_Med2, NORMAL, 13)
	SetFont(SystemFont_Shadow_Med3, NORMAL, 13)
	SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, 11)
	SetFont(SystemFont_Shadow_Small2, NORMAL, 11)
	SetFont(SystemFont_Small, NORMAL, 12)
	SetFont(SystemFont_Tiny, NORMAL, 12)
	SetFont(Tooltip_Med, NORMAL, 12)
	SetFont(Tooltip_Small, NORMAL, 12)
	SetFont(WhiteNormalNumberFont, NORMAL, 11)
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")

	-- Derived fonts
	SetFont(BossEmoteNormalHuge, NORMAL, 27, "THICKOUTLINE")
	SetFont(ErrorFont, NORMAL, 16)
	SetFont(HelpFrameKnowledgebaseNavBarHomeButtonText, NORMAL, 13)
	SetFont(QuestFontNormalSmall, NORMAL, 13)
	SetFont(WorldMapTextFont, NORMAL, 31, "THICKOUTLINE")

	-- Channel list
	for i = 1, MAX_CHANNEL_BUTTONS do
		local f = _G["ChannelButton"..i.."Text"]
		f:SetFontObject(GameFontNormalSmallLeft)
	end

	-- Player title
	for _, butt in pairs(PaperDollTitlesPane.buttons) do butt.text:SetFontObject(GameFontHighlightSmallLeft) end
end

-- New Fonts Need to be set as soon as possible ...
KkthnxUIFonts:ChangeWoWFonts()

K.Fonts = KkthnxUIFonts