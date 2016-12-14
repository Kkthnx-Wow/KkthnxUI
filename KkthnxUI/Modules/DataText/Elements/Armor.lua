local K, C, L = unpack(select(2, ...))
if C.DataText.BottomBar ~= true then return end

local select = select
local format = string.format
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction
local UnitLevel = UnitLevel
local UnitArmor = UnitArmor
local InCombatLockdown = InCombatLockdown

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local OnMouseDown = function(self, btn)
	if (btn ~= "LeftButton") then
		return
	end

	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Mitigation")
	GameTooltip:AddLine(" ")

	local PlayerLevel = UnitLevel("player") + 3
	local EffectiveArmor = select(2, UnitArmor("player"))

	for i = 1, 4 do
		local ArmorReduction = PaperDollFrame_GetArmorReduction(EffectiveArmor, PlayerLevel)

		GameTooltip:AddDoubleLine(NameColor .. LEVEL .. " " .. PlayerLevel .. ":|r", format(ValueColor .. "%.2f%%" .. "|r", ArmorReduction))
		PlayerLevel = PlayerLevel - 1
	end

	local TargetLevel = UnitLevel("target")
	if (TargetLevel and TargetLevel > 0 and (TargetLevel > PlayerLevel + 3 or TargetLevel < PlayerLevel)) then
		GameTooltip:AddLine(" ")

		local ArmorReduction = PaperDollFrame_GetArmorReduction(EffectiveArmor, TargetLevel)
		GameTooltip:AddDoubleLine(NameColor .. LEVEL .. " " .. TargetLevel .. ":|r", format(ValueColor .. "%.2f%%" .. "|r", ArmorReduction))
	end

	GameTooltip:Show()
end

local Update = function(self)
	local Value = select(2, UnitArmor("player"))

	self.Text:SetFormattedText("%s: %s", NameColor .. ARMOR .. "|r", ValueColor .. K.Comma(Value) .. "|r")
end

local Enable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_RESISTANCES")
	self:RegisterEvent("FORGE_MASTER_ITEM_CHANGED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register(ARMOR, Enable, Disable, Update)