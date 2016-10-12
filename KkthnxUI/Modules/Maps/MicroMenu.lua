local K, C, L = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

local match = string.match
local CreateFrame, UIParent = CreateFrame, UIParent
local ToggleFrame = ToggleFrame
local ToggleDropDownMenu = ToggleDropDownMenu

local MicroMenu = CreateFrame("Frame", "MicroButtonsDropDown", UIParent, "UIDropDownMenuTemplate")

MicroMenu.Buttons = {
	{text = ACHIEVEMENT_BUTTON,
		func = function()
			ToggleAchievementFrame()
		end,
	notCheckable = true},

	{text = CHARACTER_BUTTON,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
	notCheckable = true},

	{text = SPELLBOOK_ABILITIES_BUTTON,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end
		end,
	notCheckable = true},

	{text = TALENTS_BUTTON,
		func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if K.Level >= SHOW_TALENT_LEVEL then
				ShowUIPanel(PlayerTalentFrame)
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL), 1, 0.1, 0.1)
				else
					print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
				end
			end
		end,
	notCheckable = true},

	{text = WORLD_MAP.." / "..QUESTLOG_BUTTON,
		func = function()
			ShowUIPanel(WorldMapFrame)
		end,
	notCheckable = true},

	{text = MOUNTS,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal(1)
		end,
	notCheckable = true},

	{text = PETS,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal(2)
		end,
	notCheckable = true},

	{text = TOY_BOX,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
		ToggleCollectionsJournal(3) end,
	notCheckable = true},

	{text = HEIRLOOMS,
		func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal(4)
		end,
	notCheckable = true},

	{text = SOCIAL_BUTTON,
		func = function()
			ToggleFriendsFrame(1)
		end,
	notCheckable = true},

	{text = PLAYER_V_PLAYER,
		func = function()
			if K.Level >= SHOW_PVP_LEVEL then
				TogglePVPUI()
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL), 1, 0.1, 0.1)
				else
					print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL).."|r")
				end
			end
		end,
	notCheckable = true},

	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE,
		func = function()
			if K.Level >= SHOW_LFD_LEVEL then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL), 1, 0.1, 0.1)
				else
					print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL).."|r")
				end
			end
		end,
	notCheckable = true},

	{text = ACHIEVEMENTS_GUILD_TAB,
		func = function()
			if IsInGuild() then
				if (not GuildFrame) then
					GuildFrame_LoadUI()
				end

				GuildFrame_Toggle()
			else
				if (not LookingForGuildFrame) then
					LookingForGuildFrame_LoadUI()
				end

				LookingForGuildFrame_Toggle()
			end
		end,
	notCheckable = true},

	{text = RAID,
		func = function()
			ToggleFriendsFrame(4)
		end,
	notCheckable = true},

	{text = HELP_BUTTON,
		func = function()
			ToggleHelpFrame()
		end,
	notCheckable = true},

	{text = CALENDAR_VIEW_EVENT,
		func = function()
			if (not CalendarFrame) then
				LoadAddOn("Blizzard_Calendar")
			end

			Calendar_Toggle()
		end,
	notCheckable = true},

	{text = ENCOUNTER_JOURNAL,
		func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(FEATURE_NOT_YET_AVAILABLE, 1, 0.1, 0.1)
				else
					print("|cffffff00"..FEATURE_NOT_YET_AVAILABLE.."|r")
				end
			end
		end,
	notCheckable = true},

	{text = ORDER_HALL_LANDING_PAGE_TITLE,
		func = function()
			if K.Level > 89 then
				GarrisonLandingPageMinimapButton_OnClick()
			end
		end,
	notCheckable = true},

	{text = LOOT_ROLLS,
		func = function()
			ToggleFrame(LootHistoryFrame)
		end,
	notCheckable = true},

	{text = SOCIAL_TWITTER_COMPOSE_NEW_TWEET,
		func = function()
			if not SocialPostFrame then
				LoadAddOn("Blizzard_SocialUI")
			end

			local IsTwitterEnabled = C_Social.IsSocialEnabled()

			if IsTwitterEnabled then
				Social_SetShown(true)
			else
				K.Print(SOCIAL_TWITTER_TWEET_NOT_LINKED)
			end
		end,
	notCheckable = true},

	{text = MAINMENU_BUTTON,
		func = function()
			if (not GameMenuFrame:IsShown()) then
				if (VideoOptionsFrame:IsShown()) then
					VideoOptionsFrameCancel:Click()
				elseif (AudioOptionsFrame:IsShown()) then
					AudioOptionsFrameCancel:Click()
				elseif (InterfaceOptionsFrame:IsShown()) then
					InterfaceOptionsFrameCancel:Click()
				end
				CloseMenus()
				CloseAllWindows()
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
				MainMenuMicroButton_SetNormal()
			end
		end,
	notCheckable = true},
}

if not IsTrialAccount() and not C_StorePublic.IsDisabledByParentalControls() then
	tinsert(MicroMenu.Buttons, {text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end, notCheckable = true})
end

Minimap:SetScript("OnMouseUp", function(self, button)
	local position = MinimapAnchor:GetPoint()
	if button == "RightButton" then
		if position:match("LEFT") then
			Lib_EasyMenu(MicroMenu.Buttons, MicroMenu, "cursor", 0, 0, "MENU")
		else
			Lib_EasyMenu(MicroMenu.Buttons, MicroMenu, "cursor", K.Scale(-160), 0, "MENU", 2)
		end
	elseif button == "MiddleButton" then
		if position:match("LEFT") then
			ToggleDropDownMenu(nil, nil, MiniMapTrackingDropDown, "cursor", 0, 0, "MENU", 2)
		else
			ToggleDropDownMenu(nil, nil, MiniMapTrackingDropDown, "cursor", -160, 0, "MENU", 2)
		end
	elseif button == "LeftButton" then
		Minimap_OnClick(self)
	end
end)