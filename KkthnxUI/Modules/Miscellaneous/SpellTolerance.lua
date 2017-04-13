local K, C, L = unpack(select(2, ...))
if C.General.SpellTolerance ~= true then return end

-- Lua API
local _G = _G
local math_min = math.min

-- Wow API
local GetNetStats = _G.GetNetStats
local GetCVar = _G.GetCVar

local SpellTolerance = CreateFrame("Frame", "AutoLagTolerance")
SpellTolerance.cache = GetCVar("SpellQueueWindow")
SpellTolerance.timer = 0

local function SpellTolerance_OnUpdate(self, elapsed)
	self.timer = self.timer + elapsed

	if self.timer < 1.0 then
		return
	end

	self.timer = 0

	local SpellLatency = math_min(400, select(4, GetNetStats()))

	if SpellLatency == 0 then
		return
	end

	if SpellLatency == self.cache then
		return
	end

	K:LockCVar("SpellQueueWindow", SpellLatency)

	self.cache = SpellLatency
end

SpellTolerance:SetScript("OnUpdate", SpellTolerance_OnUpdate)