local K, C, L = select(2, ...):unpack()

local format = string.format
local GetCritChance = GetCritChance
local GetSpellCritChance = GetSpellCritChance
local GetRangedCritChance = GetRangedCritChance
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local CR_CRIT_SPELL = CR_CRIT_SPELL
local CR_CRIT_SPELL_TOOLTIP = CR_CRIT_SPELL_TOOLTIP
local SPELL_CRIT_CHANCE = SPELL_CRIT_CHANCE
local RANGED_CRIT_CHANCE = RANGED_CRIT_CHANCE
local CR_CRIT_RANGED_TOOLTIP = CR_CRIT_RANGED_TOOLTIP
local CR_CRIT_RANGED = CR_CRIT_RANGED
local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local CR_CRIT_MELEE_TOOLTIP = CR_CRIT_MELEE_TOOLTIP
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CRIT_ABBR = CRIT_ABBR

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	local Text, Tooltip

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(SPELL_CRIT_CHANCE)
	GameTooltip:AddLine(" ")

	if (K.Role == "CASTER") then
		Text = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPELL_CRIT_CHANCE) .. " " .. format("%.2f%%", GetSpellCritChance(1)) .. FONT_COLOR_CODE_CLOSE
		Tooltip = format(CR_CRIT_SPELL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_SPELL)), GetCombatRatingBonus(CR_CRIT_SPELL))
	else
		if (K.Class == "HUNTER") then
			Text = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, RANGED_CRIT_CHANCE) .. " " .. format("%.2f%%", GetRangedCritChance()) .. FONT_COLOR_CODE_CLOSE
			Tooltip = format(CR_CRIT_RANGED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_RANGED)), GetCombatRatingBonus(CR_CRIT_RANGED))
		else
			Text = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MELEE_CRIT_CHANCE) .. " " .. format("%.2f%%", GetCritChance()) .. FONT_COLOR_CODE_CLOSE
			Tooltip = format(CR_CRIT_MELEE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_MELEE)), GetCombatRatingBonus(CR_CRIT_MELEE))
		end
	end

	GameTooltip:AddDoubleLine(Text, nil, 1, 1, 1)
	GameTooltip:AddLine(Tooltip, nil, nil, nil, true)
	GameTooltip:Show()
end

local Update = function(self)
	local Melee = GetCritChance()
	local Spell = GetSpellCritChance(1)
	local Ranged = GetRangedCritChance()
	local Value

	if (Spell > Melee) then
		Value = Spell
	elseif (K.Class == "HUNTER") then
		Value = Ranged
	else
		Value = Melee
	end

	self.Text:SetFormattedText("%s: %s%.2f%%", NameColor .. COMBAT_RATING_NAME10 .. "|r", ValueColor, Value)
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register(COMBAT_RATING_NAME10, Enable, Disable, Update)
