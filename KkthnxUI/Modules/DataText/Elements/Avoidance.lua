local K, C, L = unpack(select(2, ...))

local format = string.format
local abs = abs
local UnitLevel = UnitLevel

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local Dodge, Parry, Block, Avoidance, TargetLevel, PlayerLevel, BaseMissChance, LevelDifference
local GetBlockChance = GetBlockChance
local GetParryChance = GetParryChance
local GetDodgeChance = GetDodgeChance

local Update = function(self)
	TargetLevel = UnitLevel("target")
	PlayerLevel = UnitLevel("player")
	local BaseMissChance, LevelDifference, Avoidance

	if (TargetLevel == -1) then
		BaseMissChance = (5 - (3 * 0.2))
		LevelDifference = 3
	elseif (TargetLevel > PlayerLevel) then
		BaseMissChance = (5 - ((TargetLevel - PlayerLevel) * 0.2))
		LevelDifference = (TargetLevel - PlayerLevel)
	elseif (TargetLevel < PlayerLevel and TargetLevel > 0) then
		BaseMissChance = (5 + ((PlayerLevel - TargetLevel) * 0.2))
		LevelDifference = (TargetLevel - PlayerLevel)
	else
		BaseMissChance = 5
		LevelDifference = 0
	end

	if (K.Race == "NightElf") then
		BaseMissChance = BaseMissChance + 2
	end

	if (LevelDifference >= 0) then
		Dodge = (GetDodgeChance() - LevelDifference * 0.2)
		Parry = (GetParryChance() - LevelDifference * 0.2)
		Block = (GetBlockChance() - LevelDifference * 0.2)
		Avoidance = (Dodge + Parry + Block)

		self.Text:SetText(NameColor .. "Avd: " .. "|r" .. ValueColor .. format("%.2f", Avoidance) .. "|r")
	else
		Dodge = (GetDodgeChance() + abs(LevelDifference * 0.2))
		Parry = (GetParryChance() + abs(LevelDifference * 0.2))
		Block = (GetBlockChance() + abs(LevelDifference * 0.2))
		Avoidance = (Dodge + Parry + Block)

		self.Text:SetText(NameColor .. L.DataText.AvoidAnceShort .. "|r" .. ValueColor .. format("%.2f", Avoidance) .. "|r")
	end
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()

	if (TargetLevel > 1) then
		GameTooltip:AddDoubleLine("Avoidance Breakdown" .. " (" .. LEVEL .. " " .. TargetLevel .. ")")
	elseif (TargetLevel == -1) then
		GameTooltip:AddDoubleLine("Avoidance Breakdown" .. " (" .. BOSS .. ")")
	else
		GameTooltip:AddDoubleLine("Avoidance Breakdown" .. " (" .. LEVEL .. " " .. TargetLevel .. ")")
	end
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(NameColor .. DODGE_CHANCE .. ":|r", format(ValueColor .. "%.2f", Dodge) .. "%|r")
	GameTooltip:AddDoubleLine(NameColor .. PARRY_CHANCE .. ":|r", format(ValueColor .. "%.2f", Parry) .. "%|r")
	GameTooltip:AddDoubleLine(NameColor .. BLOCK_CHANCE .. ":|r", format(ValueColor .. "%.2f", Block) .. "%|r")

	GameTooltip:Show()
end

local Enable = function(self)
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
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

DataText:Register("Avoidance", Enable, Disable, Update)