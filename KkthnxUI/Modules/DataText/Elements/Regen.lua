local K, C, L = unpack(select(2, ...))

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format

local function Update(self)
	local Base, Combat = GetPowerRegen()
	local Value

	if(InCombatLockdown()) then
		Value = floor(Combat * 5)
	else
		Value = floor(Base * 5)
	end

	self.Text:SetFormattedText("%s: %s", NameColor .. MANA_REGEN_ABBR .. "|r", ValueColor .. K.Comma(Value) .. "|r")
end

local function Enable(self)
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end

DataText:Register(MANA_REGEN_ABBR, Enable, Disable, Update)