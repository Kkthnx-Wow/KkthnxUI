local K, C, L = unpack(select(2, ...))
if C["Minimap"].Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format

-- Wow API
local ClearAllTracking = _G.ClearAllTracking
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetNumTrackingTypes = _G.GetNumTrackingTypes
local GetTrackingInfo = _G.GetTrackingInfo
local HUNTER_TRACKING = _G.HUNTER_TRACKING
local HUNTER_TRACKING_TEXT = _G.HUNTER_TRACKING_TEXT
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local L_EasyMenu = _G.L_EasyMenu
local L_L_UIDropDownMenu_CreateInfo = _G.L_L_UIDropDownMenu_CreateInfo
local L_ToggleDropDownMenu = _G.L_ToggleDropDownMenu
local L_UIDropDownMenu_AddButton = _G.L_UIDropDownMenu_AddButton
local LoadAddOn = _G.LoadAddOn
local MINIMAP_TRACKING_NONE = _G.MINIMAP_TRACKING_NONE
local MiniMapTracking_SetTracking = _G.MiniMapTracking_SetTracking
local MiniMapTrackingDropDown_IsNoTrackingActive = _G.MiniMapTrackingDropDown_IsNoTrackingActive
local MiniMapTrackingDropDownButton_IsActive = _G.MiniMapTrackingDropDownButton_IsActive
local ShowUIPanel = _G.ShowUIPanel
local SOCIAL_TWITTER_TWEET_NOT_LINKED = _G.SOCIAL_TWITTER_TWEET_NOT_LINKED
local ToggleAchievementFrame = _G.ToggleAchievementFrame
local ToggleFrame = _G.ToggleFrame
local TOWNSFOLK = _G.TOWNSFOLK
local TOWNSFOLK_TRACKING_TEXT = _G.TOWNSFOLK_TRACKING_TEXT
local UIErrorsFrame = _G.UIErrorsFrame
local UnitClass = _G.UnitClass

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CalendarFrame, SocialPostFrame, C_Social, Social_SetShown, L_UIDROPDOWNMENU_MENU_VALUE
-- GLOBALS: FEATURE_BECOMES_AVAILABLE_AT_LEVEL, ToggleQuestLog, ToggleGuildFrame, Calendar_Toggle
-- GLOBALS: GuildFrame_TabClicked, GuildFrameTab2, ToggleFriendsFrame, SHOW_PVP_LEVEL
-- GLOBALS: MiniMapTrackingDropDown, ToggleDropDownMenu, Minimap_OnClick, ToggleCharacter
-- GLOBALS: SpellBookFrame, PlayerTalentFrame, TalentFrame_LoadUI, SHOW_TALENT_LEVEL
-- GLOBALS: StoreMicroButton, L_EasyMenu, GarrisonLandingPage_Toggle, MinimapAnchor
-- GLOBALS: ToggleEncounterJournal, FEATURE_NOT_YET_AVAILABLE, ToggleCollectionsJournal
-- GLOBALS: ToggleHelpFrame, ToggleCalendar, ToggleBattlefieldMinimap, LootHistoryFrame
-- GLOBALS: TogglePVPUI, SHOW_LFD_LEVEL, PVEFrame_ToggleFrame, C_AdventureJournal, HideUIPanel

