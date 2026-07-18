--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Module: Skins — Blizzard Fonts
-- Notes:
-- - Replaces Blizzard FontFamily / Font objects with KkthnxUIFont.
-- - Catalog of retail FontFamily globals for UI font replace.
-- - Font flag logic lives in K.SetFont / K.CanFlagSlug (Functions.lua).
-- - No FontMap GUI / LSM pickers this pass — gated on Skins.BlizzardFrames only.
-- - Incident (Fonts, Jul 2026): old dump had Outlineoutline typos and missed
--   NamePlateCastBar / ObjectiveTracker / housing Game* fonts.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local _G = _G
local strmatch = _G.string.match
local table_insert = _G.table.insert

local chatFontHeights = { 12, 13, 14, 15, 16, 17, 18, 19, 20 }
local lastFont = {}

-- Thin alias — real SLUG / SHADOW / ScaleAnimationMode logic is K.SetFont.
local SetFont = K.SetFont

function K:UpdateBlizzardFonts()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local fontObj = _G.KkthnxUIFont
	if not fontObj then
		return
	end

	local NORMAL, size, style = fontObj:GetFont()
	size = size or 12
	style = style or ""

	local NUMBER = NORMAL
	local NAMEFONT = NORMAL
	local COMBAT = NORMAL

	-- Outline prefixes from active UI font style (thick/outline pairing).
	local prefix = strmatch(style, "(SHADOW)") or strmatch(style, "(MONOCHROME)") or ""
	local thick = prefix .. "THICKOUTLINE"
	local outline = prefix .. "OUTLINE"
	if style == "" or style == "NONE" then
		thick = "THICKOUTLINE"
		outline = "OUTLINE"
	elseif not strmatch(style, "OUTLINE") and not strmatch(style, "THICK") then
		-- UI font may be plain; still outline world/raid text when replace is on.
		thick = "THICKOUTLINE"
		outline = "OUTLINE"
	end

	local titanic = size * 4.0
	local monstrous = size * 3.5
	local colossal = size * 3.0
	local massive = size * 2.5
	local gigantic = size * 2.0
	local enormous = size * 1.9
	local mega = size * 1.7
	local huge = size * 1.5
	local large = size * 1.3
	local big = size * 1.2
	local medium = size * 1.1
	local small = size * 0.9
	local tiny = size * 0.8

	_G.CHAT_FONT_HEIGHTS = chatFontHeights
	_G.UNIT_NAME_FONT = NAMEFONT
	_G.DAMAGE_TEXT_FONT = COMBAT

	SetFont(_G.CombatTextFont, COMBAT, 120, "SHADOW")
	SetFont(_G.ChatBubbleFont, NORMAL, 9, style)

	SetFont(_G.SystemFont_NamePlate, NORMAL, 9, style)
	SetFont(_G.SystemFont_NamePlateFixed, NORMAL, 9, style)
	SetFont(_G.SystemFont_NamePlateCastBar, NORMAL, 9, style)
	SetFont(_G.SystemFont_NamePlate_Outlined, NORMAL, 9, style)
	SetFont(_G.SystemFont_LargeNamePlate, NORMAL, 12, style)
	SetFont(_G.SystemFont_LargeNamePlateFixed, NORMAL, 12, style)

	-- FontMap defaults (no per-category GUI — fixed replace sizes).
	-- Zone/world map FontFamilies are also in the bulk list below (bulk sizes win).
	SetFont(_G.MailTextFontNormal, NORMAL, big, "NONE")
	SetFont(_G.SystemFont_Shadow_Large_Outline, NORMAL, big, "SHADOW")
	SetFont(_G.ErrorFont, NORMAL, big, "SHADOW")
	SetFont(_G.PVPInfoTextString, NORMAL, large, outline)
	SetFont(_G.PVPArenaTextString, NORMAL, large, outline)
	SetFont(_G.SubZoneTextFont, NORMAL, huge, outline)
	SetFont(_G.ZoneTextFont, NORMAL, mega, outline)
	SetFont(_G.WorldMapTextFont, NORMAL, mega, outline)
	SetFont(_G.QuestFont, NORMAL, medium, "NONE")
	SetFont(_G.QuestTitleFont, NORMAL, big, "NONE")
	SetFont(_G.QuestFontNormalSmall, NORMAL, medium, "NONE")
	SetFont(_G.ObjectiveFont, NORMAL, size, "SHADOW")

	local talking = _G.TalkingHeadFrame
	if talking and talking.NameFrame and talking.NameFrame.Name then
		SetFont(talking.NameFrame.Name, NORMAL, large, outline)
	end
	if talking and talking.TextFrame and talking.TextFrame.Text then
		SetFont(talking.TextFrame.Text, NORMAL, big, "SHADOW")
	end

	-- lastFont only skips the bulk FontFamily walk — MapFont-style objects above always re-apply.
	if lastFont.font == NORMAL and lastFont.size == size and lastFont.style == style then
		return
	end

	_G.STANDARD_TEXT_FONT = NORMAL

	lastFont.font = NORMAL
	lastFont.size = size
	lastFont.style = style

	-- Raid Warnings / Boss emote (animated blur if size fights SetTextHeight).
	SetFont(_G.GameFontNormalHuge, NORMAL, 20, outline)

	-- Number fonts
	SetFont(_G.Number11Font, NUMBER, small)
	SetFont(_G.Number12Font, NUMBER, size)
	SetFont(_G.Number12Font_o1, NUMBER, size, "OUTLINE")
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, NUMBER, size, "OUTLINE")
	SetFont(_G.NumberFont_Shadow_Small, NUMBER, size, "SHADOW")
	SetFont(_G.NumberFont_Small, NUMBER, size)
	SetFont(_G.NumberFontNormalSmall, NUMBER, size, "OUTLINE")
	SetFont(_G.Number13Font, NUMBER, medium)
	SetFont(_G.Number13FontGray, NUMBER, medium, "SHADOW")
	SetFont(_G.Number13FontWhite, NUMBER, medium, "SHADOW")
	SetFont(_G.Number13FontYellow, NUMBER, medium, "SHADOW")
	SetFont(_G.Number14FontGray, NUMBER, medium, "SHADOW")
	SetFont(_G.Number14FontWhite, NUMBER, medium, "SHADOW")
	SetFont(_G.NumberFont_Outline_Med, NUMBER, medium, "OUTLINE")
	SetFont(_G.NumberFont_Shadow_Med, NUMBER, medium, "SHADOW")
	SetFont(_G.NumberFontNormal, NUMBER, medium, "OUTLINE")
	SetFont(_G.Number15Font, NUMBER, medium)
	SetFont(_G.NumberFont_Outline_Large, NUMBER, big, outline)
	SetFont(_G.Number18Font, NUMBER, big)
	SetFont(_G.Number18FontWhite, NUMBER, big, "SHADOW")
	SetFont(_G.NumberFont_Outline_Huge, NUMBER, enormous, thick)

	-- World map (overrides MapFont sizes above)
	SetFont(_G.SubZoneTextFont, NORMAL, gigantic, outline)
	SetFont(_G.WorldMapTextFont, NORMAL, massive, outline)

	-- Objective tracker — SHADOW for header + lines.
	-- OUTLINE on HeaderFont was wrong (yellow titles looked stroked); bare "" on
	-- LineFont/Font12-22 became SLUG with zero shadow (flat white objectives).
	SetFont(_G.ObjectiveTrackerHeaderFont, NORMAL, medium, "SHADOW")
	SetFont(_G.ObjectiveTrackerLineFont, NORMAL, size, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont12, NORMAL, size, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont13, NORMAL, medium, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont14, NORMAL, medium, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont15, NORMAL, medium, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont16, NORMAL, big, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont17, NORMAL, big, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont18, NORMAL, big, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont19, NORMAL, big, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont20, NORMAL, large, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont21, NORMAL, large, "SHADOW")
	SetFont(_G.ObjectiveTrackerFont22, NORMAL, large, "SHADOW")

	-- Quest shadow variants (parchment shadow color)
	SetFont(_G.QuestFont_Shadow_Small, NORMAL, medium, "SHADOW", 0.49, 0.35, 0.05, 1)
	SetFont(_G.QuestFont_Shadow_Huge, NORMAL, large, "SHADOW", 0.49, 0.35, 0.05, 1)
	SetFont(_G.QuestFont_Shadow_Super_Huge, NORMAL, large, "SHADOW", 0.49, 0.35, 0.05, 1)
	SetFont(_G.QuestFont_Shadow_Enormous, NORMAL, mega, "SHADOW", 0.49, 0.35, 0.05, 1)

	-- Game / system fonts
	SetFont(_G.SystemFont_Tiny, NORMAL, tiny)
	SetFont(_G.AchievementFont_Small, NORMAL, small)
	SetFont(_G.FriendsFont_Small, NORMAL, small, "SHADOW")
	SetFont(_G.Game10Font_o1, NORMAL, small, "OUTLINE")
	SetFont(_G.InvoiceFont_Small, NORMAL, small)
	SetFont(_G.ReputationDetailFont, NORMAL, small, "SHADOW")
	SetFont(_G.SpellFont_Small, NORMAL, small)
	SetFont(_G.SubSpellFont, NORMAL, small)
	SetFont(_G.SystemFont_Outline_Small, NORMAL, small, "OUTLINE")
	SetFont(_G.SystemFont_Shadow_Small, NORMAL, small, "SHADOW")
	SetFont(_G.Tooltip_Small, NORMAL, small)
	SetFont(_G.SystemFont_Small, NORMAL, small)
	SetFont(_G.SystemFont_Small2, NORMAL, small)
	SetFont(_G.FriendsFont_11, NORMAL, small, "SHADOW")
	SetFont(_G.FriendsFont_UserText, NORMAL, small, "SHADOW")
	SetFont(_G.GameFontHighlightSmall2, NORMAL, small, "SHADOW")
	SetFont(_G.GameFontNormalSmall2, NORMAL, small, "SHADOW")
	SetFont(_G.Fancy12Font, NORMAL, size)
	SetFont(_G.FriendsFont_Normal, NORMAL, size, "SHADOW")
	SetFont(_G.Game12Font, NORMAL, size)
	SetFont(_G.InvoiceFont_Med, NORMAL, size)
	SetFont(_G.SystemFont_Med1, NORMAL, size)
	SetFont(_G.SystemFont_Shadow_Med1, NORMAL, size, "SHADOW")
	SetFont(_G.Tooltip_Med, NORMAL, size)
	SetFont(_G.Game13FontShadow, NORMAL, medium, "SHADOW")
	SetFont(_G.GameFontNormalMed1, NORMAL, medium, "SHADOW")
	SetFont(_G.SystemFont_Med2, NORMAL, medium)
	SetFont(_G.SystemFont_Outline, NORMAL, medium, outline)
	SetFont(_G.DestinyFontMed, NORMAL, medium)
	SetFont(_G.Fancy14Font, NORMAL, medium)
	SetFont(_G.FriendsFont_Large, NORMAL, medium, "SHADOW")
	SetFont(_G.GameFontHighlightMedium, NORMAL, medium, "SHADOW")
	SetFont(_G.GameFontNormalMed2, NORMAL, medium, "SHADOW")
	SetFont(_G.GameFontNormalMed3, NORMAL, medium, "SHADOW")
	SetFont(_G.GameTooltipHeader, NORMAL, medium)
	SetFont(_G.PriceFont, NORMAL, medium)
	SetFont(_G.SystemFont_Med3, NORMAL, medium)
	SetFont(_G.SystemFont_Shadow_Med2, NORMAL, medium, "SHADOW")
	SetFont(_G.SystemFont_Shadow_Med3, NORMAL, medium, "SHADOW")
	SetFont(_G.Game15Font_Shadow, NORMAL, medium, "SHADOW")
	SetFont(_G.Game15Font_o1, NORMAL, medium)
	SetFont(_G.MailFont_Large, NORMAL, medium)
	SetFont(_G.QuestFont_Large, NORMAL, medium)
	SetFont(_G.Game16Font, NORMAL, big)
	SetFont(_G.GameFontNormalLarge, NORMAL, big, "SHADOW")
	SetFont(_G.SystemFont_Large, NORMAL, big)
	SetFont(_G.SystemFont_Shadow_Large, NORMAL, big, "SHADOW")
	SetFont(_G.SystemFont16_Shadow_ThickOutline, NORMAL, big, outline)
	SetFont(_G.Game17Font_Shadow, NORMAL, big, "SHADOW")
	SetFont(_G.Game18Font, NORMAL, big)
	SetFont(_G.GameFontNormalLarge2, NORMAL, big, "SHADOW")
	SetFont(_G.QuestFont_Huge, NORMAL, big)
	SetFont(_G.SystemFont_Shadow_Large2, NORMAL, big, "SHADOW")
	SetFont(_G.SystemFont_Huge1, NORMAL, large)
	SetFont(_G.Game20Font, NORMAL, large)
	SetFont(_G.SystemFont_Huge1_Outline, NORMAL, large, outline)
	SetFont(_G.SystemFont_Shadow_Huge1, NORMAL, large, outline)
	SetFont(_G.Game22Font, NORMAL, large)
	SetFont(_G.Fancy22Font, NORMAL, large)
	SetFont(_G.SystemFont_OutlineThick_Huge2, NORMAL, large, thick)
	SetFont(_G.Fancy24Font, NORMAL, huge)
	SetFont(_G.Game24Font, NORMAL, huge)
	SetFont(_G.GameFontHighlightHuge2, NORMAL, huge, "SHADOW")
	SetFont(_G.GameFontNormalHuge2, NORMAL, huge, "SHADOW")
	SetFont(_G.QuestFont_Super_Huge, NORMAL, huge)
	SetFont(_G.SystemFont_Huge2, NORMAL, huge)
	SetFont(_G.SystemFont_Shadow_Huge2, NORMAL, huge, "SHADOW")
	SetFont(_G.BossEmoteNormalHuge, NORMAL, mega, "SHADOW")
	SetFont(_G.SystemFont_Shadow_Huge3, NORMAL, mega, "SHADOW")
	SetFont(_G.SystemFont_Shadow_Huge4, NORMAL, mega, "SHADOW")
	SetFont(_G.Game30Font, NORMAL, enormous)
	SetFont(_G.QuestFont_Enormous, NORMAL, enormous)
	SetFont(_G.CoreAbilityFont, NORMAL, enormous)
	SetFont(_G.DestinyFontHuge, NORMAL, enormous)
	SetFont(_G.GameFont_Gigantic, NORMAL, enormous, "SHADOW")
	SetFont(_G.SystemFont_OutlineThick_WTF, NORMAL, enormous, outline)

	-- Big display fonts
	SetFont(_G.Game40Font, NORMAL, gigantic)
	SetFont(_G.Game42Font, NORMAL, gigantic)
	SetFont(_G.Game46Font, NORMAL, massive)
	SetFont(_G.Game48Font, NORMAL, massive)
	SetFont(_G.Game48FontShadow, NORMAL, massive, "SHADOW")
	SetFont(_G.Game60Font, NORMAL, colossal, "OUTLINE")
	SetFont(_G.Game72Font, NORMAL, monstrous, "OUTLINE")
	SetFont(_G.Game120Font, NORMAL, titanic, "OUTLINE")
end

table_insert(C.defaultThemes, function()
	K:UpdateBlizzardFonts()
end)
