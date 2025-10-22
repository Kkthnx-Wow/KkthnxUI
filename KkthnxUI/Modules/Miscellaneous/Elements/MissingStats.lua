local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

--- Creates and initializes the missing stats enhancement for the character pane.
-- Extends the default stats display by appending additional stats to Blizzard's
-- categories, improving visibility without overriding defaults.
-- Why: Provides comprehensive player stats overview, essential for optimization.
-- @return nil
-- @usage Module:CreateMissingStats() -- Called via module registration.
function Module:CreateMissingStats()
	if not C["Misc"].ImprovedStats then
		-- NOTE: Early exit if feature disabled in config.
		return
	end
	if C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
		-- NOTE: Avoid conflicts with similar addons.
		return
	end

	-- Append to existing stat categories to preserve Blizzard defaults and other addon mods.
	-- Why: Full overrides can cause conflicts; appending is safer and modular.
	local attributes = PAPERDOLL_STATCATEGORIES[1].stats
	local enhancements = PAPERDOLL_STATCATEGORIES[2].stats

	-- Attributes category extensions.
	tinsert(attributes, { stat = "ARMOR" })
	tinsert(attributes, { stat = "STAGGER", hideAt = 0, roles = { Enum.LFGRole.Tank } })
	tinsert(attributes, {
		stat = "ATTACK_DAMAGE",
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, {
		stat = "ATTACK_ATTACKSPEED",
		primary = LE_UNIT_STAT_STRENGTH,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, {
		stat = "ATTACK_DAMAGE",
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, {
		stat = "ATTACK_AP",
		hideAt = 0,
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, {
		stat = "ATTACK_ATTACKSPEED",
		primary = LE_UNIT_STAT_AGILITY,
		roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage },
	})
	tinsert(attributes, { stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT })
	tinsert(attributes, { stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT })
	tinsert(attributes, { stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY })
	tinsert(attributes, { stat = "RUNE_REGEN", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH })
	tinsert(attributes, { stat = "FOCUS_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY })
	tinsert(attributes, { stat = "MOVESPEED" })

	-- Enhancements category extensions.
	tinsert(enhancements, { stat = "LIFESTEAL", hideAt = 0 })
	tinsert(enhancements, { stat = "AVOIDANCE", hideAt = 0 })
	tinsert(enhancements, { stat = "SPEED", hideAt = 0 })
	tinsert(enhancements, { stat = "DODGE", roles = { Enum.LFGRole.Tank } })
	tinsert(enhancements, { stat = "PARRY", hideAt = 0, roles = { Enum.LFGRole.Tank } })
	tinsert(enhancements, { stat = "BLOCK", hideAt = 0, showFunc = C_PaperDollInfo.OffhandHasShield })

	-- Custom update functions for regen stats.
	-- Why: Blizzard's default handlers are reused; we set numericValue to trigger them.
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

	-- Local aliases for frequently used safe globals (performance optimization).
	-- Why: Reduces global lookups; safe for math/string/table as per Lua 5.1 best practices.
	local format, max, floor = string.format, math.max, math.floor
	local BreakUpLargeNumbers, GetMeleeHaste, UnitAttackSpeed = BreakUpLargeNumbers, GetMeleeHaste, UnitAttackSpeed
	local GetAverageItemLevel, GetMinItemLevel = GetAverageItemLevel, C_PaperDollInfo.GetMinItemLevel
	local SetLabelAndText = PaperDollFrame_SetLabelAndText
	local HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE = HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE

	--- Custom setter for attack speed stat.
	-- Handles dual-wield display and tooltip.
	-- @param statFrame The stat frame to update.
	-- @param unit The unit (player) to query.
	-- @return nil
	local function SetAttackSpeed(statFrame, unit)
		local meleeHaste = GetMeleeHaste()
		local speed, offhandSpeed = UnitAttackSpeed(unit)
		local displaySpeed = format("%.2f", speed)
		if offhandSpeed then
			displaySpeed = displaySpeed .. " / " .. format("%.2f", offhandSpeed)
		end
		SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED) .. " " .. displaySpeed .. FONT_COLOR_CODE_CLOSE
		statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
		statFrame:Show()
	end

	-- Hook Blizzard's attack speed function safely.
	-- Why: hooksecurefunc avoids taint and allows post-processing.
	hooksecurefunc("PaperDollFrame_SetAttackSpeed", SetAttackSpeed)

	hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unit)
		if unit ~= "player" then
			return
		end

		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
		local minItemLevel = GetMinItemLevel() or 0
		local displayItemLevel = max(minItemLevel, avgItemLevelEquipped)
		displayItemLevel = floor(displayItemLevel * 10 + 0.5) / 10 -- Precise to 1 decimal.
		avgItemLevel = floor(avgItemLevel * 10 + 0.5) / 10

		if displayItemLevel ~= avgItemLevel then
			displayItemLevel = displayItemLevel .. " / " .. avgItemLevel
		end
		SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, displayItemLevel, false, displayItemLevel)
	end)

	hooksecurefunc("PaperDollFrame_SetLabelAndText", function(statFrame, label, _, isPercentage)
		if isPercentage or label == STAT_HASTE then
			statFrame.Value:SetFormattedText("%.2f%%", statFrame.numericValue)
		end
	end)

	--- Styles stat frames with custom font.
	-- Called on update to ensure new frames are styled.
	-- Why: Consistent UI theme; done per-update as pool recycles frames.
	-- @return nil
	local function StyleStatFrames()
		for statFrame in CharacterStatsPane.statsFramePool:EnumerateActive() do
			statFrame.Label:SetFontObject(Game11Font)
			statFrame.Value:SetFontObject(Game11Font)
		end
	end

	hooksecurefunc("PaperDollFrame_UpdateStats", StyleStatFrames)

	-- Create scrollable panel directly (no event needed since registered via module).
	-- Why: Module registration handles init timing, ensuring UI APIs are available.
	local statPanel = CreateFrame("Frame", nil, CharacterFrameInsetRight)
	statPanel:SetSize(200, 350)
	statPanel:SetPoint("TOP", 0, -5)

	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = K.Noop -- Noop to prevent showing.

	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
	scrollFrame:SetScrollChild(stat)

	CharacterStatsPane:ClearAllPoints()
	CharacterStatsPane:SetParent(stat)
	CharacterStatsPane:SetAllPoints(stat)

	-- Hook for visibility sync.
	-- Why: Ensures panel shows/hides with the default stats pane.
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		statPanel:SetShown(CharacterStatsPane:IsShown())
	end)
end

-- Register the module.
-- Why: Uses KkthnxUI's module system for organized loading/unloading.
Module:RegisterMisc("MissingStats", Module.CreateMissingStats)