-- This function is copied from FrameXML and modified to use DropDownMenu library function calls
-- Using the regular DropDownMenu code causes taints in various places.
local function MiniMapTrackingDropDown_Initialize(self, level)
	local name, texture, active, category, nested, numTracking
	local count = GetNumTrackingTypes()
	local info
	local _, class = UnitClass("player")

	if (level == 1) then
		info = L_L_UIDropDownMenu_CreateInfo()
		info.text = MINIMAP_TRACKING_NONE
		info.checked = MiniMapTrackingDropDown_IsNoTrackingActive
		info.func = ClearAllTracking
		info.icon = nil
		info.arg1 = nil
		info.isNotRadio = true
		info.keepShownOnClick = true
		L_UIDropDownMenu_AddButton(info, level)

		if (class == "HUNTER") then -- only show hunter dropdown for hunters
			numTracking = 0
			-- make sure there are at least two options in dropdown
			for id = 1, count do
				name, texture, active, category, nested = GetTrackingInfo(id)
				if (nested == HUNTER_TRACKING and category == "spell") then
					numTracking = numTracking + 1
				end
			end
			if (numTracking > 1) then
				info.text = HUNTER_TRACKING_TEXT
				info.func = nil
				info.notCheckable = true
				info.keepShownOnClick = false
				info.hasArrow = true
				info.value = HUNTER_TRACKING
				L_UIDropDownMenu_AddButton(info, level)
			end
		end

		info.text = TOWNSFOLK_TRACKING_TEXT
		info.func = nil
		info.notCheckable = true
		info.keepShownOnClick = false
		info.hasArrow = true
		info.value = TOWNSFOLK
		L_UIDropDownMenu_AddButton(info, level)
	end

	for id = 1, count do
		name, texture, active, category, nested = GetTrackingInfo(id)
		info = L_L_UIDropDownMenu_CreateInfo()
		info.text = name
		info.checked = MiniMapTrackingDropDownButton_IsActive
		info.func = MiniMapTracking_SetTracking
		info.icon = texture
		info.arg1 = id
		info.isNotRadio = true
		info.keepShownOnClick = true
		if (category == "spell") then
			info.tCoordLeft = 0.0625
			info.tCoordRight = 0.9
			info.tCoordTop = 0.0625
			info.tCoordBottom = 0.9
		else
			info.tCoordLeft = 0
			info.tCoordRight = 1
			info.tCoordTop = 0
			info.tCoordBottom = 1
		end
		if (level == 1 and
		(nested < 0 or -- this tracking shouldn't be nested
		(nested == HUNTER_TRACKING and class ~= "HUNTER") or
		(numTracking == 1 and category == "spell"))) then -- this is a hunter tracking ability, but you only have one
			L_UIDropDownMenu_AddButton(info, level)
		elseif (level == 2 and (nested == TOWNSFOLK or (nested == HUNTER_TRACKING and class == "HUNTER")) and nested == L_UIDROPDOWNMENU_MENU_VALUE) then
			L_UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Create the new minimap tracking dropdown frame and initialize it
