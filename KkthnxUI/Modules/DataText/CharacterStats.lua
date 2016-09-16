local K, C, L, _ = select(2, ...):unpack()

local format = string.format
local floor = math.floor

CharacterStatsPane.ItemLevelCategory:Hide()
CharacterStatsPane.ItemLevelCategory.Title:Hide()
CharacterStatsPane.ItemLevelCategory.Background:Hide()
CharacterStatsPane.ItemLevelFrame:ClearAllPoints()
CharacterStatsPane.ItemLevelFrame:SetWidth(186)
CharacterStatsPane.ItemLevelFrame:SetHeight(28)
CharacterStatsPane.ItemLevelFrame:SetPoint("TOP", CharacterStatsPane, "TOP", 0, -8)
CharacterStatsPane.ItemLevelFrame.Background:ClearAllPoints()
CharacterStatsPane.ItemLevelFrame.Background:SetWidth(186)
CharacterStatsPane.ItemLevelFrame.Background:SetHeight(28)
CharacterStatsPane.ItemLevelFrame.Background:SetPoint("CENTER", CharacterStatsPane.ItemLevelFrame, "CENTER", 0, 0)
CharacterStatsPane.ItemLevelFrame.Value:SetFont(C.Media.Font, 16, "THINOUTLINE")

hooksecurefunc(CharacterStatsPane.AttributesCategory, "SetPoint", function(self, _, _, _, _, _, flag)
	if flag ~= "CharacterStatsPane" then
		self:ClearAllPoints()
		self:SetPoint("TOP", CharacterStatsPane.ItemLevelFrame, "BOTTOM", 0, -10, "CharacterStatsPane")
	end
end)

hooksecurefunc(CharacterStatsPane.AttributesCategory.Background, "SetPoint", function(self, _, _, _, _, _, flag)
	if flag ~= "CharacterStatsPane" then
		self:ClearAllPoints()
		self:SetPoint("CENTER", CharacterStatsPane.AttributesCategory, "CENTER", 0, 2, "CharacterStatsPane")
	end
end)

hooksecurefunc(CharacterStatsPane.EnhancementsCategory.Background, "SetPoint", function(self, _, _, _, _, _, flag)
	if flag ~= "CharacterStatsPane" then
		self:ClearAllPoints()
		self:SetPoint("CENTER", CharacterStatsPane.EnhancementsCategory, "CENTER", 0, 2, "CharacterStatsPane")
	end
end)

PAPERDOLL_STATCATEGORIES= {
	[1] = {
		categoryFrame = "AttributesCategory",
		stats = {
			[1] = {stat = "ARMOR"},
			[2] = {stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH},
			[3] = {stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY},
			[4] = {stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT},
			[5] = {stat = "STAMINA"},
			[6] = {stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_STRENGTH, roles = {"TANK", "DAMAGER"}},
			[7] = {stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH, roles = { "TANK", "DAMAGER"}},
			[8] = {stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_STRENGTH, roles = { "TANK", "DAMAGER"}},
			[9] = {stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_AGILITY, roles = {"TANK", "DAMAGER"}},
			[10] = {stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_AGILITY, roles = {"TANK", "DAMAGER"}},
			[11] = {stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_AGILITY, roles = {"TANK", "DAMAGER"}},
			[12] = {stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT},
			[13] = {stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT},
			[14] = {stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY},
			[15] = {stat = "RUNE_REGEN", hideAt = 0},
			[16] = {stat = "FOCUS_REGEN", hideAt = 0},
		},
	},
	[2] = {
		categoryFrame = "EnhancementsCategory",
		stats = {
			[1] = {stat = "CRITCHANCE", hideAt = 0},
			[2] = {stat = "HASTE", hideAt = 0},
			[3] = {stat = "VERSATILITY", hideAt = 0},
			[4] = {stat = "MASTERY", hideAt = 0},
			[5] = {stat = "LIFESTEAL", hideAt = 0},
			[6] = {stat = "AVOIDANCE", hideAt = 0},
			[7] = {stat = "DODGE", hideAt = 0, roles = {"TANK"}},
			[8] = {stat = "PARRY", hideAt = 0, roles = {"TANK"}},
			[9] = {stat = "BLOCK", hideAt = 0, roles = {"TANK"}},
		},
	},
}

function PaperDollFrame_SetItemLevel(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide()
		return
	end

	local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
	avgItemLevel = floor(avgItemLevel)
	avgItemLevelEquipped = floor(avgItemLevelEquipped)
	PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, ((avgItemLevelEquipped).."/"..avgItemLevel), false, avgItemLevelEquipped)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel
	if (avgItemLevelEquipped ~= avgItemLevel) then
		statFrame.tooltip = statFrame.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped)
	end
	statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
end

function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste()
	local speed, offhandSpeed = UnitAttackSpeed(unit)

	local displaySpeed = format("%.2f", speed)
	if offhandSpeed then offhandSpeed = format("%.2f", offhandSpeed) end
	if offhandSpeed then displaySpeedxt =  displaySpeed .." / ".. offhandSpeed else displaySpeedxt =  displaySpeed end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
	statFrame:Show()
end

function PaperDollFrame_SetMovementSpeed(statFrame, unit)
	statFrame.wasSwimming = nil
	statFrame.unit = unit
	MovementSpeed_OnUpdate(statFrame)

	statFrame.onEnterFunc = MovementSpeed_OnEnter
	statFrame:Show()
end

function PaperDollFrame_SetEnergyRegen(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide()
		return
	end

	local powerType, powerToken = UnitPowerType(unit)
	if (powerToken ~= "ENERGY") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, NOT_APPLICABLE, false, 0)
		statFrame.tooltip = nil
		statFrame:Hide()
		return
	end

	local regenRate = GetPowerRegen()
	local regenRateText = BreakUpLargeNumbers(regenRate)
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, regenRateText, false, regenRate)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP
	statFrame:Show()
end

function PaperDollFrame_SetFocusRegen(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide()
		return
	end

	local powerType, powerToken = UnitPowerType(unit)
	if (powerToken ~= "FOCUS") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, NOT_APPLICABLE, false, 0)
		statFrame.tooltip = nil
		statFrame:Hide()
		return
	end

	local regenRate = GetPowerRegen()
	local regenRateText = BreakUpLargeNumbers(regenRate)
	PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, regenRateText, false, regenRate)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP
	statFrame:Show()
end

function PaperDollFrame_SetRuneRegen(statFrame, unit)
	if (unit ~= "player") then
		statFrame:Hide()
		return
	end

	local _, class = UnitClass(unit)
	if (class ~= "DEATHKNIGHT") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, NOT_APPLICABLE, false, 0)
		statFrame.tooltip = nil
		statFrame:Hide()
		return
	end

	local _, regenRate = GetRuneCooldown(1) -- ASSUMING THEY ARE ALL THE SAME FOR NOW
	local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate))
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRateText, false, regenRate)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP
	statFrame:Show()
end