local K, C, L = unpack(select(2, ...))
if C["General"].SpellTolerance ~= true then return end

local AutoLagTolerance = CreateFrame("Frame", "AutoLagTolerance")
local GetNetStats = GetNetStats
local min = math.min
local SetCVar = SetCVar

AutoLagTolerance.cache = GetCVar("SpellQueueWindow")
AutoLagTolerance.timer = 0

local function AutoLagTolerance_OnUpdate(self, elapsed)
	self.timer = self.timer + elapsed

	if self.timer < 1.0 then
		return
	end

	self.timer = 0

	local latency = min(400, select(4, GetNetStats()))

	if latency == 0 then
		return
	end

	if latency == self.cache then
		return
	end

	SetCVar("SpellQueueWindow", latency)

	self.cache = latency
end

AutoLagTolerance:SetScript("OnUpdate", AutoLagTolerance_OnUpdate)