local KkthnxUIMiniMapTrackingDropDown = CreateFrame("Frame", "KkthnxUIMiniMapTrackingDropDown", UIParent, "L_UIDropDownMenuTemplate")
KkthnxUIMiniMapTrackingDropDown:SetID(1)
KkthnxUIMiniMapTrackingDropDown:SetClampedToScreen(true)
KkthnxUIMiniMapTrackingDropDown:Hide()
L_UIDropDownMenu_Initialize(KkthnxUIMiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU")
KkthnxUIMiniMapTrackingDropDown.noResize = true

local guildText = IsInGuild() and ACHIEVEMENTS_GUILD_TAB or LOOKINGFORGUILD
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent)
local micromenu = {
	{
		text = MAINMENU_BUTTON,
		isTitle = true,
		notCheckable = true,
	},
	{text = CHARACTER_BUTTON, icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle", notCheckable = 1, func = function()
			ToggleCharacter("PaperDollFrame")
	end},
	{text = SPELLBOOK_ABILITIES_BUTTON, icon = "Interface\\MINIMAP\\TRACKING\\Class", notCheckable = 1, func = function()
			if InCombatLockdown() then
				K.Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end
	end},
	{text = TALENTS_BUTTON, icon = "Interface\\MINIMAP\\TRACKING\\Ammunition", notCheckable = 1, func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if K.Level >= SHOW_TALENT_LEVEL then
				ShowUIPanel(PlayerTalentFrame)
			else
				if C["Error"].White == false then
					UIErrorsFrame:AddMessage(string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
				end
			end
	end},
	{text = ACHIEVEMENT_BUTTON, icon = "Interface\\cursor\\Directions", notCheckable = 1, func = function()
			ToggleAchievementFrame()
	end},
	{text = QUESTLOG_BUTTON, icon = "Interface\\GossipFrame\\ActiveQuestIcon", notCheckable = 1, func = function()
			ToggleQuestLog()
	end},
	{text = guildText, icon = "Interface\\GossipFrame\\TabardGossipIcon", notCheckable = 1, func = function()
			ToggleGuildFrame()
			if IsInGuild() then
				GuildFrame_TabClicked(GuildFrameTab2)
			end
	end},
	{text = SOCIAL_BUTTON, icon = "Interface\\FriendsFrame\\PlusManz-BattleNet", notCheckable = 1, func = function()
			ToggleFriendsFrame()
	end},
	{text = PLAYER_V_PLAYER, icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster", notCheckable = 1, func = function()
			if K.Level >= SHOW_PVP_LEVEL then
				TogglePVPUI()
			else
				if C["Error"].White == false then
					UIErrorsFrame:AddMessage(string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL).."|r")
				end
			end
	end},
	{text = DUNGEONS_BUTTON, icon = "Interface\\LFGFRAME\\BattleNetWorking0", notCheckable = 1, func = function()
			if K.Level >= SHOW_LFD_LEVEL then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				if C["Error"].White == false then
					UIErrorsFrame:AddMessage(string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL).."|r")
				end
			end
	end},
	{text = ADVENTURE_JOURNAL, icon = "Interface\\MINIMAP\\TRACKING\\Profession", notCheckable = 1, func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				if C["Error"].White == false then
					UIErrorsFrame:AddMessage(FEATURE_NOT_YET_AVAILABLE, 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..FEATURE_NOT_YET_AVAILABLE.."|r")
				end
			end
	end},
	{text = HEIRLOOMS, icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle", notCheckable = 1, func = function()
			ToggleCollectionsJournal(4)
	end},
	{text = COLLECTIONS, icon = "Interface\\MINIMAP\\TRACKING\\StableMaster", notCheckable = 1, func = function()
			if InCombatLockdown() then
				K.Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal()
	end},
	{text = HELP_BUTTON, icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz", notCheckable = 1, func = function()
			ToggleHelpFrame()
	end},
	{text = CALENDAR_VIEW_EVENT, icon = "Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp", notCheckable = 1, func = function()
			if (not CalendarFrame) then
				LoadAddOn("Blizzard_Calendar")
			end
			Calendar_Toggle()
	end},
	{text = BATTLEFIELD_MINIMAP, colorCode = "|cff999999", icon = "Interface\\PVPFrame\\Icon-Combat", notCheckable = 1, func = function()
			ToggleBattlefieldMinimap()
	end},
	{text = LOOT_ROLLS, icon = "Interface\\Buttons\\UI-GroupLoot-Dice-Up", notCheckable = 1, func = function()
			ToggleFrame(LootHistoryFrame)
	end},
	{text = "Compose New Tweet", icon = "Interface\\FriendsFrame\\BroadcastIcon", notCheckable = 1, func = function()
			if not SocialPostFrame then
				LoadAddOn("Blizzard_SocialUI")
			end
			local IsTwitterEnabled = C_Social.IsSocialEnabled()
			if IsTwitterEnabled then
				Social_SetShown(true)
			else
				K.Print(SOCIAL_TWITTER_TWEET_NOT_LINKED)
			end
	end},
}

if GameMenuButtonStore and ((C_StorePublic and not C_StorePublic.IsEnabled()) and not C_StorePublic.IsDisabledByParentalControls()
or (IsTrialAccount and IsTrialAccount()) or (GameLimitedMode_IsActive and GameLimitedMode_IsActive())) then
	tinsert(micromenu, {text = BLIZZARD_STORE, icon = "Interface\\MINIMAP\\TRACKING\\None", notCheckable = 1, func = function() StoreMicroButton:Click() end})
end

if K.Level > 99 then
	tinsert(micromenu, {text = ORDER_HALL_LANDING_PAGE_TITLE, icon = "", notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
elseif K.Level > 89 then
	tinsert(micromenu, {text = GARRISON_LANDING_PAGE_TITLE, icon = "", notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
end

Minimap:SetScript("OnMouseUp", function(self, btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if position:match("LEFT") then
			L_EasyMenu(micromenu, menuFrame, "cursor")
		else
			L_EasyMenu(micromenu, menuFrame, "cursor", -160, 0)
		end
	elseif btn == "RightButton" then
		L_ToggleDropDownMenu(1, nil, KkthnxUIMiniMapTrackingDropDown, "cursor")
	else
		Minimap_OnClick(self)
	end
end)