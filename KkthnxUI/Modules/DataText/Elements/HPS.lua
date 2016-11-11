local K, C, L = select(2, ...):unpack()

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format
local select = select
local UnitAffectingCombat = UnitAffectingCombat
local max = math.max

local PlayerGUID = UnitGUID("player")
local Events = {
	SPELL_HEAL = true,
	SPELL_PERIODIC_HEAL = true
}

local tslu = 1
local TotalHeals = 0
local CombatTime = 0
local AmountHealed = 0
local OverHeals = 0

local function GetHPS()
	if(TotalHeals == 0) then
		return (ValueColor .. "0.0 |r" .. NameColor .. "HPS" .. "|r")
	else
		return format(ValueColor .. "%.1fk |r" .. NameColor .. "HPS" .. "|r", ((TotalHeals or 0) / (CombatTime or 1)) / 1000)
	end
end

local function CreateFunctions(self)
	function self:COMBAT_LOG_EVENT_UNFILTERED(...)
		if(not Events[select(2, ...)]) then
			return
		end

		local ID = select(4, ...)

		if(ID == PlayerGUID) then
			AmountHealed = select(15, ...)
			OverHeals = select(16, ...)
			TotalHeals = TotalHeals + max(0, AmountHealed - OverHeals)
		end
	end

	function self:PLAYER_REGEN_ENABLED()
		self.Text:SetText(GetHPS())
	end

	function self:PLAYER_REGEN_DISABLED()
		TotalHeals = 0
		CombatTime = 0
		AmountHealed = 0
		OverHeals = 0
	end

	self.Functions = true
end

local function OnUpdate(self, t)
	if(UnitAffectingCombat("player")) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CombatTime = CombatTime + t
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	tslu = tslu + t

	if(tslu >= 1) then
		tslu = 0
		self.Text:SetText(GetHPS())
	end
end

local function OnMouseDown()
	TotalHeals = 0
	CombatTime = 0
	AmountHealed = 0
	OverHeals = 0
end

local function Update(self, event, ...)
	if(not event) then
		self.Text:SetText(GetHPS())
	else
		self[event](self, ...)
	end
end

local function Enable(self)
	if(not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	if(not self.Functions) then
		CreateFunctions(self)
	end

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	-- self:RegisterEvent("UNIT_PET")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnUpdate", OnUpdate)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register("HPS", Enable, Disable, Update)
