local K, C, L = select(2, ...):unpack()

local select = select
local format, join = string.format, string.join
local UnitArmor = UnitArmor
local UnitBonusArmor = UnitBonusArmor
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction
local UnitLevel = UnitLevel
local GetBladedArmorEffect = GetBladedArmorEffect
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local BONUS_ARMOR = BONUS_ARMOR
local STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP = STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP
local STAT_ARMOR_TOTAL_TOOLTIP = STAT_ARMOR_TOTAL_TOOLTIP
local STAT_NO_BENEFIT_TOOLTIP = STAT_NO_BENEFIT_TOOLTIP
local InCombatLockdown = InCombatLockdown

local EffectiveArmor, BonusArmor, IsNegatedForSpec, ArmorReduction, HasAura, Percent

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
	GameTooltip:AddLine(BONUS_ARMOR)
	GameTooltip:AddLine(" ")

	EffectiveArmor = select(2, UnitArmor("player"))
	BonusArmor, IsNegatedForSpec = UnitBonusArmor("player")
	ArmorReduction = PaperDollFrame_GetArmorReduction(EffectiveArmor, UnitLevel("player"))
	HasAura, Percent = GetBladedArmorEffect()

	Text = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BONUS_ARMOR) .. " " .. format("%s", BonusArmor) .. FONT_COLOR_CODE_CLOSE

	if (HasAura) then
		Tooltip = format(STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP, ArmorReduction, (BonusArmor * (Percent / 100)))
	elseif (not IsNegatedForSpec) then
		Tooltip = format(STAT_ARMOR_TOTAL_TOOLTIP, ArmorReduction)
	else
		Tooltip = STAT_NO_BENEFIT_TOOLTIP
	end

	GameTooltip:AddDoubleLine(Text, nil, 1, 1, 1)
	GameTooltip:AddLine(Tooltip, nil, nil, nil, true)

	if ((HasAura) or (not IsNegatedForSpec)) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Mitigation By Level")

		local PlayerLevel = UnitLevel("player") + 3
		for i = 1, 4 do
			ArmorReduction = PaperDollFrame_GetArmorReduction(EffectiveArmor, PlayerLevel)

			GameTooltip:AddDoubleLine(PlayerLevel, format("%.2f%%", ArmorReduction), 1, 1, 1)

			PlayerLevel = PlayerLevel - 1
		end

		local Level = UnitLevel("target")
		if (Level and Level > 0 and (Level > PlayerLevel + 3 or Level < PlayerLevel)) then
			ArmorReduction = PaperDollFrame_GetArmorReduction(EffectiveArmor, Level)

			GameTooltip:AddDoubleLine(Level, format("%.2f%%", ArmorReduction), 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

local OnEvent = function(self)
	local Value = UnitBonusArmor("player")

	self.Text:SetFormattedText("%s: %s", NameColor .. BONUS_ARMOR .. "|r", ValueColor .. K.Comma(Value) .. "|r")
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("FORGE_MASTER_ITEM_CHANGED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
	self:SetScript("OnEvent", OnEvent)
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

DataText:Register(BONUS_ARMOR, Enable, Disable, OnEvent)
