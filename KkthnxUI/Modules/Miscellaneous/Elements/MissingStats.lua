--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Restores and enhances character statistics hidden in the default Blizzard UI.
-- - Design: Injects additional categories into PAPERDOLL_STATCATEGORIES and hooks stat update functions.
-- - Events: None (Static UI modification and hooks)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local math_floor = _G.math.floor
local math_max = _G.math.max
local string_format = _G.string.format
local table_insert = _G.table.insert

local _G = _G
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local CreateFrame = _G.CreateFrame
local GetAverageItemLevel = _G.GetAverageItemLevel
local GetMeleeHaste = _G.GetMeleeHaste
local HookSecureFunc = _G.hooksecurefunc
local UnitAttackSpeed = _G.UnitAttackSpeed

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_PaperDollInfo_GetMinItemLevel = _G.C_PaperDollInfo.GetMinItemLevel
local C_PaperDollInfo_OffhandHasShield = _G.C_PaperDollInfo.OffhandHasShield

-- REASON: Injects missing or hidden statistics into the character sheet categories to provide a more detailed view.
function Module:createImprovedStatFrames()
	if not C["Misc"].ImprovedStats or C_AddOns_IsAddOnLoaded("DejaCharacterStats") then
		return
	end

	local attributeList = _G.PAPERDOLL_STATCATEGORIES[1].stats
	local enhancementList = _G.PAPERDOLL_STATCATEGORIES[2].stats

	-- SG: Inject Missing Attributes
	table_insert(attributeList, { stat = "ARMOR" })
	table_insert(attributeList, { stat = "STAGGER", hideAt = 0, roles = { _G.Enum.LFGRole.Tank } })
	table_insert(attributeList, {
		stat = "ATTACK_DAMAGE",
		primary = _G.LE_UNIT_STAT_STRENGTH,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = _G.LE_UNIT_STAT_STRENGTH,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, {
		stat = "ATTACK_ATTACKSPEED",
		primary = _G.LE_UNIT_STAT_STRENGTH,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, {
		stat = "ATTACK_DAMAGE",
		primary = _G.LE_UNIT_STAT_AGILITY,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = _G.LE_UNIT_STAT_AGILITY,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, {
		stat = "ATTACK_ATTACKSPEED",
		primary = _G.LE_UNIT_STAT_AGILITY,
		roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage },
	})
	table_insert(attributeList, { stat = "SPELLPOWER", hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT })
	table_insert(attributeList, { stat = "MANAREGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT })
	table_insert(attributeList, { stat = "ENERGY_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY })
	table_insert(attributeList, { stat = "RUNE_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_STRENGTH })
	table_insert(attributeList, { stat = "FOCUS_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY })
	table_insert(attributeList, { stat = "MOVESPEED" })

	-- SG: Inject Missing Enhancements
	table_insert(enhancementList, { stat = "LIFESTEAL", hideAt = 0 })
	table_insert(enhancementList, { stat = "AVOIDANCE", hideAt = 0 })
	table_insert(enhancementList, { stat = "SPEED", hideAt = 0 })
	table_insert(enhancementList, { stat = "DODGE", roles = { _G.Enum.LFGRole.Tank } })
	table_insert(enhancementList, { stat = "PARRY", hideAt = 0, roles = { _G.Enum.LFGRole.Tank } })
	table_insert(enhancementList, { stat = "BLOCK", hideAt = 0, showFunc = C_PaperDollInfo_OffhandHasShield })

	-- REASON: Overrides internal update functions to ensure numeric values are properly reset before calculation.
	_G.PAPERDOLL_STATINFO["ENERGY_REGEN"].updateFunc = function(statFrame, unitID)
		statFrame.numericValue = 0
		_G.PaperDollFrame_SetEnergyRegen(statFrame, unitID)
	end

	_G.PAPERDOLL_STATINFO["RUNE_REGEN"].updateFunc = function(statFrame, unitID)
		statFrame.numericValue = 0
		_G.PaperDollFrame_SetRuneRegen(statFrame, unitID)
	end

	_G.PAPERDOLL_STATINFO["FOCUS_REGEN"].updateFunc = function(statFrame, unitID)
		statFrame.numericValue = 0
		_G.PaperDollFrame_SetFocusRegen(statFrame, unitID)
	end

	local function updatePaperDollAttackSpeed(statFrame, unitID)
		local meleeHasteValue = GetMeleeHaste()
		local mainHandSpeed, offHandSpeed = UnitAttackSpeed(unitID)
		local speedText = string_format("%.2f", mainHandSpeed)
		if offHandSpeed then
			speedText = speedText .. " / " .. string_format("%.2f", offHandSpeed)
		end
		_G.PaperDollFrame_SetLabelAndText(statFrame, _G.WEAPON_SPEED, speedText, false, mainHandSpeed)

		statFrame.tooltip = _G.HIGHLIGHT_FONT_COLOR_CODE .. string_format(_G.PAPERDOLLFRAME_TOOLTIP_FORMAT, _G.ATTACK_SPEED) .. " " .. speedText .. _G.FONT_COLOR_CODE_CLOSE
		statFrame.tooltip2 = string_format(_G.STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHasteValue))
		statFrame:Show()
	end

	HookSecureFunc("PaperDollFrame_SetAttackSpeed", updatePaperDollAttackSpeed)

	HookSecureFunc("PaperDollFrame_SetItemLevel", function(statFrame, unitID)
		if unitID ~= "player" then
			return
		end

		local averageLevel, equippedLevel = GetAverageItemLevel()
		local minimumLevel = C_PaperDollInfo_GetMinItemLevel() or 0
		local itemLevelValue = math_max(minimumLevel, equippedLevel)
		itemLevelValue = math_floor(itemLevelValue * 10 + 0.5) / 10
		averageLevel = math_floor(averageLevel * 10 + 0.5) / 10

		local itemLevelText = itemLevelValue
		if itemLevelValue ~= averageLevel then
			itemLevelText = itemLevelValue .. " / " .. averageLevel
		end
		_G.PaperDollFrame_SetLabelAndText(statFrame, _G.STAT_AVERAGE_ITEM_LEVEL, itemLevelText, false, itemLevelValue)
	end)

	HookSecureFunc("PaperDollFrame_SetLabelAndText", function(statFrame, labelText, _, isStatPercentage)
		if isStatPercentage or labelText == _G.STAT_HASTE then
			statFrame.Value:SetFormattedText("%.2f%%", statFrame.numericValue)
		end
	end)

	local function styleCharacterStatFrames()
		for statFrame in _G.CharacterStatsPane.statsFramePool:EnumerateActive() do
			statFrame.Label:SetFontObject(_G.Game11Font)
			statFrame.Value:SetFontObject(_G.Game11Font)
		end
	end

	HookSecureFunc("PaperDollFrame_UpdateStats", styleCharacterStatFrames)

	-- REASON: Creates an improved scrolling container for character stats to accommodate the increased number of entries.
	local statFrameContainer = CreateFrame("Frame", nil, _G.CharacterFrameInsetRight)
	statFrameContainer:SetSize(200, 350)
	statFrameContainer:SetPoint("TOP", 0, -5)

	local statScrollFrame = CreateFrame("ScrollFrame", nil, statFrameContainer, "UIPanelScrollFrameTemplate")
	statScrollFrame:SetAllPoints()
	statScrollFrame.ScrollBar:Hide()
	statScrollFrame.ScrollBar.Show = K.Noop

	local statContentFrame = CreateFrame("Frame", nil, statScrollFrame)
	statContentFrame:SetSize(200, 1)
	statScrollFrame:SetScrollChild(statContentFrame)

	_G.CharacterStatsPane:ClearAllPoints()
	_G.CharacterStatsPane:SetParent(statContentFrame)
	_G.CharacterStatsPane:SetAllPoints(statContentFrame)

	HookSecureFunc("PaperDollFrame_UpdateSidebarTabs", function()
		statFrameContainer:SetShown(_G.CharacterStatsPane:IsShown())
	end)
end

Module:RegisterMisc("MissingStats", Module.createImprovedStatFrames)
