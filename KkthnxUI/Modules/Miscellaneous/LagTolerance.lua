local K, C, L = unpack(select(2, ...))
if C.General.CustomLagTolerance ~= true then return end

-- Lua API
local _G = _G
local select = select

-- Wow API
local GetNetStats = _G.GetNetStats
local SetCVar = _G.SetCVar
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool

local newTolerance = select(4, GetNetStats())
local currentTolerance = GetCVar("maxSpellStartRecoveryOffset")
local lastUpdateTime = 0

local function LagTolerance_Update(self, elapsed)
	lastUpdateTime = lastUpdateTime + elapsed

	-- Update once per second.
	if lastUpdateTime < 1.0 then
		return
	else
		lastUpdateTime = 0
	end

	-- Ignore an empty value.
	if newTolerance == 0 or newTolerance == nil then
		return
	end

	-- Prevent update spam.
	if newTolerance == currentTolerance then
		return
	else
		currentTolerance = newTolerance
	end

	-- Adjust the "Lag Tolerance" slider.
	local RecoveryOffset = GetCVarBool("maxSpellStartRecoveryOffset")
	if not RecoveryOffset then
		SetCVar("maxSpellStartRecoveryOffset", newTolerance)
	end
	-- print(currentTolerance.. " > " ..newTolerance)
end

local function LagTolerance_Event(self, event)
	local LagTolerance = GetCVarBool("reducedLagTolerance")

	if event == "PLAYER_ENTERING_WORLD" then
		if not LagTolerance then
			SetCVar("reducedLagTolerance", 1)
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_ENTERING_WORLD")
Loading:SetScript("OnUpdate", LagTolerance_Update)
Loading:SetScript("OnEvent", LagTolerance_Event)