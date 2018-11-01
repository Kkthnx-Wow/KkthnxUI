local K, C = unpack(select(2, ...))
if C["Minimap"].Enable ~= true then
	return
end

local _G = _G

local ACHIEVEMENT_BUTTON = _G.ACHIEVEMENT_BUTTON
local ACHIEVEMENTS_GUILD_TAB = _G.ACHIEVEMENTS_GUILD_TAB
local BLIZZARD_STORE = _G.BLIZZARD_STORE
local CHARACTER_BUTTON = _G.CHARACTER_BUTTON
local CloseAllWindows = _G.CloseAllWindows
local CloseMenus = _G.CloseMenus
local CreateFrame = _G.CreateFrame
local GARRISON_TYPE_8_0_LANDING_PAGE_TITLE = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE
local GarrisonLandingPageMinimapButton_OnClick = _G.GarrisonLandingPageMinimapButton_OnClick
local HELP_BUTTON = _G.HELP_BUTTON
local HideUIPanel = _G.HideUIPanel
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsShiftKeyDown = _G.IsShiftKeyDown
local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local MainMenuMicroButton_SetNormal = _G.MainMenuMicroButton_SetNormal
local PlaySound = _G.PlaySound
local ShowUIPanel = _G.ShowUIPanel
local SOCIAL_BUTTON = _G.SOCIAL_BUTTON
local SPELLBOOK_ABILITIES_BUTTON = _G.SPELLBOOK_ABILITIES_BUTTON
local UIParent = _G.UIParent

local UIMiniMapTrackingMenu = CreateFrame("Frame", "UIMiniMapTrackingMenu", UIParent, "UIDropDownMenuTemplate")
UIMiniMapTrackingMenu:SetID(1)
UIMiniMapTrackingMenu:SetClampedToScreen(true)
UIMiniMapTrackingMenu:Hide()
UIDropDownMenu_Initialize(UIMiniMapTrackingMenu, MiniMapTrackingDropDown_Initialize, "MENU")
UIMiniMapTrackingMenu.noResize = true

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent)
local menuList = {
	{text = CHARACTER_BUTTON,
		icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
	notCheckable = true},

	{text = SPELLBOOK_ABILITIES_BUTTON,
		icon = "Interface\\MINIMAP\\TRACKING\\Class",
		func = function()
			if not SpellBookFrame:IsShown() then
				ShowUIPanel(SpellBookFrame)
			else
				HideUIPanel(SpellBookFrame)
			end
		end,
	notCheckable = true},

	{text = TALENTS_BUTTON,
		func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end

			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		end,
	notCheckable = true},

	{text = ACHIEVEMENT_BUTTON,
		func = function()
			ToggleAchievementFrame()
		end,
	notCheckable = true},

	{text = WORLD_MAP.." / "..QUESTLOG_BUTTON,
		func = function()
			ShowUIPanel(WorldMapFrame)
		end,
	notCheckable = true},

	{text = MOUNTS,
		icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
		func = function()
			ToggleCollectionsJournal(1)
		end,
	notCheckable = true},

	{text = CHAT_CHANNELS,
		func = function()
			ToggleChannelFrame()
		end,
	notCheckable = true},

	{text = PETS,
		icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
		func = function()
			ToggleCollectionsJournal(2)
		end,
	notCheckable = true},

	{text = TOY_BOX,
		icon = "Interface\\MINIMAP\\TRACKING\\Reagents",
		func = function() ToggleCollectionsJournal(3) end,
	notCheckable = true},

	{text = HEIRLOOMS,
		icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
		func = function()
			ToggleCollectionsJournal(4)
		end,
	notCheckable = true},

	{text = SOCIAL_BUTTON,
		func = function()
			ToggleFriendsFrame(1)
		end,
	notCheckable = true},

	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE.." / "..COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
		icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
		func = function()
			PVEFrame_ToggleFrame()
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

	{text = COMMUNITIES,
	func = function()
		ToggleCommunitiesFrame()
	end,
	notCheckable = true},

	{text = LFG_TITLE,
		func = function()
			ToggleLFDParentFrame()
		end,
	notCheckable = true},

	{text = RAID,
		icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
		func = function()
			ToggleFriendsFrame(3)
		end,
	notCheckable = true},

	{text = HELP_BUTTON,
		icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
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
		icon = "Interface\\MINIMAP\\TRACKING\\Profession",
		func = function()
			if not IsAddOnLoaded("Blizzard_EncounterJournal") then
				EncounterJournal_LoadUI()
			end
			ToggleFrame(EncounterJournal)
		end,
	notCheckable = true},

	{text = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
		func = function()
			GarrisonLandingPageMinimapButton_OnClick()
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
				elseif (AudioOptionsFrame:IsShown() ) then
					AudioOptionsFrameCancel:Click()
				elseif (InterfaceOptionsFrame:IsShown()) then
					InterfaceOptionsFrameCancel:Click()
				end
				CloseMenus()
				CloseAllWindows()
				PlaySound(850) -- IG_MAINMENU_OPEN
				ShowUIPanel(GameMenuFrame);
			else
				PlaySound(854) -- IG_MAINMENU_QUIT
				HideUIPanel(GameMenuFrame)
				MainMenuMicroButton_SetNormal()
			end
		end,
	notCheckable = true},

	{text = BLIZZARD_STORE,
		func = function()
			StoreMicroButton:Click()
		end,
	notCheckable = true},
}

Minimap:SetScript("OnMouseUp", function(self, button)
	local position = self:GetPoint()

	if (button == "MiddleButton") or (button == "RightButton" and IsShiftKeyDown()) then
		if (position:match("LEFT")) then
			EasyMenu(menuList, menuFrame, "cursor")
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0)
		end
	elseif (button == "RightButton") then
		ToggleDropDownMenu(1, nil, UIMiniMapTrackingMenu, "cursor")
	else
		Minimap_OnClick(self)
	end
end)