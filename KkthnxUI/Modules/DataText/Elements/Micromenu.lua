local K, C, L = unpack(select(2, ...))

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

-- Lua API
local format = string.format
local print = print

-- Wow API
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local Lib_ToggleDropDownMenu = Lib_ToggleDropDownMenu
local ShowUIPanel = ShowUIPanel
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleFrame = ToggleFrame
local UIErrorsFrame = UIErrorsFrame

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: FEATURE_BECOMES_AVAILABLE_AT_LEVEL, ToggleQuestLog, ToggleGuildFrame
-- GLOBALS: GuildFrame_TabClicked, GuildFrameTab2, ToggleFriendsFrame, SHOW_PVP_LEVEL
-- GLOBALS: MiniMapTrackingDropDown, ToggleDropDownMenu, Minimap_OnClick
-- GLOBALS: SpellBookFrame, PlayerTalentFrame, TalentFrame_LoadUI, SHOW_TALENT_LEVEL
-- GLOBALS: StoreMicroButton, Lib_EasyMenu, GarrisonLandingPage_Toggle, MinimapAnchor
-- GLOBALS: ToggleEncounterJournal, FEATURE_NOT_YET_AVAILABLE, ToggleCollectionsJournal
-- GLOBALS: ToggleHelpFrame, ToggleCalendar, ToggleBattlefieldMinimap,  LootHistoryFrame
-- GLOBALS: TogglePVPUI, SHOW_LFD_LEVEL, PVEFrame_ToggleFrame, C_AdventureJournal

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "Lib_UIDropDownMenuTemplate")
local guildText = IsInGuild() and ACHIEVEMENTS_GUILD_TAB or LOOKINGFORGUILD

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
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
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
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL).."|r")
				end
			end
	end},
	{text = DUNGEONS_BUTTON, icon = "Interface\\LFGFRAME\\BattleNetWorking0", notCheckable = 1, func = function()
			if K.Level >= SHOW_LFD_LEVEL then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL), 1, 0.1, 0.1)
				else
					K.Print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL).."|r")
				end
			end
	end},
	{text = ADVENTURE_JOURNAL, icon = "Interface\\MINIMAP\\TRACKING\\Profession", notCheckable = 1, func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				if C.Error.White == false then
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

if not IsTrialAccount() and not C_StorePublic.IsDisabledByParentalControls() then
	tinsert(micromenu, {text = BLIZZARD_STORE, icon = "Interface\\MINIMAP\\TRACKING\\None", notCheckable = 1, func = function() StoreMicroButton:Click() end})
end

if K.Level > 99 then
	tinsert(micromenu, {text = ORDER_HALL_LANDING_PAGE_TITLE, icon = "", notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
elseif K.Level > 89 then
	tinsert(micromenu, {text = GARRISON_LANDING_PAGE_TITLE, icon = "", notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
end

local function OnMouseDown()
	Lib_EasyMenu(micromenu, menuFrame, "cursor", 0, 0, "MENU")
end

local function Update(self)
	self.Text:SetText(NameColor .. L.DataText.MicroMenu .. "|r")
end

local function Enable(self)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:SetScript("OnMouseDown", nil)
	self:UnregisterAllEvents()
end

DataText:Register(L.DataText.MicroMenu, Enable, Disable, Update)