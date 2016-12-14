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
	{text = CHARACTER_BUTTON, notCheckable = 1, func = function()
			ToggleCharacter("PaperDollFrame")
	end},
	{text = SPELLBOOK_ABILITIES_BUTTON, notCheckable = 1, func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			--ToggleFrame(SpellBookFrame)
			if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end
	end},
	{text = TALENTS_BUTTON, notCheckable = 1, func = function()
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
	end},
	{text = ACHIEVEMENT_BUTTON, notCheckable = 1, func = function()
			ToggleAchievementFrame()
	end},
	{text = QUESTLOG_BUTTON, notCheckable = 1, func = function()
			ToggleQuestLog()
	end},
	{text = guildText, notCheckable = 1, func = function()
			ToggleGuildFrame()
			if IsInGuild() then
				GuildFrame_TabClicked(GuildFrameTab2)
			end
	end},
	{text = SOCIAL_BUTTON, notCheckable = 1, func = function()
			ToggleFriendsFrame()
	end},
	{text = PLAYER_V_PLAYER, notCheckable = 1, func = function()
			if K.Level >= SHOW_PVP_LEVEL then
				TogglePVPUI()
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL), 1, 0.1, 0.1)
				else
					print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL).."|r")
				end
			end
	end},
	{text = DUNGEONS_BUTTON, notCheckable = 1, func = function()
			if K.Level >= SHOW_LFD_LEVEL then
				PVEFrame_ToggleFrame("GroupFinderFrame", nil)
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL), 1, 0.1, 0.1)
				else
					print("|cffffff00"..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL).."|r")
				end
			end
	end},
	{text = ADVENTURE_JOURNAL, notCheckable = 1, func = function()
			if C_AdventureJournal.CanBeShown() then
				ToggleEncounterJournal()
			else
				if C.Error.White == false then
					UIErrorsFrame:AddMessage(FEATURE_NOT_YET_AVAILABLE, 1, 0.1, 0.1)
				else
					print("|cffffff00"..FEATURE_NOT_YET_AVAILABLE.."|r")
				end
			end
	end},
	{text = COLLECTIONS, notCheckable = 1, func = function()
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			ToggleCollectionsJournal()
	end},
	{text = HELP_BUTTON, notCheckable = 1, func = function()
			ToggleHelpFrame()
	end},
	{text = L_MINIMAP_CALENDAR, notCheckable = 1, func = function()
			ToggleCalendar()
	end},
	{text = BATTLEFIELD_MINIMAP, notCheckable = 1, func = function()
			ToggleBattlefieldMinimap()
	end},
	{text = LOOT_ROLLS, notCheckable = 1, func = function()
			ToggleFrame(LootHistoryFrame)
	end},
}

if not IsTrialAccount() and not C_StorePublic.IsDisabledByParentalControls() then
	tinsert(micromenu, {text = BLIZZARD_STORE, notCheckable = 1, func = function() StoreMicroButton:Click() end})
end

if K.Level > 99 then
	tinsert(micromenu, {text = ORDER_HALL_LANDING_PAGE_TITLE, notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
elseif K.Level > 89 then
	tinsert(micromenu, {text = GARRISON_LANDING_PAGE_TITLE, notCheckable = 1, func = function() GarrisonLandingPage_Toggle() end})
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
