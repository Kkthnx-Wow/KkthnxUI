local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local GetKkthnxUIFont = select(1, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontSize = select(2, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontStyle = select(3, _G.KkthnxUIFont:GetFont())

local chatFontHeights = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
local lastFont = {}
local unifiedBlizzFonts = false

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then
		return
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

table_insert(C.defaultThemes, function()
	_G.CHAT_FONT_HEIGHTS = chatFontHeights
	_G.UNIT_NAME_FONT = GetKkthnxUIFont
	_G.DAMAGE_TEXT_FONT = GetKkthnxUIFont

	SetFont(_G.ChatBubbleFont, GetKkthnxUIFont, 10, "NONE") -- 13
	SetFont(_G.SystemFont_NamePlate, GetKkthnxUIFont, 9, "NONE", 0, 0, 0, 1, 1, -1) -- 9
	SetFont(_G.SystemFont_NamePlateFixed, GetKkthnxUIFont, 9, "NONE", 0, 0, 0, 1, 1, -1) -- 9
	SetFont(_G.SystemFont_LargeNamePlate, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12
	SetFont(_G.SystemFont_LargeNamePlateFixed, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12
	SetFont(_G.SystemFont_NamePlateCastBar, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12

	local size, style, stock = GetKkthnxUIFontSize, GetKkthnxUIFontStyle, not unifiedBlizzFonts
	if lastFont.font == GetKkthnxUIFont and lastFont.size == size and lastFont.style == style and lastFont.stock == stock then
		return -- only execute this when needed as it's excessive to reset all of these
	end

	_G.STANDARD_TEXT_FONT = GetKkthnxUIFont

	lastFont.font = GetKkthnxUIFont
	lastFont.size = size
	lastFont.style = style
	lastFont.stock = stock

	local normal = size
	local enormous = size * 1.9
	local mega = size * 1.7
	local huge = size * 1.5
	local large = size * 1.3
	local medium = size * 1.1
	local small = size * 0.9
	local tiny = size * 0.8
	local s = not unifiedBlizzFonts

	SetFont(_G.AchievementFont_Small, GetKkthnxUIFont, s and small or normal, "NONE") -- 10 Achiev dates
	SetFont(_G.BossEmoteNormalHuge, GetKkthnxUIFont, 24, "NONE") -- Talent Title
	SetFont(_G.CombatTextFont, GetKkthnxUIFont, 120, nil, nil, nil, nil, nil, 1, -1)
	SetFont(_G.CoreAbilityFont, GetKkthnxUIFont, 26, "NONE") -- 32 Core abilities(title)
	SetFont(_G.DestinyFontHuge, GetKkthnxUIFont, 32) -- Garrison Mission Report
	SetFont(_G.DestinyFontMed, GetKkthnxUIFont, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy12Font, GetKkthnxUIFont, 12) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy14Font, GetKkthnxUIFont, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy22Font, GetKkthnxUIFont, s and 22 or 20) -- Talking frame Title font
	SetFont(_G.Fancy24Font, GetKkthnxUIFont, s and 24 or 20) -- Artifact frame - weapon name
	SetFont(_G.FriendsFont_11, GetKkthnxUIFont, 11)
	SetFont(_G.FriendsFont_Large, GetKkthnxUIFont, s and large or normal) -- 14
	SetFont(_G.FriendsFont_Normal, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.FriendsFont_Small, GetKkthnxUIFont, s and small or normal) -- 10
	SetFont(_G.FriendsFont_UserText, GetKkthnxUIFont, normal) -- 11
	SetFont(_G.Game10Font_o1, GetKkthnxUIFont, 10, "OUTLINE")
	SetFont(_G.Game120Font, GetKkthnxUIFont, 120)
	SetFont(_G.Game12Font, GetKkthnxUIFont, 12) -- PVP Stuff
	SetFont(_G.Game13FontShadow, GetKkthnxUIFont, s and 13 or 14) -- InspectPvpFrame
	SetFont(_G.Game15Font_o1, GetKkthnxUIFont, 15) -- CharacterStatsPane (ItemLevelFrame)
	SetFont(_G.Game16Font, GetKkthnxUIFont, 16) -- Added in 7.3.5 used for ?
	SetFont(_G.Game18Font, GetKkthnxUIFont, 18) -- MissionUI Bonus Chance
	SetFont(_G.Game24Font, GetKkthnxUIFont, 24) -- Garrison Mission level (in detail frame)
	SetFont(_G.Game30Font, GetKkthnxUIFont, 30) -- Mission Level
	SetFont(_G.Game40Font, GetKkthnxUIFont, 40)
	SetFont(_G.Game42Font, GetKkthnxUIFont, 42) -- PVP Stuff
	SetFont(_G.Game46Font, GetKkthnxUIFont, 46) -- Added in 7.3.5 used for ?
	SetFont(_G.Game48Font, GetKkthnxUIFont, 48)
	SetFont(_G.Game48FontShadow, GetKkthnxUIFont, 48)
	SetFont(_G.Game60Font, GetKkthnxUIFont, 60)
	SetFont(_G.Game72Font, GetKkthnxUIFont, 72)
	SetFont(_G.GameFontHighlightMedium, GetKkthnxUIFont, s and medium or 15) -- 14 Fix QuestLog Title mouseover
	SetFont(_G.GameFontHighlightSmall2, GetKkthnxUIFont, s and small or normal) -- 11 Skill or Recipe description on TradeSkill frame
	SetFont(_G.GameFontNormalHuge2, GetKkthnxUIFont, s and huge or 24) -- 24 Mythic weekly best dungeon name
	SetFont(_G.GameFontNormalLarge, GetKkthnxUIFont, s and large or 16) -- 16
	SetFont(_G.GameFontNormalLarge2, GetKkthnxUIFont, s and large or 15) -- 18 Garrison Follower Names
	SetFont(_G.GameFontNormalMed1, GetKkthnxUIFont, s and medium or 14) -- 13 WoW Token Info
	SetFont(_G.GameFontNormalMed2, GetKkthnxUIFont, s and medium or medium) -- 14 Quest tracker
	SetFont(_G.GameFontNormalMed3, GetKkthnxUIFont, s and medium or 15) -- 14
	SetFont(_G.GameFontNormalSmall2, GetKkthnxUIFont, s and small or 12) -- 11 MissionUI Followers names
	SetFont(_G.GameFont_Gigantic, GetKkthnxUIFont, 32) -- Used at the install steps
	SetFont(_G.GameTooltipHeader, GetKkthnxUIFont, normal) -- 14
	SetFont(_G.InvoiceFont_Med, GetKkthnxUIFont, s and normal or 12) -- 12 Mail
	SetFont(_G.InvoiceFont_Small, GetKkthnxUIFont, s and small or normal) -- 10 Mail
	SetFont(_G.MailFont_Large, GetKkthnxUIFont, 14) -- 10 Mail
	SetFont(_G.Number11Font, GetKkthnxUIFont, 11)
	SetFont(_G.Number11Font, GetKkthnxUIFont, 11)
	SetFont(_G.Number12Font, GetKkthnxUIFont, 12)
	SetFont(_G.Number12Font_o1, GetKkthnxUIFont, 12, "OUTLINE")
	SetFont(_G.Number13Font, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontGray, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontWhite, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontYellow, GetKkthnxUIFont, 13)
	SetFont(_G.Number14FontGray, GetKkthnxUIFont, 14)
	SetFont(_G.Number14FontWhite, GetKkthnxUIFont, 14)
	SetFont(_G.Number15Font, GetKkthnxUIFont, 15)
	SetFont(_G.Number18Font, GetKkthnxUIFont, 18)
	SetFont(_G.Number18FontWhite, GetKkthnxUIFont, 18)
	SetFont(_G.NumberFontNormalSmall, GetKkthnxUIFont, s and small or 11, "OUTLINE") -- 12 Calendar, EncounterJournal
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, GetKkthnxUIFont, normal, "OUTLINE") -- 12
	SetFont(_G.NumberFont_Outline_Huge, GetKkthnxUIFont, s and huge or 28, "OUTLINE") -- 30
	SetFont(_G.NumberFont_Outline_Large, GetKkthnxUIFont, s and large or 15, "OUTLINE") -- 16
	SetFont(_G.NumberFont_Outline_Med, GetKkthnxUIFont, medium, "OUTLINE") -- 14
	SetFont(_G.NumberFont_Shadow_Med, GetKkthnxUIFont, s and medium or normal) -- 14 Chat EditBox
	SetFont(_G.NumberFont_Shadow_Small, GetKkthnxUIFont, s and small or normal) -- 12
	SetFont(_G.PVPArenaTextString, GetKkthnxUIFont, 22, "OUTLINE")
	SetFont(_G.PVPInfoTextString, GetKkthnxUIFont, 22, "OUTLINE")
	SetFont(_G.PriceFont, GetKkthnxUIFont, 13)
	SetFont(_G.QuestFont, GetKkthnxUIFont, normal) -- 13
	SetFont(_G.QuestFont_Enormous, GetKkthnxUIFont, s and enormous or 24) -- 30 Garrison Titles
	SetFont(_G.QuestFont_Huge, GetKkthnxUIFont, s and huge or 15) -- 18 Quest rewards title(Rewards)
	SetFont(_G.QuestFont_Large, GetKkthnxUIFont, s and large or 14) -- 14
	SetFont(_G.QuestFont_Shadow_Huge, GetKkthnxUIFont, s and huge or 15) -- 18 Quest Title
	SetFont(_G.QuestFont_Shadow_Small, GetKkthnxUIFont, s and normal or 14) -- 14
	SetFont(_G.QuestFont_Super_Huge, GetKkthnxUIFont, s and mega or 22) -- 24
	SetFont(_G.ReputationDetailFont, GetKkthnxUIFont, normal) -- 10 Rep Desc when clicking a rep
	SetFont(_G.SpellFont_Small, GetKkthnxUIFont, 10)
	SetFont(_G.SubSpellFont, GetKkthnxUIFont, 10) -- Spellbook Sub Names
	SetFont(_G.SubZoneTextFont, GetKkthnxUIFont, 24, "OUTLINE") -- 26 World Map(SubZone)
	SetFont(_G.SubZoneTextString, GetKkthnxUIFont, 25, "OUTLINE") -- 26
	SetFont(_G.SystemFont_Huge1, GetKkthnxUIFont, 20) -- Garrison Mission XP
	SetFont(_G.SystemFont_Huge1_Outline, GetKkthnxUIFont, 18, "OUTLINE") -- 20 Garrison Mission Chance
	SetFont(_G.SystemFont_Huge2, GetKkthnxUIFont, 22) -- 22 Mythic+ Score
	SetFont(_G.SystemFont_Large, GetKkthnxUIFont, s and 16 or 15)
	SetFont(_G.SystemFont_Med1, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.SystemFont_Med3, GetKkthnxUIFont, medium) -- 14
	SetFont(_G.SystemFont_Outline, GetKkthnxUIFont, s and normal or 13, "OUTLINE") -- 13 Pet level on World map
	SetFont(_G.SystemFont_OutlineThick_Huge2, GetKkthnxUIFont, s and huge or 20, "OUTLINE") -- 22
	SetFont(_G.SystemFont_OutlineThick_WTF, GetKkthnxUIFont, s and enormous or 32, "OUTLINE") -- 32 World Map
	SetFont(_G.SystemFont_Outline_Small, GetKkthnxUIFont, s and small or normal, "OUTLINE") -- 10
	SetFont(_G.SystemFont_Shadow_Huge1, GetKkthnxUIFont, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(_G.SystemFont_Shadow_Huge3, GetKkthnxUIFont, 22) -- 25 FlightMap
	SetFont(_G.SystemFont_Shadow_Huge4, GetKkthnxUIFont, 27, nil, nil, nil, nil, nil, 1, -1)
	SetFont(_G.SystemFont_Shadow_Large, GetKkthnxUIFont, 15)
	SetFont(_G.SystemFont_Shadow_Large2, GetKkthnxUIFont, 18) -- Auction House ItemDisplay
	SetFont(_G.SystemFont_Shadow_Large_Outline, GetKkthnxUIFont, 20, "OUTLINE") -- 16
	SetFont(_G.SystemFont_Shadow_Med1, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.SystemFont_Shadow_Med2, GetKkthnxUIFont, s and medium or 14.3) -- 14 Shows Order resourses on OrderHallTalentFrame
	SetFont(_G.SystemFont_Shadow_Med3, GetKkthnxUIFont, medium) -- 14
	SetFont(_G.SystemFont_Shadow_Small, GetKkthnxUIFont, small) -- 10
	SetFont(_G.SystemFont_Small, GetKkthnxUIFont, s and small or normal) -- 10
	SetFont(_G.SystemFont_Tiny, GetKkthnxUIFont, s and tiny or normal) -- 09
	SetFont(_G.Tooltip_Med, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.Tooltip_Small, GetKkthnxUIFont, s and small or normal) -- 10
	SetFont(_G.ZoneTextString, GetKkthnxUIFont, s and enormous or 32, "OUTLINE") -- 32

	-- Text that does not follow our fonts fixed below
	_G.WorldMapFrame.NavBar.homeButton.text:SetFontObject(K.UIFont)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
		local button = self.CategoryButtons[btnIndex]
		if button then
			if not button.isFontUpdated then
				button.Label:SetFontObject(K.UIFont)
				button.isFontUpdated = true
			end
		end
	end)

	-- WhoFrame LevelText
	hooksecurefunc("WhoList_Update", function()
		local buttons = WhoListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			local level = button.Level
			if level and not level.fontStyled then
				level:SetWidth(30)
				level:SetJustifyH("LEFT")
				level.fontStyled = true
			end
		end
	end)
end)
