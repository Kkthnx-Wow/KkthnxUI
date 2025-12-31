local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local table_insert = table.insert
local string_format = string.format
local math_max = math.max
local math_floor = math.floor

local BreakUpLargeNumbers = BreakUpLargeNumbers
local CreateFrame = CreateFrame
local GetAverageItemLevel = GetAverageItemLevel
local GetMeleeHaste = GetMeleeHaste
local UnitAttackSpeed = UnitAttackSpeed
local hooksecurefunc = hooksecurefunc

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_PaperDollInfo_GetMinItemLevel = C_PaperDollInfo.GetMinItemLevel
local C_PaperDollInfo_OffhandHasShield = C_PaperDollInfo.OffhandHasShield

function Module:CreateMissingStats()
	if not C["Misc"].ImprovedStats or C_AddOns_IsAddOnLoaded("DejaCharacterStats") then
		return
	end

	local attributes = PAPERDOLL_STATCATEGORIES[1].stats
	local enhancements = PAPERDOLL_STATCATEGORIES[2].stats

	table_insert(attributes, { stat = "ARMOR" })
	table_insert(attributes, { stat = "STAGGER", hideAt = 0, roles = { Enum.LFGRole.Tank } })
	table_insert(attributes, {
		stat = "ATTACK_DAMAGE",
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, {
		stat = "ATTACK_ATTACKSPEED",
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, {
		stat = "ATTACK_DAMAGE",
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, {
		stat = "ATTACK_ATTACKSPEED",
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	table_insert(attributes, { stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT })
	table_insert(attributes, { stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT })
	table_insert(attributes, { stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY })
	table_insert(attributes, { stat = "RUNE_REGEN", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH })
	table_insert(attributes, { stat = "FOCUS_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY })
	table_insert(attributes, { stat = "MOVESPEED" })

	table_insert(enhancements, { stat = "LIFESTEAL", hideAt = 0 })
	table_insert(enhancements, { stat = "AVOIDANCE", hideAt = 0 })
	table_insert(enhancements, { stat = "SPEED", hideAt = 0 })
	table_insert(enhancements, { stat = "DODGE", roles = { Enum.LFGRole.Tank } })
	table_insert(enhancements, { stat = "PARRY", hideAt = 0, roles = { Enum.LFGRole.Tank } })
	table_insert(enhancements, { stat = "BLOCK", hideAt = 0, showFunc = C_PaperDollInfo_OffhandHasShield })

	PAPERDOLL_STATINFO["ENERGY_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetEnergyRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["RUNE_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetRuneRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["FOCUS_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetFocusRegen(statFrame, unit)
	end

	local function SetAttackSpeed(statFrame, unit)
		local meleeHaste = GetMeleeHaste()
		local speed, offhandSpeed = UnitAttackSpeed(unit)
		local displaySpeed = string_format("%.2f", speed)
		if offhandSpeed then
			displaySpeed = displaySpeed .. " / " .. string_format("%.2f", offhandSpeed)
		end
		PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. string_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED) .. " " .. displaySpeed .. FONT_COLOR_CODE_CLOSE
		statFrame.tooltip2 = string_format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
		statFrame:Show()
	end

	hooksecurefunc("PaperDollFrame_SetAttackSpeed", SetAttackSpeed)

	hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unit)
		if unit ~= "player" then
			return
		end

		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
		local minItemLevel = C_PaperDollInfo_GetMinItemLevel() or 0
		local displayItemLevel = math_max(minItemLevel, avgItemLevelEquipped)
		displayItemLevel = math_floor(displayItemLevel * 10 + 0.5) / 10
		avgItemLevel = math_floor(avgItemLevel * 10 + 0.5) / 10

		if displayItemLevel ~= avgItemLevel then
			displayItemLevel = displayItemLevel .. " / " .. avgItemLevel
		end
		PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, displayItemLevel, false, displayItemLevel)
	end)

	hooksecurefunc("PaperDollFrame_SetLabelAndText", function(statFrame, label, _, isPercentage)
		if isPercentage or label == STAT_HASTE then
			statFrame.Value:SetFormattedText("%.2f%%", statFrame.numericValue)
		end
	end)

	local function StyleStatFrames()
		for statFrame in CharacterStatsPane.statsFramePool:EnumerateActive() do
			statFrame.Label:SetFontObject(Game11Font)
			statFrame.Value:SetFontObject(Game11Font)
		end
	end

	hooksecurefunc("PaperDollFrame_UpdateStats", StyleStatFrames)

	local statPanel = CreateFrame("Frame", nil, CharacterFrameInsetRight)
	statPanel:SetSize(200, 350)
	statPanel:SetPoint("TOP", 0, -5)

	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = K.Noop

	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
	scrollFrame:SetScrollChild(stat)

	CharacterStatsPane:ClearAllPoints()
	CharacterStatsPane:SetParent(stat)
	CharacterStatsPane:SetAllPoints(stat)

	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		statPanel:SetShown(CharacterStatsPane:IsShown())
	end)
end

Module:RegisterMisc("MissingStats", Module.CreateMissingStats)
