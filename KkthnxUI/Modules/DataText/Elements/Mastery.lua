local K, C, L = unpack(select(2, ...))

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local GetCombatRating = GetCombatRating
local format = string.format

local function Update(self)
	local Value = GetCombatRating(26)

	self.Text:SetFormattedText("%s: %s", NameColor .. ITEM_MOD_MASTERY_RATING_SHORT .. "|r", ValueColor .. K.Comma(Value) .. "|r" .. "|r")
end

local function Enable(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end

DataText:Register(ITEM_MOD_MASTERY_RATING_SHORT, Enable, Disable, Update)