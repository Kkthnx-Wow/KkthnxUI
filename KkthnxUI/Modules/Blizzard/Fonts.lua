local K, C = unpack(select(2, ...))

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local hooksecurefunc = _G.hooksecurefunc

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
end

local function UpdateBlizzardFonts()
	local BLANK_FONT = C["Media"].BlankFont
	local BUBBLE_FONT = C["Media"].Font
	local COMBAT_FONT = C["Media"].CombatFont
	local NORMAL_FONT = C["Media"].Font

	local SHADOW_COLOR = 0, 0, 0, 1
	local NORMAL_OFFSET = 1.25, -1.25
	local BIG_OFFSET = 2, -2

	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT = NORMAL_FONT
	DAMAGE_TEXT_FONT = COMBAT_FONT
	STANDARD_TEXT_FONT = NORMAL_FONT

	if (K.ScreenWidth > 3840) then
		_G.SetCVar("floatingcombattextcombatdamage", 0)
		_G.SetCVar("floatingcombattextcombathealing", 0)
		_G.SetCVar("floatingcombattextcombatlogperiodicspells", 0)
		_G.SetCVar("floatingcombattextpetmeleedamage", 0)

		-- set an invisible font for xp, honor kill, etc
		COMBAT_FONT = BLANK_FONT
	end

	-- Base fonts
	SetFont(AchievementFont_Small,				NORMAL_FONT, C["General"].FontSize)			 -- Achiev dates
	SetFont(BossEmoteNormalHuge,				NORMAL_FONT, 24)								 -- Talent Title
	SetFont(ChatBubbleFont,						BUBBLE_FONT, C["General"].BubbleFontSize)
	SetFont(CombatTextFont, 					COMBAT_FONT, 200, "OUTLINE") -- number here just increase the font quality.
	SetFont(CoreAbilityFont,					NORMAL_FONT, 26)								 -- Core abilities(title)
	SetFont(DestinyFontHuge,					NORMAL_FONT, 20, nil, SHADOW_COLOR, BIG_OFFSET)	 -- Garrison Mission Report
	SetFont(Fancy22Font,						NORMAL_FONT, 20)									 -- Talking frame Title font
	SetFont(Fancy24Font,						NORMAL_FONT, 20)									 -- Artifact frame - weapon name
	SetFont(FriendsFont_Large, 					NORMAL_FONT, C["General"].FontSize)
	SetFont(FriendsFont_Normal,					NORMAL_FONT, C["General"].FontSize)
	SetFont(FriendsFont_Small, 					NORMAL_FONT, C["General"].FontSize)
	SetFont(FriendsFont_UserText, 				NORMAL_FONT, C["General"].FontSize)
	SetFont(Game13FontShadow,					NORMAL_FONT, 14)									 -- InspectPvpFrame
	SetFont(Game15Font_o1,						NORMAL_FONT, 15)									 -- CharacterStatsPane (ItemLevelFrame)
	SetFont(Game18Font,							NORMAL_FONT, 18)									 -- MissionUI Bonus Chance
	SetFont(Game24Font, 						NORMAL_FONT, 24)								 -- Garrison Mission level (in detail frame)
	SetFont(SystemFont_Shadow_Large2, 			NORMAL_FONT, 17)
	SetFont(Game30Font,							NORMAL_FONT, 28)									 -- Mission Level
	SetFont(GameFont_Gigantic,					NORMAL_FONT, 32, nil, SHADOW_COLOR, BIG_OFFSET)		 -- Used at the install steps
	SetFont(GameFontHighlightMedium,			NORMAL_FONT, 15)								 -- Fix QuestLog Title mouseover
	SetFont(GameFontHighlightMedium, 			NORMAL_FONT, 15)
	SetFont(GameFontHighlightSmall2,			NORMAL_FONT, C["General"].FontSize)			 -- Skill or Recipe description on TradeSkill frame
	SetFont(GameFontNormalHuge2,				NORMAL_FONT, 24)			 					 	 -- Mythic weekly best dungeon name
	SetFont(GameFontNormalLarge2,				NORMAL_FONT, 15) 								 -- Garrison Follower Names
	SetFont(GameFontNormalMed2,					NORMAL_FONT, C["General"].FontSize*1.1)		 -- Quest tracker
	SetFont(GameFontNormalMed3,					NORMAL_FONT, 15)
	SetFont(GameFontNormalSmall2,				NORMAL_FONT, 12)			 					 	 -- MissionUI Followers names
	SetFont(GameTooltipHeader, 					NORMAL_FONT, C["General"].FontSize)
	SetFont(InvoiceFont_Med,					NORMAL_FONT, 12)								 -- mail
	SetFont(InvoiceFont_Small,					NORMAL_FONT, C["General"].FontSize)			 -- mail
	SetFont(MailFont_Large,						NORMAL_FONT, 14)								 -- mail
	SetFont(NumberFont_Outline_Huge, 			NORMAL_FONT, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large, 			NORMAL_FONT, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, 			NORMAL_FONT, C["General"].FontSize*1.1, "OUTLINE")
	SetFont(NumberFont_OutlineThick_Mono_Small, NORMAL_FONT, C["General"].FontSize, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, 				NORMAL_FONT, C["General"].FontSize) --chat editbox uses this
	SetFont(NumberFont_Shadow_Small, 			NORMAL_FONT, C["General"].FontSize)
	SetFont(NumberFontNormalSmall,				NORMAL_FONT, 11, "OUTLINE")						 -- Calendar, EncounterJournal
	SetFont(PVPArenaTextString,					NORMAL_FONT, 22, "OUTLINE")
	SetFont(PVPInfoTextString,					NORMAL_FONT, 22, "OUTLINE")
	SetFont(QuestFont, 							NORMAL_FONT, C["General"].FontSize)
	SetFont(QuestFont_Enormous, 				NORMAL_FONT, 24, nil, SHADOW_COLOR, NORMAL_OFFSET) -- Garrison Titles
	SetFont(QuestFont_Huge,						NORMAL_FONT, 15, nil, SHADOW_COLOR, BIG_OFFSET)	 -- Quest rewards title(Rewards)
	SetFont(QuestFont_Large, 					NORMAL_FONT, 14)
	SetFont(QuestFont_Shadow_Huge, 				NORMAL_FONT, 15, nil, SHADOW_COLOR, NORMAL_OFFSET) -- Quest Title
	SetFont(QuestFont_Shadow_Small, 			NORMAL_FONT, 14, nil, SHADOW_COLOR, NORMAL_OFFSET)
	SetFont(QuestFont_Super_Huge,				NORMAL_FONT, 22, nil, SHADOW_COLOR, BIG_OFFSET)
	SetFont(ReputationDetailFont,				NORMAL_FONT, C["General"].FontSize)			 -- Rep Desc when clicking a rep
	SetFont(SubZoneTextFont,					NORMAL_FONT, 24, "OUTLINE")			 -- World Map(SubZone)
	SetFont(SubZoneTextString,					NORMAL_FONT, 25, "OUTLINE")
	SetFont(SystemFont_Huge1, 					NORMAL_FONT, 20)								 -- Garrison Mission XP
	SetFont(SystemFont_Huge1_Outline, 			NORMAL_FONT, 18, "OUTLINE")			 -- Garrison Mission Chance
	SetFont(SystemFont_Large, 					NORMAL_FONT, 15)
	SetFont(SystemFont_Med1, 					NORMAL_FONT, C["General"].FontSize)
	SetFont(SystemFont_Med3, 					NORMAL_FONT, C["General"].FontSize*1.1)
	SetFont(SystemFont_Outline, 				NORMAL_FONT, 13, "OUTLINE")			 -- Pet level on World map
	SetFont(SystemFont_Outline_Small, 			NORMAL_FONT, C["General"].FontSize, "OUTLINE")
	SetFont(SystemFont_OutlineThick_Huge2, 		NORMAL_FONT, 20, "THICKOUTLINE")
	SetFont(SystemFont_OutlineThick_WTF,		NORMAL_FONT, 32, "OUTLINE")			 -- World Map
	SetFont(SystemFont_Shadow_Huge1,			NORMAL_FONT, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Shadow_Large, 			NORMAL_FONT, 15)
	SetFont(SystemFont_Shadow_Large_Outline,	NORMAL_FONT, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Med1, 			NORMAL_FONT, C["General"].FontSize)
	SetFont(SystemFont_Shadow_Med2,				NORMAL_FONT, 13 * 1.1)							 -- Shows Order resourses on OrderHallTalentFrame
	SetFont(SystemFont_Shadow_Med3,				NORMAL_FONT, 13 * 1.1)
	SetFont(SystemFont_Shadow_Med3, 			NORMAL_FONT, C["General"].FontSize*1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2, 	NORMAL_FONT, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, 			NORMAL_FONT, C["General"].FontSize*0.9)
	SetFont(SystemFont_Small,					NORMAL_FONT, C["General"].FontSize)
	SetFont(SystemFont_Tiny, 					NORMAL_FONT, C["General"].FontSize)
	SetFont(Tooltip_Med, 						NORMAL_FONT, C["General"].FontSize)
	SetFont(Tooltip_Small, 						NORMAL_FONT, C["General"].FontSize)
	SetFont(ZoneTextString,						NORMAL_FONT, 32, "OUTLINE")

	-- Sourced: DiabolicUI, (Goldpaw)
	_G.hooksecurefunc("PaperDollFrame_SetArmor", function(frame, unit)
		if unit ~= "player" then
			return
		end

		PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, unit)
		CharacterStatsPane.ItemLevelCategory:Show()
		CharacterStatsPane.ItemLevelFrame:Show()
		CharacterStatsPane.AttributesCategory:SetPoint("TOP", CharacterStatsPane.ItemLevelFrame, "BOTTOM", 0, -10)
		local msg = CharacterStatsPane.ItemLevelFrame.Value

		local total, equip = _G.GetAverageItemLevel()
		if total > 0 then
			if equip == total then
				msg:SetFormattedText("|cffffeeaa%.1f|r", equip)
			else
				msg:SetFormattedText("|cffffeeaa%.1f / %.1f|r", equip, total)
			end
		else
			msg:SetFormattedText("|cffffeeaa%s|r", _G.NONE)
		end
	end)

	-- Fix some fonts to follow our font.
	WorldMapFrameNavBarHomeButton.text:SetFontObject(SystemFont_Shadow_Med1)
	WorldMapFrame.UIElementsFrame.BountyBoard.BountyName:FontTemplate(nil, 14, "OUTLINE")
	SplashFrame.Header:FontTemplate(nil, 22)
	if IsAddOnLoaded("Blizzard_Collections") then
		WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.Name:FontTemplate(nil, 16)
	end
	LFGListFrame.ApplicationViewer.NameColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.RoleColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.PrivateGroup:FontTemplate()
	TalentMicroButtonAlert.Text:FontTemplate()

	-- Fix issue with labels not following changes to GameFontNormal as they should
	local function SetLabelFontObject(self, btnIndex)
		local button = self.CategoryButtons[btnIndex]
		if button then
			button.Label:SetFontObject(GameFontNormal)
		end
	end
	_G.hooksecurefunc("LFGListCategorySelection_AddButton", SetLabelFontObject)

	local function Channel()
		for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
			local button = _G["ChannelButton"..i]
			if button then
				button:StripTextures()
				button:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")

				_G["ChannelButton"..i.."Text"]:FontTemplate(nil, 12)
			end
		end
	end
	hooksecurefunc("ChannelList_Update", Channel)

	--Titles
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for _, object in pairs(PaperDollTitlesPane.buttons) do
			object.text:FontTemplate()
			hooksecurefunc(object.text, "SetFont", function(self, font)
				if font ~= C["Media"].Font then
					self:FontTemplate()
				end
			end)
		end
	end)

	-- Fix help frame category buttons, NFI why they need fixing
	for i = 1, 6 do
		_G["HelpFrameButton"..i.."Text"]:SetFontObject(GameFontNormalMed3)
	end
end

-- New Fonts Need to be set as soon as possible...
if C["General"].ReplaceBlizzardFonts and not K.IsAddOnEnabled("tekticles") then
	UpdateBlizzardFonts()
end
