local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local GetKkthnxUIFont = select(1, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontSize = select(2, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontStyle = select(3, _G.KkthnxUIFont:GetFont())

local unifiedBlizzFonts = false

local function ReskinFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then
		return
	end

	if style == "NONE" or not style then
		style = ""
	end

	obj:SetFont(font, size, style)

	if sr and sg and sb then
		obj:SetShadowColor(sr, sg, sb, sa)
	end

	if sox and soy then
		obj:SetShadowOffset(sox, soy)
	end

	if r and g and b then
		obj:SetTextColor(r, g, b)
	elseif r then
		obj:SetAlpha(r)
	end
end

local lastFont = {}
local chatFontHeights = { 12, 13, 14, 15, 16, 17, 18, 19, 20 }
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local NORMAL = GetKkthnxUIFont
	local NUMBER = GetKkthnxUIFont
	local NAMEFONT = GetKkthnxUIFont
	local COMBAT = GetKkthnxUIFont

	_G.CHAT_FONT_HEIGHTS = chatFontHeights

	_G.UNIT_NAME_FONT = NAMEFONT
	_G.DAMAGE_TEXT_FONT = COMBAT

	ReskinFont(_G.CombatTextFont, COMBAT, 120, nil, nil, nil, nil, nil, 1, -1)

	local BUBBLE = GetKkthnxUIFont
	ReskinFont(_G.ChatBubbleFont, BUBBLE, 12, GetKkthnxUIFontStyle) -- 13

	local PLATE = NORMAL
	local LARGE = NORMAL

	ReskinFont(_G.SystemFont_NamePlate, PLATE, 9, GetKkthnxUIFontStyle) -- 9
	ReskinFont(_G.SystemFont_NamePlateFixed, PLATE, 9, GetKkthnxUIFontStyle) -- 9
	ReskinFont(_G.SystemFont_LargeNamePlate, LARGE, 12, GetKkthnxUIFontStyle) -- 12
	ReskinFont(_G.SystemFont_LargeNamePlateFixed, LARGE, 12, GetKkthnxUIFontStyle) -- 12

	local size, style, stock = GetKkthnxUIFontSize, GetKkthnxUIFontStyle, not unifiedBlizzFonts
	if lastFont.font == NORMAL and lastFont.size == size and lastFont.style == style and lastFont.stock == stock then
		return -- only execute this when needed as it's excessive to reset all of these
	end

	_G.STANDARD_TEXT_FONT = NORMAL

	lastFont.font = NORMAL
	lastFont.size = size
	lastFont.style = style
	lastFont.stock = stock

	local enormous = size * 1.9
	local mega = size * 1.7
	local huge = size * 1.5
	local large = size * 1.3
	local medium = size * 1.1
	local small = size * 0.9
	local tiny = size * 0.8

	local outline = "OUTLINE"

	ReskinFont(_G.AchievementFont_Small, NORMAL, stock and small or size) -- 10  Achiev dates
	ReskinFont(_G.BossEmoteNormalHuge, NORMAL, 24) -- Talent Title
	ReskinFont(_G.CoreAbilityFont, NORMAL, 26) -- 32  Core abilities(title)
	ReskinFont(_G.DestinyFontHuge, NORMAL, 32) -- Garrison Mission Report
	ReskinFont(_G.DestinyFontMed, NORMAL, 14) -- Added in 7.3.5 used for ?
	ReskinFont(_G.Fancy12Font, NORMAL, 12) -- Added in 7.3.5 used for ?
	ReskinFont(_G.Fancy14Font, NORMAL, 14) -- Added in 7.3.5 used for ?
	ReskinFont(_G.Fancy22Font, NORMAL, stock and 22 or 20) -- Talking frame Title font
	ReskinFont(_G.Fancy24Font, NORMAL, stock and 24 or 20) -- Artifact frame - weapon name
	ReskinFont(_G.FriendsFont_11, NORMAL, 11)
	ReskinFont(_G.FriendsFont_Large, NORMAL, stock and large or size) -- 14
	ReskinFont(_G.FriendsFont_Normal, NORMAL, size) -- 12
	ReskinFont(_G.FriendsFont_Small, NORMAL, stock and small or size) -- 10
	ReskinFont(_G.FriendsFont_UserText, NORMAL, size) -- 11
	ReskinFont(_G.Game10Font_o1, NORMAL, 10, outline)
	ReskinFont(_G.Game120Font, NORMAL, 120)
	ReskinFont(_G.Game12Font, NORMAL, 12) -- PVP Stuff
	ReskinFont(_G.Game13FontShadow, NORMAL, stock and 13 or 14) -- InspectPvpFrame
	ReskinFont(_G.Game15Font_o1, NORMAL, 15) -- CharacterStatsPane (ItemLevelFrame)
	ReskinFont(_G.Game16Font, NORMAL, 16) -- Added in 7.3.5 used for ?
	ReskinFont(_G.Game18Font, NORMAL, 18) -- MissionUI Bonus Chance
	ReskinFont(_G.Game24Font, NORMAL, 24) -- Garrison Mission level (in detail frame)
	ReskinFont(_G.Game30Font, NORMAL, 30) -- Mission Level
	ReskinFont(_G.Game40Font, NORMAL, 40)
	ReskinFont(_G.Game42Font, NORMAL, 42) -- PVP Stuff
	ReskinFont(_G.Game46Font, NORMAL, 46) -- Added in 7.3.5 used for ?
	ReskinFont(_G.Game48Font, NORMAL, 48)
	ReskinFont(_G.Game48FontShadow, NORMAL, 48)
	ReskinFont(_G.Game60Font, NORMAL, 60)
	ReskinFont(_G.Game72Font, NORMAL, 72)
	ReskinFont(_G.GameFont_Gigantic, NORMAL, 32) -- Used at the install steps
	ReskinFont(_G.GameFontHighlightMedium, NORMAL, stock and medium or 15) -- 14  Fix QuestLog Title mouseover
	ReskinFont(_G.GameFontHighlightSmall2, NORMAL, stock and small or size) -- 11  Skill or Recipe description on TradeSkill frame
	ReskinFont(_G.GameFontNormalHuge2, NORMAL, stock and huge or 24) -- 24  Mythic weekly best dungeon name
	ReskinFont(_G.GameFontNormalLarge, NORMAL, stock and large or 16) -- 16
	ReskinFont(_G.GameFontNormalLarge2, NORMAL, stock and large or 15) -- 18  Garrison Follower Names
	ReskinFont(_G.GameFontNormalMed1, NORMAL, stock and medium or 14) -- 13  WoW Token Info
	ReskinFont(_G.GameFontNormalMed2, NORMAL, stock and medium or medium) -- 14  Quest tracker
	ReskinFont(_G.GameFontNormalMed3, NORMAL, stock and medium or 15) -- 14
	ReskinFont(_G.GameFontNormalSmall2, NORMAL, stock and small or 12) -- 11  MissionUI Followers names
	ReskinFont(_G.GameTooltipHeader, NORMAL, size) -- 14
	ReskinFont(_G.InvoiceFont_Med, NORMAL, stock and size or 12) -- 12  Mail
	ReskinFont(_G.InvoiceFont_Small, NORMAL, stock and small or size) -- 10  Mail
	ReskinFont(_G.MailFont_Large, NORMAL, 14) -- 10  Mail
	ReskinFont(_G.Number11Font, NORMAL, 11)
	ReskinFont(_G.Number11Font, NUMBER, 11)
	ReskinFont(_G.Number12Font, NORMAL, 12)
	ReskinFont(_G.Number12Font_o1, NUMBER, 12, outline)
	ReskinFont(_G.Number13Font, NUMBER, 13)
	ReskinFont(_G.Number13FontGray, NUMBER, 13)
	ReskinFont(_G.Number13FontWhite, NUMBER, 13)
	ReskinFont(_G.Number13FontYellow, NUMBER, 13)
	ReskinFont(_G.Number14FontGray, NUMBER, 14)
	ReskinFont(_G.Number14FontWhite, NUMBER, 14)
	ReskinFont(_G.Number15Font, NORMAL, 15)
	ReskinFont(_G.Number18Font, NUMBER, 18)
	ReskinFont(_G.Number18FontWhite, NUMBER, 18)
	ReskinFont(_G.NumberFont_Outline_Huge, NUMBER, stock and huge or 28, outline) -- 30
	ReskinFont(_G.NumberFont_Outline_Large, NUMBER, stock and large or 15, outline) -- 16
	ReskinFont(_G.NumberFont_Outline_Med, NUMBER, medium, outline) -- 14
	ReskinFont(_G.NumberFont_Outlineoutline_Mono_Small, NUMBER, size, outline) -- 12
	ReskinFont(_G.NumberFont_Shadow_Med, NORMAL, stock and medium or size) -- 14  Chat EditBox
	ReskinFont(_G.NumberFont_Shadow_Small, NORMAL, stock and small or size) -- 12
	ReskinFont(_G.NumberFontNormalSmall, NORMAL, stock and small or 11, outline) -- 12  Calendar, EncounterJournal
	ReskinFont(_G.PriceFont, NORMAL, 13)
	ReskinFont(_G.PVPArenaTextString, NORMAL, 22, outline)
	ReskinFont(_G.PVPInfoTextString, NORMAL, 22, outline)
	ReskinFont(_G.QuestFont, NORMAL, size) -- 13
	ReskinFont(_G.QuestFont_Enormous, NORMAL, stock and enormous or 24) -- 30  Garrison Titles
	ReskinFont(_G.QuestFont_Huge, NORMAL, stock and huge or 15) -- 18  Quest rewards title(Rewards)
	ReskinFont(_G.QuestFont_Large, NORMAL, stock and large or 14) -- 14
	ReskinFont(_G.QuestFont_Shadow_Huge, NORMAL, stock and huge or 15) -- 18  Quest Title
	ReskinFont(_G.QuestFont_Shadow_Small, NORMAL, stock and size or 14) -- 14
	ReskinFont(_G.QuestFont_Super_Huge, NORMAL, stock and mega or 22) -- 24
	ReskinFont(_G.ReputationDetailFont, NORMAL, size) -- 10  Rep Desc when clicking a rep
	ReskinFont(_G.SpellFont_Small, NORMAL, 10)
	ReskinFont(_G.SubSpellFont, NORMAL, 10) -- Spellbook Sub Names
	ReskinFont(_G.SubZoneTextFont, NORMAL, 24, outline) -- 26  World Map(SubZone)
	ReskinFont(_G.SubZoneTextString, NORMAL, 25, outline) -- 26
	ReskinFont(_G.SystemFont_Huge1, NORMAL, 20) -- Garrison Mission XP
	ReskinFont(_G.SystemFont_Huge1_Outline, NORMAL, 18, outline) -- 20  Garrison Mission Chance
	ReskinFont(_G.SystemFont_Huge2, NORMAL, 22) -- 22  Mythic+ Score
	ReskinFont(_G.SystemFont_Large, NORMAL, stock and 16 or 15)
	ReskinFont(_G.SystemFont_Med1, NORMAL, size) -- 12
	ReskinFont(_G.SystemFont_Med3, NORMAL, medium) -- 14
	ReskinFont(_G.SystemFont_Outline, NORMAL, stock and size or 13, outline) -- 13  Pet level on World map
	ReskinFont(_G.SystemFont_Outline_Small, NUMBER, stock and small or size, outline) -- 10
	ReskinFont(_G.SystemFont_Outlineoutline_Huge2, NORMAL, stock and huge or 20, outline) -- 22
	ReskinFont(_G.SystemFont_Outlineoutline_WTF, NORMAL, stock and enormous or 32, outline) -- 32  World Map
	ReskinFont(_G.SystemFont_Shadow_Huge1, NORMAL, 20, outline) -- Raid Warning, Boss emote frame too
	ReskinFont(_G.SystemFont_Shadow_Huge3, NORMAL, 22) -- 25  FlightMap
	ReskinFont(_G.SystemFont_Shadow_Huge4, NORMAL, 27, nil, nil, nil, nil, nil, 1, -1)
	ReskinFont(_G.SystemFont_Shadow_Large, NORMAL, 15)
	ReskinFont(_G.SystemFont_Shadow_Large2, NORMAL, 18) -- Auction House ItemDisplay
	ReskinFont(_G.SystemFont_Shadow_Large_Outline, NUMBER, 20, outline) -- 16
	ReskinFont(_G.SystemFont_Shadow_Med1, NORMAL, size) -- 12
	ReskinFont(_G.SystemFont_Shadow_Med2, NORMAL, stock and medium or 14.3) -- 14  Shows Order resourses on OrderHallTalentFrame
	ReskinFont(_G.SystemFont_Shadow_Med3, NORMAL, medium) -- 14
	ReskinFont(_G.SystemFont_Shadow_Small, NORMAL, small) -- 10
	ReskinFont(_G.SystemFont_Small, NORMAL, stock and small or size) -- 10
	ReskinFont(_G.SystemFont_Tiny, NORMAL, stock and tiny or size) -- 09
	ReskinFont(_G.Tooltip_Med, NORMAL, size) -- 12
	ReskinFont(_G.Tooltip_Small, NORMAL, stock and small or size) -- 10
	ReskinFont(_G.ZoneTextString, NORMAL, stock and enormous or 32, outline) -- 32
end)
