local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local GetKkthnxUIFont = select(1, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontSize = select(2, _G.KkthnxUIFont:GetFont())
local GetKkthnxUIFontStyle = select(3, _G.KkthnxUIFont:GetFont())

local GetChatFontHeights = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
local GetLastFont = {}

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
	_G.CHAT_FONT_HEIGHTS = GetChatFontHeights
	_G.DAMAGE_TEXT_FONT = GetKkthnxUIFont
	_G.STANDARD_TEXT_FONT = GetKkthnxUIFont
	_G.UNIT_NAME_FONT = GetKkthnxUIFont

	if GetLastFont.font == GetKkthnxUIFont and GetLastFont.size == GetKkthnxUIFontSize and GetLastFont.style == GetKkthnxUIFontStyle then
		return -- only execute this when needed as it's excessive to reset all of these
	end

	GetLastFont.font = GetKkthnxUIFont
	GetLastFont.size = GetKkthnxUIFontSize
	GetLastFont.style = GetKkthnxUIFontStyle

	local normal = GetKkthnxUIFontSize
	local enormous = normal * 1.9
	local mega = normal * 1.7
	local huge = normal * 1.5
	local large = normal * 1.3
	local medium = normal * 1.1
	local small = normal * 0.9
	local tiny = normal * 0.8

	SetFont(_G.AchievementCriteriaFont, GetKkthnxUIFont, 10)
	SetFont(_G.AchievementDescriptionFont, GetKkthnxUIFont, 10)
	SetFont(_G.AchievementFont_Small, GetKkthnxUIFont, small, "NONE") -- 10 Achiev dates
	SetFont(_G.BossEmoteNormalHuge, GetKkthnxUIFont, 24, "NONE") -- Talent Title
	SetFont(_G.ChatBubbleFont, GetKkthnxUIFont, 10, "NONE") -- 13
	SetFont(_G.CombatTextFont, GetKkthnxUIFont, 120, nil, nil, nil, nil, nil, 1, -1)
	SetFont(_G.CoreAbilityFont, GetKkthnxUIFont, 26, "NONE") -- 32 Core abilities(title)
	SetFont(_G.DestinyFontHuge, GetKkthnxUIFont, 32) -- Garrison Mission Report
	SetFont(_G.DestinyFontLarge, GetKkthnxUIFont, 18)
	SetFont(_G.DestinyFontMed, GetKkthnxUIFont, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy12Font, GetKkthnxUIFont, normal) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy14Font, GetKkthnxUIFont, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy16Font, GetKkthnxUIFont, 16)
	SetFont(_G.Fancy18Font, GetKkthnxUIFont, 18)
	SetFont(_G.Fancy20Font, GetKkthnxUIFont, 20)
	SetFont(_G.Fancy22Font, GetKkthnxUIFont, 22) -- Talking frame Title font
	SetFont(_G.Fancy24Font, GetKkthnxUIFont, 24) -- Artifact frame - weapon name
	SetFont(_G.Fancy27Font, GetKkthnxUIFont, 27)
	SetFont(_G.Fancy30Font, GetKkthnxUIFont, 30)
	SetFont(_G.Fancy32Font, GetKkthnxUIFont, 32)
	SetFont(_G.Fancy48Font, GetKkthnxUIFont, 48)
	SetFont(_G.FriendsFont_11, GetKkthnxUIFont, 11)
	SetFont(_G.FriendsFont_Large, GetKkthnxUIFont, large) -- 14
	SetFont(_G.FriendsFont_Normal, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.FriendsFont_Small, GetKkthnxUIFont, small) -- 10
	SetFont(_G.FriendsFont_UserText, GetKkthnxUIFont, normal) -- 11
	SetFont(_G.Game10Font_o1, GetKkthnxUIFont, 10, "OUTLINE")
	SetFont(_G.Game11Font, GetKkthnxUIFont, 11)
	SetFont(_G.Game120Font, GetKkthnxUIFont, 120)
	SetFont(_G.Game12Font, GetKkthnxUIFont, normal) -- PVP Stuff
	SetFont(_G.Game13Font, GetKkthnxUIFont, 13)
	SetFont(_G.Game13FontShadow, GetKkthnxUIFont, 13) -- InspectPvpFrame
	SetFont(_G.Game15Font, GetKkthnxUIFont, 15)
	SetFont(_G.Game15Font_o1, GetKkthnxUIFont, 15) -- CharacterStatsPane (ItemLevelFrame)
	SetFont(_G.Game16Font, GetKkthnxUIFont, 16) -- Added in 7.3.5 used for ?
	SetFont(_G.Game18Font, GetKkthnxUIFont, 18) -- MissionUI Bonus Chance
	SetFont(_G.Game20Font, GetKkthnxUIFont, 20)
	SetFont(_G.Game24Font, GetKkthnxUIFont, 24) -- Garrison Mission level (in detail frame)
	SetFont(_G.Game27Font, GetKkthnxUIFont, 27)
	SetFont(_G.Game30Font, GetKkthnxUIFont, 30) -- Mission Level
	SetFont(_G.Game32Font, GetKkthnxUIFont, 32)
	SetFont(_G.Game36Font, GetKkthnxUIFont, 36)
	SetFont(_G.Game40Font, GetKkthnxUIFont, 40)
	SetFont(_G.Game42Font, GetKkthnxUIFont, 42) -- PVP Stuff
	SetFont(_G.Game46Font, GetKkthnxUIFont, 46) -- Added in 7.3.5 used for ?
	SetFont(_G.Game48Font, GetKkthnxUIFont, 48)
	SetFont(_G.Game48FontShadow, GetKkthnxUIFont, 48)
	SetFont(_G.Game60Font, GetKkthnxUIFont, 60)
	SetFont(_G.Game72Font, GetKkthnxUIFont, 72)
	SetFont(_G.GameFontHighlightMedium, GetKkthnxUIFont, medium) -- 14 Fix QuestLog Title mouseover
	SetFont(_G.GameFontHighlightSmall2, GetKkthnxUIFont, small) -- 11 Skill or Recipe description on TradeSkill frame
	SetFont(_G.GameFontNormalHuge2, GetKkthnxUIFont, huge) -- 24 Mythic weekly best dungeon name
	SetFont(_G.GameFontNormalLarge, GetKkthnxUIFont, large) -- 16
	SetFont(_G.GameFontNormalLarge2, GetKkthnxUIFont, large) -- 18 Garrison Follower Names
	SetFont(_G.GameFontNormalMed1, GetKkthnxUIFont, medium) -- 13 WoW Token Info
	SetFont(_G.GameFontNormalMed2, GetKkthnxUIFont, medium) -- 14 Quest tracker
	SetFont(_G.GameFontNormalMed3, GetKkthnxUIFont, medium) -- 14
	SetFont(_G.GameFontNormalSmall2, GetKkthnxUIFont, small) -- 11 MissionUI Followers names
	SetFont(_G.GameFont_Gigantic, GetKkthnxUIFont, 32) -- Used at the install steps
	SetFont(_G.GameTooltipHeader, GetKkthnxUIFont, normal) -- 14
	SetFont(_G.InvoiceFont_Med, GetKkthnxUIFont, normal) -- 12 Mail
	SetFont(_G.InvoiceFont_Small, GetKkthnxUIFont, small) -- 10 Mail
	SetFont(_G.MailFont_Large, GetKkthnxUIFont, 14) -- 10 Mail
	SetFont(_G.Number11Font, GetKkthnxUIFont, 11)
	SetFont(_G.Number12Font, GetKkthnxUIFont, normal)
	SetFont(_G.Number12Font_o1, GetKkthnxUIFont, normal, "OUTLINE")
	SetFont(_G.Number13Font, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontGray, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontWhite, GetKkthnxUIFont, 13)
	SetFont(_G.Number13FontYellow, GetKkthnxUIFont, 13)
	SetFont(_G.Number14FontGray, GetKkthnxUIFont, 14)
	SetFont(_G.Number14FontWhite, GetKkthnxUIFont, 14)
	SetFont(_G.Number15Font, GetKkthnxUIFont, 15)
	SetFont(_G.Number15FontWhite, GetKkthnxUIFont, 15)
	SetFont(_G.Number16Font, GetKkthnxUIFont, 16)
	SetFont(_G.Number18Font, GetKkthnxUIFont, 18)
	SetFont(_G.Number18FontWhite, GetKkthnxUIFont, 18)
	SetFont(_G.NumberFontNormalSmall, GetKkthnxUIFont, small, "OUTLINE") -- 12 Calendar, EncounterJournal
	SetFont(_G.NumberFont_GameNormal, GetKkthnxUIFont, 10)
	SetFont(_G.NumberFont_Normal_Med, GetKkthnxUIFont, 14)
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, GetKkthnxUIFont, normal, "OUTLINE") -- 12
	SetFont(_G.NumberFont_Outline_Huge, GetKkthnxUIFont, huge, "OUTLINE") -- 30
	SetFont(_G.NumberFont_Outline_Large, GetKkthnxUIFont, large, "OUTLINE") -- 16
	SetFont(_G.NumberFont_Outline_Med, GetKkthnxUIFont, medium, "OUTLINE") -- 14
	SetFont(_G.NumberFont_Shadow_Med, GetKkthnxUIFont, medium) -- 14 Chat EditBox
	SetFont(_G.NumberFont_Shadow_Small, GetKkthnxUIFont, small) -- 12
	SetFont(_G.NumberFont_Shadow_Tiny, GetKkthnxUIFont, 10)
	SetFont(_G.NumberFont_Small, GetKkthnxUIFont, 12)
	SetFont(_G.PVPArenaTextString, GetKkthnxUIFont, 22, "OUTLINE")
	SetFont(_G.PVPInfoTextString, GetKkthnxUIFont, 22, "OUTLINE")
	SetFont(_G.PriceFont, GetKkthnxUIFont, 13)
	SetFont(_G.PriceFontGray, GetKkthnxUIFont, 14)
	SetFont(_G.PriceFontGreen, GetKkthnxUIFont, 14)
	SetFont(_G.PriceFontRed, GetKkthnxUIFont, 14)
	SetFont(_G.PriceFontWhite, GetKkthnxUIFont, 14)
	SetFont(_G.QuestFont, GetKkthnxUIFont, normal) -- 13
	SetFont(_G.QuestFont_Enormous, GetKkthnxUIFont, enormous) -- 30 Garrison Titles
	SetFont(_G.QuestFont_Huge, GetKkthnxUIFont, huge) -- 18 Quest rewards title(Rewards)
	SetFont(_G.QuestFont_Large, GetKkthnxUIFont, large) -- 14
	SetFont(_G.QuestFont_Shadow_Huge, GetKkthnxUIFont, huge) -- 18 Quest Title
	SetFont(_G.QuestFont_Shadow_Small, GetKkthnxUIFont, normal) -- 14
	SetFont(_G.QuestFont_Super_Huge, GetKkthnxUIFont, mega) -- 24
	SetFont(_G.RaidBossEmoteFrame.slot1, GetKkthnxUIFont, 20)
	SetFont(_G.RaidBossEmoteFrame.slot2, GetKkthnxUIFont, 20)
	SetFont(_G.RaidWarningFrame.slot1, GetKkthnxUIFont, 20)
	SetFont(_G.RaidWarningFrame.slot2, GetKkthnxUIFont, 20)
	SetFont(_G.ReputationDetailFont, GetKkthnxUIFont, normal) -- 10 Rep Desc when clicking a rep
	SetFont(_G.SpellFont_Small, GetKkthnxUIFont, 10)
	SetFont(_G.SplashHeaderFont, GetKkthnxUIFont, 24)
	SetFont(_G.SubSpellFont, GetKkthnxUIFont, 10) -- Spellbook Sub Names
	SetFont(_G.SubZoneTextFont, GetKkthnxUIFont, 24, "OUTLINE") -- 26 World Map(SubZone)
	SetFont(_G.SubZoneTextString, GetKkthnxUIFont, 25, "OUTLINE") -- 26
	SetFont(_G.SystemFont_Huge1, GetKkthnxUIFont, 20) -- Garrison Mission XP
	SetFont(_G.SystemFont_Huge1_Outline, GetKkthnxUIFont, 18, "OUTLINE") -- 20 Garrison Mission Chance
	SetFont(_G.SystemFont_Huge2, GetKkthnxUIFont, 22) -- 22 Mythic+ Score
	SetFont(_G.SystemFont_InverseShadow_Small, GetKkthnxUIFont, 10)
	SetFont(_G.SystemFont_Large, GetKkthnxUIFont, 16)
	SetFont(_G.SystemFont_LargeNamePlate, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12
	SetFont(_G.SystemFont_LargeNamePlateFixed, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12
	SetFont(_G.SystemFont_Med1, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.SystemFont_Med2, GetKkthnxUIFont, 13)
	SetFont(_G.SystemFont_Med3, GetKkthnxUIFont, medium) -- 14
	SetFont(_G.SystemFont_NamePlate, GetKkthnxUIFont, 9, "NONE", 0, 0, 0, 1, 1, -1) -- 9
	SetFont(_G.SystemFont_NamePlateCastBar, GetKkthnxUIFont, 11, "NONE", 0, 0, 0, 1, 1, -1) -- 12
	SetFont(_G.SystemFont_NamePlateFixed, GetKkthnxUIFont, 9, "NONE", 0, 0, 0, 1, 1, -1) -- 9
	SetFont(_G.SystemFont_Outline, GetKkthnxUIFont, normal, "OUTLINE") -- 13 Pet level on World map
	SetFont(_G.SystemFont_OutlineThick_Huge2, GetKkthnxUIFont, huge, "OUTLINE") -- 22
	SetFont(_G.SystemFont_OutlineThick_Huge4, GetKkthnxUIFont, 26, "OUTLINE")
	SetFont(_G.SystemFont_OutlineThick_WTF, GetKkthnxUIFont, enormous, "OUTLINE") -- 32 World Map
	SetFont(_G.SystemFont_Outline_Small, GetKkthnxUIFont, small, "OUTLINE") -- 10
	SetFont(_G.SystemFont_Shadow_Huge1, GetKkthnxUIFont, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(_G.SystemFont_Shadow_Huge2, GetKkthnxUIFont, 24)
	SetFont(_G.SystemFont_Shadow_Huge3, GetKkthnxUIFont, 22) -- 25 FlightMap
	SetFont(_G.SystemFont_Shadow_Huge4, GetKkthnxUIFont, 27, nil, nil, nil, nil, nil, 1, -1)
	SetFont(_G.SystemFont_Shadow_Large, GetKkthnxUIFont, 15)
	SetFont(_G.SystemFont_Shadow_Large2, GetKkthnxUIFont, 18) -- Auction House ItemDisplay
	SetFont(_G.SystemFont_Shadow_Large_Outline, GetKkthnxUIFont, 20, "OUTLINE") -- 16
	SetFont(_G.SystemFont_Shadow_Med1, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.SystemFont_Shadow_Med1_Outline, GetKkthnxUIFont, 12, OUTLINE)
	SetFont(_G.SystemFont_Shadow_Med2, GetKkthnxUIFont, medium) -- 14 Shows Order resourses on OrderHallTalentFrame
	SetFont(_G.SystemFont_Shadow_Med3, GetKkthnxUIFont, medium) -- 14
	SetFont(_G.SystemFont_Shadow_Small, GetKkthnxUIFont, small) -- 10
	SetFont(_G.SystemFont_Shadow_Small2, GetKkthnxUIFont, 11)
	SetFont(_G.SystemFont_Small, GetKkthnxUIFont, small) -- 10
	SetFont(_G.SystemFont_Small2, GetKkthnxUIFont, 11)
	SetFont(_G.SystemFont_Tiny, GetKkthnxUIFont, tiny) -- 09
	SetFont(_G.SystemFont_Tiny2, GetKkthnxUIFont, 8)
	SetFont(_G.SystemFont_WTF2, GetKkthnxUIFont, 64)
	SetFont(_G.SystemFont_World, GetKkthnxUIFont, 64)
	SetFont(_G.SystemFont_World_ThickOutline, GetKkthnxUIFont, 64)
	SetFont(_G.System_IME, GetKkthnxUIFont, 16)
	SetFont(_G.Tooltip_Med, GetKkthnxUIFont, normal) -- 12
	SetFont(_G.Tooltip_Small, GetKkthnxUIFont, small) -- 10
	SetFont(_G.ZoneTextString, GetKkthnxUIFont, enormous, "OUTLINE") -- 32

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

	-- Refont Titles Panel
	hooksecurefunc("PaperDollTitlesPane_UpdateScrollFrame", function()
		local bu = _G.PaperDollTitlesPane.buttons
		for i = 1, #bu do
			if not bu[i].fontStyled then
				SetFont(_G.bu[i].text, 12)
				bu[i].fontStyled = true
			end
		end
	end)
end)
