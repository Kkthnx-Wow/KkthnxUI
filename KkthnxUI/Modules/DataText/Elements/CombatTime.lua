local K, C, L = unpack(select(2, ...))

local floor = math.floor
local format, join = string.format, string.join
local GetTime = GetTime
local IsInInstance = IsInInstance

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local timer = 0
local startTime = 0
local timerText = "Combat"

local OnUpdate = function(self)
	timer = GetTime() - startTime

	self.Text:SetFormattedText("%s: %s", NameColor .. timerText .. "|r", ValueColor .. format("%02d:%02d.%02d", floor(timer / 60), timer % 60, (timer - floor(timer)) * 100) .. "|r")
end

local DelayOnUpdate = function(self, elapsed)
	startTime = startTime - elapsed

	if (startTime <= 0) then
		startTime = GetTime()
		timer = 0

		self:SetScript("OnUpdate", OnUpdate)
	end
end

local OnEvent = function(self, event, timerType, timeSeconds, totalTime)
	local inInstance, instanceType = IsInInstance()

	if (event == "START_TIMER" and instanceType == "arena") then
		startTime = timeSeconds
		timer = 0
		timerText = "Arena"

		self.Text:SetFormattedText("%s: %s", NameColor .. timerText .. "|r", ValueColor .. "00:00:00" .. "|r")
		self:SetScript("OnUpdate", DelayOnUpdate)
	elseif (event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_REGEN_ENABLED" and instanceType ~= "arena")) then
		self:SetScript("OnUpdate", nil)
	elseif (event == "PLAYER_REGEN_DISABLED" and instanceType ~= "arena") then
		startTime = GetTime()
		timer = 0
		timerText = "Combat"

		self:SetScript("OnUpdate", OnUpdate)
	elseif (not self.Text:GetText()) then
		self.Text:SetFormattedText("%s: %s", NameColor .. timerText .. "|r", ValueColor .. format("%02d:%02d.%02d", floor(timer / 60), timer % 60, (timer - floor(timer)) * 100) .. "|r")
	end
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("START_TIMER")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:SetScript("OnEvent", OnEvent)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end

DataText:Register(L.DataText.CombatTime, Enable, Disable, OnEvent)
