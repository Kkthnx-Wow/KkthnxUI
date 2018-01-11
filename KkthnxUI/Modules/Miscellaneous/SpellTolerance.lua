local K, C, L = unpack(select(2, ...))
if C["General"].SpellTolerance ~= true then return end

-- Lua API
local _G = _G
local math_min = math.min

-- Wow API
local GetNetStats = _G.GetNetStats
local GetCVar = _G.GetCVar

local SpellTolerance = CreateFrame("Frame", "AutoLagTolerance")
SpellTolerance:RegisterEvent("PLAYER_LOGIN")

SpellTolerance.cache = GetCVar("maxSpellStartRecoveryOffset")
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

	K.LockCVar("maxSpellStartRecoveryOffset", SpellLatency)
	-- print(SpellLatency)

	self.cache = SpellLatency
end

local function SpellTolerance_OnEvent(self, event)
	K.LockCVar("reducedLagTolerance", 1)
end

SpellTolerance:SetScript("OnUpdate", SpellTolerance_OnUpdate)
SpellTolerance:SetScript("OnEvent", SpellTolerance_OnEvent)