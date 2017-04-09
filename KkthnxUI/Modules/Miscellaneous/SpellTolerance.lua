local K, C, L = unpack(select(2, ...))
if C.General.SpellTolerance ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local GetNetStats = _G.GetNetStats
local SetCVar = _G.SetCVar

local SpellTolerance = CreateFrame("Frame")
local CurrentTolerance = tonumber(GetCVar("SpellQueueWindow"))
local LastUpdate = 0

local function SpellTolerance_OnUpdate(_, Elapsed)
	LastUpdate = LastUpdate + Elapsed

	-- Update once per 10 seconds.
	if (LastUpdate < 10) then
		return
	else
		LastUpdate = 0
	end

	-- Retrieve the world latency.
	local _, _, _, NewTolerance = GetNetStats()

	-- Prevent update spam.
	if CurrentTolerance then
		if (NewTolerance == 0 or NewTolerance == CurrentTolerance) then
			return
		else
			CurrentTolerance = NewTolerance
		end
	end

	-- Adjust our lag as needed.
	K:LockCVar("SpellQueueWindow", NewTolerance)
	-- print(NewTolerance)
end

SpellTolerance:SetScript("OnUpdate", SpellTolerance_OnUpdate)