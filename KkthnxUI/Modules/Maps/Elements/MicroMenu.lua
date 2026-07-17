--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Minimap middle-click micro menu entries.
-- - Design: Sorted alphabetically; main menu + help pinned to the bottom.
-- - Events: N/A — opened from Minimap.lua OnMouseUp.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Minimap")

local table_insert = _G.table.insert
local table_sort = _G.table.sort

local C_AddOns_IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded
local C_StorePublic_IsEnabled = _G.C_StorePublic and _G.C_StorePublic.IsEnabled
local SOUNDKIT = _G.SOUNDKIT

function Module:GetMicroMenuList()
	if self._microMenuList then
		return self._microMenuList
	end

	local menuList = {
		{
			text = _G.CHARACTER_BUTTON,
			icon = 236415,
			func = function()
				_G.ToggleCharacter("PaperDollFrame")
			end,
			notCheckable = 1,
		},
		{
			text = _G.SPELLBOOK,
			icon = 133741,
			func = function()
				if _G.PlayerSpellsUtil then
					_G.PlayerSpellsUtil.ToggleSpellBookFrame()
				else
					_G.ToggleFrame(_G.SpellBookFrame)
				end
			end,
			notCheckable = 1,
		},
		{
			text = _G.TIMEMANAGER_TITLE,
			icon = 237538,
			func = function()
				_G.ToggleFrame(_G.TimeManagerFrame)
			end,
			notCheckable = 1,
		},
		{
			text = _G.CHAT_CHANNELS,
			icon = 2056011,
			func = function()
				_G.ToggleChannelFrame()
			end,
			notCheckable = 1,
		},
		{
			text = _G.SOCIAL_BUTTON,
			icon = 442272,
			func = function()
				_G.ToggleFriendsFrame()
			end,
			notCheckable = 1,
		},
		{
			text = _G.TALENTS_BUTTON,
			icon = 3717418,
			func = function()
				if _G.PlayerSpellsUtil then
					_G.PlayerSpellsUtil.ToggleClassTalentFrame()
				else
					_G.ToggleTalentFrame()
				end
			end,
			notCheckable = 1,
		},
		{
			text = _G.GUILD,
			icon = 135026,
			func = function()
				_G.ToggleGuildFrame()
			end,
			notCheckable = 1,
		},
		{
			text = _G.COLLECTIONS,
			icon = 5321228,
			func = function()
				_G.ToggleCollectionsJournal()
			end,
			notCheckable = 1,
		},
		{
			text = _G.ACHIEVEMENT_BUTTON,
			icon = 1033987,
			func = function()
				_G.ToggleAchievementFrame()
			end,
			notCheckable = 1,
		},
		{
			text = _G.LFG_TITLE,
			icon = 134149,
			func = function()
				_G.ToggleLFDParentFrame()
			end,
			notCheckable = 1,
		},
		{
			text = L["Calendar"],
			icon = 3007435,
			func = function()
				if _G.GameTimeFrame then
					_G.GameTimeFrame:Click()
				end
			end,
			notCheckable = 1,
		},
		{
			text = _G.ENCOUNTER_JOURNAL,
			icon = 236409,
			func = function()
				if not (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_EncounterJournal")) then
					_G.UIParentLoadAddOn("Blizzard_EncounterJournal")
				end
				_G.ToggleFrame(_G.EncounterJournal)
			end,
			notCheckable = 1,
		},
		{
			text = _G.PROFESSIONS_BUTTON,
			icon = 236574,
			func = function()
				_G.ToggleProfessionsBook()
			end,
			notCheckable = 1,
		},
		{
			text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
			icon = 1044996,
			func = function()
				if _G.ExpansionLandingPageMinimapButton then
					_G.ExpansionLandingPageMinimapButton:ToggleLandingPage()
				end
			end,
			notCheckable = 1,
		},
		{
			text = _G.QUESTLOG_BUTTON,
			icon = 236669,
			func = function()
				_G.ToggleQuestLog()
			end,
			notCheckable = 1,
		},
	}

	if K.Level == 80 then
		table_insert(menuList, {
			text = _G.RATED_PVP_WEEKLY_VAULT,
			icon = "greatVault-whole-normal",
			notCheckable = 1,
			func = function()
				if not _G.WeeklyRewardsFrame and _G.WeeklyRewards_LoadUI then
					_G.WeeklyRewards_LoadUI()
				end
				_G.ToggleFrame(_G.WeeklyRewardsFrame)
			end,
		})
	end

	if C_StorePublic_IsEnabled and C_StorePublic_IsEnabled() then
		table_insert(menuList, {
			text = _G.BLIZZARD_STORE,
			icon = 939375,
			notCheckable = 1,
			func = function()
				if _G.StoreMicroButton then
					_G.StoreMicroButton:Click()
				end
			end,
		})
	end

	table_sort(menuList, function(a, b)
		if a and b and a.text and b.text then
			return a.text < b.text
		end
		return false
	end)

	table_insert(menuList, {
		text = _G.MAINMENU_BUTTON,
		microOffset = "MainMenuMicroButton",
		func = function()
			if not _G.GameMenuFrame:IsShown() then
				_G.CloseMenus()
				_G.CloseAllWindows()
				_G.PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
				_G.ShowUIPanel(_G.GameMenuFrame)
			else
				_G.PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
				_G.HideUIPanel(_G.GameMenuFrame)
				_G.MainMenuMicroButton:SetButtonState("NORMAL")
			end
		end,
		notCheckable = 1,
		icon = 134400,
	})

	table_insert(menuList, {
		text = _G.HELP_BUTTON,
		microOffset = nil,
		bottom = true,
		func = function()
			_G.ToggleHelpFrame()
		end,
		notCheckable = 1,
		icon = 511544,
	})

	self._microMenuList = menuList
	return menuList
end
