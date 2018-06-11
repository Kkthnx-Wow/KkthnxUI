local K, C = unpack(select(2, ...))
if C["Minimap"].Enable ~= true then
	return
end

local _G = _G
local string_format = string.format
local table_insert = table.insert

local ACHIEVEMENT_BUTTON = _G.ACHIEVEMENT_BUTTON
local ACHIEVEMENTS_GUILD_TAB = _G.ACHIEVEMENTS_GUILD_TAB
local ADVENTURE_JOURNAL = _G.ADVENTURE_JOURNAL
local BATTLEFIELD_MINIMAP = _G.BATTLEFIELD_MINIMAP
local BLIZZARD_STORE = _G.BLIZZARD_STORE
local C_AdventureJournal_CanBeShown = _G.C_AdventureJournal.CanBeShown
local C_Social_IsSocialEnabled = _G.C_Social.IsSocialEnabled
local C_StorePublic = _G.C_StorePublic
local C_StorePublic_IsDisabledByParentalControls = _G.C_StorePublic.IsDisabledByParentalControls
local C_StorePublic_IsEnabled = _G.C_StorePublic.IsEnabled
local CALENDAR_VIEW_EVENT = _G.CALENDAR_VIEW_EVENT
local CHARACTER_BUTTON = _G.CHARACTER_BUTTON
local COLLECTIONS = _G.COLLECTIONS
local CreateFrame = _G.CreateFrame
local DUNGEONS_BUTTON = _G.DUNGEONS_BUTTON
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local FEATURE_BECOMES_AVAILABLE_AT_LEVEL = _G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL
local FEATURE_NOT_YET_AVAILABLE = _G.FEATURE_NOT_YET_AVAILABLE
local GameLimitedMode_IsActive = _G.GameLimitedMode_IsActive
local GARRISON_LANDING_PAGE_TITLE = _G.GARRISON_LANDING_PAGE_TITLE
local HEIRLOOMS = _G.HEIRLOOMS
local HELP_BUTTON = _G.HELP_BUTTON
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsTrialAccount = _G.IsTrialAccount
local LoadAddOn = _G.LoadAddOn
local LOOKINGFORGUILD = _G.LOOKINGFORGUILD
local LOOT_ROLLS = _G.LOOT_ROLLS
local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local ORDER_HALL_LANDING_PAGE_TITLE = _G.ORDER_HALL_LANDING_PAGE_TITLE
local PLAYER_V_PLAYER = _G.PLAYER_V_PLAYER
local QUESTLOG_BUTTON = _G.QUESTLOG_BUTTON
local SHOW_LFD_LEVEL = _G.SHOW_LFD_LEVEL
local SHOW_PVP_LEVEL = _G.SHOW_PVP_LEVEL
local SHOW_TALENT_LEVEL = _G.SHOW_TALENT_LEVEL
local ShowUIPanel = _G.ShowUIPanel
local SOCIAL_BUTTON = _G.SOCIAL_BUTTON
local SOCIAL_TWITTER_TWEET_NOT_LINKED = _G.SOCIAL_TWITTER_TWEET_NOT_LINKED
local SPECIALIZATION = _G.SPECIALIZATION
local SPELLBOOK_ABILITIES_BUTTON = _G.SPELLBOOK_ABILITIES_BUTTON
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent

local MiniMapTrackingMenu = CreateFrame("Frame", "MiniMapTrackingMenu", UIParent, "UIDropDownMenuTemplate")
MiniMapTrackingMenu:SetID(1)
MiniMapTrackingMenu:SetClampedToScreen(true)
MiniMapTrackingMenu:Hide()
UIDropDownMenu_Initialize(MiniMapTrackingMenu, MiniMapTrackingDropDown_Initialize, "MENU")
MiniMapTrackingMenu.noResize = true

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
			if not SpellBookFrame:IsShown() then
				ShowUIPanel(SpellBookFrame)
			else
				HideUIPanel(SpellBookFrame)
			end
	end},
	{text = SPECIALIZATION, icon = "Interface\\MINIMAP\\TRACKING\\Ammunition", notCheckable = 1, func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if K.Level >= SHOW_TALENT_LEVEL then
				ShowUIPanel(PlayerTalentFrame)
			else
				K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
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
				K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL).."|r")
			end
	end},
	{text = DUNGEONS_BUTTON, icon = "Interface\\LFGFRAME\\BattleNetWorking0", notCheckable = 1, func = function()
			if K.Level >= SHOW_LFD_LEVEL then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL).."|r")
			end
	end},
	{text = ADVENTURE_JOURNAL, icon = "Interface\\MINIMAP\\TRACKING\\Profession", notCheckable = 1, func = function()
			if C_AdventureJournal_CanBeShown() then
				ToggleEncounterJournal()
			else
				K.Print("|cffffff00"..FEATURE_NOT_YET_AVAILABLE.."|r")
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
			local IsTwitterEnabled = C_Social_IsSocialEnabled()
			if IsTwitterEnabled then
				Social_SetShown(true)
			else
				K.Print(SOCIAL_TWITTER_TWEET_NOT_LINKED)
			end
	end},
}

if GameMenuButtonStore and ((C_StorePublic and not C_StorePublic_IsEnabled()) and not C_StorePublic_IsDisabledByParentalControls()
or (IsTrialAccount and IsTrialAccount()) or (GameLimitedMode_IsActive and GameLimitedMode_IsActive())) then
	table_insert(micromenu, {text = BLIZZARD_STORE, icon = "Interface\\MINIMAP\\TRACKING\\None", notCheckable = 1, func = function()
			StoreMicroButton:Click()
	end})
end

if K.Level > 99 then
	table_insert(micromenu, {text = ORDER_HALL_LANDING_PAGE_TITLE, icon = "Interface\\Buttons/UI-HomeButton", notCheckable = 1, func = function()
			GarrisonLandingPage_Toggle()
	end})
elseif K.Level > 89 then
	table_insert(micromenu, {text = GARRISON_LANDING_PAGE_TITLE, icon = "Interface\\Buttons/UI-HomeButton", notCheckable = 1, func = function()
			GarrisonLandingPage_Toggle()
	end})
end

Minimap:SetScript("OnMouseUp", function(self, button)
	local position = self:GetPoint()

	if (button == "MiddleButton") or (button == "RightButton" and IsShiftKeyDown()) then
		if (position:match("LEFT")) then
			EasyMenu(micromenu, menuFrame, "cursor")
		else
			EasyMenu(micromenu, menuFrame, "cursor", -160, 0)
		end
	elseif (button == "RightButton") then
		ToggleDropDownMenu(1, nil, MiniMapTrackingMenu, "cursor")
	else
		Minimap_OnClick(self)
	end
end)