local _, C = unpack(select(2, ...))

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

local dropdownFontHeight = 12
local chatFontHeights = {12, 13, 14, 15, 16, 17, 18, 19, 20}
local function ForceUpdateBlizzardFonts()
	local NORMAL = C["Media"].Fonts.KkthnxUIFont
	local NUMBER = C["Media"].Fonts.KkthnxUIFont
	local COMBAT = C["Media"].Fonts.DamageFont
	local NAMEFONT = C["Media"].Fonts.KkthnxUIFont
	local BUBBLE = C["Media"].Fonts.KkthnxUIFont

	_G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = dropdownFontHeight
	_G.CHAT_FONT_HEIGHTS = chatFontHeights

	_G.UNIT_NAME_FONT = NAMEFONT
	_G.DAMAGE_TEXT_FONT = COMBAT
	_G.STANDARD_TEXT_FONT	= NORMAL

	local size = 12
	local medium = size * 1.1
	local small = size * 0.9

	SetFont(_G.ChatBubbleFont, BUBBLE, 11)	-- 13
	SetFont(_G.AchievementFont_Small, NORMAL, size)	-- 10 Achiev dates
	SetFont(_G.BossEmoteNormalHuge, NORMAL, 24) -- Talent Title
	SetFont(_G.CoreAbilityFont, NORMAL, 26) -- 32 Core abilities(title)
	SetFont(_G.DestinyFontHuge, NORMAL, 32) -- Garrison Mission Report
	SetFont(_G.DestinyFontMed, NORMAL, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy12Font, NORMAL, 12) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy14Font, NORMAL, 14) -- Added in 7.3.5 used for ?
	SetFont(_G.Fancy22Font, NORMAL, 20) -- Talking frame Title font
	SetFont(_G.Fancy24Font, NORMAL, 20) -- Artifact frame - weapon name
	SetFont(_G.FriendsFont_11, NORMAL, 11)
	SetFont(_G.FriendsFont_Large, NORMAL, size) -- 14
	SetFont(_G.FriendsFont_Normal, NORMAL, size) -- 12
	SetFont(_G.FriendsFont_Small, NORMAL, size) -- 10
	SetFont(_G.FriendsFont_UserText, NORMAL, size) -- 11
	SetFont(_G.Game10Font_o1, NORMAL, 10, "OUTLINE")
	SetFont(_G.Game120Font, NORMAL, 120)
	SetFont(_G.Game12Font, NORMAL, 12) -- PVP Stuff
	SetFont(_G.Game13FontShadow, NORMAL, 14) -- InspectPvpFrame
	SetFont(_G.Game15Font_o1, NORMAL, 15) -- CharacterStatsPane (ItemLevelFrame)
	SetFont(_G.Game16Font, NORMAL, 16) -- Added in 7.3.5 used for ?
	SetFont(_G.Game18Font, NORMAL, 18) -- MissionUI Bonus Chance
	SetFont(_G.Game24Font, NORMAL, 24) -- Garrison Mission level (in detail frame)
	SetFont(_G.Game30Font, NORMAL, 30) -- Mission Level
	SetFont(_G.Game40Font, NORMAL, 40)
	SetFont(_G.Game42Font, NORMAL, 42) -- PVP Stuff
	SetFont(_G.Game46Font, NORMAL, 46) -- Added in 7.3.5 used for ?
	SetFont(_G.Game48Font, NORMAL, 48)
	SetFont(_G.Game48FontShadow, NORMAL, 48)
	SetFont(_G.Game60Font, NORMAL, 60)
	SetFont(_G.Game72Font, NORMAL, 72)
	SetFont(_G.GameFontHighlightMedium, NORMAL, 15) -- 14 Fix QuestLog Title mouseover
	SetFont(_G.GameFontHighlightSmall2, NORMAL, size) -- 11 Skill or Recipe description on TradeSkill frame
	SetFont(_G.GameFontNormalHuge2, NORMAL, 24) -- 24 Mythic weekly best dungeon name
	SetFont(_G.GameFontNormalLarge, NORMAL, 16) -- 16
	SetFont(_G.GameFontNormalLarge2, NORMAL, 15) -- 18 Garrison Follower Names
	SetFont(_G.GameFontNormalMed1, NORMAL, 14) -- 13 WoW Token Info
	SetFont(_G.GameFontNormalMed2, NORMAL, medium) -- 14 Quest tracker
	SetFont(_G.GameFontNormalMed3, NORMAL, 15) -- 14
	SetFont(_G.GameFontNormalSmall2, NORMAL, 12) -- 11 MissionUI Followers names
	SetFont(_G.GameFont_Gigantic, NORMAL, 32) -- Used at the install steps
	SetFont(_G.GameTooltipHeader, NORMAL, size)					-- 14
	SetFont(_G.InvoiceFont_Med, NORMAL, 12) -- 12 Mail
	SetFont(_G.InvoiceFont_Small, NORMAL, size) -- 10 Mail
	SetFont(_G.MailFont_Large, NORMAL, 14) -- 10 Mail
	SetFont(_G.Number11Font, NORMAL, 11)
	SetFont(_G.Number11Font, NUMBER, 11)
	SetFont(_G.Number12Font, NORMAL, 12)
	SetFont(_G.Number12Font_o1, NUMBER, 12, "OUTLINE")
	SetFont(_G.Number13Font, NUMBER, 13)
	SetFont(_G.Number13FontGray, NUMBER, 13)
	SetFont(_G.Number13FontWhite, NUMBER, 13)
	SetFont(_G.Number13FontYellow, NUMBER, 13)
	SetFont(_G.Number14FontGray, NUMBER, 14)
	SetFont(_G.Number14FontWhite, NUMBER, 14)
	SetFont(_G.Number15Font, NORMAL, 15)
	SetFont(_G.Number18Font, NUMBER, 18)
	SetFont(_G.Number18FontWhite, NUMBER, 18)
	SetFont(_G.NumberFontNormalSmall, NORMAL, 11, "OUTLINE") -- 12 Calendar, EncounterJournal
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, NUMBER, size, "OUTLINE") -- 12
	SetFont(_G.NumberFont_Outline_Huge, NUMBER, 28, "OUTLINE") -- 30
	SetFont(_G.NumberFont_Outline_Large, NUMBER, 15, "OUTLINE") -- 16
	SetFont(_G.NumberFont_Outline_Med, NUMBER, medium, "OUTLINE") -- 14
	SetFont(_G.NumberFont_Shadow_Med, NORMAL, size) -- 14 Chat EditBox
	SetFont(_G.NumberFont_Shadow_Small, NORMAL, size) -- 12
	SetFont(_G.PVPArenaTextString, NORMAL, 22, "OUTLINE")
	SetFont(_G.PVPInfoTextString, NORMAL, 22, "OUTLINE")
	SetFont(_G.PriceFont, NORMAL, 13)
	SetFont(_G.QuestFont, NORMAL, size) -- 13
	SetFont(_G.QuestFont_Enormous, NORMAL, 24) -- 30 Garrison Titles
	SetFont(_G.QuestFont_Huge, NORMAL, 15) -- 18 Quest rewards title(Rewards)
	SetFont(_G.QuestFont_Large, NORMAL, 14) -- 14
	SetFont(_G.QuestFont_Shadow_Huge, NORMAL, 15) -- 18 Quest Title
	SetFont(_G.QuestFont_Shadow_Small, NORMAL, 14) -- 14
	SetFont(_G.QuestFont_Super_Huge, NORMAL, 22) -- 24
	SetFont(_G.ReputationDetailFont, NORMAL, size) -- 10 Rep Desc when clicking a rep
	SetFont(_G.SpellFont_Small, NORMAL, 10)
	SetFont(_G.SubSpellFont, NORMAL, 10) -- Spellbook Sub Names
	SetFont(_G.SubZoneTextFont, NORMAL, 24, "OUTLINE") -- 26 World Map(SubZone)
	SetFont(_G.SubZoneTextString, NORMAL, 25, "OUTLINE") -- 26
	SetFont(_G.SystemFont_Huge1, NORMAL, 20) -- Garrison Mission XP
	SetFont(_G.SystemFont_Huge1_Outline, NORMAL, 18, "OUTLINE") -- 20 Garrison Mission Chance
	SetFont(_G.SystemFont_Large, NORMAL, 15)
	SetFont(_G.SystemFont_Med1, NORMAL, size) -- 12
	SetFont(_G.SystemFont_Med3, NORMAL, medium) -- 14
	SetFont(_G.SystemFont_Outline, NORMAL, 13, "OUTLINE") -- 13 Pet level on World map
	SetFont(_G.SystemFont_OutlineThick_Huge2, NORMAL, 20, "OUTLINE") -- 22
	SetFont(_G.SystemFont_OutlineThick_WTF, NORMAL, 32, "OUTLINE") -- 32 World Map
	SetFont(_G.SystemFont_Outline_Small, NUMBER, size, "OUTLINE") -- 10
	SetFont(_G.SystemFont_Shadow_Huge1, NORMAL, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(_G.SystemFont_Shadow_Huge3, NORMAL, 22) -- 25 FlightMap
	SetFont(_G.SystemFont_Shadow_Huge4, NORMAL, 27, nil, nil, nil, nil, nil, 1, -1)
	SetFont(_G.SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(_G.SystemFont_Shadow_Large2, NORMAL, 18) -- Auction House ItemDisplay
	SetFont(_G.SystemFont_Shadow_Large_Outline, NUMBER, 20, "OUTLINE") -- 16
	SetFont(_G.SystemFont_Shadow_Med1, NORMAL, size) -- 12
	SetFont(_G.SystemFont_Shadow_Med2, NORMAL, 14.3) -- 14 Shows Order resourses on OrderHallTalentFrame
	SetFont(_G.SystemFont_Shadow_Med3, NORMAL, medium) -- 14
	SetFont(_G.SystemFont_Shadow_Small, NORMAL, small) -- 10
	SetFont(_G.SystemFont_Small, NORMAL, size) -- 10
	SetFont(_G.SystemFont_Tiny, NORMAL, size) -- 09
	SetFont(_G.Tooltip_Med, NORMAL, size) -- 12
	SetFont(_G.Tooltip_Small, NORMAL, size) -- 10
	SetFont(_G.ZoneTextString, NORMAL, 32, "OUTLINE") -- 32

	-- Text that does not follow our fonts fixed below
	WorldMapFrame.NavBar.homeButton.text:FontTemplate()

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
		local button = self.CategoryButtons[btnIndex]
		if button then
			if not button.isFontUpdated then
				button.Label:SetFontObject(_G.GameFontNormal)
				button.isFontUpdated = true
			end
		end
	end)
end

ForceUpdateBlizzardFonts()